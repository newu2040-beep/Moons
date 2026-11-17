import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction.dart';
import '../models/budget.dart';
import '../models/savings_goal.dart';

class StorageService {
  static const String _keyTransactions = 'moons_transactions_v1';
  static const String _keyBudgets = 'moons_budgets_v1';
  static const String _keySavingsGoals = 'moons_goals_v1';
  static const String _keyCurrency = 'moons_currency_v1';
  static const String _keyThemeMode = 'moons_theme_mode_v1';
  static const String _keyFirstRun = 'moons_first_run_done_v1';

  // Load Transactions
  static Future<List<TransactionModel>> loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstRun = !(prefs.getBool(_keyFirstRun) ?? false);

    if (isFirstRun) {
      // Seed rich starter demo transactions
      final initial = _getInitialDemoTransactions();
      await saveTransactions(initial);
      await prefs.setBool(_keyFirstRun, true);
      return initial;
    }

    final jsonString = prefs.getString(_keyTransactions);
    if (jsonString == null || jsonString.isEmpty) return [];

    try {
      final List<dynamic> list = jsonDecode(jsonString);
      return list.map((item) => TransactionModel.fromJson(item)).toList();
    } catch (_) {
      return [];
    }
  }

  // Save Transactions
  static Future<void> saveTransactions(List<TransactionModel> transactions) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(transactions.map((t) => t.toJson()).toList());
    await prefs.setString(_keyTransactions, jsonString);
  }

  // Load Budgets
  static Future<List<Budget>> loadBudgets() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyBudgets);
    if (jsonString == null || jsonString.isEmpty) {
      // Default sample budgets
      return [
        Budget(id: 'b1', categoryId: 'food', limitAmount: 450.0, monthKey: _currentMonthKey()),
        Budget(id: 'b2', categoryId: 'shopping', limitAmount: 250.0, monthKey: _currentMonthKey()),
        Budget(id: 'b3', categoryId: 'entertainment', limitAmount: 150.0, monthKey: _currentMonthKey()),
      ];
    }
    try {
      final List<dynamic> list = jsonDecode(jsonString);
      return list.map((item) => Budget.fromJson(item)).toList();
    } catch (_) {
      return [];
    }
  }

  // Save Budgets
  static Future<void> saveBudgets(List<Budget> budgets) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(budgets.map((b) => b.toJson()).toList());
    await prefs.setString(_keyBudgets, jsonString);
  }

  // Load Savings Goals
  static Future<List<SavingsGoal>> loadSavingsGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keySavingsGoals);
    if (jsonString == null || jsonString.isEmpty) {
      return [
        SavingsGoal(
          id: 'g1',
          title: 'Japan Autumn Trip',
          targetAmount: 3200.0,
          currentAmount: 1450.0,
          targetDate: DateTime.now().add(const Duration(days: 180)),
          emoji: '✈️',
          colorValue: 0xFF38BDF8,
        ),
        SavingsGoal(
          id: 'g2',
          title: 'Emergency Cushion',
          targetAmount: 5000.0,
          currentAmount: 3800.0,
          targetDate: DateTime.now().add(const Duration(days: 90)),
          emoji: '🛡️',
          colorValue: 0xFF10B981,
        ),
      ];
    }
    try {
      final List<dynamic> list = jsonDecode(jsonString);
      return list.map((item) => SavingsGoal.fromJson(item)).toList();
    } catch (_) {
      return [];
    }
  }

  // Save Savings Goals
  static Future<void> saveSavingsGoals(List<SavingsGoal> goals) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(goals.map((g) => g.toJson()).toList());
    await prefs.setString(_keySavingsGoals, jsonString);
  }

  // Currency Preferences
  static Future<String> loadCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyCurrency) ?? '\$';
  }

  static Future<void> saveCurrency(String symbol) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCurrency, symbol);
  }

  // Theme Mode Preferences (system, light, dark)
  static Future<String> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyThemeMode) ?? 'dark';
  }

  static Future<void> saveThemeMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyThemeMode, mode);
  }

  // Reset all data
  static Future<void> resetAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static String _currentMonthKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  // Realistic starter seed transactions
  static List<TransactionModel> _getInitialDemoTransactions() {
    final now = DateTime.now();
    return [
      TransactionModel(
        id: 't1',
        title: 'Monthly Tech Salary',
        amount: 3850.00,
        date: now.subtract(const Duration(days: 2)),
        type: TransactionType.income,
        categoryId: 'salary',
        account: AccountType.bank,
        note: 'Direct payroll deposit',
      ),
      TransactionModel(
        id: 't2',
        title: 'Apartment Studio Rent',
        amount: 1100.00,
        date: now.subtract(const Duration(days: 3)),
        type: TransactionType.expense,
        categoryId: 'housing',
        account: AccountType.bank,
        note: 'November rent & maintenance',
      ),
      TransactionModel(
        id: 't3',
        title: 'Whole Foods Market',
        amount: 92.40,
        date: now.subtract(const Duration(hours: 5)),
        type: TransactionType.expense,
        categoryId: 'groceries',
        account: AccountType.creditCard,
        note: 'Weekly essentials & fresh fruit',
      ),
      TransactionModel(
        id: 't4',
        title: 'Freelance Design Retainer',
        amount: 650.00,
        date: now.subtract(const Duration(days: 4)),
        type: TransactionType.income,
        categoryId: 'freelance',
        account: AccountType.digitalWallet,
        note: 'Landing page UI kit',
      ),
      TransactionModel(
        id: 't5',
        title: 'Tokyo Ramen Bar',
        amount: 34.50,
        date: now.subtract(const Duration(days: 1)),
        type: TransactionType.expense,
        categoryId: 'food',
        account: AccountType.cash,
        note: 'Dinner with Marcus',
      ),
      TransactionModel(
        id: 't6',
        title: 'Fiber Internet & 5G',
        amount: 79.99,
        date: now.subtract(const Duration(days: 5)),
        type: TransactionType.expense,
        categoryId: 'bills',
        account: AccountType.bank,
        note: 'High-speed broadband plan',
      ),
      TransactionModel(
        id: 't7',
        title: 'Gym & Fitness Membership',
        amount: 55.00,
        date: now.subtract(const Duration(days: 6)),
        type: TransactionType.expense,
        categoryId: 'health',
        account: AccountType.creditCard,
      ),
      TransactionModel(
        id: 't8',
        title: 'Cinema & Popcorn',
        amount: 28.00,
        date: now.subtract(const Duration(days: 2)),
        type: TransactionType.expense,
        categoryId: 'entertainment',
        account: AccountType.digitalWallet,
      ),
    ];
  }
}
