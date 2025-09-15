import 'package:flutter/material.dart';
import 'package:realestate/accessories/custombutton.dart';
import 'package:realestate/admin/admin_signinPage.dart';
import 'package:realestate/pages/sign_up.dart';
import 'package:realestate/services/firebase_user.dart';
import 'dart:async';

class SignIn extends StatefulWidget {
  final VoidCallback? onToggleTheme;
  final ThemeMode themeMode;
  const SignIn({super.key, this.onToggleTheme, required this.themeMode});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
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

  /// Generic dialog
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
        Navigator.of(context).pop(); // close dialog
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

    final firebaseuser = FirebaseUser();
    final result = await firebaseuser.signIn(email, password);

    if (!mounted) return;
    if (result == "-1") {
      await _showDialog("Account deleted", "This account has been deleted.");
    } else if (result == "wrong-password") {
      await _showDialog(
        "Sign In Failed",
        "Incorrect password. Please try again.",
      );
    } else if (result == "user-not-found") {
      await _showDialog(
        "Sign In Failed",
        "No account found for that email address.",
      );
    } else if (result == null) {
      await _showDialog("Sign In Failed", "No account data found.");
    } else if (result.length == 28) {
      // just a check for uid-like string
      await _showDialog(
        "Login Successful",
        "Welcome Back!",

        autoClose: true,
        onClose: () {
          Navigator.of(context).pop();
        },
      );
    } else {
      await _showDialog("Sign In Failed", result);
    }
    setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                      const Icon(Icons.lock, size: 72),
                      const SizedBox(height: 12),
                      Text(
                        "Heavens Feel",
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

                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SignUp()),
                          );
                        },
                        child: Text(
                          "Don't have an account? Sign up",
                          style: TextStyle(color: theme.colorScheme.secondary),
                        ),
                      ),

                      const SizedBox(height: 12),

                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AdminSignIn(
                                onToggleTheme: widget.onToggleTheme,
                                themeMode: widget.themeMode,
                              ),
                            ),
                          );
                        },
                        child: Text(
                          "Switch to Admin Sign In",
                          style: TextStyle(color: theme.colorScheme.secondary),
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
