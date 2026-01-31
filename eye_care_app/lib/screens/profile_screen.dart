import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool reminderEnabled = true;

  int breakInterval = 20;
  TimeOfDay? sleepTime;
  TimeOfDay? wakeTime;

  String username = 'User';
  String email = '-';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? 'User';
      email = prefs.getString('email') ?? '-';
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ===== HEADER =====
              const Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Profile",
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text("Manage your eye care habits",
                        style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),

              /// ===== PROFILE CARD =====
              _card(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: const Color(0xFF11DF8C),
                      child: Text(
                        username.isNotEmpty
                            ? username[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(username,
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text(email,
                              style:
                                  const TextStyle(color: Colors.grey)),
                          const SizedBox(height: 4),
                          const Text(
                            "Eye Care Level: Healthy",
                            style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF11DF8C)),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right,
                        color: Colors.grey),
                  ],
                ),
              ),

              /// ===== EYE HABIT SUMMARY =====
              const Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text("Eye Habit Summary",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _statCard("5h 20m", "Screen Time", Colors.teal),
                    _statCard("7h", "Sleep", Colors.blue),
                    _statCard("6", "Breaks", Colors.purple),
                  ],
                ),
              ),

              /// ===== QUICK SETTINGS =====
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text("Quick Settings",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),

              _card(
                child: _switchTile(
                  icon: Icons.alarm,
                  color: Colors.teal,
                  title: "Reminder",
                  subtitle: "Break & sleep notifications",
                  value: reminderEnabled,
                  onChanged: (v) =>
                      setState(() => reminderEnabled = v),
                ),
              ),

              /// ===== SETTINGS =====
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text("Settings",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),

              _card(
                child: Column(
                  children: [
                    _menuItem(
                      Icons.notifications,
                      "Reminder Schedule",
                      "Set break & sleep time",
                      onTap: _showReminderSheet,
                    ),
                    const Divider(height: 1),
                    _menuItem(
                      Icons.info_outline,
                      "App Info",
                      "Version and developer info",
                      onTap: _showAppInfo,
                    ),
                  ],
                ),
              ),

              /// ===== LOGOUT =====
              Padding(
                padding: const EdgeInsets.all(16),
                child: InkWell(
                  onTap: _logout,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border:
                          Border.all(color: Colors.red.shade200),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout, color: Colors.red),
                        SizedBox(width: 8),
                        Text("Log Out",
                            style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ===== REMINDER SHEET =====
  void _showReminderSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Reminder Schedule",
                style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: breakInterval,
              items: [15, 20, 30]
                  .map((e) =>
                      DropdownMenuItem(value: e, child: Text("$e minutes")))
                  .toList(),
              onChanged: (v) => setState(() => breakInterval = v!),
            ),
          ],
        ),
      ),
    );
  }

  void _showAppInfo() {
    showDialog(
      context: context,
      builder: (_) => const AlertDialog(
        title: Text("EyeCare App"),
        content: Text(
            "Version 1.0.0\nDeveloped by Prita Ayu\n\nBuild healthy screen & sleep habits"),
      ),
    );
  }

  /// ===== REUSABLE =====
  static Widget _card({required Widget child}) => Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20)),
          child: child,
        ),
      );

  static Widget _statCard(
          String value, String label, Color color) =>
      Expanded(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              Text(value,
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: color)),
              const SizedBox(height: 4),
              Text(label,
                  style: const TextStyle(
                      fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      );

  static Widget _switchTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) =>
      Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style:
                        const TextStyle(fontWeight: FontWeight.w600)),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      );

  static Widget _menuItem(
    IconData icon,
    String title,
    String subtitle, {
    required VoidCallback onTap,
  }) =>
      InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Icon(icon, color: Colors.grey),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600)),
                    Text(subtitle,
                        style: const TextStyle(
                            fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right,
                  color: Colors.grey),
            ],
          ),
        ),
      );
}
