import 'package:eye_care_app/auth/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'package:eye_care_app/theme/app_colors.dart';
import 'dart:math';
import 'dart:async'; // Tambahkan import ini untuk Timer
import 'dart:typed_data';
import 'package:eye_care_app/app_usage/app_usage_provider.dart';
import 'package:eye_care_app/screen_time/screen_time_model.dart';
import 'package:eye_care_app/screen_time/screen_time_provider.dart';
import 'package:eye_care_app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:eye_care_app/theme/app_text.dart';
import 'package:provider/provider.dart';
import 'timers_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool reminderEnabled = true;
  TimeOfDay breakTime = const TimeOfDay(hour: 10, minute: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.putih,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// HEADER
              const Text(
                'Profil',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: AppColors.blueDark,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Kelola kebiasaan kesehatan mata Anda',
                style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
              ),

              const SizedBox(height: 28),

              /// PROFILE CARD
              _profileCard(),

              const SizedBox(height: 20),

              /// EYE HABIT SUMMARY
              const Text(
                'Ringkasan', 
                style: _sectionTitle
                ,
                ),
              const SizedBox(height: 18),
              _statsGrid(),

              const SizedBox(height: 20),

              /// QUICK SETTINGS
              // const Text('Pengaturan Cepat', style: _sectionTitle),
              // const SizedBox(height: 18),
              // _quickSettingCard(),

              const SizedBox(height: 20),

              /// SETTINGS
              const Text('Pengaturan', style: _sectionTitle),
              const SizedBox(height: 20),
              _settingsCard(),

              const SizedBox(height: 32),

              /// LOGOUT
              OutlinedButton(
                
                onPressed: () async {
                  await context.read<AuthProvider>().logout();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  side: const BorderSide(color: Colors.redAccent),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Keluar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              /// APP INFO
              const Center(
                child: Text(
                  'Eye Care App\nVersi 1.0.0\nDikembangkan oleh Tim Eye Care',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF7A9CC6),
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= WIDGETS =================

  Widget _profileCard() {
    final username = context.select((AuthProvider p) => p.username);
    final initial = username.isNotEmpty ? username[0].toUpperCase() : 'U';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration,
      child: Row(
        children: [
          Container(
            height: 64,
            width: 64,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.bluePrimary, AppColors.blueLight2],
              ),
            ),
            child: Center(
              child: Text(
                initial,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  username.isNotEmpty ? username : 'Pengguna',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E3A5F),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Perhatian kecil untuk mata',
                  style: TextStyle(fontSize: 14, color: Color(0xFF5EA1DF)),
                ),
              ],
            ),
          ),
          // const Icon(Icons.chevron_right, size: 28, color: Colors.black38),
        ],
      ),
    );
  }


Widget _statsGrid() {
  return const Row(
    children: [
      Expanded(
        child: ScreenTimeStatCard(),
      ),
      SizedBox(width: 16),
      Expanded(
        child: SleepStatCard(sleepHours: 7.5), // Ganti dengan data sleepHours kamu
      ),
    ],
  );
}

  Widget _quickSettingCard() {
    return Container(
      decoration: _cardDecoration,
      child: ListTile(
        leading: _settingIcon(Icons.alarm),
        title: const Text('Pengingat'),
        subtitle: const Text('Notifikasi istirahat & tidur'),
        trailing: Switch(
          value: reminderEnabled,
          activeColor: const Color(0xFF1E3A5F),
          onChanged: (val) {
            setState(() => reminderEnabled = val);
          },
        ),
      ),
    );
  }

  Widget _settingsCard() {
    return Container(
      decoration: _cardDecoration,
      child: Column(
        children: [
          // ListTile(
          //   leading: _settingIcon(Icons.schedule),
          //   title: const Text('Jadwal Pengingat'),
          //   subtitle: Text('Waktu istirahat: ${breakTime.format(context)}'),
          //   trailing: const Icon(Icons.chevron_right),
          //   onTap: _pickBreakTime,
          // ),
          // const Divider(height: 1),
          ListTile(
            leading: _settingIcon(Icons.info_outline),
            title: const Text('Informasi Aplikasi'),
            subtitle: const Text('Versi dan pengembang'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Eye Care App',
                applicationVersion: '1.0.0',
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _settingIcon(IconData icon) {
    return Container(
      height: 44,
      width: 44,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [Color(0xFFE8F4FF), Color(0xFFD4EBFF)],
        ),
      ),
      child: Icon(icon, color: Color(0xFF5EA1DF)),
    );
  }

  Future<void> _pickBreakTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: breakTime,
    );

    if (picked != null) {
      setState(() => breakTime = picked);
    }
  }
}

// ================= SMALL WIDGET =================

class _StatCard extends StatelessWidget {
  final String value;
  final String label;

  const _StatCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: _cardDecoration,
      child: Column(
        children: [
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Color(0xFF5EA1DF),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF7A9CC6)),
          ),
        ],
      ),
    );
  }
}

// ================= STYLES =================

const _sectionTitle = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.w700,
  color: AppColors.textPrimary,
);

final _cardDecoration = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(20),
  border: Border.all(color: Color(0xFFE8F4FF)),
  boxShadow: [
    BoxShadow(color: Color(0x145EA1DF), blurRadius: 20, offset: Offset(0, 6)),
  ],
);