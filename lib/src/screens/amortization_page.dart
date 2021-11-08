import 'package:flutter/material.dart';
import 'package:mortgageloan/src/models/Loan_model.dart';
import 'package:mortgageloan/src/widgets/datatable_widget.dart';

class AmortizationPage extends StatefulWidget {
  AmortizationPage({Key key}) : super(key: key);

  @override
  _AmortizationPageState createState() => _AmortizationPageState();
}

class _AmortizationPageState extends State<AmortizationPage> {
  @override
  Widget build(BuildContext context) {
    final Loan args = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      appBar: AppBar(title: Text("Amortization Table")),
      body: SingleChildScrollView(
        physics: ScrollPhysics(),
        child: SingleChildScrollView(
          physics: ScrollPhysics(),
          scrollDirection: Axis.horizontal,
          child: CustomDateTable(
            rowItems: generateTable(
              args.payment, 
              args.amount, 
              args.rate, 
              args.term
            )
          )
        ),
      )
    );
  }

  List<DataRow> generateTable(double payment, double amount, double rate, int term) {
    List<DataRow> rows = <DataRow>[];

    double newInterest;
    double newCapital;
    double newRate = rate / 100 / 12;
    double newAmount = amount;

    for (var i = 0; i < term; i++) {
      newInterest = double.parse((newAmount * newRate).toStringAsFixed(2));
      newCapital = double.parse((payment - newInterest).toStringAsFixed(2));
      newAmount = double.parse((newAmount - newCapital).toStringAsFixed(2));

      if (newAmount <= 0) newAmount = 0;

      rows.add(DataRow(
        cells: <DataCell>[
          DataCell(Text((i + 1).toString())),
          DataCell(Text(newInterest.toString())),
          DataCell(Text(newCapital.toString())),
          DataCell(Text(newAmount.toString()))
        ],
      ));
    }
    return rows;
  }
}