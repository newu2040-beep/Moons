import 'package:flutter/material.dart';

class TransactionCategory {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final bool isExpense;

  const TransactionCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.isExpense,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'iconCode': icon.codePoint,
        'colorValue': color.value,
        'isExpense': isExpense,
      };

  factory TransactionCategory.fromJson(Map<String, dynamic> json) {
    return TransactionCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: IconData(json['iconCode'] as int, fontFamily: 'MaterialIcons'),
      color: Color(json['colorValue'] as int),
      isExpense: json['isExpense'] as bool? ?? true,
    );
  }

  // Pre-configured expressive Material 3 category presets
  static const List<TransactionCategory> defaultCategories = [
    // Expenses
    TransactionCategory(
      id: 'food',
      name: 'Dining & Food',
      icon: Icons.restaurant_rounded,
      color: Color(0xFFFF6F61), // Coral
      isExpense: true,
    ),
    TransactionCategory(
      id: 'groceries',
      name: 'Groceries',
      icon: Icons.shopping_basket_rounded,
      color: Color(0xFF4CAF50), // Fresh Green
      isExpense: true,
    ),
    TransactionCategory(
      id: 'shopping',
      name: 'Shopping',
      icon: Icons.shopping_bag_rounded,
      color: Color(0xFFAB47BC), // Violet
      isExpense: true,
    ),
    TransactionCategory(
      id: 'transport',
      name: 'Transport',
      icon: Icons.directions_car_rounded,
      color: Color(0xFF29B6F6), // Sky Blue
      isExpense: true,
    ),
    TransactionCategory(
      id: 'housing',
      name: 'Housing & Rent',
      icon: Icons.home_rounded,
      color: Color(0xFFFFA726), // Amber
      isExpense: true,
    ),
    TransactionCategory(
      id: 'bills',
      name: 'Bills & Utilities',
      icon: Icons.receipt_long_rounded,
      color: Color(0xFF78909C), // Slate Blue
      isExpense: true,
    ),
    TransactionCategory(
      id: 'entertainment',
      name: 'Entertainment',
      icon: Icons.movie_filter_rounded,
      color: Color(0xFFEC407A), // Rose
      isExpense: true,
    ),
    TransactionCategory(
      id: 'health',
      name: 'Health & Wellness',
      icon: Icons.favorite_rounded,
      color: Color(0xFF26A69A), // Teal
      isExpense: true,
    ),
    TransactionCategory(
      id: 'education',
      name: 'Education',
      icon: Icons.school_rounded,
      color: Color(0xFF5C6BC0), // Indigo
      isExpense: true,
    ),
    TransactionCategory(
      id: 'travel',
      name: 'Travel & Trips',
      icon: Icons.flight_takeoff_rounded,
      color: Color(0xFF00ACC1), // Cyan
      isExpense: true,
    ),
    TransactionCategory(
      id: 'other_expense',
      name: 'Other Expense',
      icon: Icons.category_rounded,
      color: Color(0xFF8D6E63), // Cocoa
      isExpense: true,
    ),

    // Incomes
    TransactionCategory(
      id: 'salary',
      name: 'Salary',
      icon: Icons.account_balance_wallet_rounded,
      color: Color(0xFF00C853), // Emerald
      isExpense: false,
    ),
    TransactionCategory(
      id: 'freelance',
      name: 'Freelance & Side-gig',
      icon: Icons.laptop_mac_rounded,
      color: Color(0xFF00B0FF), // Electric Blue
      isExpense: false,
    ),
    TransactionCategory(
      id: 'investments',
      name: 'Investments & Crypto',
      icon: Icons.trending_up_rounded,
      color: Color(0xFFFFB300), // Gold
      isExpense: false,
    ),
    TransactionCategory(
      id: 'gift',
      name: 'Gifts & Bonus',
      icon: Icons.card_giftcard_rounded,
      color: Color(0xFFFF4081), // Pink Accent
      isExpense: false,
    ),
    TransactionCategory(
      id: 'other_income',
      name: 'Other Income',
      icon: Icons.savings_rounded,
      color: Color(0xFF66BB6A), // Light Green
      isExpense: false,
    ),
  ];

  static TransactionCategory getById(String id) {
    return defaultCategories.firstWhere(
      (cat) => cat.id == id,
      orElse: () => const TransactionCategory(
        id: 'unknown',
        name: 'General',
        icon: Icons.donut_small_rounded,
        color: Colors.blueGrey,
        isExpense: true,
      ),
    );
  }
}
