import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import 'package:mortgageloan/src/database/loan_repository.dart';
import 'package:mortgageloan/src/models/loan_model.dart';
import 'package:mortgageloan/src/router/routes.dart';
import 'package:mortgageloan/src/utils/loan_calculator.dart';
import 'package:mortgageloan/src/widgets/adbanner_widget.dart';
import 'package:mortgageloan/src/widgets/custom_slider.dart';
import 'package:mortgageloan/src/widgets/drawer_widget.dart';
import 'package:upgrader/upgrader.dart';
import 'package:mortgageloan/src/utils/interstitial_ad_helper.dart';
import 'package:mortgageloan/src/services/analytics_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _loanAmountController = TextEditingController();
  final TextEditingController _interestRateController = TextEditingController();
  final TextEditingController _loanPeriodController = TextEditingController();

  double _payment = 21247.04; // default match image
  double _loanAmount = 1000000;
  int _loanPeriod = 5;
  double _interestRate = 10.0;
  double _totalInterest = 0.0;

  final LoanRepository loanRepo = LoanRepository();
  final _currencyFormat = intl.NumberFormat.currency(
    locale: 'en_US',
    symbol: '\$',
    decimalDigits: 2,
  );
  final _numberFormat = intl.NumberFormat("#,###", "en_US");

  late final InterstitialAdHelper _adHelper;

  @override
  void initState() {
    super.initState();
    _loanAmountController.text = _numberFormat.format(_loanAmount);
    _interestRateController.text = _interestRate.toStringAsFixed(2);
    _loanPeriodController.text = _loanPeriod.toString();
    calc();
    _adHelper =
        InterstitialAdHelper(adCountKey: "amortizationCount", adFrequency: 2);
    _adHelper.load();
  }

  @override
  void dispose() {
    _adHelper.dispose();
    _loanAmountController.dispose();
    _interestRateController.dispose();
    _loanPeriodController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final upgrader = UpgradeAlert(
      upgrader: Upgrader(debugLogging: true),
      child: Scaffold(
        key: _scaffoldKey,
        drawerEnableOpenDragGesture: false,
        drawer: const CustomDrawer(currentRoute: AppRoutes.home),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF6F8F9),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.menu, color: Color(0xFF2C3E50)),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          title: const Text(
            "Loan Calculator",
            style: TextStyle(
              color: Color(0xFF2C3E50),
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.history, color: Color(0xFF2C3E50)),
              onPressed: () => context.push(AppRoutes.history),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Loan Amount Card
              _buildCard(child: _buildAmountSection()),
              const SizedBox(height: 16),

              // Interest Rate Card
              _buildCard(child: _buildInterestSection()),
              const SizedBox(height: 16),

              // Loan Period Card
              _buildCard(child: _buildPeriodSection()),
              const SizedBox(height: 24),

              // Estimated Monthly Installment
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF40E0D0).withValues(alpha: 0.05),
                      spreadRadius: 5,
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'Estimated Monthly Installment',
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _currencyFormat.format(_payment),
                      style: const TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF32D3B8),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Fees and taxes may apply based\non your region.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Generate Button
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () => goToAmortization(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF32D3B8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 4,
                    shadowColor: const Color(0xFF32D3B8).withValues(alpha: 0.4),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Generate Amortization Schedule',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
        bottomNavigationBar: const CustomAdBanner(),
      ),
    );

    return upgrader;
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            spreadRadius: 0,
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildAmountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Loan Amount',
          style: TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Text(
                '\$',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF9CA3AF),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _loanAmountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (value) {
                    final String clean = value.replaceAll(RegExp(r'[^0-9]'), '');
                    if (clean.isEmpty) {
                      _loanAmount = 0;
                    } else {
                      _loanAmount = double.parse(clean);
                      if (_loanAmount > 5000000) _loanAmount = 5000000;
                    }
                    setState(() {
                      calc();
                    });
                  },
                  onSubmitted: (value) {
                    _loanAmountController.text = _numberFormat.format(
                      _loanAmount,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _buildCustomSlider(
          value: _loanAmount,
          min: 1000,
          max: 5000000,
          onChanged: (val) {
            setState(() {
              _loanAmount = val;
              _loanAmountController.text = _numberFormat.format(val);
              calc();
            });
          },
        ),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '\$1k',
              style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
            ),
            Text(
              '\$5M',
              style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInterestSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Interest Rate',
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            Container(
              width: 100,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _interestRateController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF32D3B8),
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (value) {
                        double? val = double.tryParse(value);
                        if (val != null) {
                          if (val > 20) val = 20;
                          if (val < 1) val = 1;
                          _interestRate = val;
                          setState(() {
                            calc();
                          });
                        }
                      },
                      onSubmitted: (value) {
                        _interestRateController.text =
                            _interestRate.toStringAsFixed(2);
                      },
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    '%',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildCustomSlider(
          value: _interestRate,
          min: 1,
          max: 20,
          onChanged: (val) {
            setState(() {
              _interestRate = val;
              _interestRateController.text = val.toStringAsFixed(2);
              calc();
            });
          },
        ),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '1%',
              style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
            ),
            Text(
              '20%',
              style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPeriodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Loan Period',
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            Container(
              width: 120,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _loanPeriodController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (value) {
                        int? val = int.tryParse(value);
                        if (val != null) {
                          if (val > 30) val = 30;
                          if (val < 1) val = 1;
                          _loanPeriod = val;
                          setState(() {
                            calc();
                          });
                        }
                      },
                      onSubmitted: (value) {
                        _loanPeriodController.text = _loanPeriod.toString();
                      },
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Years',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildCustomSlider(
          value: _loanPeriod.toDouble(),
          min: 1,
          max: 30,
          onChanged: (val) {
            setState(() {
              _loanPeriod = val.round();
              _loanPeriodController.text = _loanPeriod.toString();
              calc();
            });
          },
        ),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '1 Yr',
              style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
            ),
            Text(
              '30 Yrs',
              style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCustomSlider({
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return SliderTheme(
      data: SliderThemeData(
        activeTrackColor: const Color(0xFFE5E7EB), // grey base
        inactiveTrackColor: const Color(0xFFE5E7EB),
        trackHeight: 4.0,
        thumbShape: const CustomThumbShape(
          color: Color(0xFF32D3B8),
        ), // teal outline thumb
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
        trackShape: CustomTrackShape(
          progress: (value - min) / (max - min),
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: Slider(
        value: value.clamp(min, max),
        min: min,
        max: max,
        onChanged: onChanged,
      ),
    );
  }

  void goToAmortization() async {
    if (await validField()) {
      final loan = Loan(
        amount: _loanAmount,
        payment: _payment,
        rate: _interestRate,
        term: _loanPeriod,
        totalInterest: _totalInterest,
      );

      AnalyticsService.logEvent(
        'amortization_generated',
        parameters: {
          'amount': _loanAmount,
          'rate': _interestRate,
          'term': _loanPeriod,
        },
      );

      loanRepo.insertRecord(loan);
      _adHelper.handleAdDetailNavigation(() {
        context.push(AppRoutes.amortization, extra: loan);
      });
    }
  }

  void calc() {
    try {
      if (_loanAmount <= 0 || _loanPeriod <= 0 || _interestRate <= 0) {
        _payment = 0;
        _totalInterest = 0;
        return;
      }

      final monthlyPayment = LoanCalculator.calculateMonthlyPayment(
        amount: _loanAmount,
        rate: _interestRate,
        termYears: _loanPeriod,
      );

      final totalInterest = LoanCalculator.calculateTotalInterest(
        monthlyPayment: monthlyPayment,
        termYears: _loanPeriod,
        amount: _loanAmount,
      );

      _payment = monthlyPayment;
      _totalInterest = totalInterest;
    } catch (e) {
      _payment = 0;
      _totalInterest = 0;
    }
  }

  Future<bool> validField({String? message, bool showMessage = true}) async {
    if (_loanAmount <= 0 || _loanPeriod <= 0 || _interestRate <= 0) {
      if (showMessage) {
        await showDialog<void>(
          barrierDismissible: false,
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Warning"),
              content: Text(
                message ?? "All fields are required and must be greater than 0",
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Ok"),
                ),
              ],
            );
          },
        );
      }
      return false;
    }
    return true;
  }
}
