import 'package:flutter/material.dart';

class AiInsightsPage extends StatelessWidget {
  const AiInsightsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // We will extract arguments here later to customize the insights,
    // for now we use an empty map or arguments if passed.
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
            {};

    final loanType = args['type'] ?? 'Mortgage';
    final country = args['country'] ?? 'United States';

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F8F9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
          onPressed: () => Navigator.pop(context),
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
            _buildOptimalRepaymentCard(),
            const SizedBox(height: 16),
            _buildMarketComparisonCard(6.2, 6.8),
            const SizedBox(height: 16),
            _buildRefinancingAlertCard(),
            const SizedBox(
                height: 120), // padding for floating action / bottom elements
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildFloatingActions(),
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
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF3ac0b5), Color(0xFF27a9bf)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 50, color: Color(0xFF94A3B8)),
                // In a real app we'd load the avatar image here
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
                    Text(
                      "Optimized for $country Market",
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 13,
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
              color: Color(0xFF14EFCD), // Cyan/Teal variant
              shape: BoxShape.circle,
            ),
            child:
                const Icon(Icons.bar_chart, color: Color(0xFF0F172A), size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildOptimalRepaymentCard() {
    return _buildInsightsCard(
      icon: Icons.savings,
      iconColor: const Color(0xFF14EFCD),
      title: "Optimal Repayment Plan",
      subtitle: "Based on current cash flow",
      badgeText: "TOP PICK",
      badgeColor: const Color(0xFF14EFCD),
      content: RichText(
        text: const TextSpan(
          style: TextStyle(color: Color(0xFF4B5563), fontSize: 14, height: 1.5),
          children: [
            TextSpan(text: "Making a "),
            TextSpan(
              text: "15% extra annual payment",
              style: TextStyle(
                  color: Color(0xFF14EFCD), fontWeight: FontWeight.bold),
            ),
            TextSpan(text: " could save you approximately "),
            TextSpan(
              text: "\$42,000",
              style: TextStyle(
                  color: Color(0xFF1F2937), fontWeight: FontWeight.bold),
            ),
            TextSpan(text: " in total interest over the loan term."),
          ],
        ),
      ),
      actionText: "Simulate this plan →",
      onActionTap: () {},
    );
  }

  Widget _buildMarketComparisonCard(double userRate, double avgRate) {
    return _buildInsightsCard(
      icon: Icons.insert_chart,
      iconColor: const Color(0xFF14EFCD),
      title: "Local Market Comparison",
      subtitle: "Compared to national average",
      badgeText: "",
      badgeColor: Colors.transparent,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
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
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  "${(avgRate - userRate).toStringAsFixed(1)}% Better",
                  style: const TextStyle(
                      color: Color(0xFF16A34A),
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            "You are currently beating the market average. Lock this rate if possible.",
            style:
                TextStyle(color: Color(0xFF4B5563), fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildRefinancingAlertCard() {
    return _buildInsightsCard(
      icon: Icons.notifications_active,
      iconColor: const Color(0xFFF97316),
      iconBgColor: const Color(0xFFFFEDD5),
      title: "Refinancing Alert",
      subtitle: "Future opportunity",
      badgeText: "",
      badgeColor: Colors.transparent,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Rates are projected to drop in Q3. Set a reminder to re-evaluate refinancing options then.",
            style:
                TextStyle(color: Color(0xFF4B5563), fontSize: 14, height: 1.5),
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
                      widthFactor: 0.75,
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
              const Text(
                "High Probability",
                style: TextStyle(
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
                        if (badgeText.isNotEmpty)
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
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
                onTap: () {},
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble,
                          color: Color(0xFF14EFCD), size: 20),
                      SizedBox(width: 8),
                      Text(
                        "Chat with Advisor",
                        style: TextStyle(
                          color: Color(0xFF1F2937),
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
          const SizedBox(height: 12),
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
                onTap: () {},
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle,
                          color: Color(0xFF0F172A), size: 20),
                      SizedBox(width: 8),
                      Text(
                        "Apply Strategy",
                        style: TextStyle(
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
}
