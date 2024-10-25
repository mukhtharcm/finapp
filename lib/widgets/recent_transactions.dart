import 'package:flutter/material.dart';
import 'package:finapp/models/transaction.dart';
import 'package:finapp/models/category.dart';
import 'package:signals/signals_flutter.dart';

class RecentTransactions extends StatelessWidget {
  final ListSignal<Transaction> transactions;
  final ListSignal<Category> categories;

  const RecentTransactions({
    super.key,
    required this.transactions,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Transactions',
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Watch((context) {
          final transactionList = transactions.toList();
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: transactionList.length > 5 ? 5 : transactionList.length,
            itemBuilder: (context, index) {
              final transaction = transactionList[index];
              final category = categories.firstWhere(
                (c) => c.id == transaction.categoryId,
                orElse: () => Category(name: 'Uncategorized', icon: '❓'),
              );
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: transaction.type == TransactionType.expense
                        ? theme.colorScheme.errorContainer
                        : theme.colorScheme.primaryContainer,
                    child: Text(
                      category.icon,
                      style: TextStyle(
                        fontSize: 24,
                        color: transaction.type == TransactionType.expense
                            ? theme.colorScheme.error
                            : theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  title: Text(transaction.description,
                      style: theme.textTheme.titleMedium),
                  subtitle: Text(category.name),
                  trailing: Text(
                    '${transaction.type == TransactionType.expense ? '-' : '+'}\$${transaction.amount.toStringAsFixed(2)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: transaction.type == TransactionType.expense
                          ? theme.colorScheme.error
                          : theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ],
    );
  }
}
