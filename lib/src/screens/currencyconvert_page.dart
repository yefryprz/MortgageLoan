import 'package:flutter/material.dart';
import 'package:mortgageloan/src/widgets/adbanner_widget.dart';
import 'package:intl/intl.dart' as intl;
import 'package:mortgageloan/src/services/currency_service.dart';
import 'package:mortgageloan/src/widgets/drawer_widget.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mortgageloan/src/database/hive.dart';

class CurrencyConvertPage extends StatefulWidget {
  @override
  _CurrencyConvertPageState createState() => _CurrencyConvertPageState();
}

class _CurrencyConvertPageState extends State<CurrencyConvertPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _amountController = TextEditingController();

  double _amount = 0;
  String _fromCurrency = 'USD';
  String _toCurrency = 'EUR';
  double _result = 0;
  final CurrencyService _currencyService = CurrencyService();
  bool _isLoading = false;
  bool _isCurrenciesLoading = true;
  Map<String, String> _availableCurrencies = {};
  DateTime? _selectedDate;

  InterstitialAd? _interstitialAd;
  final LoanData _loanRepo =
      LoanData(); // Reusing LoanData for ad count methods

  final _currencyFormat = intl.NumberFormat.currency(
    locale: 'en_US',
    symbol: '',
    decimalDigits: 2,
  );

  @override
  void initState() {
    super.initState();
    _loadInterstitialAd();
    _loadCurrencies();
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    _amountController.dispose();
    super.dispose();
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
              _loanRepo.resetAdCount();
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

  Future<void> _loadCurrencies() async {
    setState(() => _isCurrenciesLoading = true);
    try {
      final currencies = await _currencyService.getAvailableCurrencies();

      setState(() {
        _availableCurrencies = currencies;
        _isCurrenciesLoading = false;

        // Verificar si las monedas por defecto están disponibles
        if (!currencies.containsKey(_fromCurrency)) {
          _fromCurrency = currencies.keys.first;
        }
        if (!currencies.containsKey(_toCurrency)) {
          _toCurrency = currencies.keys.first;
        }
      });
    } catch (e) {
      setState(() => _isCurrenciesLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading currencies: $e')),
      );
    }
  }

  List<String> get _currencies => _availableCurrencies.keys.toList();

  Widget _buildCurrencyDropdown(
    String value,
    String label,
    void Function(String?) onChanged,
  ) {
    if (_isCurrenciesLoading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          CircularProgressIndicator(),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          items: _currencies.map((String currency) {
            return DropdownMenuItem(
              value: currency,
              child: Text(_availableCurrencies[currency] ?? currency),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Date (Optional)',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          InkWell(
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              );
              if (picked != null && picked != _selectedDate) {
                setState(() {
                  _selectedDate = picked;
                  _convertCurrency();
                });
              }
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedDate == null
                        ? 'Select date'
                        : intl.DateFormat('yyyy-MM-dd').format(_selectedDate!),
                  ),
                  Icon(Icons.calendar_today),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyFlow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(
            Icons.import_export, // Este icono muestra flechas arriba y abajo
            color: Colors.teal,
            size: 30,
          ),
          onPressed: () {
            setState(() {
              // Intercambiar las monedas
              final temp = _fromCurrency;
              _fromCurrency = _toCurrency;
              _toCurrency = temp;
              // Actualizar la conversión
              _convertCurrency();
            });
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: CustomDrawer(),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text("Currency Converter"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Amount',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _amount = double.tryParse(value) ?? 0;
                        _convertCurrency();
                      });
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            _buildDatePicker(),
            SizedBox(height: 24),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCurrencyDropdown(
                    _fromCurrency,
                    'From',
                    (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _fromCurrency = newValue;
                          _convertCurrency();
                        });
                      }
                    },
                  ),
                  SizedBox(height: 16),
                  _buildCurrencyFlow(),
                  SizedBox(height: 16),
                  _buildCurrencyDropdown(
                    _toCurrency,
                    'To',
                    (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _toCurrency = newValue;
                          _convertCurrency();
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 32),
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
                    'Converted Amount',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  _isLoading
                      ? CircularProgressIndicator()
                      : Text(
                          '${_currencyFormat.format(_result)} $_toCurrency',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomAdBanner(),
    );
  }

  Future<void> _convertCurrency() async {
    if (_amount <= 0) {
      setState(() => _result = 0);
      return;
    }

    if (_fromCurrency == _toCurrency) {
      setState(() => _result = _amount);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _currencyService.convertCurrency(
        _fromCurrency,
        _toCurrency,
        _amount,
        _selectedDate,
      );

      setState(() {
        _result = result;
        _isLoading = false;
      });

      // Ad logic
      var adCount = await _loanRepo.getAdCount();
      if (adCount >= 3) {
        if (_interstitialAd != null) {
          await _showInterstitialAd();
        } else {
          _loanRepo.resetAdCount();
        }
      } else {
        _loanRepo.AdCountUp();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error converting currency: $e')),
      );
      setState(() => _isLoading = false);
    }
  }
}
