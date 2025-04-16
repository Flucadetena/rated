import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:labhouse/services/auth/anonymous.dart';
import 'package:labhouse/services/auth/google.dart';

class AuthDetails extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User? user = _auth.currentUser;

  StreamSubscription? _subAuth;

  Stream<User?> get userChanges => _auth.userChanges();

  /// Authenticates the user with Google
  Future<User?> get googleSignIn => getGoogleSignIn();

  /// Default Auth Anonymously
  Future<void> get anonymousSignIn => getAnonymousSignIn();

  String? get name =>
      (user?.isAnonymous ?? true)
          ? null
          : ((user!.displayName ?? '').isEmpty)
          ? 'Add your name'
          : user!.displayName;
  String? get email => (user?.email?.isEmpty ?? true) ? null : user!.email!;
  bool get isAnonymous => user?.isAnonymous ?? true;

  @override
  void onInit() {
    super.onInit();
    _listenToAuth();
  }

  @override
  onClose() {
    _subAuth?.cancel();
    super.onClose();
  }

  _listenToAuth() {
    _subAuth = _auth.userChanges().listen((newUser) async {
      user = newUser;

      if (newUser == null) {
        await anonymousSignIn;
      } else {
        _setBasicNameAndPhoto();
        FirebaseCrashlytics.instance.setUserIdentifier(newUser.uid);
      }
      update();
    });
  }

  _setBasicNameAndPhoto() async {
    if (user!.displayName == null && user!.providerData.firstWhereOrNull((p) => p.displayName != null) != null) {
      await user!.updateDisplayName(
        user!.providerData.firstWhere((p) => p.displayName != null).displayName!.replaceAll('+', ' '),
      );
    }
    if (user!.photoURL == null && user!.providerData.firstWhereOrNull((p) => p.photoURL != null) != null) {
      await user!.updatePhotoURL(user!.providerData.firstWhere((p) => p.photoURL != null).photoURL);
    }
    update();
  }

  void signOut() {
    // To wait for the animation ends
    Timer(150.milliseconds, () async {
      await _auth.signOut();
      GoogleSignIn().signOut();
    });
  }

  static bool get isAuth => Get.find<AuthDetails>().user != null;
  static User? get currentUser => Get.find<AuthDetails>().user;
}
