import 'dart:math';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:mortgageloan/src/models/LoanData.dart';
import 'package:mortgageloan/src/widgets/card_widger.dart';
import 'package:mortgageloan/src/widgets/input_widget.dart';

class HomePage extends StatefulWidget {

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  
  double _payment = 0;
  final amountInput = new TextEditingController();
  final termInput = new TextEditingController();
  final rateInput = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan,
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
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
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
                onPressed: (){
                  setState(() {
                    calc(double.parse(amountInput.text), int.parse(termInput.text), double.parse(rateInput.text));
                  });
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

  void goToAmortization(){
    Navigator.pushNamed(context, "amortization", arguments: LoanData(double.parse(amountInput.text), _payment, double.parse(rateInput.text), int.parse(termInput.text)));
  }

  void calc(double amount, int term, double rate) async {

    if (amount == 0 || term == 0 || rate == 0) {
      await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Warning"),
            content: Text("All fields are required"),
            actions: [
              FlatButton(onPressed:() => Navigator.pop(context), child: Text("Ok")),
            ],
          );
        }
      );
      return;
    }

    var interest = rate / 100 / 12;
    var result = (1 - pow(1 + interest, term * -1)) / interest;
    this._payment = double.parse((amount / result).toStringAsFixed(2));
  }

  void cleanFields(BuildContext context) {
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