import 'package:flutter/material.dart';
import 'package:mortgageloan/src/database/hive.dart';
import 'package:mortgageloan/src/models/loan_model.dart';
import 'package:mortgageloan/src/models/compound_interest_model.dart';
import 'package:mortgageloan/src/widgets/adbanner_widget.dart';
import 'package:mortgageloan/src/widgets/drawer_widget.dart';
import 'package:intl/intl.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final loanRepo = LoanData();
  int _selectedTabIndex = 0;

  final NumberFormat _currencyFormat =
      NumberFormat.currency(locale: 'en_US', symbol: '\$');
  final DateFormat _timeFormat = DateFormat('h:mm a');

  InterstitialAd? _interstitialAd;

  @override
  void initState() {
    super.initState();
    _loadInterstitialAd();
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    super.dispose();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: "ca-app-pub-4574158711047577/4568082033",
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              _interstitialAd = null;
              loanRepo.resetAdCount("historyCount");
              _loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (err) {
          _interstitialAd = null;
        },
      ),
    );
  }

  Future<void> _handleAdDetailNavigation(VoidCallback onNavigate) async {
    onNavigate();
    int adCount = await loanRepo.getAdCount("historyCount");
    if (adCount >= 4) {
      // 5 clicks
      if (_interstitialAd != null) {
        await _interstitialAd!.show();
      } else {
        loanRepo.resetAdCount("historyCount");
      }
    } else {
      loanRepo.AdCountUp("historyCount");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF6F8F9),
      drawer: CustomDrawer(),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: _selectedTabIndex == 0
                ? _buildLoanHistory()
                : _buildCompoundHistory(),
          ),
        ],
      ),
      bottomNavigationBar: CustomAdBanner(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF6F8F9),
        ),
      ),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.menu, color: Color(0xFF1F2937)),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      title: const Text(
        "Calculation History",
        style: TextStyle(
          color: Color(0xFF1F2937),
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Color(0xFF6B7280)),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.delete_sweep, color: Color(0xFF6B7280)),
          onPressed: () => _showClearAllConfirmDialog(context),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTabIndex = 0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedTabIndex == 0
                      ? const Color(0xFFE6F7F5)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(26),
                ),
                alignment: Alignment.center,
                child: Text(
                  "Loans",
                  style: TextStyle(
                    color: _selectedTabIndex == 0
                        ? const Color(0xFF3ac0b5)
                        : const Color(0xFF6B7280),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTabIndex = 1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedTabIndex == 1
                      ? const Color(0xFFE6F7F5)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(26),
                ),
                alignment: Alignment.center,
                child: Text(
                  "Compound Interest",
                  style: TextStyle(
                    color: _selectedTabIndex == 1
                        ? const Color(0xFF3ac0b5)
                        : const Color(0xFF6B7280),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getDateLabel(DateTime? date) {
    if (date == null) return "OLDER";
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final aWeekAgo = today.subtract(const Duration(days: 7));

    final itemDate = DateTime(date.year, date.month, date.day);

    if (itemDate == today) {
      return "TODAY";
    } else if (itemDate == yesterday) {
      return "YESTERDAY";
    } else if (itemDate.isAfter(aWeekAgo)) {
      return "LAST WEEK";
    } else {
      return DateFormat('MMM yyyy').format(date).toUpperCase();
    }
  }

  Widget _buildLoanHistory() {
    return FutureBuilder<List<Loan>>(
      future: loanRepo.selectRecords(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(
              child: CircularProgressIndicator(color: Color(0xFF3ac0b5)));
        }

        if (snapshot.data?.isEmpty ?? true) {
          return _buildEmptyState("No loan history yet.");
        }

        List<Loan> sortedLoans = List.from(snapshot.data!);
        sortedLoans.sort((a, b) =>
            (b.date ?? DateTime(2000)).compareTo(a.date ?? DateTime(2000)));

        List<Widget> listItems = [];
        String currentLabel = "";

        for (var loan in sortedLoans) {
          String label = _getDateLabel(loan.date);
          if (label != currentLabel) {
            listItems.add(Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 8, left: 24),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF9CA3AF),
                  letterSpacing: 1.2,
                ),
              ),
            ));
            currentLabel = label;
          }
          listItems.add(_buildLoanCard(loan));
        }

        return ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 24),
          children: listItems,
        );
      },
    );
  }

  Widget _buildCompoundHistory() {
    return FutureBuilder<List<CompoundInterest>>(
      future: loanRepo.getCompoundInterestHistory(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(
              child: CircularProgressIndicator(color: Color(0xFF3ac0b5)));
        }

        if (snapshot.data?.isEmpty ?? true) {
          return _buildEmptyState("No investment history yet.");
        }

        List<CompoundInterest> sortedData = List.from(snapshot.data!);
        sortedData.sort((a, b) =>
            (b.date ?? DateTime(2000)).compareTo(a.date ?? DateTime(2000)));

        List<Widget> listItems = [];
        String currentLabel = "";

        for (var data in sortedData) {
          String label = _getDateLabel(data.date);
          if (label != currentLabel) {
            listItems.add(Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 8, left: 24),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF9CA3AF),
                  letterSpacing: 1.2,
                ),
              ),
            ));
            currentLabel = label;
          }
          listItems.add(_buildCompoundCard(data));
        }

        return ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 24),
          children: listItems,
        );
      },
    );
  }

  Widget _buildLoanCard(Loan data) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            spreadRadius: 2,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE6F7F5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.home,
                        color: Color(0xFF3ac0b5), size: 18),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Mortgage",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
              Text(
                data.date != null ? _timeFormat.format(data.date!) : "",
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                _currencyFormat.format(data.amount ?? 0).split('.')[0],
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF27a9bf),
                ),
              ),
              Text(
                '.${_currencyFormat.format(data.amount ?? 0).split('.')[1]}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "${data.term ?? 0}-year fixed rate mortgage at ${(data.rate ?? 0).toStringAsFixed(2)}% APR.",
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "MONTHLY",
                        style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF9CA3AF),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _currencyFormat.format(data.payment ?? 0),
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "TOTAL INTEREST",
                        style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF9CA3AF),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _currencyFormat.format(data.totalInterest ?? 0),
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _handleAdDetailNavigation(() {
                      Navigator.pushNamed(context, 'amortization',
                          arguments: data);
                    });
                  },
                  icon: const Icon(Icons.calendar_month, size: 18),
                  label: const Text(
                    "View Schedule",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF27a9bf),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () {
                  _showDeleteConfirmDialog(context, () {
                    setState(() {
                      loanRepo.deleteRecord(data.id);
                    });
                  });
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                child: const Icon(Icons.delete_outline,
                    color: Color(0xFF94A3B8), size: 22),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompoundCard(CompoundInterest data) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            spreadRadius: 2,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE0F2FE),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.show_chart,
                        color: Color(0xFF0284C7), size: 18),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Investment",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
              Text(
                data.date != null ? _timeFormat.format(data.date!) : "",
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            "PROJECTED FINAL BALANCE",
            style: TextStyle(
                fontSize: 10,
                color: Color(0xFF9CA3AF),
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                _currencyFormat.format(data.result ?? 0).split('.')[0],
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF27a9bf),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "INITIAL PRINCIPAL",
                    style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF9CA3AF),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _currencyFormat.format(data.principal ?? 0).split('.')[0],
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937)),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    "INTEREST EARNED",
                    style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF9CA3AF),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "+${_currencyFormat.format((data.result ?? 0) - (data.principal ?? 0)).split('.')[0]}",
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF22C55E)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "INTEREST RATE",
                    style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF9CA3AF),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${data.rate?.toStringAsFixed(2) ?? '0.00'}%",
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937)),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    "PERIOD",
                    style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF9CA3AF),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${data.years ?? 0} ${(data.years ?? 0) == 1 ? 'Year' : 'Years'}",
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    List<Map<String, dynamic>> yearlyDetails = [];
                    double currentBalance = data.principal ?? 0;

                    for (int i = 1; i <= (data.years ?? 0); i++) {
                      double previousBalance = currentBalance;
                      double interestForYear =
                          currentBalance * ((data.rate ?? 0) / 100);
                      currentBalance = previousBalance + interestForYear;

                      yearlyDetails.add({
                        'year': i,
                        'startBalance': previousBalance,
                        'interest': interestForYear,
                        'endBalance': currentBalance,
                      });
                    }
                    _handleAdDetailNavigation(() {
                      Navigator.pushNamed(context, 'compound_breakdown',
                          arguments: {
                            'principal': data.principal ?? 0,
                            'rate': data.rate ?? 0,
                            'result': data.result ?? 0,
                            'yearlyDetails': yearlyDetails,
                          });
                    });
                  },
                  icon: const Icon(Icons.visibility_outlined, size: 18),
                  label: const Text(
                    "View Details",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF27a9bf),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () {
                  _showDeleteConfirmDialog(context, () {
                    setState(() {
                      loanRepo.deleteCompoundInterest(data.id);
                    });
                  });
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                child: const Icon(Icons.delete_outline,
                    color: Color(0xFF94A3B8), size: 22),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.history_toggle_off,
              size: 64, color: const Color(0xFF94A3B8).withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 16,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, VoidCallback onDelete) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Delete Record',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
        content: const Text(
          'Are you sure you want to delete this record?',
          style: TextStyle(color: Color(0xFF6B7280)),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actionsPadding: const EdgeInsets.only(right: 16, bottom: 16),
        actions: [
          TextButton(
            child: const Text('Cancel',
                style: TextStyle(
                    color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444), // Cleaner red
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12))),
            child: const Text('Delete',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            onPressed: () {
              Navigator.pop(context);
              onDelete();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Record deleted')),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showClearAllConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Clear History',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
        content: const Text(
          'Are you sure you want to delete all records?',
          style: TextStyle(color: Color(0xFF6B7280)),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actionsPadding: const EdgeInsets.only(right: 16, bottom: 16),
        actions: [
          TextButton(
            child: const Text('Cancel',
                style: TextStyle(
                    color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12))),
            child: const Text('Clear All',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            onPressed: () {
              setState(() {
                loanRepo.deleteAllRecord();
                loanRepo.deleteAllCompoundInterest();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All records cleared')),
              );
            },
          ),
        ],
      ),
    );
  }
}
