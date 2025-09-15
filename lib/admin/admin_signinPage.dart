import 'package:flutter/material.dart';
import 'package:realestate/accessories/custombutton.dart';
import 'package:realestate/admin/home_page_admin.dart';
import 'package:realestate/pages/sign_in.dart';
import 'package:realestate/services/firebase_admin.dart';

class AdminSignIn extends StatefulWidget {
  final VoidCallback? onToggleTheme;
  final ThemeMode themeMode;
  const AdminSignIn({super.key, this.onToggleTheme, required this.themeMode});

  @override
  State<AdminSignIn> createState() => _AdminSignInState();
}

class _AdminSignInState extends State<AdminSignIn> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isSubmitting = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _showDialog(
    String title,
    String message, {
    bool autoClose = false,
    VoidCallback? onClose,
  }) async {
    if (!mounted) return;

    showDialog<void>(
      context: context,
      barrierDismissible: !autoClose,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          if (!autoClose)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (onClose != null) onClose();
              },
              child: const Text("OK"),
            ),
        ],
      ),
    );

    if (autoClose) {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        Navigator.of(context).pop();
        if (onClose != null) onClose();
      }
    }
  }

  Future<void> _handleSignIn() async {
  final email = emailController.text.trim();
  final password = passwordController.text.trim();

  if (email.isEmpty || password.isEmpty) {
    await _showDialog(
      "Sign In Failed",
      "Please enter both email and password.",
    );
    return;
  }

  setState(() => _isSubmitting = true);

  final adminService = FirebaseAdmin(); // implement this as shown before
  final admin = await adminService.signInAdmin(email, password);

  if (!mounted) return;

  if (admin == null) {
    await _showDialog(
      "Sign In Failed",
      "Invalid email or password, or no admin record found.",
    );
  } else {
    await _showDialog(
      "Login Successful",
      "Welcome, ${admin.name}",
      autoClose: true,
      onClose: () {
        // Navigate to Admin Home Page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => AdminHomePage(
              onToggleTheme: widget.onToggleTheme ?? () {},
              themeMode: widget.themeMode,
            ),
          ),
        );
      },
    );
  }

  setState(() => _isSubmitting = false);
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.admin_panel_settings, size: 72),
                      const SizedBox(height: 12),
                      Text(
                        "Admin Panel",
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                        textScaler: TextScaler.linear(2),
                      ),
                      const SizedBox(height: 24),

                      // Email
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(labelText: "Email"),
                        onSubmitted: (_) => FocusScope.of(context).nextFocus(),
                      ),
                      const SizedBox(height: 16),

                      // Password
                      TextField(
                        controller: passwordController,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          labelText: "Password",
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        onSubmitted: (_) => _handleSignIn(),
                      ),
                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: Custombutton(
                          buttonText: 'Sign In',
                          icon: Icons.login_outlined,
                          onPressed: _isSubmitting ? () {} : _handleSignIn,
                          height: 52,
                          fontSize: 20,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Switch to normal user sign in
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => SignIn(onToggleTheme: widget.onToggleTheme, themeMode: widget.themeMode)),
                          );
                        },
                        child: Text(
                          "Switch to Normal User Sign In",
                          style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
