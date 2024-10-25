import 'package:flutter/material.dart';
import 'package:finapp/services/finance_service.dart';
import 'package:finapp/models/transaction.dart';
import 'package:finapp/screens/add_transaction_screen.dart';
import 'package:signals/signals_flutter.dart';

class IncomeScreen extends StatelessWidget {
  final FinanceService financeService;

  const IncomeScreen({super.key, required this.financeService});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Income', style: theme.textTheme.headlineSmall),
      ),
      body: Watch((context) {
        final incomeTransactions = financeService.transactions
            .where((t) => t.type == TransactionType.income)
            .toList();
        return ListView.builder(
          itemCount: incomeTransactions.length,
          itemBuilder: (context, index) {
            final transaction = incomeTransactions[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Icon(Icons.trending_up_rounded,
                      color: theme.colorScheme.primary),
                ),
                title: Text(transaction.description,
                    style: theme.textTheme.titleMedium),
                subtitle: Text(transaction.timestamp.toString().split(' ')[0]),
                trailing: Text(
                  '\$${transaction.amount.toStringAsFixed(2)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
                transactionType: TransactionType.income,
              ),
            ),
          );
        },
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}
