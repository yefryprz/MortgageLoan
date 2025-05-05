import 'package:flutter/material.dart';
import 'package:mortgageloan/src/models/loan_model.dart';
import 'package:mortgageloan/src/widgets/adbanner_widget.dart';

class AmortizationPage extends StatefulWidget {
  const AmortizationPage({Key? key}) : super(key: key);

  @override
  _AmortizationPageState createState() => _AmortizationPageState();
}

class _AmortizationPageState extends State<AmortizationPage> {
  String formatCurrency(double value) {
    final pattern = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    String result = value.toStringAsFixed(2);
    result = result.replaceAllMapped(pattern, (Match m) => '${m[1]},');
    return "\$ $result";
  }

  @override
  Widget build(BuildContext context) {
    final Loan args = ModalRoute.of(context)!.settings.arguments as Loan;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Amortization Schedule"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoColumn(
                    'Loan Amount', formatCurrency(args.amount ?? 0)),
                _buildInfoColumn('Term', '${args.term} years'),
                _buildInfoColumn('Rate', '${args.rate}%'),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(10),
              physics: const BouncingScrollPhysics(),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Month')),
                      DataColumn(label: Text('Payment')),
                      DataColumn(label: Text('Principal')),
                      DataColumn(label: Text('Interest')),
                      DataColumn(label: Text('Balance')),
                    ],
                    rows: generateTable(
                        args.payment, args.amount, args.rate, args.term),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomAdBanner(),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  List<DataRow> generateTable(
      double? payment, double? amount, double? rate, int? term) {
    List<DataRow> rows = <DataRow>[];

    double balance = amount!;
    double monthlyRate = rate! / 100 / 12;
    double monthlyPayment = payment!;

    for (var month = 1; month <= term! * 12; month++) {
      // Calculate interest and principal for this period
      double interest =
          double.parse((balance * monthlyRate).toStringAsFixed(2));
      double principal =
          double.parse((monthlyPayment - interest).toStringAsFixed(2));

      // Adjust final payment if needed
      if (balance < monthlyPayment) {
        principal = balance;
        monthlyPayment = principal + interest;
      }

      // Update remaining balance
      balance = double.parse((balance - principal).toStringAsFixed(2));
      if (balance < 0) balance = 0;

      rows.add(DataRow(
        cells: <DataCell>[
          DataCell(Text(month.toString())),
          DataCell(Text(formatCurrency(monthlyPayment))),
          DataCell(Text(formatCurrency(principal))),
          DataCell(Text(formatCurrency(interest))),
          DataCell(Text(formatCurrency(balance))),
        ],
      ));

      if (balance <= 0) break;
    }
    return rows;
  }
}
