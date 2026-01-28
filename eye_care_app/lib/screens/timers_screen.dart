import 'dart:async';
import 'package:flutter/material.dart';

class TimersScreen extends StatefulWidget {
  const TimersScreen({super.key});

  @override
  State<TimersScreen> createState() => _TimersScreenState();
}

class _TimersScreenState extends State<TimersScreen> {
  bool timerActive = false;
  int seconds = 1200; // 20 minutes
  bool notificationsEnabled = true;
  Timer? timer;

  final List<Map<String, String>> todayStats = [
    {'label': 'Screen Time', 'value': '4h 12m', 'change': '-18%'},
    {'label': 'Breaks Taken', 'value': '12', 'change': '+3'},
    {'label': 'Avg Break Time', 'value': '22 min', 'change': '+2m'},
  ];

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void startPauseTimer() {
    if (timerActive) {
      timer?.cancel();
    } else {
      timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (seconds > 0) {
          setState(() => seconds--);
        } else {
          t.cancel();
          setState(() => timerActive = false);
        }
      });
    }
    setState(() => timerActive = !timerActive);
  }

  void resetTimer() {
    timer?.cancel();
    setState(() {
      seconds = 1200;
      timerActive = false;
    });
  }

  String formatTime(int secs) {
    final m = (secs ~/ 60).toString().padLeft(2, '0');
    final s = (secs % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Screen Timer'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// ================= HEADER =================
            const Text(
              'Protect your eyes with regular breaks',
              style: TextStyle(color: Colors.black54),
            ),

            const SizedBox(height: 20),

            /// ================= TIMER CARD =================
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFEFF6FF), Color(0xFFE6FFFA)],
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(24)),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    _iconCircle(Icons.schedule, Colors.blue, size: 32),
                    const SizedBox(height: 12),
                    const Text(
                      '20-20-20 Rule Timer',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Look at something 20 feet away for 20 seconds',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 20),

                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          Text(
                            formatTime(seconds),
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            seconds == 0
                                ? 'Time for a break!'
                                : 'Until next break',
                            style: const TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: const StadiumBorder(),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                          ),
                          onPressed: startPauseTimer,
                          icon: Icon(
                            timerActive ? Icons.pause : Icons.play_arrow,
                          ),
                          label: Text(timerActive ? 'Pause' : 'Start'),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            shape: const StadiumBorder(),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                          ),
                          onPressed: resetTimer,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reset'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            /// ================= SETTINGS =================
            const Text(
              'Settings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: ListTile(
                leading: _iconCircle(Icons.notifications, Colors.purple),
                title: const Text('Break Reminders'),
                subtitle: const Text(
                  'Get notified when it\'s time to rest',
                  style: TextStyle(fontSize: 12),
                ),
                trailing: Switch(
                  value: notificationsEnabled,
                  onChanged: (v) {
                    setState(() => notificationsEnabled = v);
                  },
                ),
              ),
            ),

            const SizedBox(height: 24),

            /// ================= TODAY STATS =================
            const Text(
              'Today\'s Activity',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            ...todayStats.map((stat) => Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              stat['label']!,
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.black54),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              stat['value']!,
                              style: const TextStyle(fontSize: 22),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.trending_down,
                                color: Colors.green, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              stat['change']!,
                              style: const TextStyle(color: Colors.green),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )),

            const SizedBox(height: 24),

            /// ================= WEEKLY PROGRESS =================
            const Text(
              'This Week',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [4.5, 3.8, 5.2, 4.1, 3.5, 4.2, 3.9]
                          .asMap()
                          .entries
                          .map(
                            (e) => Column(
                              children: [
                                Container(
                                  width: 24,
                                  height: e.value * 20,
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  ['M', 'T', 'W', 'T', 'F', 'S', 'S'][e.key],
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          )
                          .toList(),
                    ),
                    const Divider(height: 32),
                    const Text(
                      'Average daily screen time',
                      style: TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '4.2 hours',
                      style:
                          TextStyle(fontSize: 20, color: Colors.blue),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconCircle(IconData icon, Color color, {double size = 24}) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: size),
    );
  }
}
