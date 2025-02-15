import 'package:pocketbase/pocketbase.dart';

enum TransactionType { income, expense }

class Transaction {
  final String? id;
  final String userId;
  final TransactionType type;
  final double amount;
  final String description;
  final DateTime timestamp;
  final String categoryId;
  final String accountId;
  final DateTime created;

  Transaction({
    this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.description,
    required this.timestamp,
    required this.categoryId,
    required this.accountId,
    required this.created,
  });

  factory Transaction.fromRecord(RecordModel record) {
    return Transaction(
      id: record.id,
      userId: record.getStringValue('user_id'),
      type: record.getStringValue('type') == 'income'
          ? TransactionType.income
          : TransactionType.expense,
      amount: record.getDoubleValue('amount'),
      description: record.getStringValue('description'),
      timestamp: DateTime.parse(record.getStringValue('timestamp')),
      categoryId: record.getStringValue('category'),
      accountId: record.getStringValue('account'),
      created: DateTime.parse(record.created),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'type': type == TransactionType.income ? 'income' : 'expense',
      'amount': amount,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'category': categoryId,
      'account': accountId,
    };
  }
}
