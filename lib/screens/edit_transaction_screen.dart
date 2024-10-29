import 'package:finapp/widgets/transaction_form.dart';
import 'package:flutter/material.dart';
import 'package:finapp/models/transaction.dart';
import 'package:finapp/models/suggested_transaction.dart';
import 'package:finapp/services/finance_service.dart';

class EditTransactionScreen extends StatelessWidget {
  final Transaction? transaction;
  final SuggestedTransaction? suggestedTransaction;
  final FinanceService financeService;
  final Function(SuggestedTransaction)? onSuggestedEdit;

  const EditTransactionScreen({
    super.key,
    required this.transaction,
    required this.financeService,
  })  : suggestedTransaction = null,
        onSuggestedEdit = null;

  // Named constructor for suggested transactions
  const EditTransactionScreen.suggested({
    super.key,
    required SuggestedTransaction transaction,
    required this.financeService,
    required Function(SuggestedTransaction) onEdit,
  })  : suggestedTransaction = transaction,
        transaction = null,
        onSuggestedEdit = onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Transaction', style: theme.textTheme.headlineSmall),
      ),
      body: TransactionForm(
        initialTransaction: transaction,
        initialSuggestedTransaction: suggestedTransaction,
        financeService: financeService,
        onSubmit: (editedTransaction) async {
          try {
            if (transaction != null) {
              await financeService.updateTransaction(
                transaction!.id!,
                editedTransaction,
              );
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Transaction updated successfully')),
                );
              }
            } else if (suggestedTransaction != null &&
                onSuggestedEdit != null) {
              // Convert Transaction to SuggestedTransaction
              final suggested = SuggestedTransaction(
                amount: editedTransaction.amount,
                description: editedTransaction.description,
                categoryId: editedTransaction.categoryId,
                accountId: editedTransaction.accountId,
                type: editedTransaction.type == TransactionType.income
                    ? SuggestedTransactionType.income
                    : SuggestedTransactionType.expense,
              );
              onSuggestedEdit!(suggested);
              if (context.mounted) {
                Navigator.pop(context);
              }
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Failed to update transaction')),
              );
            }
          }
        },
      ),
    );
  }
}
