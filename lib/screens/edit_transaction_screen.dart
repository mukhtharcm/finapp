import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finapp/blocs/transaction/transaction_bloc.dart';
import 'package:finapp/models/transaction.dart';
import 'package:finapp/models/suggested_transaction.dart';
import 'package:finapp/widgets/transaction_form.dart';
import 'package:get_it/get_it.dart';
import 'package:finapp/services/finance_service.dart';

class EditTransactionScreen extends StatelessWidget {
  final Transaction? transaction;
  final SuggestedTransaction? suggestedTransaction;
  final Function(SuggestedTransaction)? onSuggestedEdit;
  final FinanceService financeService = GetIt.instance<FinanceService>();

  EditTransactionScreen({
    super.key,
    this.transaction,
    this.suggestedTransaction,
    this.onSuggestedEdit,
  });

  EditTransactionScreen.suggested({
    super.key,
    required SuggestedTransaction transaction,
    required Function(SuggestedTransaction) onEdit,
  })  : suggestedTransaction = transaction,
        onSuggestedEdit = onEdit,
        transaction = null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<TransactionBloc, TransactionState>(
      listener: (context, state) {
        if (state is TransactionSuccess) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Transaction updated successfully')),
          );
        } else if (state is TransactionFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${state.error}')),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Edit Transaction', style: theme.textTheme.headlineSmall),
        ),
        body: TransactionForm(
          initialTransaction: transaction,
          initialSuggestedTransaction: suggestedTransaction,
          financeService: financeService,
          onSubmit: (editedTransaction) async {
            if (transaction != null) {
              context.read<TransactionBloc>().add(
                    UpdateTransaction(
                      id: transaction!.id!,
                      transaction: editedTransaction,
                    ),
                  );
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
          },
        ),
      ),
    );
  }
}
