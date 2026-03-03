import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mortgageloan/src/widgets/adbanner_widget.dart';

class CompoundRow {
  final int year;
  final double startBalance;
  final double interest;
  final double endBalance;

  CompoundRow(this.year, this.startBalance, this.interest, this.endBalance);
}

class CompoundBreakdownPage extends StatelessWidget {
  const CompoundBreakdownPage({Key? key}) : super(key: key);

  String formatCurrencyWhole(double value) {
    if (value < 0) value = 0;
    final formatter =
        NumberFormat.currency(locale: 'en_US', symbol: '\$', decimalDigits: 0);
    return formatter.format(value);
  }

  String formatCurrencyShort(double value) {
    if (value < 0) value = 0;
    final formatter = NumberFormat.compactCurrency(
        locale: 'en_US', symbol: '\$', decimalDigits: 2);
    return formatter.format(value);
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final double principal = args['principal'] as double;
    final double rate = args['rate'] as double;
    final double result = args['result'] as double;
    final List<CompoundRow> allRows =
        (args['yearlyDetails'] as List).map((row) {
      return CompoundRow(
        row['year'] as int,
        row['startBalance'] as double,
        row['interest'] as double,
        row['endBalance'] as double,
      );
    }).toList();

    double totalInterest = result - principal;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F9),
      bottomNavigationBar: CustomAdBanner(),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Column(
                  children: [
                    const SizedBox(height: 60),
                    Expanded(child: _buildTableSection(allRows)),
                  ],
                ),
                Positioned(
                  top: -25, // Move summary bar up visually
                  left: 0,
                  right: 0,
                  child:
                      _buildSummaryBar(principal, rate, totalInterest, result),
                ),
              ],
            ),
          ),
          _buildExportButton(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 45, left: 20, right: 20, bottom: 45),
      decoration: const BoxDecoration(
        color: Color(0xFF3ac0b5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const Text(
            "Yearly Breakdown",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(width: 48), // Balance alignment
        ],
      ),
    );
  }

  Widget _buildSummaryBar(
      double principal, double rate, double interest, double result) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildSummaryColumn("INITIAL", formatCurrencyShort(principal)),
          Container(
              width: 1, height: 40, color: Colors.grey.withValues(alpha: 0.2)),
          _buildSummaryColumn("INTEREST", "+${formatCurrencyShort(interest)}",
              color: const Color(0xFF3ac0b5)),
          Container(
              width: 1, height: 40, color: Colors.grey.withValues(alpha: 0.2)),
          _buildSummaryColumn("BALANCE", formatCurrencyShort(result)),
        ],
      ),
    );
  }

  Widget _buildSummaryColumn(String label, String value, {Color? color}) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1)),
        const SizedBox(height: 8),
        Text(value,
            style: TextStyle(
                color: color ?? const Color(0xFF0F172A),
                fontSize: 16,
                fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildTableSection(List<CompoundRow> allRows) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      // No extra clipping or decoration, let table scroll smoothly
      child: Column(
        children: [
          // Fixed Header
          Table(
            columnWidths: const {
              0: FlexColumnWidth(1),
              1: FlexColumnWidth(2),
              2: FlexColumnWidth(2),
            },
            children: [
              TableRow(
                decoration: const BoxDecoration(
                    border: Border(
                  bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
                )),
                children:
                    ['YEAR', 'BALANCE', 'ACCUMULATED INTEREST'].map((label) {
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                      textAlign:
                          label == 'YEAR' ? TextAlign.left : TextAlign.right,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          // Scrollable Data
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 20),
              physics: const BouncingScrollPhysics(),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Table(
                  columnWidths: const {
                    0: FlexColumnWidth(1),
                    1: FlexColumnWidth(2),
                    2: FlexColumnWidth(2),
                  },
                  children: allRows.map((r) {
                    double cumulativeInterest =
                        r.endBalance - allRows.first.startBalance;
                    return TableRow(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                              color: const Color(0xFFF1F5F9), width: 1),
                        ),
                      ),
                      children: [
                        _tableCell(r.year.toString(),
                            bold: true, align: TextAlign.left),
                        _tableCell(formatCurrencyWhole(r.endBalance),
                            color: const Color(0xFF64748B),
                            align: TextAlign.right),
                        _tableCell(
                            "+${formatCurrencyWhole(cumulativeInterest)}",
                            color: const Color(0xFF3ac0b5),
                            bold: true,
                            align: TextAlign.right),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tableCell(String text,
      {Color? color, bool bold = false, TextAlign align = TextAlign.center}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Text(
        text,
        style: TextStyle(
          color: color ?? const Color(0xFF0F172A),
          fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
          fontSize: 13,
        ),
        textAlign: align,
      ),
    );
  }

  Widget _buildExportButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30, top: 10),
      child: TextButton.icon(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('CSV export not implemented yet.')),
          );
        },
        icon: const Icon(Icons.download_outlined,
            color: Color(0xFF3ac0b5), size: 20),
        label: const Text(
          "Export as CSV",
          style: TextStyle(
            color: Color(0xFF3ac0b5),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
