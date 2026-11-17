import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../models/budget.dart';
import '../models/savings_goal.dart';
import '../models/category.dart';
import '../services/storage_service.dart';

enum TimeFilter {
  today('Today'),
  thisWeek('This Week'),
  thisMonth('This Month'),
  allTime('All Time');

  final String label;
  const TimeFilter(this.label);
}

class AppState extends ChangeNotifier {
  List<TransactionModel> _transactions = [];
  List<Budget> _budgets = [];
  List<SavingsGoal> _savingsGoals = [];
  String _currencySymbol = '\$';
  ThemeMode _themeMode = ThemeMode.dark;
  TimeFilter _selectedTimeFilter = TimeFilter.thisMonth;
  bool _isLoading = true;

  // Getters
  List<TransactionModel> get transactions => List.unmodifiable(_transactions);
  List<Budget> get budgets => List.unmodifiable(_budgets);
  List<SavingsGoal> get savingsGoals => List.unmodifiable(_savingsGoals);
  String get currencySymbol => _currencySymbol;
  ThemeMode get themeMode => _themeMode;
  TimeFilter get selectedTimeFilter => _selectedTimeFilter;
  bool get isLoading => _isLoading;

  AppState() {
    _initialize();
  }

  Future<void> _initialize() async {
    _isLoading = true;
    notifyListeners();

    _transactions = await StorageService.loadTransactions();
    _budgets = await StorageService.loadBudgets();
    _savingsGoals = await StorageService.loadSavingsGoals();
    _currencySymbol = await StorageService.loadCurrency();

    final themeStr = await StorageService.loadThemeMode();
    _themeMode = themeStr == 'light'
        ? ThemeMode.light
        : (themeStr == 'system' ? ThemeMode.system : ThemeMode.dark);

    _isLoading = false;
    notifyListeners();
  }

  void setTimeFilter(TimeFilter filter) {
    _selectedTimeFilter = filter;
    notifyListeners();
  }

  // Filtered transactions based on selected timeframe
  List<TransactionModel> get filteredTransactions {
    final now = DateTime.now();
    return _transactions.where((tx) {
      switch (_selectedTimeFilter) {
        case TimeFilter.today:
          return tx.date.year == now.year &&
              tx.date.month == now.month &&
              tx.date.day == now.day;
        case TimeFilter.thisWeek:
          final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
          final beginningOfWeek =
              DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
          return tx.date.isAfter(beginningOfWeek);
        case TimeFilter.thisMonth:
          return tx.date.year == now.year && tx.date.month == now.month;
        case TimeFilter.allTime:
          return true;
      }
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  // Financial Metrics
  double get totalIncome {
    return filteredTransactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get totalExpense {
    return filteredTransactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get netBalance => totalIncome - totalExpense;

  // All-time balance across accounts
  double get totalAllTimeBalance {
    final income = _transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
    final expense = _transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
    return income - expense;
  }

  // Savings rate percentage
  double get savingsRate {
    if (totalIncome <= 0) return 0.0;
    final saved = totalIncome - totalExpense;
    if (saved <= 0) return 0.0;
    return (saved / totalIncome * 100).clamp(0.0, 100.0);
  }

  // Category breakdown for expenses
  Map<String, double> get categoryExpensesMap {
    final map = <String, double>{};
    for (final tx in filteredTransactions) {
      if (tx.type == TransactionType.expense) {
        map[tx.categoryId] = (map[tx.categoryId] ?? 0.0) + tx.amount;
      }
    }
    return map;
  }

  // Category breakdown for income
  Map<String, double> get categoryIncomeMap {
    final map = <String, double>{};
    for (final tx in filteredTransactions) {
      if (tx.type == TransactionType.income) {
        map[tx.categoryId] = (map[tx.categoryId] ?? 0.0) + tx.amount;
      }
    }
    return map;
  }

  // Account balances
  Map<AccountType, double> get accountBalances {
    final map = <AccountType, double>{
      AccountType.bank: 0.0,
      AccountType.cash: 0.0,
      AccountType.creditCard: 0.0,
      AccountType.digitalWallet: 0.0,
    };

    for (final tx in _transactions) {
      final multiplier = tx.type == TransactionType.income ? 1.0 : -1.0;
      map[tx.account] = (map[tx.account] ?? 0.0) + (tx.amount * multiplier);
    }
    return map;
  }

  // Transaction CRUD
  Future<void> addTransaction(TransactionModel tx) async {
    _transactions.insert(0, tx);
    await StorageService.saveTransactions(_transactions);
    notifyListeners();
  }

  Future<void> updateTransaction(TransactionModel tx) async {
    final index = _transactions.indexWhere((t) => t.id == tx.id);
    if (index != -1) {
      _transactions[index] = tx;
      await StorageService.saveTransactions(_transactions);
      notifyListeners();
    }
  }

  Future<void> deleteTransaction(String id) async {
    _transactions.removeWhere((t) => t.id == id);
    await StorageService.saveTransactions(_transactions);
    notifyListeners();
  }

  // Budget CRUD
  Future<void> setBudget(String categoryId, double limit) async {
    final now = DateTime.now();
    final monthKey = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    final index = _budgets.indexWhere((b) => b.categoryId == categoryId);

    if (index != -1) {
      _budgets[index] = _budgets[index].copyWith(limitAmount: limit);
    } else {
      _budgets.add(Budget(
        id: 'b_${DateTime.now().millisecondsSinceEpoch}',
        categoryId: categoryId,
        limitAmount: limit,
        monthKey: monthKey,
      ));
    }
    await StorageService.saveBudgets(_budgets);
    notifyListeners();
  }

  Future<void> deleteBudget(String id) async {
    _budgets.removeWhere((b) => b.id == id);
    await StorageService.saveBudgets(_budgets);
    notifyListeners();
  }

  double getSpentForCategoryThisMonth(String categoryId) {
    final now = DateTime.now();
    return _transactions
        .where((t) =>
            t.type == TransactionType.expense &&
            t.categoryId == categoryId &&
            t.date.year == now.year &&
            t.date.month == now.month)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  // Savings Goals CRUD
  Future<void> addSavingsGoal(SavingsGoal goal) async {
    _savingsGoals.add(goal);
    await StorageService.saveSavingsGoals(_savingsGoals);
    notifyListeners();
  }

  Future<void> contributeToGoal(String goalId, double depositAmount) async {
    final index = _savingsGoals.indexWhere((g) => g.id == goalId);
    if (index != -1) {
      final goal = _savingsGoals[index];
      _savingsGoals[index] = goal.copyWith(
        currentAmount: (goal.currentAmount + depositAmount).clamp(0.0, double.infinity),
      );
      await StorageService.saveSavingsGoals(_savingsGoals);
      notifyListeners();
    }
  }

  Future<void> deleteSavingsGoal(String goalId) async {
    _savingsGoals.removeWhere((g) => g.id == goalId);
    await StorageService.saveSavingsGoals(_savingsGoals);
    notifyListeners();
  }

  // Settings
  Future<void> setCurrency(String symbol) async {
    _currencySymbol = symbol;
    await StorageService.saveCurrency(symbol);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final modeStr = mode == ThemeMode.light
        ? 'light'
        : (mode == ThemeMode.system ? 'system' : 'dark');
    await StorageService.saveThemeMode(modeStr);
    notifyListeners();
  }

  Future<void> resetAllData() async {
    await StorageService.resetAll();
    await _initialize();
  }
}

// InheritedWidget helper for clean, zero-dependency reactive state in Flutter
class AppStateScope extends InheritedNotifier<AppState> {
  const AppStateScope({
    super.key,
    required AppState state,
    required super.child,
  }) : super(notifier: state);

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppStateScope>();
    assert(scope != null, 'No AppStateScope found in context');
    return scope!.notifier!;
  }
}
