import 'package:finapp/utils/currency_utils.dart';
import 'package:finapp/models/transaction.dart';

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

  Transaction toTransaction(String userId) {
    return Transaction(
      userId: userId,
      type: type == SuggestedTransactionType.income
          ? TransactionType.income
          : TransactionType.expense,
      amount: amount,
      description: description,
      timestamp: DateTime.now(),
      categoryId: categoryId,
      accountId: accountId,
      created: DateTime.now(),
    );
  }
}
