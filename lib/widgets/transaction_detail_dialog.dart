import 'package:flutter/material.dart';
import 'package:finapp/models/transaction.dart';
import 'package:finapp/models/category.dart';
import 'package:intl/intl.dart';

class TransactionDetailDialog extends StatelessWidget {
  final Transaction transaction;
  final Category category;

  const TransactionDetailDialog({
    super.key,
    required this.transaction,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM d, yyyy HH:mm');

    return AlertDialog(
      title: const Text('Transaction Details'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: const Text('Description'),
            subtitle: Text(transaction.description),
          ),
          ListTile(
            title: const Text('Amount'),
            subtitle: Text(
              '${transaction.type == TransactionType.expense ? '-' : '+'}\$${transaction.amount.toStringAsFixed(2)}',
              style: TextStyle(
                color: transaction.type == TransactionType.expense
                    ? theme.colorScheme.error
                    : theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            title: const Text('Category'),
            subtitle: Text('${category.icon} ${category.name}'),
          ),
          ListTile(
            title: const Text('Date'),
            subtitle: Text(dateFormat.format(transaction.timestamp)),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
