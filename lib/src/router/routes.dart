import 'package:flutter/material.dart';
import 'package:mortgageloan/src/screens/amortization_page.dart';
import 'package:mortgageloan/src/screens/history_page.dart';
import 'package:mortgageloan/src/screens/home_page.dart';

Map<String, WidgetBuilder> routes(){
  return <String, WidgetBuilder>{
    "/" : (BuildContext contet) => HomePage(),
    "amortization": (BuildContext context) => AmortizationPage(),
    "history": (BuildContext context) => HistoryPage()
  };
}