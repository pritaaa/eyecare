import 'package:flutter/material.dart';
import 'package:eye_care_app/theme/app_colors.dart';
import 'package:eye_care_app/theme/app_text.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  double scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.biru,
      appBar: AppBar(
        title: const Text('Vision Test'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 20,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// SNELLEN IMAGE
            Expanded(
              child: Center(
                child: Transform.scale(
                  scale: scale,
                  child: Image.asset(
                    'assets/image/snellen.jpeg',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            /// SLIDER
            const Text(
              'Adjust until letters are just readable',
              style: TextStyle(color: Colors.white),
            ),

            Slider(
              min: 0.6,
              max: 1.8,
              value: scale,
              onChanged: (value) {
                setState(() => scale = value);
              },
            ),

            const SizedBox(height: 12),

            /// FINISH BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TestResultScreen(scale: scale),
                    ),
                  );
                },
                child: const Text('Finish Test',
                style: TextStyle(
                        color: AppColors.oren,
                        
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TestResultScreen extends StatelessWidget {
  final double scale;

  const TestResultScreen({
    super.key,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    final result = _getResult(scale);

    return Scaffold(
      backgroundColor: AppColors.biru,
      appBar: AppBar(
        title: const Text('Test Result'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 20,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            /// RESULT CARD (PUTIH)
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    /// ICON
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: result.color.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        result.icon,
                        size: 56,
                        color: result.color,
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// TITLE
                    Text(
                      result.title,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: result.color,
                      ),
                    ),

                    const SizedBox(height: 12),

                    /// DESCRIPTION
                    Text(
                      result.description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 24),

                    const Divider(),

                    /// INFO
                    _infoRow('Test Type', 'Visual Acuity'),
                    _infoRow(
                      'Scale Value',
                      scale.toStringAsFixed(2),
                    ),
                    _infoRow('Test Date', 'Today'),
                  ],
                ),
              ),
            ),

            const Spacer(),

            /// RETAKE
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'Retake Test',
                  style: TextStyle(
                    color: AppColors.oren,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            /// BACK HOME
            OutlinedButton(
              onPressed: () {
                Navigator.popUntil(
                  context,
                  (route) => route.isFirst,
                );
              },
              child: const Text(
                'Back to Home',
                style: TextStyle(color: AppColors.birumuda),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// RESULT LOGIC
  _ResultData _getResult(double scale) {
    if (scale <= 0.9) {
      return _ResultData(
        title: 'Excellent Vision',
        description: 'Your visual acuity appears normal.',
        color: Colors.green,
        icon: Icons.check_circle,
      );
    } else if (scale <= 1.3) {
      return _ResultData(
        title: 'Mild Difficulty',
        description:
            'You may have slight difficulty seeing small details.',
        color: AppColors.oren,
        icon: Icons.visibility,
      );
    } else {
      return _ResultData(
        title: 'Needs Attention',
        description:
            'Consider consulting an eye care professional.',
        color: Colors.red,
        icon: Icons.warning_rounded,
      );
    }
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.black54),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _ResultData {
  final String title;
  final String description;
  final Color color;
  final IconData icon;

  _ResultData({
    required this.title,
    required this.description,
    required this.color,
    required this.icon,
  });
}

