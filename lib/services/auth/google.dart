import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:labhouse/components/popups/popups.dart';
import 'package:labhouse/services/helpers.dart';

Future<OAuthCredential?> get _getGoogleAuthCredentials async {
  try {
    GoogleSignIn googleSignIn = GoogleSignIn();
    GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();

    /// If the sign in process is aborted
    if (googleSignInAccount == null) return null;

    GoogleSignInAuthentication googleAuth = await googleSignInAccount.authentication;

    return GoogleAuthProvider.credential(accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
  } catch (err, stack) {
    await crashError(err, 'Error getting credentials from Google provider.', stack: stack);
    return null;
  }
}

Future<User?> getGoogleSignIn() async {
  try {
    OAuthCredential? credential = await _getGoogleAuthCredentials;

    if (credential == null) return null;

    try {
      UserCredential authResult = await FirebaseAuth.instance.currentUser!.linkWithCredential(credential);

      return authResult.user;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "provider-already-linked":
        case "credential-already-in-use":
          UserCredential authResult = await FirebaseAuth.instance.signInWithCredential(credential);
          return authResult.user;

        case "email-already-in-use":
          showGetSnackBar(message: 'Looks like you already have an account with Apple Sign In');
          return null;
        default:
          throw Exception('Error linking with Google: ${e.code}');
      }
    }
  } catch (err, stack) {
    showGetSnackBar(message: 'Something happen, please try again or contact support');
    crashError(err, 'Error login in with Google', stack: stack);
    return null;
  }
}
