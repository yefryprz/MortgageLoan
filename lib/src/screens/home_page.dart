import 'dart:math';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:mortgageloan/src/database/load.data.dart';
import 'package:mortgageloan/src/models/Loan.model.dart';
import 'package:mortgageloan/src/widgets/card_widger.dart';
import 'package:mortgageloan/src/widgets/drawler_widget.dart';
import 'package:mortgageloan/src/widgets/input_widget.dart';

class HomePage extends StatefulWidget {

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  
  double _payment = 0;
  final amountInput = TextEditingController();
  final termInput = TextEditingController();
  final rateInput = TextEditingController();
  final loanRepo = LoanData();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Calculator"),
        actions: [
          IconButton(
            icon: Icon(Icons.cached), 
            onPressed: () {
              cleanFields(context);
            }
          )
        ],
      ),
      drawer: CustomDrawler(),
      body: Container(
        margin: EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
        child: ListView(
          children: [
            CustomInput(
              label: "Loan Amount",
              suffixIcon: Icon(Icons.attach_money),
              inputType: TextInputType.number,
              inputControl: amountInput
            ),
            SizedBox(height: 15.0),
            CustomInput(
              label: "Term (months)",
              suffixIcon: Icon(Icons.calendar_today),
              inputType: TextInputType.number,
              inputControl: termInput
            ),
            SizedBox(height: 15.0),
            CustomInput(
              label: "Interest Rate",
              suffixIcon: Icon(Icons.keyboard),
              inputType: TextInputType.number,
              inputControl: rateInput
            ),
            SizedBox(height: 15.0),
            SizedBox(
              height: 56.0,
              child: FlatButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)
                ),
                child: Text("Calculate", 
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24.0
                )),
                color: Colors.cyan,
                onPressed: () async {
                  if (await validField()) {
                    setState(() {
                        calc(double.parse(amountInput.text), int.parse(termInput.text), double.parse(rateInput.text));
                    });
                  }
                }
              ),
            ),
            Divider(),
            CustomCard(amount: _payment.toString(), acction: goToAmortization)
          ],
        ),
      ),
    );
  }

  void goToAmortization() async {
    if (await validField()) {
      Navigator.pushNamed(context, "amortization", arguments: 
      Loan(
        amount: double.parse(amountInput.text), 
        payment:_payment, 
        rate: double.parse(rateInput.text), 
        term: int.parse(termInput.text)
      ));
    }
  }

  void calc(double amount, int term, double rate) {
    var interest = rate / 100 / 12;
    var result = (1 - pow(1 + interest, term * -1)) / interest;
    this._payment = double.parse((amount / result).toStringAsFixed(2));

    loanRepo.insertRecord(Loan(
      amount: double.parse(amountInput.text), 
      payment:_payment, 
      rate: double.parse(rateInput.text), 
      term: int.parse(termInput.text)
    ));
  }

  Future<bool> validField({String message, bool showMessage = true}) async {
    if (amountInput.text.isEmpty || termInput.text.isEmpty || rateInput.text.isEmpty) {
      if (showMessage) {
        await showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Warning"),
              content: Text(message == null ? "All fields are required" : message),
              actions: [
                FlatButton(onPressed:() => Navigator.pop(context), child: Text("Ok")),
              ],
            );
          }
        );
      }
      return false;
    }
    else return true;
  }

  void cleanFields(BuildContext context) async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Confirm"),
          content: Text("Are you sure that want to clean all field ?"),
          actions: [
            FlatButton(
              onPressed: () {
                setState(() {
                  amountInput.clear();
                  termInput.clear();
                  rateInput.clear();
                  _payment = 0;
                });
                Navigator.pop(context);
              }, 
              child: Text("Yes") 
            ),
            FlatButton(
              onPressed: () {
                Navigator.pop(context);
              }, 
              child: Text("No") 
            )
          ],
        );
      }
    );
  }

}