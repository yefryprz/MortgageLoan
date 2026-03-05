class AiAnalysisResponse {
  final AiAnalysisData? analysis;

  AiAnalysisResponse({this.analysis});

  factory AiAnalysisResponse.fromJson(Map<String, dynamic> json) {
    return AiAnalysisResponse(
      analysis: json['analysis'] != null
          ? AiAnalysisData.fromJson(json['analysis'])
          : null,
    );
  }
}

class AiAnalysisData {
  final String? id;
  final String? createdAt;
  final String? region;
  final String? loanType;
  final String? status;
  final Summary? summary;
  final MarketComparison? marketComparison;
  final OptimalRepaymentPlan? optimalRepaymentPlan;
  final RefinancingAlert? refinancingAlert;
  final List<BankRecommendation>? bankRecommendations;
  final List<NegotiationStrategy>? negotiationStrategies;
  final RiskAssessment? riskAssessment;
  final TaxImplications? taxImplications;
  final List<InsuranceRecommendation>? insuranceRecommendations;
  final ExtraPaymentImpact? extraPaymentImpact;
  final AmortizationSnapshot? amortizationSnapshot;
  final List<ActionItem>? actionItems;

  AiAnalysisData({
    this.id,
    this.createdAt,
    this.region,
    this.loanType,
    this.status,
    this.summary,
    this.marketComparison,
    this.optimalRepaymentPlan,
    this.refinancingAlert,
    this.bankRecommendations,
    this.negotiationStrategies,
    this.riskAssessment,
    this.taxImplications,
    this.insuranceRecommendations,
    this.extraPaymentImpact,
    this.amortizationSnapshot,
    this.actionItems,
  });

  factory AiAnalysisData.fromJson(Map<String, dynamic> json) {
    return AiAnalysisData(
      id: json['id'] as String?,
      createdAt: json['createdAt'] as String?,
      region: json['region'] as String?,
      loanType: json['loanType'] as String?,
      status: json['status'] as String?,
      summary:
          json['summary'] != null ? Summary.fromJson(json['summary']) : null,
      marketComparison: json['marketComparison'] != null
          ? MarketComparison.fromJson(json['marketComparison'])
          : null,
      optimalRepaymentPlan: json['optimalRepaymentPlan'] != null
          ? OptimalRepaymentPlan.fromJson(json['optimalRepaymentPlan'])
          : null,
      refinancingAlert: json['refinancingAlert'] != null
          ? RefinancingAlert.fromJson(json['refinancingAlert'])
          : null,
      bankRecommendations: (json['bankRecommendations'] as List<dynamic>?)
          ?.map((e) => BankRecommendation.fromJson(e))
          .toList(),
      negotiationStrategies: (json['negotiationStrategies'] as List<dynamic>?)
          ?.map((e) => NegotiationStrategy.fromJson(e))
          .toList(),
      riskAssessment: json['riskAssessment'] != null
          ? RiskAssessment.fromJson(json['riskAssessment'])
          : null,
      taxImplications: json['taxImplications'] != null
          ? TaxImplications.fromJson(json['taxImplications'])
          : null,
      insuranceRecommendations:
          (json['insuranceRecommendations'] as List<dynamic>?)
              ?.map((e) => InsuranceRecommendation.fromJson(e))
              .toList(),
      extraPaymentImpact: json['extraPaymentImpact'] != null
          ? ExtraPaymentImpact.fromJson(json['extraPaymentImpact'])
          : null,
      amortizationSnapshot: json['amortizationSnapshot'] != null
          ? AmortizationSnapshot.fromJson(json['amortizationSnapshot'])
          : null,
      actionItems: (json['actionItems'] as List<dynamic>?)
          ?.map((e) => ActionItem.fromJson(e))
          .toList(),
    );
  }
}

class Summary {
  final String? title;
  final String? subtitle;
  final num? overallScore;
  final String? scoreLabel;
  final String? riskLevel;
  final List<String>? highlights;

  Summary(
      {this.title,
      this.subtitle,
      this.overallScore,
      this.scoreLabel,
      this.riskLevel,
      this.highlights});

  factory Summary.fromJson(Map<String, dynamic> json) {
    return Summary(
      title: json['title'] as String?,
      subtitle: json['subtitle'] as String?,
      overallScore: json['overallScore'] as num?,
      scoreLabel: json['scoreLabel'] as String?,
      riskLevel: json['riskLevel'] as String?,
      highlights: (json['highlights'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );
  }
}

class MarketComparison {
  final num? userRate;
  final num? averageRate;
  final num? rateDifference;
  final String? ratingLabel;
  final String? comparedTo;
  final String? advice;
  final String? historicalTrend;
  final String? forecastNote;

  MarketComparison({
    this.userRate,
    this.averageRate,
    this.rateDifference,
    this.ratingLabel,
    this.comparedTo,
    this.advice,
    this.historicalTrend,
    this.forecastNote,
  });

  factory MarketComparison.fromJson(Map<String, dynamic> json) {
    return MarketComparison(
      userRate: json['userRate'] as num?,
      averageRate: json['averageRate'] as num?,
      rateDifference: json['rateDifference'] as num?,
      ratingLabel: json['ratingLabel'] as String?,
      comparedTo: json['comparedTo'] as String?,
      advice: json['advice'] as String?,
      historicalTrend: json['historicalTrend'] as String?,
      forecastNote: json['forecastNote'] as String?,
    );
  }
}

class OptimalRepaymentPlan {
  final String? title;
  final String? tag;
  final String? description;
  final num? extraPaymentPercent;
  final String? extraPaymentType;
  final num? totalInterestSaved;
  final String? totalInterestSavedFormatted;
  final num? newLoanTermMonths;
  final num? originalLoanTermMonths;
  final num? monthsSaved;
  final bool? simulationAvailable;

  OptimalRepaymentPlan({
    this.title,
    this.tag,
    this.description,
    this.extraPaymentPercent,
    this.extraPaymentType,
    this.totalInterestSaved,
    this.totalInterestSavedFormatted,
    this.newLoanTermMonths,
    this.originalLoanTermMonths,
    this.monthsSaved,
    this.simulationAvailable,
  });

  factory OptimalRepaymentPlan.fromJson(Map<String, dynamic> json) {
    return OptimalRepaymentPlan(
      title: json['title'] as String?,
      tag: json['tag'] as String?,
      description: json['description'] as String?,
      extraPaymentPercent: json['extraPaymentPercent'] as num?,
      extraPaymentType: json['extraPaymentType'] as String?,
      totalInterestSaved: json['totalInterestSaved'] as num?,
      totalInterestSavedFormatted:
          json['totalInterestSavedFormatted'] as String?,
      newLoanTermMonths: json['newLoanTermMonths'] as num?,
      originalLoanTermMonths: json['originalLoanTermMonths'] as num?,
      monthsSaved: json['monthsSaved'] as num?,
      simulationAvailable: json['simulationAvailable'] as bool?,
    );
  }
}

class RefinancingAlert {
  final bool? active;
  final String? urgency;
  final String? probability;
  final String? title;
  final String? subtitle;
  final String? description;
  final num? projectedNewRate;
  final num? estimatedSavings;
  final String? estimatedSavingsFormatted;
  final String? recommendedAction;
  final String? timeframe;

  RefinancingAlert({
    this.active,
    this.urgency,
    this.probability,
    this.title,
    this.subtitle,
    this.description,
    this.projectedNewRate,
    this.estimatedSavings,
    this.estimatedSavingsFormatted,
    this.recommendedAction,
    this.timeframe,
  });

  factory RefinancingAlert.fromJson(Map<String, dynamic> json) {
    return RefinancingAlert(
      active: json['active'] as bool?,
      urgency: json['urgency'] as String?,
      probability: json['probability'] as String?,
      title: json['title'] as String?,
      subtitle: json['subtitle'] as String?,
      description: json['description'] as String?,
      projectedNewRate: json['projectedNewRate'] as num?,
      estimatedSavings: json['estimatedSavings'] as num?,
      estimatedSavingsFormatted: json['estimatedSavingsFormatted'] as String?,
      recommendedAction: json['recommendedAction'] as String?,
      timeframe: json['timeframe'] as String?,
    );
  }
}

class BankRecommendation {
  final num? rank;
  final String? bankName;
  final num? interestRate;
  final num? apr;
  final num? loanTermYears;
  final num? monthlyPayment;
  final String? monthlyPaymentFormatted;
  final num? totalInterest;
  final num? closingCosts;
  final List<String>? pros;
  final List<String>? cons;
  final String? bestFor;
  final String? specialOffers;
  final String? url;

  BankRecommendation({
    this.rank,
    this.bankName,
    this.interestRate,
    this.apr,
    this.loanTermYears,
    this.monthlyPayment,
    this.monthlyPaymentFormatted,
    this.totalInterest,
    this.closingCosts,
    this.pros,
    this.cons,
    this.bestFor,
    this.specialOffers,
    this.url,
  });

  factory BankRecommendation.fromJson(Map<String, dynamic> json) {
    return BankRecommendation(
      rank: json['rank'] as num?,
      bankName: json['bankName'] as String?,
      interestRate: json['interestRate'] as num?,
      apr: json['apr'] as num?,
      loanTermYears: json['loanTermYears'] as num?,
      monthlyPayment: json['monthlyPayment'] as num?,
      monthlyPaymentFormatted: json['monthlyPaymentFormatted'] as String?,
      totalInterest: json['totalInterest'] as num?,
      closingCosts: json['closingCosts'] as num?,
      pros: (json['pros'] as List<dynamic>?)?.map((e) => e as String).toList(),
      cons: (json['cons'] as List<dynamic>?)?.map((e) => e as String).toList(),
      bestFor: json['bestFor'] as String?,
      specialOffers: json['specialOffers'] as String?,
      url: json['url'] as String?,
    );
  }
}

class NegotiationStrategy {
  final num? id;
  final String? title;
  final String? difficulty;
  final num? potentialSavings;
  final String? potentialSavingsFormatted;
  final String? description;
  final List<String>? steps;
  final List<String>? talkingPoints;

  NegotiationStrategy({
    this.id,
    this.title,
    this.difficulty,
    this.potentialSavings,
    this.potentialSavingsFormatted,
    this.description,
    this.steps,
    this.talkingPoints,
  });

  factory NegotiationStrategy.fromJson(Map<String, dynamic> json) {
    return NegotiationStrategy(
      id: json['id'] as num?,
      title: json['title'] as String?,
      difficulty: json['difficulty'] as String?,
      potentialSavings: json['potentialSavings'] as num?,
      potentialSavingsFormatted: json['potentialSavingsFormatted'] as String?,
      description: json['description'] as String?,
      steps:
          (json['steps'] as List<dynamic>?)?.map((e) => e as String).toList(),
      talkingPoints: (json['talkingPoints'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );
  }
}

class RiskAssessment {
  final String? overallRisk;
  final num? debtToIncomeRatio;
  final String? debtToIncomeStatus;
  final num? loanToValueRatio;
  final String? loanToValueStatus;
  final num? affordabilityIndex;
  final List<String>? warnings;
  final List<String>? positives;

  RiskAssessment({
    this.overallRisk,
    this.debtToIncomeRatio,
    this.debtToIncomeStatus,
    this.loanToValueRatio,
    this.loanToValueStatus,
    this.affordabilityIndex,
    this.warnings,
    this.positives,
  });

  factory RiskAssessment.fromJson(Map<String, dynamic> json) {
    return RiskAssessment(
      overallRisk: json['overallRisk'] as String?,
      debtToIncomeRatio: json['debtToIncomeRatio'] as num?,
      debtToIncomeStatus: json['debtToIncomeStatus'] as String?,
      loanToValueRatio: json['loanToValueRatio'] as num?,
      loanToValueStatus: json['loanToValueStatus'] as String?,
      affordabilityIndex: json['affordabilityIndex'] as num?,
      warnings: (json['warnings'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      positives: (json['positives'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );
  }
}

class TaxImplications {
  final bool? applicable;
  final String? region;
  final bool? deductibleInterest;
  final num? estimatedAnnualDeduction;
  final String? estimatedAnnualDeductionFormatted;
  final num? estimatedTaxSavings;
  final String? estimatedTaxSavingsFormatted;
  final List<String>? notes;

  TaxImplications({
    this.applicable,
    this.region,
    this.deductibleInterest,
    this.estimatedAnnualDeduction,
    this.estimatedAnnualDeductionFormatted,
    this.estimatedTaxSavings,
    this.estimatedTaxSavingsFormatted,
    this.notes,
  });

  factory TaxImplications.fromJson(Map<String, dynamic> json) {
    return TaxImplications(
      applicable: json['applicable'] as bool?,
      region: json['region'] as String?,
      deductibleInterest: json['deductibleInterest'] as bool?,
      estimatedAnnualDeduction: json['estimatedAnnualDeduction'] as num?,
      estimatedAnnualDeductionFormatted:
          json['estimatedAnnualDeductionFormatted'] as String?,
      estimatedTaxSavings: json['estimatedTaxSavings'] as num?,
      estimatedTaxSavingsFormatted:
          json['estimatedTaxSavingsFormatted'] as String?,
      notes:
          (json['notes'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );
  }
}

class InsuranceRecommendation {
  final String? type;
  final bool? required;
  final String? reason;
  final num? estimatedMonthlyCost;
  final String? estimatedMonthlyCostFormatted;
  final String? recommendation;

  InsuranceRecommendation({
    this.type,
    this.required,
    this.reason,
    this.estimatedMonthlyCost,
    this.estimatedMonthlyCostFormatted,
    this.recommendation,
  });

  factory InsuranceRecommendation.fromJson(Map<String, dynamic> json) {
    return InsuranceRecommendation(
      type: json['type'] as String?,
      required: json['required'] as bool?,
      reason: json['reason'] as String?,
      estimatedMonthlyCost: json['estimatedMonthlyCost'] as num?,
      estimatedMonthlyCostFormatted:
          json['estimatedMonthlyCostFormatted'] as String?,
      recommendation: json['recommendation'] as String?,
    );
  }
}

class ExtraPaymentImpact {
  // We can skip deep parsing of lumpSum, monthlyExtra, biweeklyPayments for now
  // or define them as Maps since not strictly typed in all UI usages.
  final Map<String, dynamic>? lumpSum;
  final Map<String, dynamic>? monthlyExtra;
  final Map<String, dynamic>? biweeklyPayments;

  ExtraPaymentImpact({
    this.lumpSum,
    this.monthlyExtra,
    this.biweeklyPayments,
  });

  factory ExtraPaymentImpact.fromJson(Map<String, dynamic> json) {
    return ExtraPaymentImpact(
      lumpSum: json['lumpSum'] as Map<String, dynamic>?,
      monthlyExtra: json['monthlyExtra'] as Map<String, dynamic>?,
      biweeklyPayments: json['biweeklyPayments'] as Map<String, dynamic>?,
    );
  }
}

class AmortizationSnapshot {
  final num? firstYearPrincipal;
  final num? firstYearInterest;
  final num? midTermPrincipal;
  final num? midTermInterest;
  final num? lastYearPrincipal;
  final num? lastYearInterest;
  final num? totalInterest;
  final String? totalInterestFormatted;
  final num? totalCost;
  final String? totalCostFormatted;

  AmortizationSnapshot({
    this.firstYearPrincipal,
    this.firstYearInterest,
    this.midTermPrincipal,
    this.midTermInterest,
    this.lastYearPrincipal,
    this.lastYearInterest,
    this.totalInterest,
    this.totalInterestFormatted,
    this.totalCost,
    this.totalCostFormatted,
  });

  factory AmortizationSnapshot.fromJson(Map<String, dynamic> json) {
    return AmortizationSnapshot(
      firstYearPrincipal: json['firstYearPrincipal'] as num?,
      firstYearInterest: json['firstYearInterest'] as num?,
      midTermPrincipal: json['midTermPrincipal'] as num?,
      midTermInterest: json['midTermInterest'] as num?,
      lastYearPrincipal: json['lastYearPrincipal'] as num?,
      lastYearInterest: json['lastYearInterest'] as num?,
      totalInterest: json['totalInterest'] as num?,
      totalInterestFormatted: json['totalInterestFormatted'] as String?,
      totalCost: json['totalCost'] as num?,
      totalCostFormatted: json['totalCostFormatted'] as String?,
    );
  }
}

class ActionItem {
  final String? priority;
  final String? action;
  final String? deadline;
  final String? impact;

  ActionItem({
    this.priority,
    this.action,
    this.deadline,
    this.impact,
  });

  factory ActionItem.fromJson(Map<String, dynamic> json) {
    return ActionItem(
      priority: json['priority'] as String?,
      action: json['action'] as String?,
      deadline: json['deadline'] as String?,
      impact: json['impact'] as String?,
    );
  }
}
