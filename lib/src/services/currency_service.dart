import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyService {
  static const String _baseUrl = 'https://api.currencybeacon.com/v1';
  static const String _bearerToken = 'mvhREoY2f8UjpJ45vjT7RVn7JSvihea4';

  Future<double> convertCurrency(
      String fromCurrency, String toCurrency, double amount,
      [DateTime? date]) async {
    try {
      // Formatear la fecha si se proporciona, de lo contrario usar la fecha actual
      final String dateStr = date != null
          ? '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}'
          : '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}';

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
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final Map<String, dynamic> rates = data['response']['rates'] ?? {};
        final double rate = rates[toCurrency]?.toDouble() ?? 0.0;

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

  Future<Map<String, String>> getAvailableCurrencies() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/currencies'),
        headers: {
          'Authorization': 'Bearer $_bearerToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> currencies = data['response'] ?? [];

        // Crear un mapa temporal para ordenar por nombre
        Map<String, Map<String, String>> tempMap = {};
        for (var currency in currencies) {
          final String shortCode = currency['short_code'] ?? '';
          final String name = currency['name'] ?? '';
          if (shortCode.isNotEmpty && name.isNotEmpty) {
            tempMap[name] = {'shortCode': shortCode, 'name': name};
          }
        }

        // Ordenar las claves (nombres) alfabéticamente
        final sortedKeys = tempMap.keys.toList()..sort();

        // Crear el mapa final ordenado
        Map<String, String> currencyMap = {};
        for (var key in sortedKeys) {
          final item = tempMap[key]!;
          currencyMap[item['shortCode']!] = item['name']!;
        }

        return currencyMap;
      } else {
        throw Exception('Failed to load currencies: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching currencies: $e');
    }
  }
}
