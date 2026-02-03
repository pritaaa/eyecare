import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eye_care_app/screen_time/screen_time_provider.dart';
import 'package:provider/provider.dart';

class ScreenTimeWarning {
  /// ✅ Fungsi untuk cek dan tampilkan warning
  static Future<void> checkAndShow(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toString().split(' ')[0]; // format: 2025-02-03
    final lastWarningDate = prefs.getString('last_warning_date') ?? '';

    // Jangan tampilkan warning jika sudah muncul hari ini
    if (lastWarningDate == today) return;

    final provider = context.read<ScreenTimeProvider>();
    final screenTime = provider.report;

    if (screenTime != null && screenTime.hours >= 3) {
      _showDialog(context, screenTime.hours, screenTime.minutes);
      await prefs.setString('last_warning_date', today);
    }
  }

  /// ✅ Fungsi untuk tampilkan dialog
  static void _showDialog(BuildContext context, int hours, int minutes) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 32),
            SizedBox(width: 12),
            Expanded(child: Text('Peringatan Durasi Layar!')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Durasi layar Anda hari ini:',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            SizedBox(height: 8),
            Text(
              '${hours}h ${minutes}m',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Waktu layar yang disarankan maksimal 3 jam per hari untuk menjaga kesehatan mata.',
                      style: TextStyle(fontSize: 12, color: Colors.red[800]),
                    ),
                  ),
                ],
              ),
            ),
            // SizedBox(height: 16),
            // Text(
            //   '💡 Tips Kesehatan Mata:',
            //   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            // ),
            // SizedBox(height: 8),
            // _tipItem('Istirahatkan mata setiap 20 menit'),
            // _tipItem('Atur waktu tidur yang cukup'),
            // _tipItem('Kurangi penggunaan layar sebelum tidur'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.blue,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text('Mengerti', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  static Widget _tipItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 16),
          SizedBox(width: 8),
          Expanded(
            child: Text(text, style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}