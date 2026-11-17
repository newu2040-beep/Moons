import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../providers/app_state.dart';
import '../models/category.dart';
import '../models/savings_goal.dart';
import '../models/budget.dart';
import '../theme/app_theme.dart';

class ToolsScreen extends StatefulWidget {
  const ToolsScreen({super.key});

  @override
  State<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends State<ToolsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Built-in Financial Tools'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorColor: isDark ? const Color(0xFF818CF8) : const Color(0xFF4F46E5),
          labelColor: isDark ? const Color(0xFF818CF8) : const Color(0xFF4F46E5),
          unselectedLabelColor: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          tabs: const [
            Tab(text: 'Budgets', icon: Icon(Icons.pie_chart_outline_rounded)),
            Tab(text: 'Savings Vaults', icon: Icon(Icons.savings_outlined)),
            Tab(text: 'Loan / EMI Calc', icon: Icon(Icons.calculate_outlined)),
            Tab(text: 'Currency Converter', icon: Icon(Icons.currency_exchange_rounded)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _BudgetsTabView(),
          _SavingsVaultsTabView(),
          _LoanCalculatorTabView(),
          _CurrencyConverterTabView(),
        ],
      ),
    );
  }
}

// ---------------- TAB 1: BUDGETS ----------------
class _BudgetsTabView extends StatelessWidget {
  const _BudgetsTabView();

  void _showAddBudgetDialog(BuildContext context, AppState state) {
    String selectedCatId = TransactionCategory.defaultCategories
        .firstWhere((c) => c.isExpense)
        .id;
    final limitController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setDialogState) {
          return AlertDialog(
            title: const Text('Set Monthly Budget'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedCatId,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: TransactionCategory.defaultCategories
                      .where((c) => c.isExpense)
                      .map((cat) => DropdownMenuItem(
                            value: cat.id,
                            child: Row(
                              children: [
                                Icon(cat.icon, color: cat.color, size: 20),
                                const SizedBox(width: 8),
                                Text(cat.name),
                              ],
                            ),
                          ))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedCatId = val);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: limitController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Monthly Limit (${state.currencySymbol})',
                    hintText: 'e.g. 500.00',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  final limit = double.tryParse(limitController.text);
                  if (limit != null && limit > 0) {
                    state.setBudget(selectedCatId, limit);
                    Navigator.pop(ctx);
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final budgets = appState.budgets;
    final currency = appState.currencySymbol;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Category Limits',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              FilledButton.tonalIcon(
                onPressed: () => _showAddBudgetDialog(context, appState),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('New Budget'),
              ),
            ],
          ),
          const SizedBox(height: 14),

          if (budgets.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              alignment: Alignment.center,
              child: const Text('No budgets defined. Tap "New Budget" to create one!'),
            )
          else
            ...budgets.map((budget) {
              final cat = TransactionCategory.getById(budget.categoryId);
              final spent = appState.getSpentForCategoryThisMonth(budget.categoryId);
              final progress = (spent / budget.limitAmount).clamp(0.0, 1.2);
              final isOver = spent > budget.limitAmount;
              final isWarning = spent >= budget.limitAmount * 0.8 && !isOver;

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF151C2C) : Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: isOver
                        ? MoonsTheme.expenseRed
                        : (isDark ? const Color(0xFF242E45) : Colors.grey.shade100),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: cat.color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(cat.icon, color: cat.color, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cat.name,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                                ),
                              ),
                              Text(
                                isOver
                                    ? 'Exceeded by $currency${(spent - budget.limitAmount).toStringAsFixed(2)}'
                                    : 'Remaining: $currency${(budget.limitAmount - spent).toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: isOver
                                      ? MoonsTheme.expenseRed
                                      : (isWarning ? Colors.amber : Colors.grey.shade500),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, size: 20),
                          onPressed: () => appState.deleteBudget(budget.id),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: (progress > 1.0 ? 1.0 : progress).toDouble(),
                        minHeight: 10,
                        backgroundColor:
                            isDark ? const Color(0xFF1E273D) : Colors.grey.shade100,
                        valueColor: AlwaysStoppedAnimation(
                          isOver
                              ? MoonsTheme.expenseRed
                              : (isWarning ? Colors.amber : cat.color),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$currency${spent.toStringAsFixed(2)} spent',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          'Cap: $currency${budget.limitAmount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

// ---------------- TAB 2: SAVINGS VAULTS ----------------
class _SavingsVaultsTabView extends StatelessWidget {
  const _SavingsVaultsTabView();

  void _showDepositDialog(BuildContext context, AppState state, SavingsGoal goal) {
    final depositController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Contribute to ${goal.title}'),
        content: TextField(
          controller: depositController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Deposit Amount (${state.currencySymbol})',
            hintText: 'e.g. 100.00',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final amount = double.tryParse(depositController.text);
              if (amount != null && amount > 0) {
                state.contributeToGoal(goal.id, amount);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add Funds'),
          ),
        ],
      ),
    );
  }

  void _showCreateGoalDialog(BuildContext context, AppState state) {
    final titleController = TextEditingController();
    final targetController = TextEditingController();
    String emoji = '🌕';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setDialogState) {
        return AlertDialog(
          title: const Text('New Moon Vault Goal'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Goal Title',
                  hintText: 'e.g. Dream Trip, Mac Studio',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: targetController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Target Amount (${state.currencySymbol})',
                  hintText: 'e.g. 2500',
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: ['🌕', '✈️', '💻', '🚗', '🛡️', '🏡'].map((e) {
                  final isSel = e == emoji;
                  return GestureDetector(
                    onTap: () => setDialogState(() => emoji = e),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSel ? Colors.indigo.withOpacity(0.2) : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: isSel ? Border.all(color: Colors.indigo) : null,
                      ),
                      child: Text(e, style: const TextStyle(fontSize: 22)),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                final target = double.tryParse(targetController.text);
                if (titleController.text.trim().isNotEmpty && target != null && target > 0) {
                  state.addSavingsGoal(SavingsGoal(
                    id: 'goal_${DateTime.now().millisecondsSinceEpoch}',
                    title: titleController.text.trim(),
                    targetAmount: target,
                    currentAmount: 0.0,
                    targetDate: DateTime.now().add(const Duration(days: 120)),
                    emoji: emoji,
                  ));
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Create Vault'),
            ),
          ],
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final goals = appState.savingsGoals;
    final currency = appState.currencySymbol;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Moon Vaults & Goals',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              FilledButton.tonalIcon(
                onPressed: () => _showCreateGoalDialog(context, appState),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('New Vault'),
              ),
            ],
          ),
          const SizedBox(height: 14),

          if (goals.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              alignment: Alignment.center,
              child: const Text('No active vaults. Create a goal to start saving!'),
            )
          else
            ...goals.map((goal) {
              final pct = (goal.progress * 100).toStringAsFixed(0);
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF151C2C) : Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: isDark ? const Color(0xFF242E45) : Colors.grey.shade100,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(goal.emoji, style: const TextStyle(fontSize: 28)),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                goal.title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                                ),
                              ),
                              Text(
                                '$currency${goal.currentAmount.toStringAsFixed(0)} of $currency${goal.targetAmount.toStringAsFixed(0)} ($pct%)',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline_rounded,
                              color: Color(0xFF10B981)),
                          onPressed: () => _showDepositDialog(context, appState, goal),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, size: 20),
                          onPressed: () => appState.deleteSavingsGoal(goal.id),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: goal.progress,
                        minHeight: 10,
                        backgroundColor:
                            isDark ? const Color(0xFF1E273D) : Colors.grey.shade100,
                        valueColor: const AlwaysStoppedAnimation(Color(0xFF38BDF8)),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

// ---------------- TAB 3: LOAN / EMI CALCULATOR ----------------
class _LoanCalculatorTabView extends StatefulWidget {
  const _LoanCalculatorTabView();

  @override
  State<_LoanCalculatorTabView> createState() => _LoanCalculatorTabViewState();
}

class _LoanCalculatorTabViewState extends State<_LoanCalculatorTabView> {
  double _principal = 10000;
  double _interestRate = 8.5; // percent per year
  double _tenureMonths = 24;

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currency = appState.currencySymbol;

    // Monthly interest calculation (EMI formula: P * r * (1+r)^n / ((1+r)^n - 1))
    final r = (_interestRate / 12) / 100;
    final n = _tenureMonths;
    double emi = 0;
    if (r > 0) {
      emi = (_principal * r * math.pow(1 + r, n)) / (math.pow(1 + r, n) - 1);
    } else {
      emi = _principal / n;
    }
    final totalPayment = emi * n;
    final totalInterest = totalPayment - _principal;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // EMI Result Banner
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                const Text(
                  'Monthly Installment (EMI)',
                  style: TextStyle(color: Color(0xFFC7D2FE), fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Text(
                  '$currency${emi.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Text('Total Interest', style: TextStyle(color: Color(0xFFE0E7FF), fontSize: 11)),
                        Text('$currency${totalInterest.toStringAsFixed(0)}',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    Column(
                      children: [
                        const Text('Total Payable', style: TextStyle(color: Color(0xFFE0E7FF), fontSize: 11)),
                        Text('$currency${totalPayment.toStringAsFixed(0)}',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Sliders
          Text('Loan Amount: $currency${_principal.toStringAsFixed(0)}',
              style: const TextStyle(fontWeight: FontWeight.w700)),
          Slider(
            value: _principal,
            min: 500,
            max: 100000,
            divisions: 199,
            onChanged: (val) => setState(() => _principal = val),
          ),

          const SizedBox(height: 12),
          Text('Annual Interest Rate: ${_interestRate.toStringAsFixed(1)}%',
              style: const TextStyle(fontWeight: FontWeight.w700)),
          Slider(
            value: _interestRate,
            min: 1.0,
            max: 25.0,
            divisions: 240,
            onChanged: (val) => setState(() => _interestRate = val),
          ),

          const SizedBox(height: 12),
          Text('Tenure: ${_tenureMonths.toInt()} months (${(_tenureMonths / 12).toStringAsFixed(1)} years)',
              style: const TextStyle(fontWeight: FontWeight.w700)),
          Slider(
            value: _tenureMonths,
            min: 6,
            max: 120,
            divisions: 114,
            onChanged: (val) => setState(() => _tenureMonths = val),
          ),
        ],
      ),
    );
  }
}

// ---------------- TAB 4: CURRENCY CONVERTER ----------------
class _CurrencyConverterTabView extends StatefulWidget {
  const _CurrencyConverterTabView();

  @override
  State<_CurrencyConverterTabView> createState() => _CurrencyConverterTabViewState();
}

class _CurrencyConverterTabViewState extends State<_CurrencyConverterTabView> {
  final _amountController = TextEditingController(text: '100');
  String _from = 'USD';
  String _to = 'EUR';

  static const Map<String, double> _rates = {
    'USD': 1.0,
    'EUR': 0.92,
    'GBP': 0.79,
    'JPY': 155.0,
    'INR': 84.4,
    'CAD': 1.39,
    'AUD': 1.53,
    'CHF': 0.88,
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final fromRate = _rates[_from] ?? 1.0;
    final toRate = _rates[_to] ?? 1.0;
    final converted = (amount / fromRate) * toRate;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF151C2C) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark ? const Color(0xFF242E45) : Colors.grey.shade100,
              ),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Amount to convert',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    DropdownButton<String>(
                      value: _from,
                      items: _rates.keys.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _from = v);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.swap_horiz_rounded, size: 28),
                      onPressed: () {
                        setState(() {
                          final temp = _from;
                          _from = _to;
                          _to = temp;
                        });
                      },
                    ),
                    DropdownButton<String>(
                      value: _to,
                      items: _rates.keys.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _to = v);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  '${converted.toStringAsFixed(2)} $_to',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF10B981),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
