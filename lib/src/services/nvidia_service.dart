import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mortgageloan/src/config/env.dart';
import '../models/ai_analysis_model.dart';

class NvidiaService {
  static final RegExp _placeholderRegex = RegExp(r'\{\{.*?\}\}');

  static const String _systemPrompt = '''
You are an expert loan analysis advisor. Generate recommendations, negotiation strategies, and comparative analysis.
RULES: Respond ONLY in valid JSON matching the given schema. Use real-world data for the region. CAUTION: All market data, interest rates, and bank information MUST NOT be older than 2 years to avoid outdated information. All text in your response MUST be in English.
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
      "overallScore": 85,
      "scoreLabel": "String",
      "riskLevel": "high | medium | low",
      "highlights": ["String"]
    },
    "marketComparison": {
      "userRate": 6.5,
      "averageRate": 6.8,
      "rateDifference": -0.3,
      "ratingLabel": "String",
      "comparedTo": "String",
      "advice": "String"
    },
    "optimalRepaymentPlan": {
      "title": "String",
      "description": "String",
      "extraPaymentPercent": 10,
      "totalInterestSaved": 35000,
      "monthsSaved": 48
    },
    "refinancingAlert": {
      "active": false,
      "urgency": "String",
      "description": "String"
    },
    "bankRecommendations": [
      {
        "bankName": "String",
        "interestRate": 6.2,
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
      "overallRisk": "low | medium | high",
      "warnings": ["String"],
      "positives": ["String"]
    },
    "actionItems": [
      {
        "action": "String",
        "priority": "high | medium | low",
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
    final apiKey = Env.nvidiaApiKey;
    final apiUrl = Env.nvidiaApiUrl;
    final aiModel = Env.nvidiaModel;

    if (apiKey.isEmpty || apiKey == 'your_key_here') {
      throw Exception('NVIDIA_API_KEY is not configured');
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
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': aiModel,
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
        'temperature': 0.6,
        'top_p': 0.95,
        'max_tokens': 16384,
        'reasoning_budget': 4096,
        'chat_template_kwargs': {'enable_thinking': true},
        'stream': false,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded =
          Map<String, dynamic>.from(jsonDecode(response.body) as Map);
      final List<dynamic>? choices = decoded['choices'] as List<dynamic>?;
      final Map<String, dynamic>? firstChoice =
          choices != null && choices.isNotEmpty
              ? Map<String, dynamic>.from(choices[0] as Map)
              : null;
      final Map<String, dynamic>? message = firstChoice?['message'] != null
          ? Map<String, dynamic>.from(firstChoice!['message'] as Map)
          : null;
      final String contentMessage = (message?['content'] as String?) ?? '{}';

      // Clean up markdown block if present
      String cleanedJson = contentMessage.trim();
      if (cleanedJson.startsWith('```json')) {
        cleanedJson = cleanedJson.substring(7);
      } else if (cleanedJson.startsWith('```')) {
        cleanedJson = cleanedJson.substring(3);
      }
      if (cleanedJson.endsWith('```')) {
        cleanedJson = cleanedJson.substring(0, cleanedJson.length - 3);
      }
      cleanedJson = cleanedJson.trim();

      final Map<String, dynamic> jsonContent =
          Map<String, dynamic>.from(jsonDecode(cleanedJson) as Map);
      return AiAnalysisResponse.fromJson(jsonContent);
    } else {
      throw Exception(
          'Failed to generate AI strategy: ${response.statusCode} - ${response.body}');
    }
  }
}
