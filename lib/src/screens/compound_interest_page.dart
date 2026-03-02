import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:mortgageloan/src/database/hive.dart';
import 'package:mortgageloan/src/models/compound_interest_model.dart';
import 'package:mortgageloan/src/widgets/adbanner_widget.dart';
import 'package:mortgageloan/src/widgets/drawer_widget.dart'; // Fix import path
import 'package:google_mobile_ads/google_mobile_ads.dart';

class CompoundInterestPage extends StatefulWidget {
  @override
  _CompoundInterestPageState createState() => _CompoundInterestPageState();
}

class _CompoundInterestPageState extends State<CompoundInterestPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _principalController = TextEditingController();
  double _principal = 0;
  double _rate = 5.0;
  int _years = 5;
  double _result = 0;
  List<Map<String, dynamic>> _yearlyDetails = [];

  final _currencyFormat = intl.NumberFormat.currency(
    locale: 'id',
    symbol: '\$ ',
    decimalDigits: 2,
  );

  InterstitialAd? _interstitialAd;
  final loanRepo = LoanData();
  int _calcCounter = 0;
  static const String CALC_COUNTER_KEY = 'compound_calc_counter';

  @override
  void initState() {
    super.initState();
    _loadInterstitialAd();
    _loadCalcCounter();
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    super.dispose();
  }

  Future<void> _loadCalcCounter() async {
    _calcCounter = await loanRepo.getValue(CALC_COUNTER_KEY) ?? 0;
  }

  Future<void> _saveCalcCounter() async {
    await loanRepo.setValue(CALC_COUNTER_KEY, _calcCounter);
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
              _calcCounter = 0;
              _saveCalcCounter();
              _loadInterstitialAd();
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
      _loadInterstitialAd();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: CustomDrawer(), // Fix class name
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text("Compound Interest"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Principal Amount
            buildInputSection(
              'Principal Amount',
              _principalController,
              _principal,
              0,
              100000000,
              (value) {
                setState(() {
                  _principal = value;
                  calculate();
                });
              },
            ),

            SizedBox(height: 24),

            // Interest Rate
            buildSliderSection(
              'Interest Rate',
              _rate,
              '${_rate.toStringAsFixed(1)}%',
              1,
              30,
              290,
              (value) {
                setState(() {
                  _rate = value;
                  calculate();
                });
              },
            ),

            SizedBox(height: 24),

            // Time Period
            buildSliderSection(
              'Time Period',
              _years.toDouble(),
              '$_years Years',
              1,
              30,
              29,
              (value) {
                setState(() {
                  _years = value.round();
                  calculate();
                });
              },
            ),

            SizedBox(height: 32),

            // Result Section
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
                    'Final Amount',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    _currencyFormat.format(_result),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 32),

            // Investment Table
            if (_yearlyDetails.isNotEmpty) ...[
              Text(
                'Investment Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    DataColumn(label: Text('Year')),
                    DataColumn(label: Text('Start Balance')),
                    DataColumn(label: Text('Interest')),
                    DataColumn(label: Text('End Balance')),
                  ],
                  rows: _yearlyDetails.map((year) {
                    return DataRow(
                      cells: [
                        DataCell(Text(year['year'].toString())),
                        DataCell(
                            Text(_currencyFormat.format(year['startBalance']))),
                        DataCell(
                            Text(_currencyFormat.format(year['interest']))),
                        DataCell(
                            Text(_currencyFormat.format(year['endBalance']))),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],

            SizedBox(height: 24),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: saveCalculation,
                child: Text(
                  'Save Calculation',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomAdBanner(),
    );
  }

  void calculate() {
    double amount = _principal;
    _yearlyDetails = [];

    for (int year = 1; year <= _years; year++) {
      double interest = amount * (_rate / 100);
      double newAmount = amount + interest;

      _yearlyDetails.add({
        'year': year,
        'startBalance': amount,
        'interest': interest,
        'endBalance': newAmount,
      });

      amount = newAmount;
    }

    setState(() {
      _result = amount;
    });
  }

  void saveCalculation() async {
    if (_principal > 0) {
      // Check for duplicates
      final records = await LoanData().getCompoundInterestHistory();
      bool isDuplicate = records.any((record) =>
          record.principal == _principal &&
          record.rate == _rate &&
          record.years == _years);

      if (isDuplicate) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Duplicate Record'),
            content: Text('This calculation already exists in history.'),
            actions: [
              TextButton(
                child: Text('Cancel'),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: Text('Save Anyway'),
                onPressed: () {
                  _saveRecord();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      } else {
        _saveRecord();
      }
    }

    _calcCounter++;
    _saveCalcCounter();
    if (_calcCounter >= 3) {
      if (_interstitialAd != null) {
        _showInterstitialAd();
      } else {
        _calcCounter = 0;
        _saveCalcCounter();
      }
    }
  }

  void _saveRecord() {
    final calculation = CompoundInterest(
      principal: _principal,
      rate: _rate,
      years: _years,
      result: _result,
      date: DateTime.now(),
    );

    LoanData().saveCompoundInterest(calculation);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Calculation saved')),
    );
  }

  Widget buildInputSection(
    String title,
    TextEditingController controller,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
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
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            prefixText: '\$ ',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onChanged: (value) {
            if (value.isEmpty) {
              onChanged(0);
              return;
            }

            String digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
            if (digitsOnly.isEmpty) return;

            double amount = double.parse(digitsOnly);
            if (amount > max) amount = max;
            if (amount < min) amount = min;

            onChanged(amount);

            // Format the number with commas
            final formattedText =
                intl.NumberFormat("#,###", "en_US").format(amount);

            // Only update if the formatted text is different
            if (controller.text != formattedText) {
              controller.text = formattedText;
              controller.selection = TextSelection.fromPosition(
                TextPosition(offset: controller.text.length),
              );
            }
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
            onChanged: (sliderValue) {
              onChanged(sliderValue);
              // Update text field when slider changes
              controller.text =
                  intl.NumberFormat("#,###", "en_US").format(sliderValue);
            },
          ),
        ),
      ],
    );
  }

  Widget buildSliderSection(
    String title,
    double value,
    String displayValue,
    double min,
    double max,
    int divisions,
    ValueChanged<double> onChanged,
  ) {
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
          displayValue,
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
}
