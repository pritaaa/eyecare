import 'package:eye_care_app/theme/app_colors.dart';
import 'package:flutter/material.dart';

class TipsScreen extends StatelessWidget {
  const TipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.biru,

      /// ================= APP BAR =================
      appBar: AppBar(
        backgroundColor: AppColors.ijo,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          color: AppColors.teksgelap,
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Eye Care Tips',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.teksputih,
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
                      colors: [Color(0xFFECFEFF), Color(0xFFEFF6FF)],
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
                          color: Colors.teal,
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
                                color: Colors.teal,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Stay Hydrated',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Drink plenty of water to keep your eyes moist and reduce dryness. Aim for 8 glasses a day.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
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

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _categoryCard(
                    icon: Icons.monitor,
                    title: 'Screen Time',
                    iconBg: const Color(0xFFEFF6FF),
                    iconColor: Colors.blue,
                    tips: const [
                      'Follow the 20-20-20 rule',
                      'Reduce screen brightness',
                      'Position screen 20-26 inches away',
                    ],
                  ),
                  _categoryCard(
                    icon: Icons.apple,
                    title: 'Nutrition',
                    iconBg: const Color(0xFFECFDF5),
                    iconColor: Colors.green,
                    tips: const [
                      'Eat leafy greens and carrots',
                      'Include omega-3 fatty acids',
                      'Take vitamin A supplements',
                    ],
                  ),
                  _categoryCard(
                    icon: Icons.visibility,
                    title: 'Protection',
                    iconBg: const Color(0xFFF5F3FF),
                    iconColor: Colors.purple,
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

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _quickTipCard(
                    icon: Icons.sunny,
                    title: 'Blink More Often',
                    description:
                        'When staring at screens, we blink less. Make a conscious effort to blink regularly.',
                    bgColor: const Color(0xFFFFFBEB),
                    borderColor: const Color(0xFFFDE68A),
                  ),
                  _quickTipCard(
                    icon: Icons.nightlight_round,
                    title: 'Rest Before Bed',
                    description:
                        'Avoid screens 1 hour before sleep to reduce eye strain and improve sleep quality.',
                    bgColor: const Color(0xFFEEF2FF),
                    borderColor: const Color(0xFFC7D2FE),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            /// ================= GENERAL ADVICE =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Icon(Icons.lightbulb, color: AppColors.ijo),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Remember',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Regular eye exams are essential. Visit an eye care professional at least once a year.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
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
          color: AppColors.putih
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
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...tips.map(
              (tip) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const Text('• '),
                    Expanded(
                      child: Text(
                        tip,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
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
          Icon(icon),
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
