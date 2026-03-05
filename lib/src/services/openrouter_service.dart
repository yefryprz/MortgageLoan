import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/ai_analysis_model.dart';

class OpenRouterService {
  static const String _systemPrompt = '''
Eres un asesor experto en análisis de préstamos. Genera recomendaciones, estrategias de negociación y análisis comparativo.
REGLAS: Responde ÚNICAMENTE en JSON válido según el schema dado. Usa datos reales de la región usando el idioma correspondiente.
''';

  static const String _userPromptTemplate = '''
Analiza el siguiente préstamo y genera recomendaciones financieras completas:
DATOS DEL PRÉSTAMO:

- Región: {{region}}
- Moneda: {{currency}}
- Tipo de préstamo: {{loanType}} (Hipotecario | Vehículo | Corporativo | Personal)
- Valor del bien / Monto del préstamo: {{propertyValue}}
- Pago inicial (Down Payment): {{downPayment}} ({{downPaymentPercentage}}%)
- Monto financiado: {{loanAmount}}
- Tasa de interés: {{interestRate}}%
- Duración: {{durationYears}} años
- Pago mensual estimado: {{monthlyPayment}}

ESCENARIOS AVANZADOS (si los completó el usuario):
- Pago extra único: {{lumpSumPayment}} en el año {{lumpSumYear}}
- Objetivo de escenario: {{scenarioGoal}} (Reducir Pago | Acortar Plazo)

CONTEXTO ADICIONAL:
- Fecha de consulta: {{currentDate}}

INSTRUCCIONES:
1. Genera una estrategia de pago óptima basada en el flujo de caja del usuario.
2. Compara la tasa de interés del usuario con el promedio del mercado de su región.
3. Identifica oportunidades de refinanciamiento.
4. Sugiere los bancos/entidades más competitivos para este tipo de préstamo en la región.
5. Proporciona estrategias de negociación con los bancos.
6. Evalúa el riesgo financiero del préstamo.
7. Calcula el impacto de pagos extra sobre el interés total.
8. Incluye recomendaciones fiscales si aplica.

Responde ÚNICAMENTE con el siguiente JSON Array/Object schema, sin texto adicional:
```json
{
  "analysis": {
    "summary": {
      "title": "String",
      "subtitle": "String",
      "overallScore": "Number (0-100)",
      "scoreLabel": "String",
      "riskLevel": "high | medium | low",
      "highlights": ["String"]
    },
    "marketComparison": {
      "userRate": "Number",
      "averageRate": "Number",
      "rateDifference": "Number",
      "ratingLabel": "String",
      "comparedTo": "String",
      "advice": "String"
    },
    "optimalRepaymentPlan": {
      "title": "String",
      "description": "String",
      "extraPaymentPercent": "Number",
      "totalInterestSaved": "Number",
      "monthsSaved": "Number"
    },
    "refinancingAlert": {
      "active": "Boolean",
      "urgency": "String",
      "description": "String"
    },
    "bankRecommendations": [
      {
        "bankName": "String",
        "interestRate": "Number",
        "pros": ["String"],
        "cons": ["String"]
      }
    ],
    "negotiationStrategies": [
      {
        "title": "String",
        "description": "String",
        "steps": ["String"]
      }
    ],
    "riskAssessment": {
      "overallRisk": "String",
      "warnings": ["String"],
      "positives": ["String"]
    },
    "actionItems": [
      {
        "action": "String",
        "priority": "String",
        "impact": "String"
      }
    ]
  }
}
```
''';

  Future<AiAnalysisResponse> getAiAnalysis({
    required Map<String, dynamic> loanData,
  }) async {
    final apiKey = dotenv.env['OPENROUTER_API_KEY'];
    if (apiKey == null || apiKey.isEmpty || apiKey == 'your_key_here') {
      throw Exception('OPENROUTER_API_KEY not found in .env');
    }

    String userPrompt = _userPromptTemplate;

    // Replace placeholders
    loanData.forEach((key, value) {
      userPrompt = userPrompt.replaceAll('{{$key}}', value.toString());
    });
    // For anything missing, replace with N/A
    userPrompt = userPrompt.replaceAll(RegExp(r'\{\{.*?\}\}'), 'N/A');

    final response = await http.post(
      Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
        'X-OpenRouter-Title': 'Loan Calculator AI',
      },
      body: jsonEncode({
        'model': 'qwen/qwen3-235b-a22b-thinking-2507',
        'response_format': {'type': 'json_object'},
        'messages': [
          {
            'role': 'system',
            'content': _systemPrompt,
          },
          {
            'role': 'user',
            'content': userPrompt,
          }
        ],
        'temperature': 0.1,
        'max_tokens': 2000,
      }),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final contentMessage =
          decoded['choices']?[0]?['message']?['content'] ?? '{}';
      final jsonContent = jsonDecode(contentMessage);
      return AiAnalysisResponse.fromJson(jsonContent);
    } else {
      throw Exception(
          'Failed to generate AI strategy: ${response.statusCode} - ${response.body}');
    }
  }
}
