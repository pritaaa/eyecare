import 'package:flutter/material.dart';

class VisionTestScreen extends StatefulWidget {
  const VisionTestScreen({super.key});

  @override
  State<VisionTestScreen> createState() => _VisionTestScreenState();
}

class _VisionTestScreenState extends State<VisionTestScreen> {
  String? selectedTest;
  bool testStarted = false;

  final List<Map<String, String>> tests = [
    {
      'id': 'acuity',
      'title': 'Visual Acuity Test',
      'description': 'Test your ability to see details at various distances',
      'duration': '3 min',
      'difficulty': 'Easy',
    },
    {
      'id': 'color',
      'title': 'Color Blindness Test',
      'description': 'Identify numbers in colored patterns',
      'duration': '2 min',
      'difficulty': 'Easy',
    },
    {
      'id': 'astigmatism',
      'title': 'Astigmatism Test',
      'description': 'Check for irregular curvature of the eye',
      'duration': '2 min',
      'difficulty': 'Easy',
    },
    {
      'id': 'contrast',
      'title': 'Contrast Sensitivity',
      'description': 'Test your ability to distinguish between objects',
      'duration': '4 min',
      'difficulty': 'Medium',
    },
  ];

  @override
  Widget build(BuildContext context) {
    /// ================= TEST IN PROGRESS =================
    if (testStarted && selectedTest != null) {
      return _testInProgress();
    }

    /// ================= TEST DETAIL =================
    if (selectedTest != null) {
      final test = tests.firstWhere((t) => t['id'] == selectedTest);
      return _testDetail(test);
    }

    /// ================= TEST LIST =================
    return _testList();
  }

  /// ================= TEST LIST SCREEN =================
  Widget _testList() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Vision Tests'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Quick self-assessments for your eye health',
            style: TextStyle(color: Colors.black54),
          ),

          const SizedBox(height: 16),

          _infoBox(
            color: Colors.amber,
            text:
                'These tests are for screening purposes only and do not replace professional eye exams.',
          ),

          const SizedBox(height: 16),

          ...tests.map((test) => _testCard(test)).toList(),

          const SizedBox(height: 16),

          _successBox(),
        ],
      ),
    );
  }

  /// ================= TEST DETAIL =================
  Widget _testDetail(Map<String, String> test) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => setState(() => selectedTest = null),
        ),
        title: Text(test['title']!),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _iconCircle(Icons.remove_red_eye, Colors.blue),

                const SizedBox(height: 12),

                Text(test['description']!,
                    style: const TextStyle(color: Colors.black54)),

                const SizedBox(height: 16),

                _infoRow('Duration', test['duration']!),
                _infoRow('Difficulty', test['difficulty']!),

                const SizedBox(height: 16),

                _infoBox(
                  color: Colors.blue,
                  text:
                      'Find a well-lit area\nRemove glasses if testing without them\nHold device at arm\'s length',
                ),

                const Spacer(),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: const StadiumBorder(),
                    minimumSize: const Size.fromHeight(48),
                  ),
                  onPressed: () {
                    setState(() => testStarted = true);
                  },
                  child: const Text('Start Test'),
                ),

                const SizedBox(height: 8),

                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    shape: const StadiumBorder(),
                    minimumSize: const Size.fromHeight(48),
                  ),
                  onPressed: () {
                    setState(() => selectedTest = null);
                  },
                  child: const Text('Back'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ================= TEST IN PROGRESS =================
  Widget _testInProgress() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Test in Progress'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _iconCircle(Icons.remove_red_eye, Colors.blue, size: 48),

                const SizedBox(height: 16),

                const Text(
                  'This is a demo.\nIn a real app, the test would appear here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54),
                ),

                const SizedBox(height: 24),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: const StadiumBorder(),
                    minimumSize: const Size.fromHeight(48),
                  ),
                  onPressed: () {
                    setState(() {
                      testStarted = false;
                      selectedTest = null;
                    });
                  },
                  child: const Text('Complete Test'),
                ),

                const SizedBox(height: 8),

                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    shape: const StadiumBorder(),
                    minimumSize: const Size.fromHeight(48),
                  ),
                  onPressed: () {
                    setState(() => testStarted = false);
                  },
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ================= COMPONENTS =================
  Widget _testCard(Map<String, String> test) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: _iconCircle(Icons.remove_red_eye, Colors.blue),
        title: Text(test['title']!),
        subtitle: Text(test['description']!),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          setState(() => selectedTest = test['id']);
        },
      ),
    );
  }

  Widget _iconCircle(IconData icon, Color color, {double size = 24}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: size),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          Text(value),
        ],
      ),
    );
  }

  Widget _infoBox({required Color color, required String text}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, style: TextStyle(color: Colors.black)),
    );
  }

  Widget _successBox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'Last test: 2 weeks ago\nYour vision appears normal!',
        style: TextStyle(color: Colors.green),
      ),
    );
  }
}
