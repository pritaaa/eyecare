import 'package:eye_care_app/screens/home_screen.dart';
import 'package:eye_care_app/theme/app_colors.dart';
import 'package:flutter/material.dart';

class TipOfTheDayCard extends StatelessWidget {
  const TipOfTheDayCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [
            AppColors.bluePrimary,
            AppColors.blueDark,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.bluePrimary.withOpacity(0.25),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.water_drop,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TIP OF THE DAY',
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 0.5,
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Tetap Terhidrasi',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Minumlah banyak air untuk menjaga kelembapan mata dan mengurangi kekeringan. Usahakan minum 8 gelas sehari.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class TipsScreen extends StatelessWidget {
  const TipsScreen({super.key});

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
              child: const Icon(
                Icons.arrow_back,
                color: AppColors.bluePrimary,
              ),
            ),
          ),
        ),
        title: const Text(
          'Tips Perawatan Mata',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            // _SearchBar(),
            SizedBox(height: 10),

            TipOfTheDayCard(),
            SizedBox(height: 32),

            Text(
              'Berdasarkan Kategori',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 16),

            CategoryCard(
              icon: Icons.computer,
              iconBg: AppColors.blueLight,
              title: 'Durasi Layar',
              tips: [
                'Ikuti aturan 20-20-20',
                'Kurangi kecerahan layar',
                'Letakkan layar pada jarak 20–26 inci',
              ],
            ),

            CategoryCard(
              icon: Icons.restaurant,
              iconBg: AppColors.blueLight2,
              title: 'Nutrisi',
              tips: [
                'Makan sayuran berdaun hijau dan wortel',
                'Tambahkan asam lemak omega-3',
                'Konsumsi suplemen vitamin A',
              ],
            ),

            CategoryCard(
              icon: Icons.wb_sunny,
              iconBg: AppColors.blueAccent,
              title: 'Proteksi',
              tips: [
                'Wear UV-blocking sunglasses',
                'Use blue light filters at night',
                'Avoid rubbing your eyes',
              ],
            ),

            CategoryCard(
              icon: Icons.remove_red_eye,
              iconBg: AppColors.bluePrimary,
              iconColor: Colors.white,
              title: 'Latihan Mata',
              tips: [
                'Gunakan kacamata hitam yang melindungi dari sinar UV',
                'Gunakan filter cahaya biru pada malam hari',
                'Hindari menggosok mata Anda',
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final List<String> tips;

  const CategoryCard({
    super.key,
    required this.icon,
    required this.iconBg,
    this.iconColor = AppColors.bluePrimary,
    required this.title,
    required this.tips,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: AppColors.bluePrimary.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 14),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          ...tips.map(
            (tip) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 20,
                    width: 20,
                    decoration: BoxDecoration(
                      color: AppColors.blueLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 12,
                      color: AppColors.bluePrimary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      tip,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // TextButton(
          //   onPressed: () {
          //     // navigate to detail
          //   },
          //   // child: const Row(
          //   //   mainAxisSize: MainAxisSize.min,
          //   //   children: [
          //   //     Text('View more tips'),
          //   //     SizedBox(width: 6),
          //   //     Icon(Icons.arrow_forward, size: 16),
          //   //   ],
          //   // ),
          // ),
        ],
      ),
    );
  }
}
