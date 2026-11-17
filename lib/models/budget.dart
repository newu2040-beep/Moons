class Budget {
  final String id;
  final String categoryId;
  final double limitAmount;
  final String monthKey; // e.g. "2026-11"

  Budget({
    required this.id,
    required this.categoryId,
    required this.limitAmount,
    required this.monthKey,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'categoryId': categoryId,
        'limitAmount': limitAmount,
        'monthKey': monthKey,
      };

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id'] as String,
      categoryId: json['categoryId'] as String,
      limitAmount: (json['limitAmount'] as num).toDouble(),
      monthKey: json['monthKey'] as String,
    );
  }

  Budget copyWith({
    String? id,
    String? categoryId,
    double? limitAmount,
    String? monthKey,
  }) {
    return Budget(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      limitAmount: limitAmount ?? this.limitAmount,
      monthKey: monthKey ?? this.monthKey,
    );
  }
}
