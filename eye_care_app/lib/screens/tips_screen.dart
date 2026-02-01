import 'package:eye_care_app/screens/home_screen.dart';
import 'package:eye_care_app/theme/app_colors.dart';
import 'package:flutter/material.dart';

class TipsScreen extends StatelessWidget {
  const TipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.putih,

      /// ================= APP BAR =================
      appBar: AppBar(
        backgroundColor: AppColors.birumuda,
        foregroundColor: AppColors.birugelap,
        elevation: 20,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          color: AppColors.teksgelap,
          onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(),
        ),
      ),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Eye Care Tips',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.birugelap,
              ),
            ),
            
            
          ],
        ),
      ),

      /// ================= BODY =================
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 16),

            /// ================= DAILY TIP =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.birumuda, Colors.lightBlue],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.birugelap,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.water_drop,
                            color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TIP OF THE DAY',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.putih,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Stay Hydrated',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color:Colors.white
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Drink plenty of water to keep your eyes moist and reduce dryness. Aim for 8 glasses a day.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            /// ================= CATEGORIES =================
            _sectionTitle('By Category'),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _categoryCard(
                    icon: Icons.monitor,
                    title: 'Screen Time',
                    iconBg: AppColors.birugelap,
                    iconColor: Colors.white,
                    tips: const [
                      'Follow the 20-20-20 rule',
                      'Reduce screen brightness',
                      'Position screen 20-26 inches away',
                    ],
                  ),
                  _categoryCard(
                    icon: Icons.apple,
                    title: 'Nutrition',
                    iconBg: AppColors.birugelap,
                    iconColor: Colors.white,
                    tips: const [
                      'Eat leafy greens and carrots',
                      'Include omega-3 fatty acids',
                      'Take vitamin A supplements',
                    ],
                  ),
                  _categoryCard(
                    icon: Icons.visibility,
                    title: 'Protection',
                    iconBg: AppColors.birugelap,
                    iconColor: Colors.white,
                    tips: const [
                      'Wear UV-blocking sunglasses',
                      'Use blue light filters at night',
                      'Avoid rubbing your eyes',
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            /// ================= QUICK TIPS =================
            _sectionTitle('Quick Tips'),
            const SizedBox(height: 20),


            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _quickTipCard(
                    icon: Icons.sunny,
                    title: 'Blink More Often',
                    description:
                        'When staring at screens, we blink less. Make a conscious effort to blink regularly.',
                    bgColor: const Color(0xFFBBE0EF),
                    borderColor: AppColors.birumuda,
                  ),
                  _quickTipCard(
                    icon: Icons.nightlight_round,
                    title: 'Rest Before Bed',
                    description:
                        'Avoid screens 1 hour before sleep to reduce eye strain and improve sleep quality.',
                    bgColor: const Color(0xFFACBAC4),
                    borderColor: AppColors.biru,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// ================= GENERAL ADVICE =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                color:AppColors.birumuda,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Icon(Icons.lightbulb,
                      color: AppColors.birugelap),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Remember',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color:AppColors.birugelap,
                                ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Regular eye exams are essential. Visit an eye care professional at least once a year.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ================= COMPONENTS =================

  static Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.biru
        ),
      ),
    );
  }

  static Widget _categoryCard({
    required IconData icon,
    required String title,
    required Color iconBg,
    required Color iconColor,
    required List<String> tips,
  }) {
    return Card(
      color:Colors.white70,
      shadowColor: AppColors.birugelap,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.biru),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...tips.map(
              (tip) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const Text('• ',
                    style:TextStyle(
                      color:Colors.black54
                    )),
                    Expanded(
                      child: Text(
                        tip,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.birumuda,
                        ),
                      ),
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

  static Widget _quickTipCard({
    required IconData icon,
    required String title,
    required String description,
    required Color bgColor,
    required Color borderColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Icon(icon,
          color:AppColors.biru),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
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
