import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'profile_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // ===== CONTROLLERS =====
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // ===== SAVE LOGIN (LOCAL STORAGE) =====
  Future<void> saveLogin(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('email', email);
    await prefs.setString(
      'username',
      email.split('@')[0], // auto username
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

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
                const Text(
                  "Sign In",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Welcome back! Please login to continue",
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
                      await saveLogin(emailController.text);

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ProfileScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      "Sign In",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                /// ===== SIGN UP =====
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SignUpScreen()),
                      );
                    },
                    child: const Text(
                      "Don't have an account? Sign Up",
                      style: TextStyle(
                        color: Colors.teal,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
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
