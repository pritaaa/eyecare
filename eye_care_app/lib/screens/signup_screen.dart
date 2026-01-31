import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> _saveAccount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', usernameController.text);
    await prefs.setString('email', emailController.text);
    await prefs.setString('password', passwordController.text);
  }

  @override
  void dispose() {
    usernameController.dispose();
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
                const SizedBox(height: 24),

                /// BACK
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.teal),
                ),

                const SizedBox(height: 24),

                /// LOGO
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

                /// TITLE
                const Text(
                  "Create Account",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  "Start building healthy screen & sleep habits",
                  style: TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 32),

                /// USERNAME
                _inputField(
                  controller: usernameController,
                  label: "Username",
                  icon: Icons.person_outline,
                ),

                const SizedBox(height: 16),

                /// EMAIL
                _inputField(
                  controller: emailController,
                  label: "Email",
                  icon: Icons.email_outlined,
                ),

                const SizedBox(height: 16),

                /// PASSWORD
                _inputField(
                  controller: passwordController,
                  label: "Password",
                  icon: Icons.lock_outline,
                  isPassword: true,
                ),

                const SizedBox(height: 32),

                /// SIGN UP BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (usernameController.text.isEmpty ||
                          emailController.text.isEmpty ||
                          passwordController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please fill all fields"),
                          ),
                        );
                        return;
                      }

                      await _saveAccount();

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Account created successfully"),
                        ),
                      );

                      Navigator.pop(context); // balik ke Login
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                /// LOGIN LINK
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      "Already have an account? Sign In",
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

  /// INPUT FIELD
  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
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
