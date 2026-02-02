import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String _username = '';

  bool get isLoggedIn => _isLoggedIn;
  String get username => _username;

  /// Cek status login saat aplikasi baru dibuka (Splash Screen)
  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    _username = prefs.getString('username') ?? 'User';
    notifyListeners();
  }

  /// Fungsi Login/Signup (Simpan nama ke lokal)
  Future<void> login(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', true);
    // Hapus atau komen baris di bawah ini.
    // Biarkan 'username' tetap seperti apa adanya dari hasil Sign Up.
    // await prefs.setString('username', name);

    _isLoggedIn = true;
    _username = name;
    notifyListeners();
  }

  /// Fungsi Logout (Hapus data)
  /// Fungsi Logout (Hapus HANYA status login)
Future<void> logout() async {
  final prefs = await SharedPreferences.getInstance();
  
  // HANYA hapus status login, JANGAN clear() semua
  await prefs.remove('is_logged_in');
  
  // Reset state di provider
  _isLoggedIn = false;
  _username = '';
  
  notifyListeners();
}
}
