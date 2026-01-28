import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool darkMode = false;
  bool breakReminder = true;

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
                    Text("Manage your account and preferences",
                        style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),

              /// ===== PROFILE CARD =====
              _card(
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.blue,
                      child: Text("SC",
                          style:
                              TextStyle(color: Colors.white, fontSize: 22)),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Sarah Chen",
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600)),
                          SizedBox(height: 4),
                          Text("sarah.chen@email.com",
                              style: TextStyle(color: Colors.grey)),
                          Text("Member since Jan 2026",
                              style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
              ),

              /// ===== STATS =====
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text("Your Stats",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _statCard("24", "Tests taken", Colors.blue),
                    _statCard("156", "Hours saved", Colors.teal),
                    _statCard("8", "Visits", Colors.purple),
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
                child: Column(
                  children: [
                    _switchTile(
                      icon: Icons.dark_mode,
                      color: Colors.indigo,
                      title: "Dark Mode",
                      subtitle: "Reduce eye strain at night",
                      value: darkMode,
                      onChanged: (v) => setState(() => darkMode = v),
                    ),
                    const Divider(height: 1),
                    _switchTile(
                      icon: Icons.notifications,
                      color: Colors.amber,
                      title: "Break Reminders",
                      subtitle: "Get notified to rest eyes",
                      value: breakReminder,
                      onChanged: (v) => setState(() => breakReminder = v),
                    ),
                  ],
                ),
              ),

              /// ===== SETTINGS MENU =====
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text("Settings",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),

              _card(
                child: Column(
                  children: [
                    _menuItem(Icons.person, "Account Settings",
                        "Update your personal information"),
                    _menuItem(Icons.notifications, "Notifications",
                        "Manage your notification preferences"),
                    _menuItem(Icons.shield, "Privacy & Security",
                        "Control your privacy settings"),
                    _menuItem(Icons.help, "Help & Support",
                        "Get assistance and FAQs"),
                    _menuItem(Icons.description, "Terms & Policies",
                        "View our terms and privacy policy"),
                  ],
                ),
              ),

              /// ===== APP INFO =====
              _card(
                color: Colors.grey.shade100,
                child: const Center(
                  child: Column(
                    children: [
                      Text("EyeCare App",
                          style: TextStyle(color: Colors.grey)),
                      SizedBox(height: 4),
                      Text("Version 1.0.0",
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ),

              /// ===== LOGOUT =====
              Padding(
                padding: const EdgeInsets.all(16),
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.red.shade200),
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

  /// ===== REUSABLE WIDGETS =====

  Widget _card({required Widget child, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color ?? Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: child,
      ),
    );
  }

  Widget _statCard(String value, String label, Color color) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Text(value,
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: color)),
              const SizedBox(height: 4),
              Text(label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _switchTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(subtitle,
                  style:
                      const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }

  Widget _menuItem(IconData icon, String title, String subtitle) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.grey),
            ),
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
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
