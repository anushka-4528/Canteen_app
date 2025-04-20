// lib/screens/auth/student_otp.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application5/screens/student/student_main_page.dart';

class StudentOtp extends StatefulWidget {
  final String verificationId;
  final String collegeId;

  const StudentOtp({super.key, required this.verificationId, required this.collegeId});

  @override
  State<StudentOtp> createState() => _StudentOtpState();
}

class _StudentOtpState extends State<StudentOtp> {
  final TextEditingController _otpController = TextEditingController();
  bool _isVerifying = false;

  void _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) return;

    setState(() => _isVerifying = true);
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: otp,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => StudentMainPage()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verification failed: ${e.toString()}')),
      );
    } finally {
      setState(() => _isVerifying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Enter OTP")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Enter OTP'),
            ),
            const SizedBox(height: 20),
            _isVerifying
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _verifyOtp,
              child: const Text('Verify'),
            ),
          ],
        ),
      ),
    );
  }
}

