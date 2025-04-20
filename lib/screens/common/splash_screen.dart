// lib/screens/common/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../auth/login_selection.dart';
import '../student/student_main_page.dart';
import '../canteen_staff/canteen_main_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    navigate();
  }

  Future<void> navigate() async {
    await Future.delayed(const Duration(seconds: 2));
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final role = await AuthService().getUserRole(user.uid);
      if (role == 'staff') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CanteenMainPage()));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const StudentMainPage()));
      }
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginSelection()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}