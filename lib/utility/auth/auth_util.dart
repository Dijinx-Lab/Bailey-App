import 'dart:convert';
import 'dart:math';

import 'package:bailey/models/api/user/apple_user/apple_user_credentials.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthUtil {
  static FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  static Future<void> signOut() async {
    await firebaseAuth.signOut();
    await GoogleSignIn().signOut();
  }

  static Future<UserCredential?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    try {
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        return await firebaseAuth.signInWithCredential(credential);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<AppleUserCredential?> signInWithApple() async {
    try {
      final rawNonce = generateNonce();
      final nonce = sha256ofString(rawNonce);
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );
      UserCredential appleAuthCreds =
          await firebaseAuth.signInWithCredential(oauthCredential);

      return AppleUserCredential(
          email: appleCredential.email ?? "",
          fullName:
              "${appleCredential.givenName} ${appleCredential.familyName}",
          userCredential: appleAuthCreds);
    } catch (e) {
      debugPrint(e.toString());
      if (e.toString().contains("AuthorizationErrorCode.canceled")) return null;
      rethrow;
    }
  }

  static String generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  static String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static Future<bool> deleteAccount() async {
    User? user = firebaseAuth.currentUser;
    if (user != null) {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        await GoogleSignIn().signOut();

        try {
          await user.reauthenticateWithCredential(credential);
          await user.delete();
          return true;
        } catch (e) {
          return false;
        }
      }
    }
    return true;
  }
}
