import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:fl_chart/fl_chart.dart';
import 'package:mortgageloan/src/database/hive.dart';
import 'package:mortgageloan/src/models/compound_interest_model.dart';
import 'package:mortgageloan/src/widgets/adbanner_widget.dart';
import 'package:mortgageloan/src/widgets/drawer_widget.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class CompoundInterestPage extends StatefulWidget {
  @override
  _CompoundInterestPageState createState() => _CompoundInterestPageState();
}

class _CompoundInterestPageState extends State<CompoundInterestPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _principalController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _yearsController = TextEditingController();

  double _principal = 1000000;
  double _rate = 5.0;
  int _years = 10;
  double _result = 0;
  List<Map<String, dynamic>> _yearlyDetails = [];

  final _currencyFormat = intl.NumberFormat.currency(
    locale: 'en_US',
    symbol: '\$',
    decimalDigits: 2,
  );

  final _numberFormat = intl.NumberFormat("#,###", "en_US");

  InterstitialAd? _interstitialAd;
  final loanRepo = LoanData();

  @override
  void initState() {
    super.initState();
    _principalController.text = _numberFormat.format(_principal);
    _rateController.text = _rate.toStringAsFixed(2);
    _yearsController.text = _years.toString();
    calculate();
    _loadInterstitialAd();
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    _principalController.dispose();
    _rateController.dispose();
    _yearsController.dispose();
    super.dispose();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: "ca-app-pub-4574158711047577/4568082033",
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              _interstitialAd = null;
              loanRepo.resetAdCount("compoundCount");
              _loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (err) {
          _interstitialAd = null;
        },
      ),
    );
  }

  Future<void> _showInterstitialAd() async {
    if (_interstitialAd == null) return;
    try {
      await _interstitialAd!.show();
    } catch (e) {
      _loadInterstitialAd();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF6F8F9),
      drawer: CustomDrawer(),
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF3ac0b5), Color(0xFF27a9bf)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text(
          "Compound Interest",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildCalculatorCard(),
            const SizedBox(height: 16),
            _buildResultCard(),
            const SizedBox(height: 16),
            if (_yearlyDetails.isNotEmpty) _buildInvestmentBreakdownPreview(),
            const SizedBox(height: 24),
            _buildFullTableButton(),
            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: CustomAdBanner(),
    );
  }

  Widget _buildCalculatorCard() {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            spreadRadius: 2,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Principal Amount Card
          _buildPrincipalSection(),
          const SizedBox(height: 24),

          // Interest Rate Card
          _buildInterestSection(),
          const SizedBox(height: 24),

          // Time Period Card
          _buildPeriodSection(),
        ],
      ),
    );
  }

  Widget _buildPrincipalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Principal Amount',
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Container() // Empty spacer
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFFAFBFC),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Text(
                '\$',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF9CA3AF),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _principalController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (value) {
                    String clean = value.replaceAll(RegExp(r'[^0-9]'), '');
                    if (clean.isEmpty) {
                      _principal = 0;
                    } else {
                      _principal = double.parse(clean);
                      if (_principal > 50000000) _principal = 50000000;
                    }
                    setState(() {
                      calculate();
                    });
                  },
                  onSubmitted: (value) {
                    _principalController.text =
                        _numberFormat.format(_principal);
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _buildCustomSlider(
          value: _principal,
          min: 1000,
          max: 50000000,
          onChanged: (val) {
            setState(() {
              _principal = val;
              _principalController.text = _numberFormat.format(val);
              calculate();
            });
          },
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
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Row(
              children: [
                SizedBox(
                  width: 60,
                  child: TextField(
                    controller: _rateController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
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
                      double? val = double.tryParse(value);
                      if (val != null) {
                        if (val > 20) val = 20;
                        if (val < 1) val = 1;
                        _rate = val;
                        setState(() {
                          calculate();
                        });
                      }
                    },
                    onSubmitted: (value) {
                      _rateController.text = _rate.toStringAsFixed(2);
                    },
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  '%',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildCustomSlider(
          value: _rate,
          min: 1,
          max: 20,
          onChanged: (val) {
            setState(() {
              _rate = val;
              _rateController.text = val.toStringAsFixed(2);
              calculate();
            });
          },
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
              'Time Period',
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Row(
              children: [
                SizedBox(
                  width: 50,
                  child: TextField(
                    controller: _yearsController,
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
                        _years = val;
                        setState(() {
                          calculate();
                        });
                      }
                    },
                    onSubmitted: (value) {
                      _yearsController.text = _years.toString();
                    },
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  'Years',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildCustomSlider(
          value: _years.toDouble(),
          min: 1,
          max: 30,
          onChanged: (val) {
            setState(() {
              _years = val.round();
              _yearsController.text = _years.toString();
              calculate();
            });
          },
          divisions: 29,
        ),
      ],
    );
  }

  Widget _buildCustomSlider({
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
    int? divisions,
  }) {
    return SliderTheme(
      data: SliderThemeData(
        activeTrackColor: const Color(0xFF3ac0b5),
        inactiveTrackColor: const Color(0xFFE2E8F0),
        trackHeight: 4.0,
        thumbShape: const RoundSliderThumbShape(
          enabledThumbRadius: 12,
          elevation: 4,
          pressedElevation: 8,
        ),
        thumbColor: Colors.white,
        overlayColor: const Color(0xFF3ac0b5).withValues(alpha: 0.1),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
      ),
      child: Slider(
        value: value.clamp(min, max),
        min: min,
        max: max,
        divisions: divisions,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildResultCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            spreadRadius: 2,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Final Amount',
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _currencyFormat.format(_result),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3ac0b5),
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
            height: 150,
            child: _buildGrowthChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthChart() {
    if (_yearlyDetails.isEmpty) return const SizedBox();

    List<FlSpot> spots = [];
    spots.add(FlSpot(0, _principal)); // Start point

    for (int i = 0; i < _yearlyDetails.length; i++) {
      // Step size for x-axis if there are many years. For simplicity plot them all
      spots.add(FlSpot(_yearlyDetails[i]['year'].toDouble(),
          _yearlyDetails[i]['endBalance']));
    }

    // Determine max Y for scaling
    double maxY = _result * 1.1;

    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) =>
                Colors.blueGrey.withValues(alpha: 0.9),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                return LineTooltipItem(
                  _currencyFormat.format(spot.y),
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
        ),
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          show: true,
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              getTitlesWidget: (value, meta) {
                // Determine step for showing year markers at bottom
                int step = _years > 10 ? (_years ~/ 5) : 2;
                if (value.toInt() == 0 ||
                    value.toInt() == _years ||
                    (value.toInt() % step == 0)) {
                  return Text(
                    value.toInt().toString(),
                    style:
                        const TextStyle(color: Color(0xFF9CA3AF), fontSize: 10),
                  );
                }
                return const Text('');
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: _years.toDouble(),
        minY: _principal * 0.9,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: false,
            color: const Color(0xFF3ac0b5),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                // Only show dots exactly where we show labels
                int step = _years > 10 ? (_years ~/ 5) : 2;
                if (spot.x == 0 ||
                    spot.x == _years ||
                    spot.x.toInt() % step == 0) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: Colors.white,
                    strokeWidth: 2,
                    strokeColor: const Color(0xFF3ac0b5),
                  );
                }
                return FlDotCirclePainter(radius: 0, color: Colors.transparent);
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF3ac0b5).withValues(alpha: 0.3),
                  const Color(0xFF3ac0b5).withValues(alpha: 0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvestmentBreakdownPreview() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            spreadRadius: 2,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Investment Breakdown',
            style: TextStyle(
              color: Color(0xFF1F2937),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Table(
            columnWidths: const {
              0: FlexColumnWidth(1),
              1: FlexColumnWidth(2),
              2: FlexColumnWidth(2),
            },
            children: [
              TableRow(
                decoration: const BoxDecoration(
                  color: Color(0xFFFAFBFC),
                ),
                children: [
                  _headerCell('YEAR'),
                  _headerCell('BALANCE'),
                  _headerCell('INTEREST', align: TextAlign.right),
                ],
              ),
              // Show max 3 records
              for (int i = 0;
                  i < (_yearlyDetails.length > 3 ? 3 : _yearlyDetails.length);
                  i++)
                TableRow(
                  decoration: const BoxDecoration(
                    border:
                        Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
                  ),
                  children: [
                    _dataCell(_yearlyDetails[i]['year'].toString(), bold: true),
                    _dataCell(
                        _currencyFormat.format(_yearlyDetails[i]['endBalance']),
                        color: const Color(0xFF64748B)),
                    _dataCell(
                        '+${_currencyFormat.format(_yearlyDetails[i]['interest'])}',
                        color: const Color(0xFF22C55E),
                        align: TextAlign.right),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerCell(String text, {TextAlign align = TextAlign.left}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF6B7280),
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
        textAlign: align,
      ),
    );
  }

  Widget _dataCell(String text,
      {Color? color, bool bold = false, TextAlign align = TextAlign.left}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Text(
        text,
        style: TextStyle(
          color: color ?? const Color(0xFF1F2937),
          fontSize: 13,
          fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
        ),
        textAlign: align,
      ),
    );
  }

  Widget _buildFullTableButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: navigateToBreakdown,
        icon: const Icon(Icons.table_chart_outlined,
            color: Colors.white, size: 24),
        label: const Text(
          'Full Yearly Table',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3ac0b5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          shadowColor: const Color(0xFF3ac0b5).withValues(alpha: 0.4),
        ),
      ),
    );
  }

  void calculate() {
    if (_principal <= 0) {
      setState(() {
        _result = 0;
        _yearlyDetails = [];
      });
      return;
    }

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

    _result = amount;
  }

  void navigateToBreakdown() async {
    if (_principal <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Principal amount must be greater than 0')),
      );
      return;
    }

    // Save calculation before navigating
    _saveCalculationSilent();

    Navigator.pushNamed(context, "compound_breakdown", arguments: {
      'principal': _principal,
      'rate': _rate,
      'years': _years,
      'result': _result,
      'yearlyDetails': _yearlyDetails
    });
  }

  void _saveCalculationSilent() async {
    if (_principal > 0) {
      final records = await loanRepo.getCompoundInterestHistory();
      bool isDuplicate = records.any((record) =>
          record.principal == _principal &&
          record.rate == _rate &&
          record.years == _years);

      if (!isDuplicate) {
        final calculation = CompoundInterest(
          principal: _principal,
          rate: _rate,
          years: _years,
          result: _result,
          date: DateTime.now(),
        );
        loanRepo.saveCompoundInterest(calculation);
      }
    }

    var adCount = await loanRepo.getAdCount("compoundCount");
    if (adCount >= 2) {
      // 3 clicks
      if (_interstitialAd != null) {
        await _showInterstitialAd();
      } else {
        loanRepo.resetAdCount("compoundCount");
      }
    } else {
      loanRepo.AdCountUp("compoundCount");
    }
  }
}
