import 'package:eye_care_app/auth/auth_provider.dart';
import 'package:eye_care_app/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:sizer/sizer.dart';
import 'signup_screen.dart';
import 'package:eye_care_app/theme/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF6FBFA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: height),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, // ⭐ INI KUNCINYA
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// ===== LOGO =====
                    Center(
                      child: Container(
                        height: 110,
                        width: 110,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/image/logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    /// ===== TITLE =====
                    Text(
                      "Masuk",
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.biru,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Selamat datang kembali! Silakan login untuk melanjutkan",
                      style: TextStyle(color: Colors.grey),
                    ),

                    const SizedBox(height: 32),

                    /// ===== EMAIL =====
                    _inputField(
                      label: "Email",
                      icon: Icons.email_outlined,
                      controller: emailController,
                    ),

                    const SizedBox(height: 16),

                    /// ===== PASSWORD =====
                    _inputField(
                      label: "Password",
                      icon: Icons.lock_outline,
                      controller: passwordController,
                      isPassword: true,
                    ),

                    const SizedBox(height: 20),

                    /// ===== LOGIN BUTTON =====
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () async {
                          final email = emailController.text;
                          final password = passwordController.text;

                          if (email.isEmpty || password.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Silakan isi semua kolom"),
                              ),
                            );
                            return;
                          }

                          final prefs = await SharedPreferences.getInstance();
                          final storedEmail = prefs.getString('email');
                          final storedPassword = prefs.getString('password');
                          final storedUsername = prefs.getString('username');

                          if (storedEmail != null &&
                              storedEmail == email &&
                              storedPassword == password) {
                            await context.read<AuthProvider>().login(
                              storedUsername ?? 'User',
                            );

                            if (context.mounted) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const MainScreen(),
                                ),
                              );
                            }
                          } else {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Alamat email atau kata sandi tidak valid",
                                  ),
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.birugelap,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          "Masuk",
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    /// ===== SIGN UP =====
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Belum punya akun? ",
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SignUpScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              "Daftar",
                              style: TextStyle(
                                color: AppColors.biru,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// ===== INPUT FIELD =====
  Widget _inputField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
