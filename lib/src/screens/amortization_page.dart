import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mortgageloan/src/models/loan_model.dart';
import 'package:mortgageloan/src/widgets/adbanner_widget.dart';

class AmortizationRow {
  final int month;
  final double payment;
  final double principal;
  final double interest;
  final double balance;
  AmortizationRow(
      this.month, this.payment, this.principal, this.interest, this.balance);
}

class AmortizationPage extends StatefulWidget {
  const AmortizationPage({Key? key}) : super(key: key);

  @override
  _AmortizationPageState createState() => _AmortizationPageState();
}

class _AmortizationPageState extends State<AmortizationPage> {
  int _currentPage = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String formatCurrency(double value) {
    if (value < 0) value = 0;
    final formatter =
        NumberFormat.currency(locale: 'en_US', symbol: '', decimalDigits: 2);
    return formatter.format(value);
  }

  String formatCurrencyWhole(double value) {
    if (value < 0) value = 0;
    final formatter =
        NumberFormat.currency(locale: 'en_US', symbol: '\$', decimalDigits: 0);
    return formatter.format(value);
  }

  List<AmortizationRow> _generateRows(
      double monthlyPayment, double amount, double rate, int termMonths) {
    List<AmortizationRow> rows = [];
    double balance = amount;
    double monthlyRate = rate / 100 / 12;

    for (var month = 1; month <= termMonths; month++) {
      double interest =
          double.parse((balance * monthlyRate).toStringAsFixed(2));
      double principal =
          double.parse((monthlyPayment - interest).toStringAsFixed(2));

      if (balance < monthlyPayment) {
        principal = balance;
        monthlyPayment = principal + interest;
      }

      balance = double.parse((balance - principal).toStringAsFixed(2));
      if (balance < 0) balance = 0;

      rows.add(
          AmortizationRow(month, monthlyPayment, principal, interest, balance));

      if (balance <= 0) break;
    }
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    final Loan args = ModalRoute.of(context)!.settings.arguments as Loan;

    double totalInterest = args.totalInterest ?? 0;
    double principal = args.amount ?? 0;
    double totalPaid = principal + totalInterest;

    int totalMonths = (args.term ?? 0) * 12;
    int totalYears = args.term ?? 0;
    List<AmortizationRow> allRows = _generateRows(
        args.payment ?? 0, principal, args.rate ?? 0, totalMonths);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F9),
      body: Column(
        children: [
          _buildHeader(context, principal, totalInterest, totalPaid),
          Expanded(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Column(
                  children: [
                    const SizedBox(
                        height:
                            60), // Further reduced space before 'MONTHLY BREAKDOWN'
                    Expanded(child: _buildTableSection(allRows, totalYears)),
                  ],
                ),
                Positioned(
                  top: -25, // Move summary bar up visually
                  left: 0,
                  right: 0,
                  child: _buildSummaryBar(totalMonths, args.rate ?? 0),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomAdBanner(),
    );
  }

  Widget _buildHeader(BuildContext context, double principal, double interest,
      double totalPaid) {
    return Container(
      padding: const EdgeInsets.only(top: 45, left: 20, right: 20, bottom: 35),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF3ac0b5), Color(0xFF27a9bf)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const Text(
                "AMORTIZATION SCHEDULE",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 1.2,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Share logic not implemented yet.')),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("TOTAL EXPECTED",
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1)),
                  const SizedBox(height: 4),
                  Text(formatCurrencyWhole(totalPaid),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("LOAN AMOUNT",
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1)),
                  const SizedBox(height: 4),
                  Text(formatCurrencyWhole(principal),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: 1.0, // Static indication per mockup simplified semantics
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("TOTAL PRINCIPAL",
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(formatCurrencyWhole(principal),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("TOTAL INTEREST",
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(formatCurrencyWhole(interest),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryBar(int termMonths, double rate) {
    DateTime now = DateTime.now();
    DateTime payoff =
        DateTime(now.year + (termMonths ~/ 12), now.month + (termMonths % 12));
    String payoffStr = DateFormat('MMM yyyy').format(payoff);

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
          _buildSummaryColumn("TERM", "$termMonths Mo"),
          Container(
              width: 1, height: 40, color: Colors.grey.withValues(alpha: 0.2)),
          _buildSummaryColumn("RATE", "${rate.toStringAsFixed(2)}%",
              color: const Color(0xFF3ac0b5)),
          Container(
              width: 1, height: 40, color: Colors.grey.withValues(alpha: 0.2)),
          _buildSummaryColumn("PAYOFF", payoffStr),
        ],
      ),
    );
  }

  Widget _buildSummaryColumn(String label, String value, {Color? color}) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1)),
        const SizedBox(height: 8),
        Text(value,
            style: TextStyle(
                color: color ?? const Color(0xFF2C3E50),
                fontSize: 16,
                fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildTableSection(List<AmortizationRow> allRows, int totalYears) {
    if (totalYears == 0) totalYears = 1;
    return Column(
      children: [
        Padding(
          padding:
              const EdgeInsets.only(left: 24, right: 24, top: 0, bottom: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "MONTHLY BREAKDOWN",
                style: TextStyle(
                    color: Color(0xFF2C3E50),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1),
              ),
              TextButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('CSV download logical not implemented yet.')),
                  );
                },
                icon: const Icon(Icons.download,
                    size: 16, color: Color(0xFF3ac0b5)),
                label: const Text("CSV",
                    style: TextStyle(
                        color: Color(0xFF3ac0b5), fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            physics:
                const AlwaysScrollableScrollPhysics(), // Ensure slide works
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: totalYears,
            itemBuilder: (context, pageIndex) {
              int startRow = pageIndex * 12;
              int endRow = startRow + 12;
              if (endRow > allRows.length) endRow = allRows.length;
              List<AmortizationRow> pageRows =
                  allRows.sublist(startRow, endRow);

              return _buildPageTable(pageRows);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 20, top: 10),
          child: Column(
            children: [
              Text(
                "YEAR ${_currentPage + 1} OF $totalYears",
                style: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  totalYears > 10 ? 10 : totalYears, // limit dots if many years
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 10 : 8,
                    height: _currentPage == index ? 10 : 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentPage == index
                          ? const Color(0xFF3ac0b5)
                          : const Color(0xFF3ac0b5).withValues(alpha: 0.3),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPageTable(List<AmortizationRow> rows) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            spreadRadius: 2,
            blurRadius: 10,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            // Fixed Header
            Table(
              columnWidths: const {
                0: FlexColumnWidth(1),
                1: FlexColumnWidth(2),
                2: FlexColumnWidth(2),
                3: FlexColumnWidth(2),
                4: FlexColumnWidth(2),
              },
              children: [
                TableRow(
                  decoration: const BoxDecoration(color: Color(0xFFFAFBFC)),
                  children: [
                    'MO',
                    'PAYMENT',
                    'PRINCIPAL',
                    'INTEREST',
                    'BALANCE'
                  ].map((label) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 8),
                      child: Text(
                        label,
                        style: const TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            // Scrollable Data
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Table(
                  columnWidths: const {
                    0: FlexColumnWidth(1),
                    1: FlexColumnWidth(2),
                    2: FlexColumnWidth(2),
                    3: FlexColumnWidth(2),
                    4: FlexColumnWidth(2),
                  },
                  children: rows.map((r) {
                    return TableRow(
                      children: [
                        _tableCell(r.month.toString().padLeft(2, '0'),
                            color: const Color(0xFF3ac0b5), bold: true),
                        _tableCell(formatCurrency(r.payment), bold: true),
                        _tableCell(formatCurrency(r.principal),
                            color: Colors.blueAccent),
                        _tableCell(formatCurrency(r.interest),
                            color: Colors.deepPurpleAccent),
                        _tableCell(formatCurrency(r.balance),
                            bold: true, fontSize: 13),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tableCell(String text,
      {Color? color, bool bold = false, double fontSize = 12}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: Text(
        text,
        style: TextStyle(
          color: color ?? const Color(0xFF2C3E50),
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          fontSize: fontSize,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
