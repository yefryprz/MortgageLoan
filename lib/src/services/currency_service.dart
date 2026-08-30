import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mortgageloan/src/config/env.dart';
import 'package:mortgageloan/src/services/cache_service.dart';

class CurrencyService {
  static final String _baseUrl = Env.currencyBaseUrl;
  static final String _bearerToken = Env.currencyToken;

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<double> convertCurrency(
      String fromCurrency, String toCurrency, double amount,
      [DateTime? date]) async {
    try {
      final String dateStr =
          date != null ? _formatDate(date) : _formatDate(DateTime.now());

      final queryParams = {
        'base': fromCurrency,
        'symbols': toCurrency,
        'date': dateStr,
      };

      final response = await http.get(
        Uri.parse('$_baseUrl/historical').replace(queryParameters: queryParams),
        headers: {
          'Authorization': 'Bearer $_bearerToken',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            Map<String, dynamic>.from(json.decode(response.body) as Map);
        final dynamic respObj = data['response'];
        final Map<String, dynamic> rates = respObj is Map
            ? Map<String, dynamic>.from(respObj['rates'] as Map? ?? {})
            : {};
        final double rate = (rates[toCurrency] as num?)?.toDouble() ?? 0.0;

        if (rate == 0.0) {
          throw Exception('Exchange rate not found for $toCurrency');
        }

        return amount * rate;
      } else {
        throw Exception('Failed to load exchange rate: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error converting currency: $e');
    }
  }

  Future<Map<String, double>> getTimeSeries(String fromCurrency,
      String toCurrency, DateTime startDate, DateTime endDate) async {
    try {
      final String startStr = _formatDate(startDate);
      final String endStr = _formatDate(endDate);

      // Use api_key query param for timeseries endpoint as requested
      final queryParams = {
        'api_key': _bearerToken,
        'base': fromCurrency,
        'symbols': toCurrency,
        'start_date': startStr,
        'end_date': endStr,
      };

      final response = await http.get(
        Uri.parse('$_baseUrl/timeseries').replace(queryParameters: queryParams),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            Map<String, dynamic>.from(json.decode(response.body) as Map);
        final dynamic respObj = data['response'];
        final Map<String, dynamic> responseData =
            respObj is Map ? Map<String, dynamic>.from(respObj) : {};

        final Map<String, double> timeseries = {};

        // The API returns dates as keys, and inside each date, currency codes as keys
        responseData.forEach((dateKey, value) {
          if (value is Map && value.containsKey(toCurrency)) {
            final val = value[toCurrency];
            if (val is num) {
              timeseries[dateKey] = val.toDouble();
            }
          }
        });

        return timeseries;
      } else {
        throw Exception('Failed to load timeseries: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching timeseries: $e');
    }
  }

  Future<Map<String, String>> getAvailableCurrencies() async {
    final cached = CacheService().get<Map<String, String>>('currencies');
    if (cached != null) {
      return cached;
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/currencies'),
        headers: {
          'Authorization': 'Bearer $_bearerToken',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            Map<String, dynamic>.from(json.decode(response.body) as Map);
        final List<dynamic> currencies =
            (data['response'] as List<dynamic>?) ?? [];

        final Map<String, Map<String, String>> tempMap = {};
        for (var currency in currencies) {
          if (currency is Map) {
            final String shortCode =
                (currency['short_code'] as String?) ?? '';
            final String name = (currency['name'] as String?) ?? '';
            if (shortCode.isNotEmpty && name.isNotEmpty) {
              tempMap[name] = {'shortCode': shortCode, 'name': name};
            }
          }
        }

        final sortedKeys = tempMap.keys.toList()..sort();
        final Map<String, String> currencyMap = {};
        for (var key in sortedKeys) {
          final item = tempMap[key]!;
          currencyMap[item['shortCode']!] = item['name']!;
        }

        CacheService().set('currencies', currencyMap);

        return currencyMap;
      } else {
        throw Exception('Failed to load currencies: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching currencies: $e');
    }
  }
}
