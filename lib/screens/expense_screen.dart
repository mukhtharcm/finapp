import 'package:flutter/material.dart';
import 'package:finapp/services/finance_service.dart';
import 'package:finapp/services/auth_service.dart';
import 'package:finapp/models/transaction.dart';
import 'package:finapp/models/category.dart';
import 'package:finapp/screens/add_transaction_screen.dart';
import 'package:signals/signals_flutter.dart';
import 'package:finapp/widgets/transaction_detail_dialog.dart';
import 'package:finapp/utils/currency_utils.dart';
import 'package:get_it/get_it.dart';

class ExpenseScreen extends StatelessWidget {
  final FinanceService financeService;
  final AuthService authService = GetIt.instance<AuthService>();

  ExpenseScreen({super.key, required this.financeService});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencySymbol =
        CurrencyUtils.getCurrencySymbol(authService.preferredCurrency);
    return Scaffold(
      appBar: AppBar(
        title: Text('Expenses', style: theme.textTheme.headlineSmall),
      ),
      body: Watch((context) {
        final expenseTransactions = financeService.transactions
            .where((t) => t.type == TransactionType.expense)
            .toList();
        return ListView.builder(
          itemCount: expenseTransactions.length,
          itemBuilder: (context, index) {
            final transaction = expenseTransactions[index];
            final category = financeService.categories.firstWhere(
              (c) => c.id == transaction.categoryId,
              orElse: () => Category(name: 'Uncategorized', icon: '❓'),
            );
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.errorContainer,
                  child: Text(category.icon,
                      style: TextStyle(
                          fontSize: 24, color: theme.colorScheme.error)),
                ),
                title: Text(transaction.description,
                    style: theme.textTheme.titleMedium),
                subtitle: Text(transaction.timestamp.toString().split(' ')[0]),
                trailing: Text(
                  '-$currencySymbol${transaction.amount.toStringAsFixed(2)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.error,
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddTransactionScreen(
                financeService: financeService,
                transactionType: TransactionType.expense,
              ),
            ),
          );
        },
        child: const Icon(Icons.add_rounded),
      ),
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
