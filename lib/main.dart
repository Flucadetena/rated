import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:labhouse/controllers/rankings.dart';
import 'package:labhouse/init.dart';
import 'package:labhouse/screens/home.dart';
import 'package:labhouse/screens/welcome.dart';
import 'package:labhouse/services/theme.dart';

void main() async {
  await initAppServices();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool loadedRankings = false;

  @override
  Widget build(BuildContext context) {
    /// Forces app to be in portrait mode, only for Android.
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: darkTheme,
      home: GetBuilder<RankingsDetails>(
        init: RankingsDetails(),
        builder: (details) {
          if (!loadedRankings && details.rankings != null) {
            FlutterNativeSplash.remove();
          }
          return switch (details.rankings) {
            null => SizedBox(),
            [] => WelcomeScreen(),
            _ => HomeScreen(),
          };
        },
      ),
    );
  }
}
