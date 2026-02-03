import 'package:flutter/material.dart';
import 'package:eye_care_app/theme/app_colors.dart';
import 'package:eye_care_app/theme/app_text.dart';
import 'test_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // WAJIB ADA

class TestResultScreen extends StatelessWidget {
  final double scale;

  const TestResultScreen({super.key, required this.scale});

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
        title: Text(
          'Hasil Tes',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            /// ================= CONTENT =================
            Expanded(
              child: SingleChildScrollView(
                child: Card(
                  color: AppColors.putih,
                  // elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// TITLE
                        Text(
                          'Kategori Hasil Tes Snellen',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),

                        const SizedBox(height: 16),

                        _snellenRow(
                          category: 'Normal',
                          result: '20/20',
                          description: 'Penglihatan tajam dan normal',
                          color: Colors.green,
                        ),

                        _snellenRow(
                          category: 'Penurunan Ringan',
                          result: '20/30 – 20/40',
                          description: 'Penglihatan sedikit menurun',
                          color: AppColors.oren,
                        ),

                        _snellenRow(
                          category: 'Penurunan Sedang',
                          result: '20/50 – 20/60',
                          description:
                              'Penglihatan mulai terganggu, disarankan pemeriksaan lanjutan',
                          color: Colors.orangeAccent,
                        ),

                        _snellenRow(
                          category: 'Penurunan Berat',
                          result: '≥ 20/70',
                          description:
                              'Penglihatan buruk, disarankan segera pergi ke klinik terdekat',
                          color: Colors.red,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            /// RETAKE BUTTON
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
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'Ulangi Tes',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 8),

            /// BACK HOME
            OutlinedButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text(
                'Kembali ke Beranda',
                style: TextStyle(color: AppColors.biru),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

Widget _snellenRow({
  required String category,
  required String result,
  required String description,
  required Color color,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 14),
    padding: const EdgeInsets.all(14),
    width: double.infinity,
    decoration: BoxDecoration(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: color.withOpacity(0.4)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          category,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          result,
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Text(
          description,
          style: TextStyle(
            fontSize: 13.sp,
            height: 1.4,
            color: AppColors.teksgelap,
          ),
        ),
      ],
    ),
  );
}
