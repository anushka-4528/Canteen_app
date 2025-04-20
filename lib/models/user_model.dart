// lib/models/user_model.dart
class AppUser {
  final String uid;
  final String? phoneNumber;
  final String role;

  AppUser({required this.uid, this.phoneNumber, required this.role});

  factory AppUser.fromMap(Map<String, dynamic> map, String uid) {
    return AppUser(
      uid: uid,
      phoneNumber: map['phoneNumber'],
      role: map['role'] ?? 'student',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'phoneNumber': phoneNumber,
      'role': role,
    };
  }
}