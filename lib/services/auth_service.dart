// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<String?> getUserRole(String uid) async {
    final doc = await _db.collection("users").doc(uid).get();
    return doc.exists ? doc["role"] : null;
  }

  Future<UserCredential> signInStaff(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> verifyPhone(
      String phoneNumber,
      Function(String verificationId) onCodeSent,
      Function(String uid) onVerified,
      ) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (credential) async {
        final result = await _auth.signInWithCredential(credential);
        onVerified(result.user!.uid);
      },
      verificationFailed: (e) => throw Exception(e.message),
      codeSent: (verificationId, _) => onCodeSent(verificationId),
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  Future<UserCredential> signInWithOtp(String verificationId, String smsCode) {
    final credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: smsCode);
    return _auth.signInWithCredential(credential);
  }
}