import 'dart:math';
import 'package:eye_care_app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:eye_care_app/theme/app_colors.dart';
import 'package:eye_care_app/theme/app_text.dart';

class TimersScreen extends StatefulWidget {
  const TimersScreen({super.key});

  @override
  State<TimersScreen> createState() => _TimersScreenState();
}

class _TimersScreenState extends State<TimersScreen> {
  TimeOfDay bedTime = const TimeOfDay(hour: 23, minute: 0);
  TimeOfDay wakeTime = const TimeOfDay(hour: 7, minute: 0);

  final List<double> weeklyHours = [4.5, 3.8, 5.2, 4.1, 3.5, 4.2, 3.9];
  final List<String> weekLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  final List<Map<String, dynamic>> appUsage = [
  {'name': 'WhatsApp', 'hours': 2.0},
  {'name': 'Instagram', 'hours': 1.5},
  {'name': 'YouTube', 'hours': 1.2},
  {'name': 'TikTok', 'hours': 0.8},
];



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
      backgroundColor: AppColors.biru,
      appBar: AppBar(
        title: const Text('Sleep & Screen'),
        backgroundColor: AppColors.ijo,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Track your sleep & screen habits',
              style: TextStyle(color: AppColors.teksabu),
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
              'Yesterday',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.teksputih,
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
                  color: Colors.blue,
                  backgroundImage: 'assets/bg_wave.png', // optional
                ),
                StatCard(
                  title: 'Total Sleep',
                  value: '${sleepHours.toStringAsFixed(1)}h',
                  icon: Icons.nightlight_round,
                  color: Colors.orange,
                  backgroundImage: 'assets/bg_gradient.png', // optional
                ),
              ],
            ),

            const SizedBox(height: 32),
            const Text(
              'This Week',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.teksputih),
            ),
            const SizedBox(height: 12),

            WeeklyBarChart(
              hours: weeklyHours,
              labels: weekLabels,
            ),

            const SizedBox(height: 16),
            appUsageList(),




          ],
        ),
      ),
    );
  }

  Widget appUsageList() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'App Usage',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.teksputih,
        ),
      ),

      const SizedBox(height: 8),

      ListView.separated(
        itemCount: appUsage.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        separatorBuilder: (_, __) => Divider(
          height: 16,
          thickness: 0.8,
          color: Colors.grey.shade300,
        ),
        itemBuilder: (context, index) {
          final app = appUsage[index];

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              /// APP NAME (KIRI)
              Text(
                app['name'],
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),

              /// HOURS (KANAN)
              Text(
                '${app['hours'].toString().replaceAll('.', ',')} h',
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
          Text(time, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
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
    ..color = AppColors.biruijo
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
            fontSize: 14, // sebelumnya 12
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

  const WeeklyBarChart({
    super.key,
    required this.hours,
    required this.labels,
  }) : assert(hours.length == labels.length);

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(hours.length, (i) {
              return Column(
                children: [
                  Container(
                    width: 28,
                    height: hours[i] * 20,
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(labels[i], style: const TextStyle(fontSize: 12, color: Colors.black54)),
                ],
              );
            }),
          ),
          const SizedBox(height: 16),
          const Divider(),
          Text(
            '${average.toStringAsFixed(1)} hours',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
          ),
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
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
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
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          /// ICON POJOK
          Positioned(
            top: 16,
            right: 16,
            child: Icon(
              icon,
              color: Colors.white.withOpacity(0.9),
              size: 28,
            ),
          ),

          /// TEXT CONTENT
          Positioned(
            left: 16,
            bottom: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
