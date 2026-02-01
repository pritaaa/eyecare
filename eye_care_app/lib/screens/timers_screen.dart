import 'dart:math';
import 'package:eye_care_app/app_usage/app_usage_provider.dart';
import 'package:eye_care_app/screen_time/screen_time_provider.dart';
import 'package:eye_care_app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:eye_care_app/theme/app_text.dart';
import 'package:provider/provider.dart';

import 'package:flutter/services.dart';

class UsagePermission {
  static const _channel = MethodChannel('usage_stats');

  static Future<void> openSettings() async {
    await _channel.invokeMethod('openUsageSettings');
  }
}

class TimersScreen extends StatefulWidget {
  const TimersScreen({super.key});

  @override
  State<TimersScreen> createState() => _TimersScreenState();
}

class _TimersScreenState extends State<TimersScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ScreenTimeProvider>().loadTodayReport();
      final appUsageProvider = context.read<AppUsageProvider>();
      appUsageProvider.checkPermission().then((_) {
        if (appUsageProvider.hasPermission) {
          appUsageProvider.loadUsageStats();
        }
      });
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.putih,
      appBar: AppBar(
        title: const Text('Sleep & Screen',style: TextStyle(color: Colors.white),),
        backgroundColor: AppColors.birumuda,
        foregroundColor: Colors.black,
        elevation: 20,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Track your sleep & screen habits',
              style: TextStyle(color: AppColors.biru),
            ),
            const SizedBox(height: 20),

            /// Sleep Clock
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Text(
                      'Sleep Schedule',
                      style: TextStyle(fontWeight: FontWeight.bold),
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
                          label: 'Bedtime',
                          time: formatTime(bedTime),
                          onTap: () => pickTime(isBedTime: true),
                        ),
                        _timeInfo(
                          label: 'Wake up',
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

            /// ================= YESTERDAY STATS =================
            const Text(
              'Today',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.biru,
              ),
            ),

            const SizedBox(height: 12),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                StatCard(
                  title: 'Screen Time',
                  value: '5h 10m',
                  icon: Icons.phone_android,
                  color: AppColors.putih,
                  
                  backgroundImage: '../assets/image/timers1.png', // optional
                ),
                StatCard(
                  title: 'Total Sleep',
                  value: '${sleepHours.toStringAsFixed(1)}h',
                  icon: Icons.nightlight_round,
                  color: AppColors.putih,
                  backgroundImage: 'assets/image/timer2.png', // optional
                ),
              ],
            ),

            const SizedBox(height: 32),
            const Text(
              'This Week',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.biru),
            ),
            const SizedBox(height: 12),

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

                // Jika loading selesai tapi data kosong (Izin belum diberikan)
                if (provider.weeklyReport.isEmpty) {
                  return Center(
                    child: Column(
                      children: [
                        const Text(
                          "Data tidak tersedia.\nIzinkan akses penggunaan aplikasi.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white70),
                        ),
                        TextButton(
                          onPressed: () => UsagePermission.openSettings(),
                          child: const Text("Buka Pengaturan"),
                        ),
                      ],
                    ),
                  );
                }

                // Konversi data dari Provider (ms) ke Jam (double)
                final List<double> hours = provider.weeklyReport.map((data) {
                  final ms = data['usageMs'] as int;
                  return ms / (1000 * 60 * 60); // ms ke jam
                }).toList();

                final List<String> labels = provider.weeklyReport
                    .map((data) => data['label'] as String)
                    .toList();

                return WeeklyBarChart(hours: hours, labels: labels);
              },
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
        if (!provider.hasPermission || provider.apps.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'App Usage (Top 5)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.teksputih,
              ),
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
                              color: Colors.white60,
                              size: 28,
                            ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              app.appName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.white60,
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
                        color: AppColors.teksputih,
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

/// ================= CLOCK PAINTER =================

class SleepClockPainter extends CustomPainter {
  final double startAngle;
  final double sweepAngle;

  SleepClockPainter({
    required this.startAngle,
    required this.sweepAngle,
  });

  

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
    ..color = AppColors.oren
    ..style = PaintingStyle.stroke
    ..strokeWidth = 26
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
        border: Border.all(
          color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(hours.length, (i) {
              // Normalisasi tinggi bar agar tidak overflow jika jamnya > 10
              // Kita asumsikan max bar height = 100 pixel untuk 12 jam
              double barHeight = (hours[i] / 12) * 120;
              if (barHeight > 120) barHeight = 120;
              if (barHeight < 5 && hours[i] > 0) barHeight = 5; // Min height

              return Column(
                children: [
                  Container(
                    width: 28,
                    height: barHeight,
                    decoration: const BoxDecoration(
                      color: AppColors.birumuda,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    labels[i],
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              );
            }),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? backgroundImage;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.backgroundImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: color.withOpacity(0.9),
        image: backgroundImage != null
            ? DecorationImage(
                image: AssetImage(backgroundImage!),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  color.withOpacity(0.85),
                  BlendMode.overlay,
                ),
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          /// ICON
          Align(
            alignment: Alignment.topRight,
            child: Icon(
              icon,
              size: 26,
              color: AppColors.teksgelap.withOpacity(0.9),
            ),
          ),

          /// TEXT
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
        ],
      ),
    );
  }
}
