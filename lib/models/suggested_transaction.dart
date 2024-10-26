enum SuggestedTransactionType { income, expense }

class SuggestedTransaction {
  final double amount;
  final String description;
  final String categoryId;
  final SuggestedTransactionType type;

  SuggestedTransaction({
    required this.amount,
    required this.description,
    required this.categoryId,
    required this.type,
  });

  factory SuggestedTransaction.fromJson(Map<String, dynamic> json) {
    return SuggestedTransaction(
      amount: json['amount'].toDouble(),
      description: json['description'],
      categoryId: json['categoryId'],
      type: json['type'] == 'income'
          ? SuggestedTransactionType.income
          : SuggestedTransactionType.expense,
    );
  }
}
