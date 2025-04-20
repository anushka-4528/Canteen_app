import 'package:flutter/material.dart';
import 'screens/auth/welcome_page.dart';
import 'screens/auth/login_selection.dart';
import 'screens/common/splash_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KMIT Canteen',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.deepOrange),
      home: const WelcomePage(), // ✅ Show welcome page first
      routes: {
        '/login-selection': (context) => const LoginSelection(),
        '/splash': (context) => const SplashScreen(), // Route to splash
      },
    );
  }
}
