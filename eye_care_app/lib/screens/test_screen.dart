import 'package:flutter/material.dart';
import 'package:eye_care_app/theme/app_colors.dart';
import 'package:eye_care_app/theme/app_text.dart';
import 'test_result.dart';
class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  double scale = 1.0;

  @override
  Widget build(BuildContext context) {
    /// ================= MEDIA QUERY =================
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final textScale = MediaQuery.of(context).textScaleFactor;

    double sp(double size) => size * textScale.clamp(1.0, 1.2);

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
          'Tes Mata',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        /// ================= INSTRUKSI =================
        Text(
          'Atur ukuran tinggi huruf baris 20/20 hingga sekitar ±4 mm menggunakan penggaris, '
          'kemudian lakukan pemeriksaan pada jarak 3 meter (±10 feet).',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: sp(13),
            color: AppColors.biru,
            height: 1.4,
          ),
        ),

        const SizedBox(height: 12),

        /// ================= IMAGE AREA =================
        Expanded(
          flex: 7,
          child: ClipRect(
            child: InteractiveViewer(
              minScale: 0.6,
              maxScale: 10,
              panEnabled: false,
              onInteractionUpdate: (details) {
                setState(() {
                  scale = details.scale.clamp(0.6, 1.8);
                });
              },
              child: SizedBox.expand(
                child: Image.asset(
                  'assets/image/snellen.jpeg',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        /// ================= BUTTON =================
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.birugelap,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TestResultScreen(scale: scale),
                ),
              );
            },
            child: Text(
              'Selesaikan Tes',
              style: TextStyle(
                fontSize: sp(15),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),
      ],
    ),
  ),
),

    );
  }
}
