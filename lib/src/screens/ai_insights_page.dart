import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mortgageloan/src/database/hive.dart';
import 'package:mortgageloan/src/widgets/adbanner_widget.dart';
import 'package:mortgageloan/src/utils/interstitial_ad_helper.dart';
import '../models/ai_analysis_model.dart';
import '../services/openrouter_service.dart';
import '../services/analytics_service.dart';

class AiInsightsPage extends StatefulWidget {
  const AiInsightsPage({Key? key}) : super(key: key);

  @override
  State<AiInsightsPage> createState() => _AiInsightsPageState();
}

class _AiInsightsPageState extends State<AiInsightsPage> {
  late final InterstitialAdHelper _adHelper;
  final loanRepo = LoanData();

  bool _isLoading = false;
  String? _error;
  AiAnalysisResponse? _analysisResult;
  Map<String, dynamic> _args = {};

  final OpenRouterService _aiService = OpenRouterService();

  bool _isHistory = false;
  int _remainingAnalyses = 1;

  @override
  void initState() {
    super.initState();
    _adHelper = InterstitialAdHelper(adCountKey: "aiCount", adFrequency: 1);
    _adHelper.load();
    Future.delayed(Duration.zero, () {
      _checkUsageLimit();
    });
  }

  Future<void> _checkUsageLimit() async {
    final remaining = await loanRepo.getRemainingAiAnalyses();
    setState(() {
      _remainingAnalyses = remaining;
    });
  }

  void _loadHistoryData() {
    if (_args['isHistory'] == true) {
      setState(() {
        _isHistory = true;
        if (_args['savedResponse'] != null) {
          final Map<String, dynamic> savedResponse =
              jsonDecode(jsonEncode(_args['savedResponse']));
          _analysisResult = AiAnalysisResponse.fromJson(savedResponse);
        }
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    _args = args is Map ? Map<String, dynamic>.from(args) : {};
    _loadHistoryData();
  }

  @override
  void dispose() {
    _adHelper.dispose();
    super.dispose();
  }

  Future<void> _handleGenerateStrategy() async {
    if (_isLoading) return;

    final canPerform = await loanRepo.canPerformAiAnalysis();
    if (!canPerform) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Only 1 AI evaluation is allowed per day.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    // Always show ad after EACH analysis as requested
    AnalyticsService.logEvent('ai_analysis_requested',
        parameters: <String, Object>{
          'loan_type': _args['loanType'] ?? 'Mortgage',
          'region': _args['region'] ?? 'Global'
        });

    _adHelper.handleAdDetailNavigation(() {
      _fetchAiAnalysis();
    });
  }

  Future<void> _fetchAiAnalysis() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _aiService.getAiAnalysis(loanData: _args);

      // Save to history and increment counter
      await loanRepo.saveAiAnalysis(result.toJson(), _args);
      await loanRepo.incrementAiAnalysisCount();

      setState(() {
        _analysisResult = result;
        _isLoading = false;
      });

      AnalyticsService.logEvent('ai_analysis_completed',
          parameters: <String, Object>{
            'loan_type': _args['loanType'] ?? 'Mortgage',
            'score': result.analysis?.summary?.overallScore ?? 0,
          });
      _checkUsageLimit();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      AnalyticsService.logEvent('ai_analysis_failed',
          parameters: <String, Object>{'error': e.toString()});
    }
  }

  @override
  Widget build(BuildContext context) {
    final loanType = _args['loanType'] ?? 'Mortgage';
    final country = _args['region'] ?? 'Global';

    return PopScope(
        canPop: !_isLoading,
        child: Scaffold(
          backgroundColor: const Color(0xFFF6F8F9),
          appBar: AppBar(
            backgroundColor: const Color(0xFFF6F8F9),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
              onPressed: _isLoading ? null : () => Navigator.pop(context),
            ),
            title: const Text(
              "AI Financial Insights",
              style: TextStyle(
                color: Color(0xFF1F2937),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                _buildSmartAdvisorHeader(),
                const SizedBox(height: 24),
                _buildAnalysisCompleteCard(loanType, country),
                _buildAiDisclaimer(),
                const SizedBox(height: 32),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "AI Recommendations",
                    style: TextStyle(
                      color: Color(0xFF1F2937),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Column(
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF3ac0b5)),
                          ),
                          SizedBox(height: 24),
                          Text(
                            "The credit analysis process may take several minutes.\nPlease wait a moment...",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (_error != null)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFCA5A5)),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.error_outline,
                            color: Color(0xFFEF4444), size: 40),
                        const SizedBox(height: 12),
                        Text(
                          "Failed to generate strategy: $_error",
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Color(0xFF991B1B)),
                        ),
                      ],
                    ),
                  )
                else if (_analysisResult != null &&
                    _analysisResult!.analysis != null)
                  _buildDynamicResults(_analysisResult!.analysis!)
                else if (!_isHistory)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Column(
                        children: [
                          const Text(
                            "Tap 'Generate Strategy' to analyze your loan.",
                            style: TextStyle(color: Color(0xFF6B7280)),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Remaining evaluations today: $_remainingAnalyses/1",
                            style: const TextStyle(
                                color: Color(0xFF3ac0b5),
                                fontWeight: FontWeight.bold,
                                fontSize: 12),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Only 1 AI evaluation is allowed per day.",
                            style: TextStyle(
                                color: Color(0xFF9CA3AF), fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ),
                SizedBox(height: _isHistory ? 40 : 120),
              ],
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: _isHistory ? null : _buildFloatingActions(),
          bottomNavigationBar: CustomAdBanner(),
        ));
  }

  Widget _buildDynamicResults(AiAnalysisData data) {
    return Column(
      children: [
        if (data.summary != null) ...[
          _buildSummaryCard(data.summary!),
          const SizedBox(height: 16),
        ],
        if (data.optimalRepaymentPlan != null) ...[
          _buildOptimalRepaymentCard(data.optimalRepaymentPlan!),
          const SizedBox(height: 16),
        ],
        if (data.marketComparison != null) ...[
          _buildMarketComparisonCard(data.marketComparison!),
          const SizedBox(height: 16),
        ],
        if (data.refinancingAlert != null &&
            data.refinancingAlert!.active == true) ...[
          _buildRefinancingAlertCard(data.refinancingAlert!),
          const SizedBox(height: 16),
        ],
        if (data.bankRecommendations != null &&
            data.bankRecommendations!.isNotEmpty) ...[
          _buildBankRecommendationsCard(data.bankRecommendations!),
          const SizedBox(height: 16),
        ],
        if (data.negotiationStrategies != null &&
            data.negotiationStrategies!.isNotEmpty) ...[
          _buildNegotiationStrategiesCard(data.negotiationStrategies!),
          const SizedBox(height: 16),
        ],
        if (data.riskAssessment != null) ...[
          _buildRiskAssessmentCard(data.riskAssessment!),
          const SizedBox(height: 16),
        ],
        if (data.taxImplications != null &&
            data.taxImplications!.applicable == true) ...[
          _buildTaxImplicationsCard(data.taxImplications!),
          const SizedBox(height: 16),
        ],
        if (data.insuranceRecommendations != null &&
            data.insuranceRecommendations!.isNotEmpty) ...[
          _buildInsuranceRecommendationsCard(data.insuranceRecommendations!),
          const SizedBox(height: 16),
        ],
        if (data.extraPaymentImpact != null) ...[
          _buildExtraPaymentImpactCard(data.extraPaymentImpact!),
          const SizedBox(height: 16),
        ],
        if (data.amortizationSnapshot != null) ...[
          _buildAmortizationSnapshotCard(data.amortizationSnapshot!),
          const SizedBox(height: 16),
        ],
        if (data.actionItems != null && data.actionItems!.isNotEmpty) ...[
          _buildActionItemsCard(data.actionItems!),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildSmartAdvisorHeader() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              height: 80,
              width: 80,
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF3ac0b5), Color(0xFF27a9bf)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 50, color: Color(0xFF94A3B8)),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Color(0xFF3ac0b5),
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.psychology, color: Colors.white, size: 16),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          "Smart Advisor",
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFE6F7F5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            "Your personal financial strategist",
            style: TextStyle(
              color: Color(0xFF3ac0b5),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalysisCompleteCard(String loanType, String country) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3ac0b5).withValues(alpha: 0.05),
            spreadRadius: 2,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "ANALYSIS COMPLETE",
                    style: TextStyle(
                      color: Color(0xFF16A34A),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Your $loanType Strategy",
                  style: const TextStyle(
                    color: Color(0xFF1F2937),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.language,
                        size: 16, color: Color(0xFF3ac0b5)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        "Optimized for $country Market",
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF14EFCD),
              shape: BoxShape.circle,
            ),
            child:
                const Icon(Icons.bar_chart, color: Color(0xFF0F172A), size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildOptimalRepaymentCard(OptimalRepaymentPlan plan) {
    return _buildInsightsCard(
      icon: Icons.savings,
      iconColor: const Color(0xFF14EFCD),
      title: plan.title ?? "Optimal Repayment Plan",
      subtitle: plan.description ?? "",
      badgeText: "",
      badgeColor: const Color(0xFF14EFCD),
      content: RichText(
        text: TextSpan(
          style: const TextStyle(
              color: Color(0xFF4B5563), fontSize: 14, height: 1.5),
          children: [
            const TextSpan(text: "Making an extra "),
            TextSpan(
              text: "${plan.extraPaymentPercent ?? 0}% payment",
              style: const TextStyle(
                  color: Color(0xFF14EFCD), fontWeight: FontWeight.bold),
            ),
            const TextSpan(text: " could save you approximately "),
            TextSpan(
              text: plan.totalInterestSavedFormatted ??
                  "\$${plan.totalInterestSaved ?? 0}",
              style: const TextStyle(
                  color: Color(0xFF1F2937), fontWeight: FontWeight.bold),
            ),
            const TextSpan(text: " in total interest over the loan term."),
          ],
        ),
      ),
    );
  }

  Widget _buildMarketComparisonCard(MarketComparison data) {
    num userRate = data.userRate ?? 0;
    num avgRate = data.averageRate ?? 0;

    return _buildInsightsCard(
      icon: Icons.insert_chart,
      iconColor: const Color(0xFF14EFCD),
      title: "Local Market Comparison",
      subtitle: data.comparedTo != null
          ? "Compared to ${data.comparedTo}"
          : "Compared to average",
      badgeText: "",
      badgeColor: Colors.transparent,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (data.ratingLabel != null && data.ratingLabel!.isNotEmpty) ...[
            Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  data.ratingLabel!,
                  style: const TextStyle(
                      color: Color(0xFF16A34A),
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text("Your Rate",
                        style:
                            TextStyle(color: Color(0xFF9CA3AF), fontSize: 12)),
                    const SizedBox(height: 4),
                    Text("$userRate%",
                        style: const TextStyle(
                            color: Color(0xFF1F2937),
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Container(
                  width: 1,
                  height: 40,
                  color: const Color(0xFFE2E8F0),
                  margin: const EdgeInsets.symmetric(horizontal: 16)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text("Avg Rate",
                        style:
                            TextStyle(color: Color(0xFF9CA3AF), fontSize: 12)),
                    const SizedBox(height: 4),
                    Text("$avgRate%",
                        style: const TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            data.advice ?? "",
            style: const TextStyle(
                color: Color(0xFF4B5563), fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildRefinancingAlertCard(RefinancingAlert alert) {
    return _buildInsightsCard(
      icon: Icons.notifications_active,
      iconColor: const Color(0xFFF97316),
      iconBgColor: const Color(0xFFFFEDD5),
      title: alert.title ?? "Refinancing Alert",
      subtitle: alert.subtitle ?? "Future opportunity",
      badgeText: "",
      badgeColor: Colors.transparent,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            alert.description ?? "",
            style: const TextStyle(
                color: Color(0xFF4B5563), fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Container(
                        height: 6,
                        decoration: BoxDecoration(
                            color: const Color(0xFFE2E8F0),
                            borderRadius: BorderRadius.circular(3))),
                    FractionallySizedBox(
                      widthFactor: alert.probability == 'high' ? 0.75 : 0.4,
                      child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                              color: const Color(0xFFF97316),
                              borderRadius: BorderRadius.circular(3))),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "${alert.probability ?? 'Medium'} Probability",
                style: const TextStyle(
                    color: Color(0xFFF97316),
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRiskAssessmentCard(RiskAssessment risk) {
    return _buildInsightsCard(
      icon: Icons.warning_amber_rounded,
      iconColor: const Color(0xFFEAB308),
      iconBgColor: const Color(0xFFFEF9C3),
      title: "Risk Assessment",
      subtitle: "Overall Risk: ${risk.overallRisk?.toUpperCase() ?? 'UNKNOWN'}",
      badgeText: "",
      badgeColor: Colors.transparent,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (risk.warnings != null && risk.warnings!.isNotEmpty) ...[
            const Text("Warnings",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
            const SizedBox(height: 8),
            ...risk.warnings!.map((w) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("• ",
                          style: TextStyle(
                              color: Color(0xFFEAB308),
                              fontWeight: FontWeight.bold)),
                      Expanded(
                          child: Text(w,
                              style: const TextStyle(
                                  color: Color(0xFF4B5563), fontSize: 13))),
                    ],
                  ),
                )),
            const SizedBox(height: 12),
          ],
          if (risk.positives != null && risk.positives!.isNotEmpty) ...[
            const Text("Positives",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
            const SizedBox(height: 8),
            ...risk.positives!.map((p) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("• ",
                          style: TextStyle(
                              color: Color(0xFF10B981),
                              fontWeight: FontWeight.bold)),
                      Expanded(
                          child: Text(p,
                              style: const TextStyle(
                                  color: Color(0xFF4B5563), fontSize: 13))),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }

  Widget _buildActionItemsCard(List<ActionItem> actions) {
    return _buildInsightsCard(
      icon: Icons.check_circle_outline,
      iconColor: const Color(0xFF3ac0b5),
      iconBgColor: const Color(0xFFE6F7F5),
      title: "Suggested Actions",
      subtitle: "Next steps for your property",
      badgeText: "",
      badgeColor: Colors.transparent,
      content: Column(
        children: actions.map((item) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  item.priority == 'high'
                      ? Icons.priority_high
                      : Icons.keyboard_arrow_right,
                  color: item.priority == 'high'
                      ? const Color(0xFFEF4444)
                      : const Color(0xFF64748B),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.action ?? "",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Color(0xFF1F2937))),
                      if (item.impact != null)
                        Text("Impact: ${item.impact}",
                            style: const TextStyle(
                                fontSize: 12, color: Color(0xFF6B7280))),
                    ],
                  ),
                )
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSummaryCard(Summary summary) {
    return _buildInsightsCard(
      icon: Icons.lightbulb_outline,
      iconColor: const Color(0xFFF59E0B),
      iconBgColor: const Color(0xFFFEF3C7),
      title: summary.title ?? "Executive Summary",
      subtitle: summary.subtitle ?? "At a glance",
      badgeText: "",
      badgeColor: Colors.transparent,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (summary.scoreLabel != null && summary.scoreLabel!.isNotEmpty) ...[
            Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  summary.scoreLabel!,
                  style: const TextStyle(
                      color: Color(0xFFF59E0B),
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text("Score: ${summary.overallScore}/100",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              const SizedBox(width: 8),
              Text("Risk: ${summary.riskLevel?.toUpperCase()}",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: summary.riskLevel == 'high'
                          ? Colors.red
                          : Colors.green)),
            ],
          ),
          const SizedBox(height: 12),
          if (summary.highlights != null)
            ...summary.highlights!.map((h) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("• ",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Expanded(
                            child: Text(h,
                                style:
                                    const TextStyle(color: Color(0xFF4B5563)))),
                      ]),
                )),
        ],
      ),
    );
  }

  Widget _buildBankRecommendationsCard(List<BankRecommendation> banks) {
    return _buildInsightsCard(
      icon: Icons.account_balance,
      iconColor: const Color(0xFF3B82F6),
      iconBgColor: const Color(0xFFDBEAFE),
      title: "Recommended Banks",
      subtitle: "Top options in your region",
      badgeText: "",
      badgeColor: Colors.transparent,
      content: Column(
        children: banks.map((bank) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(bank.bankName ?? "Unknown Bank",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                    const SizedBox(width: 8),
                    Text("${bank.interestRate}%",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3B82F6),
                            fontSize: 16)),
                  ],
                ),
                if (bank.bestFor != null) ...[
                  const SizedBox(height: 4),
                  Text("Best for: ${bank.bestFor}",
                      style: const TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Color(0xFF6B7280),
                          fontSize: 12)),
                ],
                const SizedBox(height: 8),
                if (bank.pros != null && bank.pros!.isNotEmpty)
                  Text("Pros: ${bank.pros!.join(', ')}",
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF10B981))),
                if (bank.cons != null && bank.cons!.isNotEmpty)
                  Text("Cons: ${bank.cons!.join(', ')}",
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFFEF4444))),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNegotiationStrategiesCard(List<NegotiationStrategy> strategies) {
    return _buildInsightsCard(
      icon: Icons.handshake,
      iconColor: const Color(0xFF8B5CF6),
      iconBgColor: const Color(0xFFEDE9FE),
      title: "Negotiation Strategies",
      subtitle: "How to get a better deal",
      badgeText: "",
      badgeColor: Colors.transparent,
      content: Column(
        children: strategies.map((strategy) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(strategy.title ?? "Strategy",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 6),
                Text(strategy.description ?? "",
                    style: const TextStyle(
                        fontSize: 13, color: Color(0xFF4B5563))),
                if (strategy.steps != null && strategy.steps!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  const Text("Steps:",
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                  ...strategy.steps!.map((step) => Text("• $step",
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF6B7280)))),
                ]
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTaxImplicationsCard(TaxImplications tax) {
    return _buildInsightsCard(
      icon: Icons.receipt_long,
      iconColor: const Color(0xFF06B6D4),
      iconBgColor: const Color(0xFFCFFAFE),
      title: "Tax Implications",
      subtitle: "Region: ${tax.region ?? 'Unknown'}",
      badgeText: "",
      badgeColor: Colors.transparent,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text("Interest Deductible?",
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 8),
              Text(tax.deductibleInterest == true ? "Yes" : "No",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: tax.deductibleInterest == true
                          ? Colors.green
                          : Colors.red)),
            ],
          ),
          const SizedBox(height: 8),
          if (tax.estimatedTaxSavings != null)
            Text("Est. Annual Savings: \$${tax.estimatedTaxSavings}",
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          if (tax.notes != null)
            ...tax.notes!.map((note) => Text("• $note",
                style:
                    const TextStyle(fontSize: 13, color: Color(0xFF4B5563)))),
        ],
      ),
    );
  }

  Widget _buildInsuranceRecommendationsCard(
      List<InsuranceRecommendation> insurances) {
    return _buildInsightsCard(
      icon: Icons.shield,
      iconColor: const Color(0xFFEAB308),
      iconBgColor: const Color(0xFFFEF9C3),
      title: "Insurance Recommendations",
      subtitle: "Protect your investment",
      badgeText: "",
      badgeColor: Colors.transparent,
      content: Column(
        children: insurances.map((ins) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(ins.required == true ? Icons.error : Icons.info,
                    color: ins.required == true ? Colors.red : Colors.blue,
                    size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ins.type ?? "Insurance",
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      if (ins.recommendation != null)
                        Text(ins.recommendation!,
                            style: const TextStyle(
                                fontSize: 13, color: Color(0xFF4B5563))),
                      if (ins.estimatedMonthlyCost != null)
                        Text("Est. Cost: \$${ins.estimatedMonthlyCost}/mo",
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF6B7280))),
                    ],
                  ),
                )
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildExtraPaymentImpactCard(ExtraPaymentImpact impact) {
    return _buildInsightsCard(
      icon: Icons.payments,
      iconColor: const Color(0xFF10B981),
      iconBgColor: const Color(0xFFD1FAE5),
      title: "Extra Payment Impact",
      subtitle: "Various scenarios based on extra payments",
      badgeText: "",
      badgeColor: Colors.transparent,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (impact.lumpSum != null) ...[
            const Text("Lump Sum Impact:",
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text(impact.lumpSum.toString(),
                style: const TextStyle(fontSize: 13, color: Color(0xFF4B5563))),
            const SizedBox(height: 8),
          ],
          if (impact.monthlyExtra != null) ...[
            const Text("Monthly Extra Impact:",
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text(impact.monthlyExtra.toString(),
                style: const TextStyle(fontSize: 13, color: Color(0xFF4B5563))),
            const SizedBox(height: 8),
          ],
          if (impact.biweeklyPayments != null) ...[
            const Text("Bi-Weekly Payments Impact:",
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text(impact.biweeklyPayments.toString(),
                style: const TextStyle(fontSize: 13, color: Color(0xFF4B5563))),
          ]
        ],
      ),
    );
  }

  Widget _buildAmortizationSnapshotCard(AmortizationSnapshot snapshot) {
    return _buildInsightsCard(
      icon: Icons.table_chart,
      iconColor: const Color(0xFF6366F1),
      iconBgColor: const Color(0xFFE0E7FF),
      title: "Amortization Snapshot",
      subtitle: "A quick view of interest vs principal",
      badgeText: "",
      badgeColor: Colors.transparent,
      content: Column(
        children: [
          _buildSnapshotRow(
              "First Year Interest", "\$${snapshot.firstYearInterest ?? 0}"),
          _buildSnapshotRow(
              "First Year Principal", "\$${snapshot.firstYearPrincipal ?? 0}"),
          const Divider(),
          _buildSnapshotRow(
              "Total Interest",
              snapshot.totalInterestFormatted ??
                  "\$${snapshot.totalInterest ?? 0}",
              isBold: true),
          _buildSnapshotRow("Total Cost",
              snapshot.totalCostFormatted ?? "\$${snapshot.totalCost ?? 0}",
              isBold: true),
        ],
      ),
    );
  }

  Widget _buildSnapshotRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(label,
                style: TextStyle(
                    fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                    color: const Color(0xFF4B5563))),
          ),
          const SizedBox(width: 8),
          Text(value,
              style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildInsightsCard({
    required IconData icon,
    required Color iconColor,
    Color? iconBgColor,
    required String title,
    required String subtitle,
    required String badgeText,
    required Color badgeColor,
    required Widget content,
    String? actionText,
    VoidCallback? onActionTap,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconBgColor ?? iconColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              color: Color(0xFF1F2937),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (badgeText.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: badgeColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              badgeText,
                              style: const TextStyle(
                                color: Color(0xFF0F172A),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ]
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          content,
          if (actionText != null && onActionTap != null) ...[
            const SizedBox(height: 16),
            GestureDetector(
              onTap: onActionTap,
              child: Text(
                actionText,
                style: const TextStyle(
                  color: Color(0xFF14EFCD),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildFloatingActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3ac0b5), Color(0xFF14EFCD)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF3ac0b5).withValues(alpha: 0.2),
                  spreadRadius: 2,
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(25),
                onTap: _isLoading ? null : _handleGenerateStrategy,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle,
                          color: Color(0xFF0F172A), size: 20),
                      const SizedBox(width: 8),
                      Text(
                        _isLoading ? "Generating..." : "Generate Strategy",
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiDisclaimer() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEFCE8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFEF9C3)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Color(0xFFA16207), size: 18),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "Disclaimer: AI recommendations are for informational purposes only and may not reflect current market reality. AI can make mistakes or base results on outdated information.",
              style: TextStyle(
                color: Color(0xFF854D0E),
                fontSize: 11,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
