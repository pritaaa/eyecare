import 'package:eye_care_app/app_usage/app_usage_provider.dart';
import 'package:eye_care_app/auth/auth_provider.dart';
import 'package:eye_care_app/chatbot/controller.dart';
import 'package:eye_care_app/screen_time/screen_time_provider.dart';
import 'package:eye_care_app/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eye_care_app/screens/home_screen.dart';
import 'package:eye_care_app/screens/chat_screen.dart';
import 'package:eye_care_app/screens/profile_screen.dart';
import 'package:eye_care_app/theme/app_colors.dart';
import 'package:firebase_core/firebase_core.dart';
// 1. IMPORT SCREENUTIL
import 'package:flutter_screenutil/flutter_screenutil.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChatbotController()),
        ChangeNotifierProvider(create: (_) => ScreenTimeProvider()),
        ChangeNotifierProvider(create: (_) => AppUsageProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const EyeCareApp(),
    ),
  );
}

class EyeCareApp extends StatelessWidget {
  const EyeCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 2. BUNGKUS DENGAN SCREENUTILINIT
    return ScreenUtilInit(
      designSize: const Size(360, 800), // Ukuran standar desain (Lebar, Tinggi)
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Eye Care',
          theme: ThemeData(
            useMaterial3: true,
            fontFamily: 'Poppins',
            scaffoldBackgroundColor: AppColors.putih,
          ),
          // Menggunakan child yang dilempar dari builder
          home: child,
        );
      },
      // Halaman pertama aplikasi
      child: const SplashScreen(),
    );
  }
}

/// =======================
/// MAIN SCREEN (Navigasi)
/// =======================
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
          _screens[_currentIndex],
          Positioned(
            left: 20.w,   // Menggunakan .w untuk margin kiri responsif
            right: 20.w,  // Menggunakan .w untuk margin kanan responsif
            bottom: 20.h, // Menggunakan .h untuk jarak bawah responsif
            child: _floatingNavBar(),
          ),
        ],
      ),
    );
  }

  Widget _floatingNavBar() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 14.h), // Responsif vertikal
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r), // Menggunakan .r untuk radius responsif
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(icon: Icons.home, index: 0),
          _navItem(icon: Icons.chat_bubble_outline, index: 1),
          _navItem(icon: Icons.person_outline, index: 2),
        ],
      ),
    );
  }

  Widget _navItem({required IconData icon, required int index}) {
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
            size: 26.sp, // Ukuran Icon sekarang responsif menggunakan .sp
            color: isActive ? AppColors.birugelap : Colors.grey,
          ),
          SizedBox(height: 6.h),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 4.h,
            width: isActive ? 18.w : 0,
            decoration: BoxDecoration(
              color: AppColors.birugelap,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
        ],
      ),
    );
  }
}