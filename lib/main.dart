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
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("DotEnv initialization failed: $e");
  }

  try {
    unawaited(MobileAds.instance.initialize());
  } catch (e) {
    debugPrint("MobileAds initialization failed: $e");
  }

  try {
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
  } catch (e) {
    debugPrint("Firebase initialization failed: $e");
    // Fallback: simple error logging if Firebase is not available
    FlutterError.onError = (errorDetails) {
      debugPrint("Flutter Error: ${errorDetails.exception}");
    };
  }

  await Upgrader.clearSavedSettings();

  await Hive.initFlutter();
  await Hive.openBox("loan");
  await Hive.openBox("compound_interest");
  await Hive.openBox("ai_analysis");
  await Hive.openBox("ai_usage");
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
