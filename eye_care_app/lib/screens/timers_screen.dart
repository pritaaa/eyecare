import 'dart:math';
import 'dart:async';
import 'dart:typed_data';
import 'package:eye_care_app/app_usage/app_usage_provider.dart';
import 'package:eye_care_app/screen_time/screen_time_model.dart';
import 'package:eye_care_app/screen_time/screen_time_provider.dart';
import 'package:eye_care_app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:eye_care_app/theme/app_text.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

class TimersScreen extends StatefulWidget {
  const TimersScreen({super.key});

  @override
  State<TimersScreen> createState() => _TimersScreenState();
}

class _TimersScreenState extends State<TimersScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadData();
    _timer = Timer.periodic(
      const Duration(minutes: 30),
      (timer) => _loadData(),
    );
  }

  void _loadData() {
    Future.microtask(() {
      // ✅ Load screen time reports (today + weekly)
      context.read<ScreenTimeProvider>().loadAllReports();

      // ✅ Load app usage
      final appUsageProvider = context.read<AppUsageProvider>();
      appUsageProvider.checkPermission().then((_) async {
        if (appUsageProvider.hasPermission) {
          await appUsageProvider.loadSelectedApps();
          appUsageProvider.loadUsageStats();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  TimeOfDay bedTime = const TimeOfDay(hour: 23, minute: 0);
  TimeOfDay wakeTime = const TimeOfDay(hour: 7, minute: 0);

  double get startAngle {
    final minutes = (bedTime.hour % 12) * 60 + bedTime.minute;
    return (minutes / (12 * 60)) * 2 * pi - pi / 2;
  }

  double get sweepAngle {
    final bedMinutes = bedTime.hour * 60 + bedTime.minute;
    final wakeMinutes = wakeTime.hour * 60 + wakeTime.minute;

    int diff = wakeMinutes - bedMinutes;
    if (diff <= 0) diff += 24 * 60;

    return (diff / (12 * 60)) * 2 * pi;
  }

  double get sleepHours {
    final bedMinutes = bedTime.hour * 60 + bedTime.minute;
    final wakeMinutes = wakeTime.hour * 60 + wakeTime.minute;

    int diff = wakeMinutes - bedMinutes;
    if (diff <= 0) diff += 24 * 60;

    return diff / 60;
  }

  String formatTime(TimeOfDay t) {
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  Future<void> pickTime({required bool isBedTime}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isBedTime ? bedTime : wakeTime,
    );

    if (picked != null) {
      setState(() {
        isBedTime ? bedTime = picked : wakeTime = picked;
      });
    }
  }

  Future<void> showDebugDialog(BuildContext context) async {
    const platform = MethodChannel('eye_care/usage_stats');

    try {
      final List<dynamic> result = await platform.invokeMethod(
        'debugUsageStats',
      );

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Debug Usage Stats'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: result.length,
              itemBuilder: (context, index) {
                final app = result[index];
                return ListTile(
                  title: Text(app['appName']),
                  subtitle: Text(
                    '${app['minutes']} min\n'
                    'Tracked: ${app['isTracked']}\n'
                    'Excluded: ${app['isExcluded']}',
                  ),
                  dense: true,
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.putih,
      appBar: AppBar(
        elevation: 2,
        backgroundColor: Colors.white,
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.blueLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_back, color: AppColors.bluePrimary),
            ),
          ),
        ),
        title: const Text(
          'Durasi layar',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pantau kebiasaan tidur dan penggunaan layar Anda',
              style: TextStyle(color: AppColors.biru),
            ),
            const SizedBox(height: 16),

            /// Sleep Clock
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Text(
                      'Jadwal Tidur',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 200,
                      height: 200,
                      child: CustomPaint(
                        painter: SleepClockPainter(
                          startAngle: startAngle,
                          sweepAngle: sweepAngle,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _timeInfo(
                          label: 'Waktu Tidur',
                          time: formatTime(bedTime),
                          onTap: () => pickTime(isBedTime: true),
                        ),
                        _timeInfo(
                          label: 'Bangun',
                          time: formatTime(wakeTime),
                          onTap: () => pickTime(isBedTime: false),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// ================= STATS HARI INI =================
            const Text(
              'Hari Ini',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.biru,
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                const Expanded(child: ScreenTimeStatCard()),
                const SizedBox(width: 12),
                Expanded(child: SleepStatCard(sleepHours: sleepHours)),
              ],
            ),

            Visibility(
              visible: true,
              child: Column(
                children: [
                  const SizedBox(height: 22),
                  // const Text(
                  //   'This Week',
                  //   style: TextStyle(
                  //     fontSize: 18,
                  //     fontWeight: FontWeight.bold,
                  //     color: AppColors.biru,
                  //   ),
                  // ),
                  // const SizedBox(height: 12),
                  // const SizedBox(height: 32),
                  const Text(
                    'Minggu Ini',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.biru,
                    ),
                  ),
                  const SizedBox(height: 18),

                  Consumer<ScreenTimeProvider>(
                    builder: (context, provider, _) {
                      if (provider.isLoading && provider.weeklyReport.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      // Konversi data dari Provider (ms) ke Jam (double)
                      final List<double> hours = provider.weeklyReport.map((
                        data,
                      ) {
                        final ms = data['usageMs'] as int;
                        return ms / (1000 * 60 * 60); // ms ke jam
                      }).toList();

                      final List<String> labels = provider.weeklyReport
                          .map((data) => data['label'] as String)
                          .toList();

                      return WeeklyBarChart(hours: hours, labels: labels);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            appUsageList(),
          ],
        ),
      ),
    );
  }

  Widget appUsageList() {
    return Consumer<AppUsageProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!provider.hasPermission) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  const Text(
                    "Izin akses penggunaan diperlukan\nuntuk menampilkan daftar aplikasi.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => provider.requestPermission(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blueDark,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Izinkan Akses"),
                  ),
                ],
              ),
            ),
          );
        }

        if (provider.apps.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                "Belum ada data penggunaan hari ini.",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Penggunaan Aplikasi Hari Ini',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.biru,
                  ),
                ),
                TextButton(
                  onPressed: () => _showSelectionDialog(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text("Edit"),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ListView.separated(
              itemCount: provider.apps.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (_, __) => Divider(
                height: 16,
                thickness: 0.8,
                color: Colors.grey.shade300,
              ),
              itemBuilder: (context, index) {
                final app = provider.apps[index];
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          if (app.appIcon != null)
                            Image.memory(app.appIcon!, width: 28, height: 28)
                          else
                            const Icon(
                              Icons.apps,
                              color: AppColors.biru,
                              size: 28,
                            ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              app.appName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      _formatDuration(app.minutes),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.biru,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showSelectionDialog(BuildContext context) async {
    final provider = context.read<AppUsageProvider>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final installedApps = await provider.getInstalledApps();
    final selected = List<String>.from(provider.selectedApps);

    if (context.mounted) Navigator.pop(context);

    if (context.mounted) {
      showDialog(
        context: context,
        builder: (ctx) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('Pilih Aplikasi (Max 5)'),
                content: SizedBox(
                  width: double.maxFinite,
                  height: 400,
                  child: ListView.builder(
                    itemCount: installedApps.length,
                    itemBuilder: (context, index) {
                      final app = installedApps[index];
                      final pkg = app['packageName'] as String;
                      final name = app['appName'] as String;
                      final icon = app['appIcon'] as Uint8List?;
                      final isSelected = selected.contains(pkg);

                      return CheckboxListTile(
                        secondary: icon != null
                            ? Image.memory(icon, width: 32, height: 32)
                            : const Icon(
                                Icons.android,
                                size: 32,
                                color: Colors.grey,
                              ),
                        title: Text(name),
                        value: isSelected,
                        onChanged: (val) {
                          setState(() {
                            if (val == true) {
                              if (selected.length < 5) {
                                selected.add(pkg);
                              }
                            } else {
                              selected.remove(pkg);
                            }
                          });
                        },
                      );
                    },
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Batal'),
                  ),
                  TextButton(
                    onPressed: () {
                      provider.saveSelectedApps(selected);
                      Navigator.pop(context);
                    },
                    child: const Text('Simpan'),
                  ),
                ],
              );
            },
          );
        },
      );
    }
  }

  Widget _timeInfo({
    required String label,
    required String time,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 6),
          Text(
            time,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int totalMinutes) {
    final int hours = totalMinutes ~/ 60;
    final int minutes = totalMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}

/// ================= SCREEN TIME STAT CARD =================
/// Widget ini bisa dipanggil dari halaman lain (ProfileScreen, dll)
class ScreenTimeStatCard extends StatelessWidget {
  const ScreenTimeStatCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ScreenTimeProvider>(
      builder: (context, provider, _) {
        final screenTime = provider.report;

        // ✅ Tampilkan loading atau data
        if (provider.isLoading) {
          return const StatCard(
            title: 'Durasi Layar',
            value: 'Loading...',
            icon: Icons.phone_android,
            color: Colors.white,
          );
        }

        if (screenTime == null) {
          return const StatCard(
            title: 'Durasi Layar',
            value: '0h 0m',
            icon: Icons.phone_android,
            color: Colors.white,
          );
        }

        // ✅ Format display
        final hours = screenTime.hours;
        final minutes = screenTime.minutes;

        // DEBUG
        debugPrint('🔍 Screen Time Card - MS: ${screenTime.totalMs}');
        debugPrint('🔍 Screen Time Card - Hours: $hours, Minutes: $minutes');

        return StatCard(
          title: 'Durasi Layar',
          value: '${hours}h ${minutes}m',
          icon: Icons.phone_android,
          color: Colors.white,
        );
      },
    );
  }
}

/// ================= SLEEP STAT CARD =================
/// Widget ini bisa dipanggil dari halaman lain dengan parameter sleepHours
class SleepStatCard extends StatelessWidget {
  final double sleepHours;

  const SleepStatCard({super.key, required this.sleepHours});

  @override
  Widget build(BuildContext context) {
    return StatCard(
      title: 'Lama Tidur',
      value: '${sleepHours.toStringAsFixed(1)}h',
      icon: Icons.nightlight_round,
      color: Colors.white,
    );
  }
}

/// ================= CLOCK PAINTER =================
class SleepClockPainter extends CustomPainter {
  final double startAngle;
  final double sweepAngle;

  SleepClockPainter({required this.startAngle, required this.sweepAngle});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final basePaint = Paint()
      ..color = Colors.grey.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14;

    canvas.drawCircle(center, radius, basePaint);

    final sleepPaint = Paint()
      ..color = AppColors.birugelap
      ..style = PaintingStyle.stroke
      ..strokeWidth = 28
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      sleepPaint,
    );

    for (int i = 1; i <= 12; i++) {
      final angle = (i * 30 - 90) * pi / 180;
      final offset = Offset(
        center.dx + (radius - 28) * cos(angle),
        center.dy + (radius - 28) * sin(angle),
      );

      final tp = TextPainter(
        text: TextSpan(
          text: '$i',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black45,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      tp.paint(canvas, offset - Offset(tp.width / 2, tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(_) => true;
}

/// ================= WEEKLY BAR CHART =================
class WeeklyBarChart extends StatelessWidget {
  final List<double> hours;
  final List<String> labels;

  const WeeklyBarChart({super.key, required this.hours, required this.labels})
    : assert(hours.length == labels.length);

  double get average {
    if (hours.isEmpty) return 0;
    return hours.fold(0.0, (a, b) => a + b) / hours.length;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 150,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(hours.length, (i) {
                double barHeight = (hours[i] / 24) * 120;
                if (barHeight > 120) barHeight = 120;
                if (barHeight < 5 && hours[i] > 0) barHeight = 5;

                final isToday = i == hours.length - 1;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 28,
                      height: barHeight,
                      decoration: BoxDecoration(
                        color: isToday
                            ? AppColors.birugelap
                            : AppColors.birumuda,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      labels[i],
                      style: TextStyle(
                        fontSize: 12,
                        color: isToday ? AppColors.birugelap : Colors.black54,
                        fontWeight: isToday
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

/// ================= STAT CARD =================
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: color,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.birugelap,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.teksgelap.withOpacity(0.85),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.topRight,
            child: Icon(
              icon,
              size: 26,
              color: AppColors.teksgelap.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }
}
