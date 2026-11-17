enum TransactionType {
  expense,
  income;

  String get label => this == TransactionType.expense ? 'Expense' : 'Income';
}

enum AccountType {
  cash('Cash', '💵'),
  bank('Bank Account', '🏦'),
  creditCard('Credit Card', '💳'),
  digitalWallet('E-Wallet', '📱');

  final String label;
  final String emoji;
  const AccountType(this.label, this.emoji);
}

class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final TransactionType type;
  final String categoryId;
  final AccountType account;
  final String? note;
  final bool isRecurring;

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
    required this.categoryId,
    this.account = AccountType.bank,
    this.note,
    this.isRecurring = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'amount': amount,
        'date': date.toIso8601String(),
        'type': type.name,
        'categoryId': categoryId,
        'account': account.name,
        'note': note,
        'isRecurring': isRecurring,
      };

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      type: TransactionType.values.byName(json['type'] as String),
      categoryId: json['categoryId'] as String,
      account: json['account'] != null
          ? AccountType.values.byName(json['account'] as String)
          : AccountType.bank,
      note: json['note'] as String?,
      isRecurring: json['isRecurring'] as bool? ?? false,
    );
  }

  TransactionModel copyWith({
    String? id,
    String? title,
    double? amount,
    DateTime? date,
    TransactionType? type,
    String? categoryId,
    AccountType? account,
    String? note,
    bool? isRecurring,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      account: account ?? this.account,
      note: note ?? this.note,
      isRecurring: isRecurring ?? this.isRecurring,
    );
  }
}
