import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mortgageloan/src/services/cache_service.dart';
import 'package:mortgageloan/src/widgets/adbanner_widget.dart';
import 'package:mortgageloan/src/widgets/drawer_widget.dart';

class Country {
  final String name;
  final String flagUrl;

  Country({required this.name, required this.flagUrl});

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      name: json['name']['common'] ?? 'Unknown',
      flagUrl: json['flags']['png'] ?? '',
    );
  }
}

class LoanSimulatorPage extends StatefulWidget {
  const LoanSimulatorPage({Key? key}) : super(key: key);

  @override
  State<LoanSimulatorPage> createState() => _LoanSimulatorPageState();
}

class _LoanSimulatorPageState extends State<LoanSimulatorPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final NumberFormat _currencyFormat =
      NumberFormat.currency(locale: 'en_US', symbol: '\$');

  // API State
  List<Country> _countries = [];
  Country? _selectedCountry;
  bool _isLoadingCountries = true;

  // Loan Type Tab
  int _selectedLoanType = 0; // 0 = Mortgage, 1 = Vehicle, 2 = Consumer

  // Controllers
  final TextEditingController _amountController =
      TextEditingController(text: "450000");
  final TextEditingController _downPaymentController =
      TextEditingController(text: "90000");
  final TextEditingController _rateController =
      TextEditingController(text: "5.5");
  final TextEditingController _extraPaymentController =
      TextEditingController(text: "10000");

  // Form State
  double _amount = 450000;
  double _downPayment = 90000;
  double _rate = 5.5;
  int _durationYears = 30;

  // Scenarios State
  int _advancedScenarioMode = 0; // 0 = Lump Sum, 1 = Monthly Recurring
  double _extraPaymentAmount = 10000;
  int _lumpSumYear = 5;

  @override
  void initState() {
    super.initState();
    _fetchCountries();
  }

  Future<void> _fetchCountries() async {
    try {
      final cachedCountries = CacheService().get<List<Country>>('countries');
      if (cachedCountries != null) {
        setState(() {
          _countries = cachedCountries;
          _selectedCountry = _countries.firstWhere(
            (c) => c.name == 'United States',
            orElse: () => _countries.first,
          );
          _isLoadingCountries = false;
        });
        return;
      }

      final response = await http.get(
          Uri.parse('https://restcountries.com/v3.1/all?fields=name,flags'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final List<Country> fetchedCountries =
            data.map((json) => Country.fromJson(json)).toList();
        fetchedCountries.sort((a, b) => a.name.compareTo(b.name));

        CacheService().set('countries', fetchedCountries);

        setState(() {
          _countries = fetchedCountries;

          // Try to set United States as default
          _selectedCountry = _countries.firstWhere(
            (c) => c.name == 'United States',
            orElse: () => _countries.first,
          );
          _isLoadingCountries = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingCountries = false;
        // Fallback dummy country
        _countries = [Country(name: "United States", flagUrl: "")];
        _selectedCountry = _countries[0];
      });
    }
  }

  void _recalculate() {
    setState(() {}); // Simply triggers build to recalculate all derived values
  }

  void _reset() {
    setState(() {
      _selectedLoanType = 0;
      _amountController.text = "450000";
      _amount = 450000;
      _downPaymentController.text = "90000";
      _downPayment = 90000;
      _rateController.text = "5.5";
      _rate = 5.5;
      _durationYears = 30;
      _extraPaymentController.text = "10000";
      _extraPaymentAmount = 10000;
      _lumpSumYear = 5;
    });
  }

  double _calculateMonthlyPayment(
      double principal, double annualRate, int years) {
    if (annualRate == 0) return principal / (years * 12);
    final r = (annualRate / 100) / 12;
    final n = years * 12;
    return (principal * r * pow(1 + r, n)) / (pow(1 + r, n) - 1);
  }

  Map<String, double> _simulateLoan({
    required double principal,
    required double annualRate,
    required int years,
    double lumpSum = 0,
    int lumpSumMonth = 0,
    double monthlyExtra = 0,
  }) {
    if (principal <= 0) return {"totalInterest": 0, "monthsSaved": 0};

    final r = (annualRate / 100) / 12;
    final standardMonthlyPayment =
        _calculateMonthlyPayment(principal, annualRate, years);

    double balance = principal;
    double totalInterest = 0;
    int monthsElapsed = 0;

    for (int i = 1; i <= years * 12; i++) {
      if (balance <= 0) break;

      double interestForMonth = balance * r;
      totalInterest += interestForMonth;

      double currentPayment = standardMonthlyPayment + monthlyExtra;

      if (i == lumpSumMonth) {
        currentPayment += lumpSum;
      }

      double principalPayment = currentPayment - interestForMonth;
      balance -= principalPayment;
      monthsElapsed++;
    }

    return {
      "totalInterest": totalInterest,
      "monthsSaved": ((years * 12) - monthsElapsed).toDouble(),
    };
  }

  @override
  Widget build(BuildContext context) {
    // Derived Calculations
    final double principal =
        _selectedLoanType == 2 ? _amount : (_amount - _downPayment);
    final double baseMonthlyPayment =
        _calculateMonthlyPayment(principal, _rate, _durationYears);
    final Map<String, double> baseSimulation = _simulateLoan(
        principal: principal, annualRate: _rate, years: _durationYears);
    final double baseTotalInterest = baseSimulation['totalInterest'] ?? 0;

    // Advanced Scenario Calculation
    Map<String, double> advancedSimulation;
    if (_advancedScenarioMode == 0) {
      // Lump Sum
      advancedSimulation = _simulateLoan(
        principal: principal,
        annualRate: _rate,
        years: _durationYears,
        lumpSum: _extraPaymentAmount,
        lumpSumMonth: _lumpSumYear * 12,
      );
    } else {
      // Monthly Recurring
      advancedSimulation = _simulateLoan(
        principal: principal,
        annualRate: _rate,
        years: _durationYears,
        monthlyExtra: _extraPaymentAmount,
      );
    }

    final double advancedTotalInterest =
        advancedSimulation['totalInterest'] ?? 0;
    final double interestSavings = baseTotalInterest - advancedTotalInterest;
    final double monthsSaved = advancedSimulation['monthsSaved'] ?? 0;

    return Scaffold(
      key: _scaffoldKey,
      drawerEdgeDragWidth: MediaQuery.of(context).size.width,
      drawer: const CustomDrawer(currentRoute: "simulator"),
      backgroundColor: const Color(0xFFF6F8F9),
      bottomNavigationBar: CustomAdBanner(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Color(0xFF1F2937)),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text(
          "Loan Simulator",
          style: TextStyle(
              color: Color(0xFF1F2937),
              fontWeight: FontWeight.bold,
              fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _reset,
            child: const Text("Reset",
                style: TextStyle(
                    color: Color(0xFF3ac0b5), fontWeight: FontWeight.bold)),
          )
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRegionSelector(),
                  const SizedBox(height: 24),
                  _buildLoanTypeTabs(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLoanDetailsSection(),
                  const SizedBox(height: 24),
                  _buildResultCard(baseMonthlyPayment),
                  const SizedBox(height: 32),
                  const Text(
                    "Advanced Scenarios",
                    style: TextStyle(
                        color: Color(0xFF1F2937),
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildScenariosCard(interestSavings, monthsSaved),
                  const SizedBox(height: 24),
                  _buildAiInsightsCard(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegionSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "REGION",
          style: TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: _isLoadingCountries
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : DropdownButtonHideUnderline(
                  child: DropdownButton<Country>(
                    value: _selectedCountry,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down,
                        color: Color(0xFF6B7280)),
                    items: _countries.map((Country c) {
                      return DropdownMenuItem<Country>(
                        value: c,
                        child: Row(
                          children: [
                            if (c.flagUrl.isNotEmpty) ...[
                              Image.network(c.flagUrl,
                                  width: 24,
                                  height: 16,
                                  fit: BoxFit.cover,
                                  errorBuilder: (c, e, s) =>
                                      const Icon(Icons.flag, size: 16)),
                              const SizedBox(width: 8),
                            ],
                            Expanded(
                                child: Text(c.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14))),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (Country? val) {
                      if (val != null) {
                        setState(() => _selectedCountry = val);
                      }
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildLoanTypeTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          _buildTabBtn(0, Icons.home, "Mortgage"),
          _buildTabBtn(1, Icons.directions_car, "Vehicle"),
          _buildTabBtn(2, Icons.shopping_bag, "Consumer"),
        ],
      ),
    );
  }

  Widget _buildTabBtn(int index, IconData icon, String title) {
    bool isActive = _selectedLoanType == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedLoanType = index;
            // Adjust defaults based on type to be helpful
            if (index == 0) {
              _amount = 450000;
              _amountController.text = "450000";
              _downPayment = 90000;
              _downPaymentController.text = "90000";
              _rate = 5.5;
              _rateController.text = "5.5";
              _durationYears = 30;
            } else if (index == 1) {
              _amount = 35000;
              _amountController.text = "35000";
              _downPayment = 5000;
              _downPaymentController.text = "5000";
              _rate = 7.5;
              _rateController.text = "7.5";
              _durationYears = 5;
            } else {
              _amount = 15000;
              _amountController.text = "15000";
              _downPayment = 0;
              _downPaymentController.text = "0";
              _rate = 12.0;
              _rateController.text = "12.0";
              _durationYears = 3;
            }
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF14EFCD) : Colors.transparent,
            borderRadius: BorderRadius.circular(26),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: const Color(0xFF14EFCD).withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 16,
                  color: isActive
                      ? const Color(0xFF0F172A)
                      : const Color(0xFF64748B)),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isActive
                        ? const Color(0xFF0F172A)
                        : const Color(0xFF64748B),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoanDetailsSection() {
    String valueLabel = _selectedLoanType == 0
        ? "Property Value"
        : _selectedLoanType == 1
            ? "Vehicle Value"
            : "Loan Amount";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Loan Details",
              style: TextStyle(
                  color: Color(0xFF1F2937),
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            const Icon(Icons.info_outline, color: Color(0xFF14EFCD), size: 20),
          ],
        ),
        const SizedBox(height: 24),

        // Value Input
        _buildInputRow(valueLabel, _amountController, "\$", (val) {
          _amount = val;
          if (_downPayment > _amount) {
            _downPayment = _amount * 0.2; // reset to 20%
            _downPaymentController.text = _downPayment.toStringAsFixed(0);
          }
          _recalculate();
        }),
        _buildSlider(_amount, 1000, 1000000, (val) {
          _amount = val;
          _amountController.text = val.toStringAsFixed(0);
          _recalculate();
        }),

        const SizedBox(height: 16),

        // Down Payment (Not applicable for Consumer Loans)
        if (_selectedLoanType != 2) ...[
          _buildInputRow(
            "Down Payment (${_amount > 0 ? ((_downPayment / _amount) * 100).toStringAsFixed(0) : '0'}%)",
            _downPaymentController,
            "\$",
            (val) {
              if (val <= _amount) {
                _downPayment = val;
                _recalculate();
              }
            },
          ),
          _buildSlider(_downPayment, 0, _amount > 0 ? _amount : 1000, (val) {
            _downPayment = val;
            _downPaymentController.text = val.toStringAsFixed(0);
            _recalculate();
          }),
          const SizedBox(height: 16),
        ],

        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Interest Rate",
                      style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 12,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _rateController,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Color(0xFF1F2937)),
                            decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero),
                            onChanged: (val) {
                              _rate = double.tryParse(val) ?? 0;
                              _recalculate();
                            },
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text("%",
                            style: TextStyle(
                                color: Color(0xFF3ac0b5),
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Duration",
                      style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 12,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _durationYears,
                        isExpanded: true,
                        isDense: true,
                        icon: const Icon(Icons.keyboard_arrow_down,
                            size: 20, color: Color(0xFF64748B)),
                        items: _getDurationOptions().map((int y) {
                          return DropdownMenuItem<int>(
                            value: y,
                            child: Text("$y Years",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14)),
                          );
                        }).toList(),
                        onChanged: (int? val) {
                          if (val != null) setState(() => _durationYears = val);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  List<int> _getDurationOptions() {
    if (_selectedLoanType == 0) return [5, 10, 15, 20, 25, 30]; // Mortgage
    if (_selectedLoanType == 1) return [1, 2, 3, 4, 5, 6, 7]; // Vehicle
    return [1, 2, 3, 4, 5]; // Consumer
  }

  Widget _buildInputRow(String label, TextEditingController controller,
      String symbol, Function(double) onChanged,
      {bool isSuffix = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(label,
              style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 12,
                  fontWeight: FontWeight.w500)),
        ),
        Container(
          width: 120,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              if (!isSuffix)
                Text(symbol,
                    style: const TextStyle(
                        color: Color(0xFF3ac0b5), fontWeight: FontWeight.bold)),
              if (!isSuffix) const SizedBox(width: 4),
              Expanded(
                child: TextField(
                  controller: controller,
                  textAlign: isSuffix ? TextAlign.left : TextAlign.right,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF1F2937)),
                  decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero),
                  onChanged: (val) {
                    double parsed = double.tryParse(val) ?? 0;
                    onChanged(parsed);
                  },
                ),
              ),
              if (isSuffix) const SizedBox(width: 4),
              if (isSuffix)
                Text(symbol,
                    style: const TextStyle(
                        color: Color(0xFF3ac0b5), fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSlider(
      double value, double min, double max, Function(double) onChanged) {
    return SliderTheme(
      data: SliderThemeData(
        activeTrackColor: const Color(0xFF3ac0b5),
        inactiveTrackColor: const Color(0xFFE2E8F0),
        thumbColor: Colors.white,
        overlayColor: const Color(0xFF3ac0b5).withValues(alpha: 0.2),
        trackHeight: 4,
        thumbShape:
            const RoundSliderThumbShape(enabledThumbRadius: 10, elevation: 4),
      ),
      child: Slider(
        value: value.clamp(min, max),
        min: min,
        max: max,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildResultCard(double monthlyPayment) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)], // Dark navy gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        children: [
          const Text(
            "ESTIMATED MONTHLY PAYMENT",
            style: TextStyle(
                color: Color(0xFF14EFCD),
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                _currencyFormat.format(monthlyPayment).split('.')[0],
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold),
              ),
              const Text(
                " /mo",
                style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 16,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "Principal & Interest only. Taxes not included.",
            style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildScenariosCard(double interestSavings, double monthsSaved) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          // Scenario Tabs
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _advancedScenarioMode = 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _advancedScenarioMode == 0
                            ? const Color(0xFFE0FBF6)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "Lump Sum",
                        style: TextStyle(
                          color: _advancedScenarioMode == 0
                              ? const Color(0xFF3ac0b5)
                              : const Color(0xFF64748B),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _advancedScenarioMode = 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _advancedScenarioMode == 1
                            ? const Color(0xFFE0FBF6)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "Monthly Extra",
                        style: TextStyle(
                          color: _advancedScenarioMode == 1
                              ? const Color(0xFF3ac0b5)
                              : const Color(0xFF64748B),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Scenario Inputs
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Color(0xFFE0FBF6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.payments,
                    color: Color(0xFF3ac0b5), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _advancedScenarioMode == 0
                          ? "Lump Sum Payment"
                          : "Extra Monthly Payment",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937)),
                    ),
                    Text(
                      _advancedScenarioMode == 0
                          ? "One-time extra payment"
                          : "Recurring additional amount",
                      style: const TextStyle(
                          color: Color(0xFF9CA3AF), fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                width: 100,
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    const Text("\$",
                        style: TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontWeight: FontWeight.bold)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: TextField(
                        controller: _extraPaymentController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                        decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero),
                        onChanged: (val) {
                          _extraPaymentAmount = double.tryParse(val) ?? 0;
                          _recalculate();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (_advancedScenarioMode == 0) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Year 1",
                    style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 10)),
                Text("Year $_lumpSumYear",
                    style: const TextStyle(
                        color: Color(0xFF14EFCD),
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
                Text("Year $_durationYears",
                    style: const TextStyle(
                        color: Color(0xFF9CA3AF), fontSize: 10)),
              ],
            ),
            _buildSlider(_lumpSumYear.toDouble(), 1, _durationYears.toDouble(),
                (val) {
              setState(() => _lumpSumYear = val.toInt());
            }),
            const SizedBox(height: 16),
          ],

          // Savings Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.trending_down,
                    color: Color(0xFF10B981), size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        interestSavings > 0
                            ? "Save ${_currencyFormat.format(interestSavings).split('.')[0]} in interest"
                            : "No significant savings",
                        style: const TextStyle(
                            color: Color(0xFF0F172A),
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        interestSavings > 0
                            ? "By paying ${_currencyFormat.format(_extraPaymentAmount).split('.')[0]} extra ${_advancedScenarioMode == 0 ? 'in Year $_lumpSumYear' : 'monthly'}, you reduce your total interest and shave off ${(monthsSaved / 12).toStringAsFixed(1)} years from the term."
                            : "Increase your extra payment to see savings.",
                        style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 12,
                            height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiInsightsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.psychology, color: Color(0xFF6366F1), size: 24),
                  SizedBox(width: 8),
                  Text(
                    "AI Insights",
                    style: TextStyle(
                        color: Color(0xFF312E81),
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFE0E7FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.settings,
                    color: Color(0xFF818CF8), size: 16),
              ),
            ],
          ),
          const SizedBox(height: 16),
          RichText(
            text: TextSpan(
              style: const TextStyle(
                  color: Color(0xFF4F46E5), fontSize: 14, height: 1.5),
              children: [
                const TextSpan(
                    text:
                        "Based on current market trends in your region, shorter term options could save you "),
                TextSpan(
                    text: "significant amounts",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const TextSpan(
                    text:
                        " in total interest compared to your current selection."),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, 'ai_insights', arguments: {
                'type': _selectedLoanType == 0
                    ? "Mortgage"
                    : _selectedLoanType == 1
                        ? "Vehicle"
                        : "Consumer",
                'country': _selectedCountry?.name ?? "Global",
                'principal': _amount - _downPayment,
                'rate': _rate,
                'duration': _durationYears,
              });
            },
            child: const Row(
              children: [
                Text(
                  "View Analysis",
                  style: TextStyle(
                      color: Color(0xFF4338CA),
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward, size: 16, color: Color(0xFF4338CA)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
