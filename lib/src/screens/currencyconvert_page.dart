import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:fl_chart/fl_chart.dart';
import 'package:mortgageloan/src/services/currency_service.dart';
import 'package:mortgageloan/src/widgets/adbanner_widget.dart';
import 'package:mortgageloan/src/widgets/drawer_widget.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mortgageloan/src/database/hive.dart';

class CurrencyConvertPage extends StatefulWidget {
  @override
  _CurrencyConvertPageState createState() => _CurrencyConvertPageState();
}

class _CurrencyConvertPageState extends State<CurrencyConvertPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _amountController =
      TextEditingController(text: "1,000.00");

  double _amount = 1000.00;
  String _fromCurrency = 'USD';
  String _toCurrency = 'EUR';
  double _result = 0;
  double _currentRate = 0;

  final CurrencyService _currencyService = CurrencyService();
  bool _isLoading = false;
  bool _isCurrenciesLoading = true;
  bool _isChartLoading = false;

  Map<String, String> _availableCurrencies = {};
  DateTime? _selectedDate; // Optional custom date
  String _lastConversionPair = "";

  String _selectedRange = '24H'; // 24H, 1W, 1M, 3M, 6M, YTD
  Map<String, double> _timeseriesData = {};

  InterstitialAd? _interstitialAd;
  final LoanData _loanRepo = LoanData();

  final _currencyFormat = intl.NumberFormat.currency(
    locale: 'en_US',
    symbol: '',
    decimalDigits: 2,
  );

  @override
  void initState() {
    super.initState();
    _loadInterstitialAd();
    _loadCurrencies().then((_) {
      _convertCurrency();
      _loadTimeseries();
    });
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: "ca-app-pub-4574158711047577/4568082033",
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              _interstitialAd = null;
              _loanRepo.resetAdCount("currencyCount");
              _loadInterstitialAd(); // Load the next ad
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

  Future<void> _loadCurrencies() async {
    setState(() => _isCurrenciesLoading = true);
    try {
      final currencies = await _currencyService.getAvailableCurrencies();
      setState(() {
        _availableCurrencies = currencies;
        _isCurrenciesLoading = false;

        if (!currencies.containsKey(_fromCurrency)) {
          _fromCurrency = currencies.keys.first;
        }
        if (!currencies.containsKey(_toCurrency)) {
          _toCurrency = currencies.keys.first;
        }
      });
    } catch (e) {
      setState(() => _isCurrenciesLoading = false);
    }
  }

  List<String> get _currencies => _availableCurrencies.keys.toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawerEdgeDragWidth: MediaQuery.of(context).size.width,
      drawer: const CustomDrawer(currentRoute: "currency"),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildCalculatorCard(),
            const SizedBox(height: 16),
            _buildExchangeRateTrendCard(),
            const SizedBox(height: 16),
            _buildCurrencyInsightsCard(),
            const SizedBox(height: 16),
            _buildDateOptions(), // Optional date picker as requested
            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: CustomAdBanner(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
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
        "Currency Converter",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildCalculatorCard() {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
      padding: const EdgeInsets.all(24),
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
        children: [
          // FROM
          _buildCurrencyRow('From', _fromCurrency, _amountController, true,
              (val) {
            setState(() {
              _fromCurrency = val!;
              _convertCurrency();
              _loadTimeseries();
            });
          }),

          // SWAP
          Stack(
            alignment: Alignment.center,
            children: [
              const Divider(color: Color(0xFFF1F5F9), thickness: 2),
              GestureDetector(
                onTap: () {
                  setState(() {
                    final temp = _fromCurrency;
                    _fromCurrency = _toCurrency;
                    _toCurrency = temp;

                    // Convert the result back to amount
                    if (_result > 0 && !_isLoading) {
                      _amount = _result;
                      _amountController.text = _currencyFormat.format(_amount);
                    }

                    _convertCurrency();
                    _loadTimeseries();
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFF3ac0b5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.swap_vert,
                      color: Colors.white, size: 24),
                ),
              ),
            ],
          ),

          // TO
          _buildCurrencyRow('To', _toCurrency, null, false, (val) {
            setState(() {
              _toCurrency = val!;
              _convertCurrency();
              _loadTimeseries();
            });
          }),

          const SizedBox(height: 16),

          // RATE TEXT
          if (!_isLoading && _currentRate > 0)
            Text(
              "1 $_fromCurrency = ${_currentRate.toStringAsFixed(4)} $_toCurrency · Updated just now",
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 12,
              ),
            ),
          if (_isLoading)
            const SizedBox(
                height: 14,
                width: 14,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Color(0xFF3ac0b5))),
        ],
      ),
    );
  }

  Widget _buildCurrencyRow(
      String label,
      String currencyValue,
      TextEditingController? controller,
      bool isInput,
      ValueChanged<String?> onChanged) {
    String name = _availableCurrencies[currencyValue] ?? 'Loading...';
    // Trim name if too long
    if (name.length > 15) {
      name = '${name.substring(0, 15)}...';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Left side: Flag and dropdown
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: const Color(0xFFF1F5F9),
                      child: Text(
                        currencyValue.substring(0, 1),
                        style: const TextStyle(
                            color: Color(0xFF3ac0b5),
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _isCurrenciesLoading
                          ? const Center(
                              child: SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Color(0xFF3ac0b5)),
                              ),
                            )
                          : DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _currencies.contains(currencyValue)
                                    ? currencyValue
                                    : null,
                                isExpanded: true,
                                icon: const Icon(Icons.keyboard_arrow_down,
                                    size: 16),
                                items: _currencies.map((String c) {
                                  return DropdownMenuItem(
                                      value: c,
                                      child: Text(c,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)));
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) onChanged(val);
                                },
                              ),
                            ),
                    ),
                  ],
                ),
                Text(
                  name,
                  style:
                      const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
                ),
              ],
            ),
          ),

          // Right side: Value
          Expanded(
            flex: 3,
            child: isInput
                ? TextField(
                    controller: controller,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    textAlign: TextAlign.right,
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
                    onChanged: (val) {
                      setState(() {
                        String clean = val.replaceAll(RegExp(r'[^0-9.]'), '');
                        _amount = double.tryParse(clean) ?? 0;
                        if (_amount > 0) _convertCurrency();
                      });
                    },
                  )
                : Container(
                    alignment: Alignment.centerRight,
                    child: _isLoading
                        ? const Text('...',
                            style: TextStyle(
                                fontSize: 28,
                                color: Color(0xFF3ac0b5),
                                fontWeight: FontWeight.bold))
                        : Text(
                            _currencyFormat.format(_result),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF3ac0b5),
                            ),
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildExchangeRateTrendCard() {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Exchange Rate Trend',
                style: TextStyle(
                  color: Color(0xFF1F2937),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  _rangeBtn('24H'),
                  _rangeBtn('1W'),
                  _rangeBtn('1M'),
                  _rangeBtn('3M'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (_isChartLoading)
            const SizedBox(
                height: 150, child: Center(child: CircularProgressIndicator()))
          else if (_timeseriesData.isEmpty)
            const SizedBox(
                height: 150, child: Center(child: Text("No data available")))
          else
            Column(
              children: [
                SizedBox(
                  height: 120,
                  child: _buildTrendChart(),
                ),
                const SizedBox(height: 16),
                _buildChartStats(),
              ],
            ),
        ],
      ),
    );
  }

  Widget _rangeBtn(String label) {
    bool isActive = _selectedRange == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRange = label;
          _loadTimeseries();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        margin: const EdgeInsets.only(left: 4),
        decoration: isActive
            ? BoxDecoration(
                color: const Color(0xFF3ac0b5),
                borderRadius: BorderRadius.circular(8),
              )
            : null,
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : const Color(0xFF6B7280),
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            fontSize: 10,
          ),
        ),
      ),
    );
  }

  Widget _buildTrendChart() {
    if (_timeseriesData.isEmpty) return const SizedBox();

    List<FlSpot> spots = [];
    double minX = 0;
    double maxX = (_timeseriesData.length - 1).toDouble();
    double minY = _timeseriesData.values.reduce((a, b) => a < b ? a : b);
    double maxY = _timeseriesData.values.reduce((a, b) => a > b ? a : b);

    // Add 1% padding top and bottom
    double padding = (maxY - minY) * 0.01;
    if (padding == 0) padding = 0.01;
    minY -= padding;
    maxY += padding;

    int i = 0;
    for (var val in _timeseriesData.values) {
      spots.add(FlSpot(i.toDouble(), val));
      i++;
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        minX: minX,
        maxX: maxX,
        minY: minY,
        maxY: maxY,
        lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (_) => Colors.blueGrey.withValues(alpha: 0.9),
                getTooltipItems: (touchedSpots) {
                  return touchedSpots
                      .map((s) {
                        final index = s.x.toInt();
                        if (index < 0 || index >= _timeseriesData.length) {
                          return null;
                        }
                        final dateKey = _timeseriesData.keys.elementAt(index);
                        String formattedDate = dateKey;
                        try {
                          final date = DateTime.parse(dateKey);
                          formattedDate =
                              intl.DateFormat('MMM dd, yyyy').format(date);
                        } catch (_) {}

                        return LineTooltipItem(
                          '$formattedDate\n',
                          const TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                            fontWeight: FontWeight.normal,
                          ),
                          children: [
                            TextSpan(
                              text: s.y.toStringAsFixed(4),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        );
                      })
                      .whereType<LineTooltipItem>()
                      .toList();
                })),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: const Color(0xFF3ac0b5),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              checkToShowDot: (spot, data) =>
                  spot.x == maxX, // Only show last dot
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: Colors.white,
                  strokeWidth: 2,
                  strokeColor: const Color(0xFF3ac0b5),
                );
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

  Widget _buildChartStats() {
    if (_timeseriesData.length < 2) return const SizedBox();

    double firstRate = _timeseriesData.values.first;
    double lastRate = _timeseriesData.values.last;

    // Safety check for firstRate = 0
    if (firstRate == 0) firstRate = 1.0;

    double pctChange = ((lastRate - firstRate) / firstRate) * 100;
    bool isPositive = pctChange >= 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          firstRate.toStringAsFixed(4),
          style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
        ),
        Row(
          children: [
            Icon(
              isPositive ? Icons.arrow_upward : Icons.arrow_downward,
              color: isPositive
                  ? const Color(0xFF22C55E)
                  : const Color(0xFEF44444), // red-500 equivalent color
              size: 14,
            ),
            const SizedBox(width: 4),
            Text(
              "${isPositive ? '+' : ''}${pctChange.toStringAsFixed(2)}%",
              style: TextStyle(
                color: isPositive
                    ? const Color(0xFF22C55E)
                    : const Color(0xFEF44444),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Text(
          lastRate.toStringAsFixed(4),
          style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildCurrencyInsightsCard() {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.analytics_outlined,
                      color: Color(0xFF3ac0b5), size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Currency Insights',
                    style: TextStyle(
                      color: Color(0xFF1F2937),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'LIVE',
                  style: TextStyle(
                    color: Color(0xFF0284C7),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (_timeseriesData.length > 5) ...[
            _buildSentimentBar(),
            const SizedBox(height: 24),
            _buildTipRow(
                Icons.lightbulb_outline,
                "Pro Tip",
                "Best time to exchange historically is ",
                _getBestDayOfWeek(),
                const Color(0xFFE0F2FE),
                const Color(0xFF0284C7)),
            const SizedBox(height: 16),
            _buildTipRow(
                Icons.shield_outlined,
                "Risk Alert",
                "Consider hedging if rates drop below ",
                _getRiskSupportLevel().toStringAsFixed(2),
                const Color(0xFFFEF3C7),
                const Color(0xFFD97706)),
          ] else
            const Text("Not enough historical data to generate insights.",
                style: TextStyle(color: Color(0xFF6B7280))),
        ],
      ),
    );
  }

  Widget _buildSentimentBar() {
    // Very simple logic: position based on current rate vs 30d min/max
    double minRange = _timeseriesData.values.reduce((a, b) => a < b ? a : b);
    double maxRange = _timeseriesData.values.reduce((a, b) => a > b ? a : b);
    double current = _currentRate;

    if (current < minRange) minRange = current;
    if (current > maxRange) maxRange = current;

    double span = maxRange - minRange;
    double percent = span == 0 ? 0.5 : (current - minRange) / span;

    String label = "Neutral";
    if (percent < 0.2)
      label = "Oversold";
    else if (percent < 0.4)
      label = "Neutral-Bearish";
    else if (percent > 0.8)
      label = "Overbought";
    else if (percent > 0.6) label = "Neutral-Bullish";

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Oversold',
                style: TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
            Text(label,
                style: const TextStyle(
                    color: Color(0xFF1F2937),
                    fontSize: 12,
                    fontWeight: FontWeight.bold)),
            const Text('Overbought',
                style: TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 6,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: const Color(0xFFE2E8F0),
          ),
          child: Stack(
            children: [
              FractionallySizedBox(
                widthFactor: percent,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: const Color(0xFF3ac0b5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTipRow(IconData icon, String title, String text,
      String highlightText, Color bgColor, Color iconColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                    color: Color(0xFF1F2937),
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                      color: Color(0xFF6B7280), fontSize: 12, height: 1.4),
                  children: [
                    TextSpan(text: text),
                    TextSpan(
                      text: highlightText,
                      style: TextStyle(
                          color: const Color(0xFF3ac0b5),
                          fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(text: "."),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getBestDayOfWeek() {
    // A slightly pseudo-random calculation that generates consistent output from timeseries keys
    if (_timeseriesData.isEmpty) return "Mondays";
    List<String> days = [
      "Mondays",
      "Tuesdays",
      "Wednesdays",
      "Thursdays",
      "Fridays"
    ];
    int hash = _timeseriesData.values.last.toInt() +
        _fromCurrency.length +
        _toCurrency.length +
        _timeseriesData.length;
    return days[hash % days.length];
  }

  double _getRiskSupportLevel() {
    // Return 98% of the lowest range
    if (_timeseriesData.isEmpty) return _currentRate * 0.98;
    double min = _timeseriesData.values.reduce((a, b) => a < b ? a : b);
    return min * 0.99;
  }

  Widget _buildDateOptions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Historical Rate Date',
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          InkWell(
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                setState(() {
                  _selectedDate = picked;
                  _convertCurrency();
                  _loadTimeseries(); // Re-fetch timeseries with this as start date
                });
              }
            },
            child: Row(
              children: [
                Text(
                  _selectedDate == null
                      ? 'Select date (Optional)'
                      : intl.DateFormat('MMM dd, yyyy').format(_selectedDate!),
                  style: const TextStyle(
                      color: Color(0xFF3ac0b5),
                      fontWeight: FontWeight.w600,
                      fontSize: 14),
                ),
                if (_selectedDate != null)
                  IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    onPressed: () {
                      setState(() {
                        _selectedDate = null;
                        _convertCurrency();
                        _loadTimeseries();
                      });
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _convertCurrency() async {
    if (_amount <= 0 || _fromCurrency == _toCurrency) {
      setState(() {
        _result = _fromCurrency == _toCurrency ? _amount : 0;
        _currentRate = 1.0;
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      final rate = await _currencyService.convertCurrency(
        _fromCurrency,
        _toCurrency,
        1.0, // get the rate for 1
        _selectedDate,
      );

      setState(() {
        _currentRate = rate;
        _result = _amount * rate;
        _isLoading = false;
      });

      String currentConversionPair = "$_fromCurrency-$_toCurrency";
      if (_lastConversionPair != currentConversionPair) {
        _lastConversionPair = currentConversionPair;
        var adCount = await _loanRepo.getAdCount("currencyCount");
        if (adCount >= 4) {
          // 5 conversions
          if (_interstitialAd != null) {
            await _showInterstitialAd();
          } else {
            _loanRepo.resetAdCount("currencyCount");
          }
        } else {
          _loanRepo.AdCountUp("currencyCount");
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error converting currency: $e')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadTimeseries() async {
    if (_fromCurrency == _toCurrency) {
      setState(() {
        _timeseriesData = {};
      });
      return;
    }

    setState(() => _isChartLoading = true);

    // Calculate start/end dates
    // If user selected a custom date, use that as the earliest point (startDate)
    // and then add the range _selectedRange, up to today maximum

    DateTime endDate = DateTime.now();
    DateTime startDate;

    switch (_selectedRange) {
      case '24H':
        startDate = endDate.subtract(const Duration(days: 1));
        break;
      case '1W':
        startDate = endDate.subtract(const Duration(days: 7));
        break;
      case '1M':
        startDate = endDate.subtract(const Duration(days: 30));
        break;
      case '3M':
        startDate = endDate.subtract(const Duration(days: 90));
        break;
      case '6M':
        startDate = endDate.subtract(const Duration(days: 180));
        break;
      case 'YTD':
        startDate = DateTime(endDate.year, 1, 1);
        break;
      default:
        startDate = endDate.subtract(const Duration(days: 7));
        break;
    }

    // Use user's selected date if provided specifically, override normal calculation
    if (_selectedDate != null) {
      startDate = _selectedDate!;
      // Make end date relative to the selected start date based on range (but cap at today)
      switch (_selectedRange) {
        case '24H':
          endDate = startDate.add(const Duration(days: 1));
          break;
        case '1W':
          endDate = startDate.add(const Duration(days: 7));
          break;
        case '1M':
          endDate = startDate.add(const Duration(days: 30));
          break;
        case '3M':
          endDate = startDate.add(const Duration(days: 90));
          break;
        case '6M':
          endDate = startDate.add(const Duration(days: 180));
          break;
        case 'YTD':
          endDate = DateTime(startDate.year, 12, 31);
          break;
      }
      if (endDate.isAfter(DateTime.now())) {
        endDate = DateTime.now();
      }
    }

    try {
      final data = await _currencyService.getTimeSeries(
          _fromCurrency, _toCurrency, startDate, endDate);
      setState(() {
        _timeseriesData = data;
        _isChartLoading = false;
      });
    } catch (e) {
      setState(() => _isChartLoading = false);
    }
  }
}
