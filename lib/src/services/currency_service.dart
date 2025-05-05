import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyService {
  static const String _baseUrl =
      'https://cdn.jsdelivr.net/gh/fawazahmed0/currency-api@1/latest';

  Future<double> convertCurrency(
      String fromCurrency, String toCurrency, double amount,
      [DateTime? date]) async {
    try {
      final dateStr = date != null
          ? '/${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}'
          : '/latest';

      final response = await http.get(
        Uri.parse(
            '$_baseUrl$dateStr/currencies/$fromCurrency/$toCurrency.json'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rate = data[toCurrency] as double;
        return amount * rate;
      } else {
        throw Exception('Failed to load exchange rate');
      }
    } catch (e) {
      throw Exception('Error converting currency: $e');
    }
  }

  Future<Map<String, String>> getAvailableCurrencies() async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies.json'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Map<String, String>.from(data);
      } else {
        throw Exception('Failed to load currencies');
      }
    } catch (e) {
      throw Exception('Error fetching currencies: $e');
    }
  }
}
