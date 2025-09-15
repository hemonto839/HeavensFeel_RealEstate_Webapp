import 'package:flutter/material.dart';
import 'package:realestate/accessories/custombutton.dart';
import 'package:realestate/models/user.dart';
import 'package:realestate/pages/sign_in.dart';
import 'package:realestate/services/firebase_user.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmpasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final firebaseuser = FirebaseUser();

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmpasswordController.dispose();
    super.dispose();
  }

  /// Generic dialog (same as in SignIn)
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

  /// Simple email validation using RegExp
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  Future<void> _handleSignUp() async {
    final username = usernameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPass = confirmpasswordController.text.trim();

    if (username.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPass.isEmpty) {
      await _showDialog("Sign Up Failed", "Please fill in all fields.");
      return;
    }

    if (!_isValidEmail(email)) {
      await _showDialog("Invalid Email", "Please enter a valid email address.");
      return;
    }

    if (password.length < 6) {
      await _showDialog(
        "Weak Password",
        "Password must be at least 6 characters.",
      );
      return;
    }

    if (password != confirmPass) {
      await _showDialog("Sign Up Failed", "Passwords do not match.");
      return;
    }

    UserModel user = UserModel(
      uid: "",
      email: email,
      name: username,
      password: password,
    );

    final result = await firebaseuser.signUp(user);

    if (result != null) {
      await _showDialog(
        "Sign Up Successful",
        "Your account has been created.",
        autoClose: true,
        onClose: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const SignIn(themeMode: ThemeMode.system)),
          );
        },
      );
    } else {
      await _showDialog("Sign Up Failed", "Account creation was unsuccessful.");
    }
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
                      const Icon(Icons.person_add_alt_1, size: 72),
                      const SizedBox(height: 12),
                      Text(
                        "Create Account",
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                        textScaler: const TextScaler.linear(1.8),
                      ),
                      const SizedBox(height: 24),

                      // Username
                      TextField(
                        controller: usernameController,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: "Username",
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Email
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(labelText: "Email"),
                      ),
                      const SizedBox(height: 16),

                      // Password
                      // Password
                      TextField(
                        controller: passwordController,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.next,
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
                      ),
                      const SizedBox(height: 16),

                      // Confirm Password
                      TextField(
                        controller: confirmpasswordController,
                        obscureText: _obscureConfirmPassword,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          labelText: "Confirm Password",
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                          ),
                        ),
                        onSubmitted: (_) => _handleSignUp(),
                      ),
                      const SizedBox(height: 24),

                      // Button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: Custombutton(
                          buttonText: "Sign Up",
                          icon: Icons.person_add_alt,
                          onPressed: _handleSignUp,
                          height: 52,
                          fontSize: 20,
                        ),
                      ),

                      const SizedBox(height: 12),

                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const SignIn(themeMode: ThemeMode.system)),
                          );
                        },
                        child: Text(
                          "Already have an account? Sign in",
                          style:  TextStyle(
                            color: theme.colorScheme.secondary
                          )
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
