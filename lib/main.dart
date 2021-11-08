import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mortgageloan/src/router/routes.dart';

void main() async {
  await Hive.initFlutter();
  await Hive.openBox("loan");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          primaryColor: Colors.cyan,
          appBarTheme: AppBarTheme(
            centerTitle: true,
            backgroundColor: Colors.cyan,
            actionsIconTheme: IconThemeData(color: Colors.white),
            iconTheme: IconThemeData(color: Colors.white),
          ),
          primaryTextTheme:
              TextTheme(headline6: TextStyle(color: Colors.white))),
      debugShowCheckedModeBanner: false,
      title: 'Mortgage Loan',
      routes: routes(),
      initialRoute: "/"
    );
  }
}
