import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:labhouse/controllers/auth.dart';
import 'package:labhouse/firebase_options.dart';
import 'package:labhouse/services/helpers.dart';

initAppServices() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  //! ONLY USE WITH EMULATORS
  // if (kDebugMode) {
  //   try {
  //     FirebaseFirestore.instance.useFirestoreEmulator('192.168.1.34', 8080);
  //     await FirebaseAuth.instance.useAuthEmulator('192.168.1.34', 9099);
  //   } catch (e) {
  //     debugPrint(e.toString());
  //   }
  // }

  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterError(
      errorDetails,
      fatal:
          !(errorDetails.exception is HttpException ||
              errorDetails.exception is SocketException ||
              errorDetails.exception is HandshakeException),
    );
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    crashError(error, 'Init App Services Fatal error', stack: stack);
    return true;
  };

  Get.put(AuthDetails(), permanent: true);

  return;
}
