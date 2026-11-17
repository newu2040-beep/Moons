import 'package:flutter/material.dart';
import '../providers/app_state.dart';
import '../widgets/charts.dart';
import '../models/category.dart';
import '../theme/app_theme.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  bool _isExpenseMode = true;

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currency = appState.currencySymbol;

    final breakdownMap =
        _isExpenseMode ? appState.categoryExpensesMap : appState.categoryIncomeMap;
    final totalAmount =
        _isExpenseMode ? appState.totalExpense : appState.totalIncome;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics & Insights'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Income vs Expense comparative overview
              IncomeExpenseBarWidget(
                income: appState.totalIncome,
                expense: appState.totalExpense,
                currencySymbol: currency,
              ),
              const SizedBox(height: 20),

              // Breakdown Switcher Tabs
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF151C2C) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isExpenseMode = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _isExpenseMode
                                ? (isDark ? const Color(0xFF818CF8) : const Color(0xFF4F46E5))
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Expenses Breakdown',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: _isExpenseMode
                                  ? Colors.white
                                  : (isDark ? const Color(0xFF94A3B8) : Colors.grey.shade700),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isExpenseMode = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: !_isExpenseMode
                                ? MoonsTheme.incomeGreen
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Income Breakdown',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: !_isExpenseMode
                                  ? Colors.white
                                  : (isDark ? const Color(0xFF94A3B8) : Colors.grey.shade700),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Donut Chart Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF151C2C) : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark ? const Color(0xFF242E45) : Colors.grey.shade100,
                  ),
                ),
                child: Column(
                  children: [
                    DonutChartWidget(
                      categoryAmounts: breakdownMap,
                      totalAmount: totalAmount,
                      currencySymbol: currency,
                      centerTitle: _isExpenseMode ? 'Spent' : 'Earned',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Category Ranking List
              Text(
                'Category Ranking',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 12),

              if (breakdownMap.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF151C2C) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'No transaction data in this period',
                    style: TextStyle(
                      color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600,
                    ),
                  ),
                )
              else
                ...breakdownMap.entries.map((entry) {
                  final cat = TransactionCategory.getById(entry.key);
                  final amount = entry.value;
                  final percentage = totalAmount > 0 ? (amount / totalAmount) : 0.0;

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF151C2C) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark ? const Color(0xFF242E45) : Colors.grey.shade100,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: cat.color.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(cat.icon, color: cat.color, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                cat.name,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                                ),
                              ),
                            ),
                            Text(
                              '$currency${amount.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: percentage.clamp(0.0, 1.0),
                            minHeight: 8,
                            backgroundColor:
                                isDark ? const Color(0xFF1E273D) : Colors.grey.shade100,
                            valueColor: AlwaysStoppedAnimation(cat.color),
                          ),
                        ),
                      ],
                    ),
                  );
                }),

              const SizedBox(height: 24),

              // Moons Financial Insight Card
              _buildInsightCard(appState, isDark, currency),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInsightCard(AppState state, bool isDark, String currency) {
    final savingsRate = state.savingsRate;
    final highestCategoryEntry = state.categoryExpensesMap.entries.isNotEmpty
        ? state.categoryExpensesMap.entries.reduce((a, b) => a.value > b.value ? a : b)
        : null;

    final topCatName = highestCategoryEntry != null
        ? TransactionCategory.getById(highestCategoryEntry.key).name
        : 'N/A';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1B4B) : const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF6366F1).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome_rounded, color: Color(0xFF818CF8), size: 20),
              SizedBox(width: 8),
              Text(
                'Moons Orbit Insight',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF818CF8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            savingsRate >= 20
                ? 'Great financial gravity! You are saving ${savingsRate.toStringAsFixed(0)}% of your income. Your largest expense is in $topCatName.'
                : 'Your spending is currently outpacing your savings target. Check your $topCatName expenses to restore positive cash flow.',
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: isDark ? const Color(0xFFC7D2FE) : const Color(0xFF3730A3),
            ),
          ),
        ],
      ),
    );
  }
}
