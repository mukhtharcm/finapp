import 'package:finapp/utils/currency_utils.dart';

enum SuggestedTransactionType { income, expense }

class SuggestedTransaction {
  final double amount;
  final String description;
  final String categoryId;
  final String accountId;
  final SuggestedTransactionType type;

  SuggestedTransaction({
    required this.amount,
    required this.description,
    required this.categoryId,
    required this.accountId,
    required this.type,
  });

  factory SuggestedTransaction.fromJson(Map<String, dynamic> json) {
    return SuggestedTransaction(
      amount: json['amount'].toDouble(),
      description: json['description'],
      categoryId: json['categoryId'],
      accountId: json['accountId'],
      type: json['type'] == 'income'
          ? SuggestedTransactionType.income
          : SuggestedTransactionType.expense,
    );
  }

  String formattedAmount(String currencyCode) {
    final currencySymbol = CurrencyUtils.getCurrencySymbol(currencyCode);
    return '$currencySymbol${amount.toStringAsFixed(2)}';
  }
}
