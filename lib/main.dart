import 'dart:async';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mortgageloan/firebase_options.dart';
import 'package:mortgageloan/src/router/routes.dart';
import 'package:upgrader/upgrader.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  unawaited(MobileAds.instance.initialize());

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  await Upgrader.clearSavedSettings();

  await Hive.initFlutter();
  await Hive.openBox("loan");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
            useMaterial3: true,
            primaryColor: Colors.cyan,
            appBarTheme: const AppBarTheme(
              centerTitle: true,
              backgroundColor: Colors.cyan,
              actionsIconTheme: IconThemeData(color: Colors.white),
              iconTheme: IconThemeData(color: Colors.white),
            ),
            primaryTextTheme:
                const TextTheme(titleLarge: TextStyle(color: Colors.white))),
        debugShowCheckedModeBanner: false,
        title: 'Mortgage Loan',
        routes: routes(),
        initialRoute: "/");
  }
}
