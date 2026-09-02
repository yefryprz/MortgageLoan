import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mortgageloan/src/models/loan_model.dart';
import 'package:mortgageloan/src/screens/ai_insights_page.dart';
import 'package:mortgageloan/src/screens/amortization_page.dart';
import 'package:mortgageloan/src/screens/compound_breakdown_page.dart';
import 'package:mortgageloan/src/screens/compound_interest_page.dart';
import 'package:mortgageloan/src/screens/currencyconvert_page.dart';
import 'package:mortgageloan/src/screens/history_page.dart';
import 'package:mortgageloan/src/screens/home_page.dart';
import 'package:mortgageloan/src/screens/loan_simulator_page.dart';
import 'package:mortgageloan/src/services/analytics_service.dart';

class AppRoutes {
  const AppRoutes._();

  static const String home = '/';
  static const String amortization = '/amortization';
  static const String history = '/history';
  static const String currency = '/currency';
  static const String compound = '/compound';
  static const String compoundBreakdown = '/compound_breakdown';
  static const String simulator = '/simulator';
  static const String aiInsights = '/ai_insights';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  observers: [AnalyticsService.getObserver()],
  routes: <RouteBase>[
    GoRoute(
      path: AppRoutes.home,
      builder: (BuildContext context, GoRouterState state) {
        return const HomePage();
      },
    ),
    GoRoute(
      path: AppRoutes.amortization,
      builder: (BuildContext context, GoRouterState state) {
        final loan = state.extra as Loan?;
        return AmortizationPage(loan: loan);
      },
    ),
    GoRoute(
      path: AppRoutes.history,
      builder: (BuildContext context, GoRouterState state) {
        return const HistoryPage();
      },
    ),
    GoRoute(
      path: AppRoutes.currency,
      builder: (BuildContext context, GoRouterState state) {
        return const CurrencyConvertPage();
      },
    ),
    GoRoute(
      path: AppRoutes.compound,
      builder: (BuildContext context, GoRouterState state) {
        return const CompoundInterestPage();
      },
    ),
    GoRoute(
      path: AppRoutes.compoundBreakdown,
      builder: (BuildContext context, GoRouterState state) {
        final args = state.extra as Map<String, dynamic>?;
        return CompoundBreakdownPage(args: args);
      },
    ),
    GoRoute(
      path: AppRoutes.simulator,
      builder: (BuildContext context, GoRouterState state) {
        return const LoanSimulatorPage();
      },
    ),
    GoRoute(
      path: AppRoutes.aiInsights,
      builder: (BuildContext context, GoRouterState state) {
        final args = state.extra as Map<String, dynamic>?;
        return AiInsightsPage(args: args);
      },
    ),
  ],
);
