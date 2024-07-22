import 'package:bailey/utility/toast/toast_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
          print('Failed to delete user: $e');
          return false;
        }
      }
    }
    return true;
  }
}