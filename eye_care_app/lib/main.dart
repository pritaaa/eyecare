import 'package:eye_care_app/app_usage/app_usage_provider.dart';
import 'package:eye_care_app/chatbot/controller.dart';
import 'package:eye_care_app/screen_time/screen_time_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eye_care_app/screens/home_screen.dart';
import 'package:eye_care_app/screens/chat_screen.dart';
import 'package:eye_care_app/screens/profile_screen.dart';
import 'package:eye_care_app/theme/app_colors.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChatbotController()),
        ChangeNotifierProvider(create: (_) => ScreenTimeProvider()),
        ChangeNotifierProvider(create: (_) => AppUsageProvider()),
      ],
      child: const EyeCareApp(),
    ),
  );
}

class EyeCareApp extends StatelessWidget {
  const EyeCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Eye Care',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: AppColors.putih,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    ChatbotScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// SCREEN CONTENT
          _screens[_currentIndex],

          /// FLOATING NAVBAR
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: _FloatingNavBar(),
          ),
        ],
      ),
    );
  }

  /// ================= FLOATING NAV BAR =================
  Widget _FloatingNavBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(icon: Icons.home, index: 0),
          _NavItem(icon: Icons.chat_bubble_outline, index: 1),
          _NavItem(icon: Icons.person_outline, index: 2),
        ],
      ),
    );
  }

  /// ================= NAV ITEM =================
  Widget _NavItem({required IconData icon, required int index}) {
    final bool isActive = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 26,
            color: isActive ? AppColors.birugelap : Colors.grey,
          ),
          const SizedBox(height: 6),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 4,
            width: isActive ? 18 : 0,
            decoration: BoxDecoration(
              color: AppColors.birugelap,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}
