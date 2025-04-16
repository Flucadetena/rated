import 'package:firebase_auth/firebase_auth.dart';
import 'package:labhouse/components/popups/popups.dart';
import 'package:labhouse/services/helpers.dart';

Future<User?> getAnonymousSignIn() async {
  try {
    final userCredential = await FirebaseAuth.instance.signInAnonymously();

    return userCredential.user;
  } catch (err, stack) {
    showGetSnackBar(message: 'Something happen, please try again or contact support');
    crashError(err, 'Error login in to Google', stack: stack);
    return null;
  }
}
