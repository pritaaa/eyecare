import 'package:eye_care_app/screens/clinic_screen.dart';
import 'package:flutter/material.dart';
import 'package:eye_care_app/screens/test_screen.dart';
import 'package:eye_care_app/screens/timers_screen.dart';
import 'tips_screen.dart';
import 'package:eye_care_app/theme/app_colors.dart';
import 'package:eye_care_app/theme/app_text.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.biru,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              /// ================= HEADER =================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.biru, AppColors.biru],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back 👋',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Take care of your eyes today',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// ================= TIPS CAROUSEL =================
              const TipsCarousel(),

              const SizedBox(height: 20),

              /// ================= STATS =================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: const [
                    _StatCard(
                      value: '4.2h',
                      label: 'Screen time',
                      color: AppColors.putih,
                    ),
                    SizedBox(width: 12),
                    _StatCard(
                      value: '12',
                      label: 'Breaks',
                      color: AppColors.putih,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              /// ================= QUICK ACCESS CARD =================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.biruijo.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Quick Access',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.biruijo,
                        ),
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: _QuickAccessItem(
                              icon: Icons.remove_red_eye,
                              title: 'Vision Test',
                              subtitle: 'Check eyes',
                              color: AppColors.ijo,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const TestScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _QuickAccessItem(
                              icon: Icons.schedule,
                              title: 'Screen Timer',
                              subtitle: 'Track time',
                              color: AppColors.ijo,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const TimersScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: _QuickAccessItem(
                              icon: Icons.lightbulb,
                              title: 'Eye Tips',
                              subtitle: 'Daily tips',
                              color: AppColors.ijo,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const TipsScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _QuickAccessItem(
                              icon: Icons.location_on,
                              title: 'Clinics',
                              subtitle: 'Nearby',
                              color: AppColors.ijo,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ClinicFinderScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class TipsCarousel extends StatefulWidget {
  const TipsCarousel({super.key});

  @override
  State<TipsCarousel> createState() => _TipsCarouselState();
}

class _TipsCarouselState extends State<TipsCarousel> {
  final PageController _controller = PageController();
  int currentIndex = 0;

  final tips = [
    {
      'title': '20-20-20 Rule',
      'desc': 'Look 20 feet away every 20 minutes',
      'image': 'assets/image/banner1.png',
    },
    {
      'title': 'Blink More',
      'desc': 'Reduce dry eyes',
      'image': 'assets/image/banner2.png',
    },
    {
      'title': 'Adjust Brightness',
      'desc': 'Match your environment',
      'image': 'assets/image/banner3.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _controller,
            itemCount: tips.length,
            onPageChanged: (i) => setState(() => currentIndex = i),
            itemBuilder: (context, index) {
              final item = tips[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.asset(item['image']!, fit: BoxFit.cover),
                      ),
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.white.withOpacity(0.5),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['title']!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item['desc']!,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 8),

        /// DOT INDICATOR
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            tips.length,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: currentIndex == index ? 10 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: currentIndex == index
                    ? AppColors.biruijo
                    : AppColors.teksabu.withOpacity(0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _QuickAccessItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickAccessItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.2),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.30),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.teal),
            ),
          ],
        ),
      ),
    );
  }
}
