import 'dart:math';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:mortgageloan/src/database/hive.dart';
import 'package:mortgageloan/src/models/loan_model.dart';
import 'package:mortgageloan/src/widgets/adbanner_widget.dart';
import 'package:mortgageloan/src/widgets/card_widger.dart';
import 'package:mortgageloan/src/widgets/drawler_widget.dart';
import 'package:mortgageloan/src/widgets/input_widget.dart';
import 'package:upgrader/upgrader.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double _payment = 0;
  final controller = MaskedTextController(mask: '000,000,000');
  final termInput = TextEditingController();
  final rateInput = TextEditingController();
  final loanRepo = LoanData();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Calculator"),
          actions: [
            IconButton(
                icon: const Icon(Icons.cached_rounded),
                onPressed: () => cleanFields(context))
          ],
        ),
        drawer: CustomDrawler(),
        body: UpgradeAlert(
          upgrader: Upgrader(
            showIgnore: false,
            showLater: false,
          ),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            child: ListView(
              children: [
                CustomInput(
                    label: "Loan Amount",
                    suffixIcon: const Icon(Icons.attach_money),
                    inputType: TextInputType.number,
                    inputControl: controller),
                CustomInput(
                    label: "Term (months)",
                    suffixIcon: const Icon(Icons.calendar_today),
                    inputType: TextInputType.number,
                    inputControl: termInput),
                CustomInput(
                    label: "Interest Rate",
                    suffixIcon: const Icon(Icons.calculate_outlined),
                    inputType: TextInputType.number,
                    inputControl: rateInput),
                SizedBox(
                  height: 56.0,
                  child: TextButton(
                      child: const Text("Calculate",
                          style: TextStyle(color: Colors.teal, fontSize: 24.0)),
                      onPressed: () async {
                        if (await validField()) {
                          try {
                            setState(() => calc());
                          } catch (e) {
                            throw new Exception(e.toString());
                          }
                        }
                      }),
                ),
                const Divider(),
                CustomCard(
                    amount: _payment.toString(), acction: goToAmortization),
              ],
            ),
          ),
        ),
        bottomNavigationBar: CustomAdBanner());
  }

  void goToAmortization() async {
    if (await validField()) {
      Navigator.pushNamed(context, "amortization",
          arguments: Loan(
              amount: double.parse(controller.text.replaceAll(",", "")),
              payment: _payment,
              rate: double.parse(rateInput.text),
              term: int.parse(termInput.text)));
    }
  }

  void calc() {
    double amount = double.parse(controller.text.replaceAll(",", ""));
    int term = int.parse(termInput.text);
    double rate = double.parse(rateInput.text);

    var interest = rate / 100 / 12;
    var result = (1 - pow(1 + interest, term * -1)) / interest;
    _payment = double.parse((amount / result).toStringAsFixed(2));

    loanRepo.insertRecord(Loan(
        amount: double.parse(controller.text.replaceAll(",", "")),
        payment: _payment,
        rate: double.parse(rateInput.text),
        term: int.parse(termInput.text)));
  }

  Future<bool> validField({String? message, bool showMessage = true}) async {
    if (controller.text.isEmpty ||
        termInput.text.isEmpty ||
        rateInput.text.isEmpty) {
      if (showMessage) {
        await showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("Warning"),
                content: Text(message ?? "All fields are required"),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Ok"))
                ],
              );
            });
      }
      return false;
    } else {
      return true;
    }
  }

  void cleanFields(BuildContext context) {
    setState(() {
      controller.clear();
      termInput.clear();
      rateInput.clear();
      _payment = 0;
    });
  }
}
