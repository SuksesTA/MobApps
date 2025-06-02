import 'package:dst_mk2/pages/profil_setting.dart';
import 'package:dst_mk2/pages/security_setting.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:dst_mk2/pages/getstarted.dart';
import 'pages/login.dart';
import 'pages/signup.dart';
import 'pages/auth_landing.dart';
import 'pages/home.dart';
import 'pages/edit_name.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // ✅ Pastikan binding siap
  debugPrint("DEBUG: Aplikasi dimulai"); // ✅ Debug awal aplikasi
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Down Syndrome Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: SplashScreen(),
      routes: {
        '/auth': (context) => const AuthLanding(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/home': (context) => const HomePage(),
        '/profile': (context) => const ProfilSettingPage(),
        '/security': (context) => const SecuritySettingPage(),
        '/edit': (context) => const EditNamePage(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLoginStatus();
    });
  }

  // Fungsi untuk mengecek status login
  Future<void> _checkLoginStatus() async {
    await Future.delayed(Duration(seconds: 3));

    try {
      debugPrint("DEBUG: Memulai pengecekan status login");
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      debugPrint("DEBUG: Status login dari SharedPreferences -> $isLoggedIn");

      if (!mounted) return;

      if (isLoggedIn) {
        debugPrint("DEBUG: Navigasi ke halaman Home");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      } else {
        debugPrint("DEBUG: Navigasi ke halaman AuthLanding");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AuthLanding()),
        );
      }
    } catch (e) {
      debugPrint("ERROR saat membaca SharedPreferences: $e");
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AuthLanding()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Image.asset('assets/Splash_Screen.png')),
    );
  }
}
