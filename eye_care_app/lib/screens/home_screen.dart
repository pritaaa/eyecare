import 'package:eye_care_app/app_usage/app_usage_view.dart';
import 'package:eye_care_app/auth/auth_provider.dart';
import 'package:eye_care_app/screen_time/screen_time_view.dart';
import 'package:eye_care_app/screens/clinic_screen.dart';
import 'package:flutter/material.dart';
import 'package:eye_care_app/screens/test_screen.dart';
import 'package:eye_care_app/screens/timers_screen.dart';
import 'tips_screen.dart';
import 'package:eye_care_app/theme/app_colors.dart';
import 'package:eye_care_app/theme/app_text.dart';
import 'package:provider/provider.dart';

// final textScale = MediaQuery.of(context).textScaleFactor;
// double sp(double size) => size * textScale.clamp(1.0, 1.2);

final tips = [
  {
    'title': '20-20-20 Rule',
    'desc': 'Look 20 feet away every 20 minutes',
    'color': AppColors.blueLight2,
  },
  {
    'title': 'Blink More',
    'desc': 'Reduce dry eyes and eye strain',
    'color': AppColors.blueAccent,
  },
  {
    'title': 'Adjust Brightness',
    'desc': 'Match screen with environment',
    'color': AppColors.blueLight,
  },
];

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final textScale = MediaQuery.of(context).textScaleFactor;
    final username = context.select((AuthProvider p) => p.username);

    double sp(double size) => size * textScale.clamp(1.0, 1.2);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 140),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ================= HEADER =================
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selamat Datang Kembali $username',
                    style: TextStyle(
                      fontSize: sp(width * 0.075), // adaptif
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Mari jaga kesehatan mata hari ini',
                    style: TextStyle(
                      fontSize: sp(14),
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            /// ================= TIPS SLIDER =================
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: EyeCareTipsSection(),
            ),

            const SizedBox(height: 28),

            /// ================= PRIMARY CTA =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TestScreen()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.blueLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.blueAccent),
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 48,
                        width: 48,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.bluePrimary, AppColors.blueDark],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.remove_red_eye,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),

                      /// BIAR AMAN DI LAYAR KECIL
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Tes Kesehatan Mata',
                              style: TextStyle(
                                fontSize: sp(16),
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tes singkat • Kurang dari 3 menit',
                              style: TextStyle(
                                fontSize: sp(13),
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Icon(
                        Icons.arrow_forward,
                        color: AppColors.bluePrimary,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),

            /// ================= QUICK ACCESS =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Akses Cepat',
                style: TextStyle(
                  fontSize: sp(18),
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: width < 360 ? 1 : 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.15,
                ),
                itemCount: 4,
                itemBuilder: (context, index) {
                  final items = [
                    _QuickCard(
                      icon: Icons.remove_red_eye,
                      title: 'Tes Mata',
                      subtitle: 'Cek penglihatan',
                      bg: AppColors.blueLight,
                      iconColor: AppColors.bluePrimary,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const TestScreen()),
                      ),
                    ),
                    _QuickCard(
                      icon: Icons.schedule,
                      title: 'Timer Layar',
                      subtitle: 'Pantau durasi',
                      bg: AppColors.blueLight2,
                      iconColor: AppColors.blueDark,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const TimersScreen()),
                      ),
                    ),
                    _QuickCard(
                      icon: Icons.lightbulb,
                      title: 'Tips Mata',
                      subtitle: 'Perawatan terbaik',
                      bg: AppColors.blueAccent,
                      iconColor: AppColors.bluePrimary,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const TipsScreen()),
                      ),
                    ),
                    _QuickCard(
                      icon: Icons.local_hospital,
                      title: 'Klinik Terdekat',
                      subtitle: 'Perawatan profesional',
                      bg: AppColors.bluePrimary,
                      iconColor: Colors.white,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ClinicFinderScreen(),
                        ),
                      ),
                    ),
                  ];

                  return items[index];
                },
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _QuickCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color bg;
  final Color iconColor;
  final VoidCallback? onTap;

  const _QuickCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.bg,
    required this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.of(context).textScaleFactor;
    double sp(double size) => size * textScale.clamp(1.0, 1.2);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: AppColors.bluePrimary.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            /// ICON
            Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),

            const SizedBox(height: 12),

            /// TITLE
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: sp(15),
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 4),

            /// SUBTITLE
            Expanded(
              child: Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: sp(12), color: AppColors.textLight),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EyeCareTipsSection extends StatefulWidget {
  const EyeCareTipsSection({super.key});

  @override
  State<EyeCareTipsSection> createState() => _EyeCareTipsSectionState();
}

class _EyeCareTipsSectionState extends State<EyeCareTipsSection> {
  final PageController _controller = PageController();
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Column(
      children: [
        /// CARD SLIDER
        SizedBox(
          height: height * 0.28, // adaptif layar
          child: PageView.builder(
            controller: _controller,
            itemCount: tips.length,
            onPageChanged: (index) {
              setState(() => currentIndex = index);
            },
            itemBuilder: (context, index) {
              return _TipItem(tip: tips[index]);
            },
          ),
        ),

        const SizedBox(height: 12),

        /// DOT INDICATOR
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            tips.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: currentIndex == index ? 18 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: currentIndex == index
                    ? AppColors.birugelap
                    : AppColors.bluePrimary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TipItem extends StatelessWidget {
  final Map<String, dynamic> tip;

  const _TipItem({required this.tip});

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.of(context).textScaleFactor;
    double sp(double size) => size * textScale.clamp(1.0, 1.2);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: tip['color'],
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.bluePrimary.withOpacity(0.15),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// BADGE
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '✨ Eye Care Tip',
                style: TextStyle(
                  fontSize: sp(12),
                  fontWeight: FontWeight.w500,
                  color: AppColors.bluePrimary,
                ),
              ),
            ),

            const SizedBox(height: 12),

            /// TITLE
            Text(
              tip['title'],
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: sp(22),
                fontWeight: FontWeight.bold,
                color: AppColors.bluePrimary,
                height: 1.2,
              ),
            ),

            const SizedBox(height: 8),

            /// DESC
            Text(
              tip['desc'],
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: sp(14), color: AppColors.blueDark),
            ),

            const Spacer(),

            /// TIMER
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.bluePrimary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.timer, size: 16, color: Colors.white),
                  const SizedBox(width: 6),
                  Text(
                    'Next break in 18:45',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: sp(13),
                    ),
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
