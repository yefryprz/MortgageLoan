import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/ai_analysis_model.dart';

class OpenRouterService {
  static final RegExp _placeholderRegex = RegExp(r'\{\{.*?\}\}');

  static const String _systemPrompt = '''
You are an expert loan analysis advisor. Generate recommendations, negotiation strategies, and comparative analysis.
RULES: Respond ONLY in valid JSON matching the given schema. Use real-world data for the region. CAUTION: All market data, interest rates, and bank information MUST NOT be older than 2 years to avoid outdated information. All responses must be in English.
''';

  static const String _userPromptTemplate = '''
Analyze the following loan and generate comprehensive financial recommendations:
LOAN DATA:

- Region: {{region}}
- Currency: {{currency}}
- Loan Type: {{loanType}} (Mortgage | Vehicle | Corporate | Personal)
- Property Value / Loan Amount: {{propertyValue}}
- Down Payment: {{downPayment}} ({{downPaymentPercentage}}%)
- Financed Amount: {{loanAmount}}
- Interest Rate: {{interestRate}}%
- Duration: {{durationYears}} years
- Estimated Monthly Payment: {{monthlyPayment}}

ADVANCED SCENARIOS (if provided by user):
- One-time extra payment: {{lumpSumPayment}} in year {{lumpSumYear}}
- Scenario Goal: {{scenarioGoal}} (Reduce Payment | Shorten Term)

ADDITIONAL CONTEXT:
- Current Date: {{currentDate}}

INSTRUCTIONS:
1. Generate an optimal repayment strategy based on the user's cash flow.
2. Compare the user's interest rate with the market average for their region (use data from the last 2 years maximum).
3. Identify refinancing opportunities.
4. Suggest the most competitive banks/entities for this type of loan in the region (use data from the last 2 years maximum).
5. Provide negotiation strategies with banks.
6. Evaluate the financial risk of the loan.
7. Calculate the impact of extra payments on total interest.
8. Include tax recommendations if applicable.
9. All text in your response MUST be in English.

Respond ONLY with the following JSON Array/Object schema, without any additional text:
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
    final apiKey = dotenv.env['AI_API_KEY'];
    final apiUrl = dotenv.env['AI_API_URL'] ?? '';
    final aiModel = dotenv.env['AI_MODEL'] ?? '';

    if (apiKey == null || apiKey.isEmpty || apiKey == 'your_key_here') {
      throw Exception('AI_API_KEY not found in .env');
    }

    String userPrompt = _userPromptTemplate;

    // Replace placeholders
    loanData.forEach((key, value) {
      userPrompt = userPrompt.replaceAll('{{$key}}', value.toString());
    });
    // For anything missing, replace with N/A
    userPrompt = userPrompt.replaceAll(_placeholderRegex, 'N/A');

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
        'X-OpenRouter-Title': 'Loan Calculator AI',
      },
      body: jsonEncode({
        'model': aiModel,
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
        'temperature': 0.3,
        'max_tokens': 4000,
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
