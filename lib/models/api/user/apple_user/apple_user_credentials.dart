import 'package:firebase_auth/firebase_auth.dart';

class AppleUserCredential {
  final String fullName;
  final String email;
  final UserCredential userCredential;

  AppleUserCredential(
      {required this.fullName,
      required this.email,
      required this.userCredential});
}
