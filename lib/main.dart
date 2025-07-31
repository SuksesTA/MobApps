import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'pages/login.dart';
import 'pages/reset_password.dart';
import 'pages/signup.dart';
import 'pages/auth_landing.dart';
import 'pages/home.dart';
import 'pages/akun.dart';
import 'pages/profil_setting.dart';
import 'pages/security_setting.dart';
import 'pages/edit_name.dart';
import 'pages/new_password.dart';
import 'pages/verify_password.dart';

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  debugPrint("DEBUG: Aplikasi dimulai");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Down Syndrome Tracker',
      debugShowCheckedModeBanner: false,
      navigatorObservers: [routeObserver],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      routes: {
        '/auth': (context) => const AuthLanding(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/reset': (context) => const ResetPasswordPage(),
        '/home': (context) => const HomePage(),
        '/akun': (context) => const AccountPage(),
        '/profile': (context) => const ProfilSettingPage(),
        '/security': (context) => const SecuritySettingPage(),
        '/edit': (context) => const EditNamePage(),
        '/newpass': (context) => const NewPasswordPage(),
        '/verif': (context) => const VerifyPasswordPage(),
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
      _navigateAfterDelay();
    });
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(seconds: 3));

    final user = FirebaseAuth.instance.currentUser;
    debugPrint("DEBUG: FirebaseAuth.currentUser = ${user?.uid}");

    if (!mounted) return;

    if (user != null) {
      debugPrint("User sudah login, masuk ke Home");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } else {
      debugPrint("Belum login, masuk ke AuthLanding");
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
