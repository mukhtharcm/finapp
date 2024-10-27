import 'package:flutter/material.dart';
import 'package:finapp/models/transaction.dart';
import 'package:finapp/models/category.dart';
import 'package:finapp/widgets/transaction_detail_dialog.dart';
import 'package:signals/signals_flutter.dart';
import 'package:finapp/utils/currency_utils.dart';
import 'package:finapp/services/auth_service.dart';
import 'package:get_it/get_it.dart';

class RecentTransactions extends StatelessWidget {
  final ListSignal<Transaction> transactions;
  final ListSignal<Category> categories;
  final AuthService authService = GetIt.instance<AuthService>();

  RecentTransactions({
    super.key,
    required this.transactions,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencySymbol =
        CurrencyUtils.getCurrencySymbol(authService.preferredCurrency);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Transactions',
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Watch((context) {
          // Watch both transactions and categories
          final transactionList = transactions.toList();
          final categoryList = categories.toList();

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: transactionList.length > 5 ? 5 : transactionList.length,
            itemBuilder: (context, index) {
              final transaction = transactionList[index];
              final category = categoryList.firstWhere(
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
                    '${transaction.type == TransactionType.expense ? '-' : ''}$currencySymbol${transaction.amount.toStringAsFixed(2)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: transaction.type == TransactionType.expense
                          ? theme.colorScheme.error
                          : theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () =>
                      _showTransactionDetails(context, transaction, category),
                ),
              );
            },
          );
        }),
      ],
    );
  }

  void _showTransactionDetails(
      BuildContext context, Transaction transaction, Category category) {
    showDialog(
      context: context,
      builder: (context) => TransactionDetailDialog(
        transaction: transaction,
        category: category,
        currencySymbol:
            CurrencyUtils.getCurrencySymbol(authService.preferredCurrency),
      ),
    );
  }
}
