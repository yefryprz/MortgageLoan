import 'dart:math';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart' as intl;
import 'package:mortgageloan/src/database/hive.dart';
import 'package:mortgageloan/src/models/loan_model.dart';
import 'package:mortgageloan/src/widgets/adbanner_widget.dart';
import 'package:mortgageloan/src/widgets/drawer_widget.dart';
import 'package:upgrader/upgrader.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _loanAmountController = TextEditingController();
  double _payment = 0;
  double _loanAmount = 0;
  int _loanPeriod = 5;
  double _interestRate = 10.0;
  double _totalInterest = 0.0;

  final loanRepo = LoanData();
  final _currencyFormat = intl.NumberFormat.currency(
    locale: 'id',
    symbol: '\$ ',
    decimalDigits: 2,
  );
  final _numberFormat = intl.NumberFormat("#,###", "en_US");

  InterstitialAd? _interstitialAd;

  @override
  void initState() {
    super.initState();
    _loanAmountController.text = _numberFormat.format(_loanAmount);
    _loadInterstitialAd();
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    _loanAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final upgrader = UpgradeAlert(
      upgrader: Upgrader(),
      child: Scaffold(
        key: _scaffoldKey,
        drawer: CustomDrawer(),
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.menu),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          title: const Text("Loan Calculator"),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Loan Amount Card
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: _buildSliderSection(
                  title: 'Loan Amount',
                  value: _loanAmount,
                  formattedValue: _currencyFormat.format(_loanAmount),
                  min: 0,
                  max: 100000000, // Fixed maximum value
                  divisions: 1000000,
                  onChanged: (value) {
                    setState(() {
                      _loanAmount = value;
                      calc();
                    });
                  },
                ),
              ),

              SizedBox(height: 24),

              // Interest Rate Card
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: _buildSliderSection(
                  title: 'Interest Rate',
                  value: _interestRate,
                  formattedValue: '${_interestRate.toStringAsFixed(1)}%',
                  min: 1,
                  max: 30,
                  divisions: 290,
                  onChanged: (value) {
                    setState(() {
                      _interestRate = value;
                      calc();
                    });
                  },
                ),
              ),

              SizedBox(height: 24),

              // Loan Period Card
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: _buildSliderSection(
                  title: 'Loan Period',
                  value: _loanPeriod.toDouble(),
                  formattedValue: '$_loanPeriod Years',
                  min: 1,
                  max: 40,
                  divisions: 40,
                  onChanged: (value) {
                    setState(() {
                      _loanPeriod = value.round();
                      calc();
                    });
                  },
                ),
              ),

              SizedBox(height: 32),

              // Monthly Payment Section
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Estimated monthly installments',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      _currencyFormat.format(_payment),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Installment fees may change according to the verification results',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              // Apply Loan Button
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => goToAmortization(),
                  child: Text(
                    'Generate Amortization',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: CustomAdBanner(),
      ),
    );

    return upgrader;
  }

  String _digits(String value) {
    return value.replaceAll(RegExp(r'[^\d]'), '');
  }

  Widget _buildSliderSection({
    required String title,
    required double value,
    required String formattedValue,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
    int? divisions,
  }) {
    if (title == 'Loan Amount') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          TextField(
            controller: _loanAmountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              prefixText: '\$ ',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onTap: () {
              // Select all text when focused
              _loanAmountController.selection = TextSelection(
                baseOffset: 0,
                extentOffset: _loanAmountController.text.length,
              );
            },
            onChanged: (value) {
              if (value.isEmpty) {
                setState(() {
                  _loanAmount = 0;
                  calc();
                });

                return;
              }

              String digitsOnly = _digits(value);
              if (digitsOnly.isEmpty) return;

              double amount = double.parse(digitsOnly);
              if (amount > max) amount = max;

              setState(() {
                _loanAmount = amount;
                _loanAmountController.text = _numberFormat.format(amount);
                calc();
              });
            },
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: Colors.teal,
              inactiveTrackColor: Colors.grey[200],
              thumbColor: Colors.white,
              overlayColor: Colors.teal.withOpacity(0.1),
              trackHeight: 4.0,
              thumbShape: RoundSliderThumbShape(
                enabledThumbRadius: 12,
                elevation: 4,
              ),
              overlayShape: RoundSliderOverlayShape(overlayRadius: 24),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: (newValue) {
                setState(() {
                  _loanAmount = newValue;
                  _loanAmountController.text = _numberFormat.format(newValue);
                  calc();
                });
              },
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        Text(
          formattedValue,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: Colors.teal,
            inactiveTrackColor: Colors.grey[200],
            thumbColor: Colors.white,
            overlayColor: Colors.teal.withOpacity(0.1),
            trackHeight: 4.0,
            thumbShape: RoundSliderThumbShape(
              enabledThumbRadius: 12,
              elevation: 4,
            ),
            overlayShape: RoundSliderOverlayShape(overlayRadius: 24),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: "",
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              _interstitialAd = null;
              loanRepo.resetAdCount();
              _loadInterstitialAd(); // Load the next ad
            },
          );
        },
        onAdFailedToLoad: (err) {
          print('Failed to load an interstitial ad: ${err.message}');
          _interstitialAd = null;
        },
      ),
    );
  }

  Future<void> _showInterstitialAd() async {
    if (_interstitialAd == null) {
      print('Warning: attempt to show interstitial before loaded.');
      return;
    }

    try {
      await _interstitialAd!.show();
    } catch (e) {
      print('Error showing interstitial ad: $e');
      _loadInterstitialAd(); // Try to load next ad
    }
  }

  void goToAmortization() async {
    if (await validField()) {
      var qty = await loanRepo.getAdCount();

      final loan = Loan(
        amount: _loanAmount,
        payment: _payment,
        rate: _interestRate,
        term: _loanPeriod,
        totalInterest: _totalInterest,
      );

      if (qty >= 3) {
        if (_interstitialAd != null) {
          await _showInterstitialAd();
        } else {
          loanRepo.resetAdCount();
        }
      } else {
        loanRepo.AdCountUp();
      }

      loanRepo.insertRecord(loan);
      Navigator.pushNamed(context, "amortization", arguments: loan);
    }
  }

  void calc() {
    try {
      // Convert annual rate to monthly rate (e.g. 10% -> 0.00833)
      var monthlyRate = _interestRate / 100 / 12;

      // Convert years to months (e.g. 30 years -> 360 months)
      var totalMonths = _loanPeriod * 12;

      // Calculate monthly payment using mortgage formula
      var monthlyPayment = _loanAmount *
          (monthlyRate * pow(1 + monthlyRate, totalMonths)) /
          (pow(1 + monthlyRate, totalMonths) - 1);

      // Calculate total interest
      var totalAmount = monthlyPayment * totalMonths;
      var totalInterest = totalAmount - _loanAmount;

      setState(() {
        _payment = monthlyPayment;
        _totalInterest = totalInterest;
      });
    } catch (e) {
      print('Error calculating payment: $e');
      _payment = 0;
      _totalInterest = 0;
    }
  }

  Future<bool> validField({String? message, bool showMessage = true}) async {
    if (_loanAmount <= 0 || _loanPeriod <= 0) {
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
      _loanAmount = 0;
      _loanPeriod = 0;
      _payment = 0;
    });
  }
}
