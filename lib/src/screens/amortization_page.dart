import 'package:flutter/material.dart';
import 'package:mortgageloan/src/models/loan_model.dart';
import 'package:mortgageloan/src/widgets/adbanner_widget.dart';
import 'package:mortgageloan/src/widgets/datatable_widget.dart';

class AmortizationPage extends StatefulWidget {
  const AmortizationPage({Key? key}) : super(key: key);

  @override
  _AmortizationPageState createState() => _AmortizationPageState();
}

class _AmortizationPageState extends State<AmortizationPage> {
  @override
  Widget build(BuildContext context) {
    final Loan args = ModalRoute.of(context)!.settings.arguments as Loan;

    return Scaffold(
      appBar: AppBar(title: const Text("Amortization Table")),
      body: SingleChildScrollView(
        physics: const ScrollPhysics(),
        child: SingleChildScrollView(
            physics: const ScrollPhysics(),
            scrollDirection: Axis.horizontal,
            child: CustomDateTable(
                rowItems: generateTable(
                    args.payment, args.amount, args.rate, args.term))),
      ),
      bottomNavigationBar: CustomAdBanner(),
    );
  }

  List<DataRow> generateTable(
      double? payment, double? amount, double? rate, int? term) {
    List<DataRow> rows = <DataRow>[];

    double newInterest;
    double newCapital;
    double newRate = rate! / 100 / 12;
    double newAmount = amount!;

    for (var i = 0; i < term!; i++) {
      newInterest = double.parse((newAmount * newRate).toStringAsFixed(2));
      newCapital = double.parse((payment! - newInterest).toStringAsFixed(2));
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
