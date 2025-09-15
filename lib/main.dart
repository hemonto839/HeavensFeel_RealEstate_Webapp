import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:realestate/admin/admin_signinPage.dart';
import 'package:realestate/admin/home_page_admin.dart';
import 'package:realestate/firebase_options.dart';
import 'package:realestate/pages/home_page.dart';
import 'package:realestate/pages/sign_in.dart';
import 'package:realestate/theme/apptheme.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);  
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark
          ? ThemeMode.light
          : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HeavensFeel',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      debugShowCheckedModeBanner: false,
      initialRoute: '/home',
      routes: {
        '/home': (context) => HomePage(onToggleTheme: toggleTheme,
        themeMode: _themeMode,),
        '/signin': (context) => SignIn(onToggleTheme: toggleTheme, themeMode: _themeMode,),
        '/admin-signin': (context) => AdminSignIn(onToggleTheme: toggleTheme,themeMode: _themeMode,),
        '/admin-home': (context) =>
            AdminHomePage(onToggleTheme: toggleTheme, themeMode: _themeMode,),
      },
    );
  }
}

