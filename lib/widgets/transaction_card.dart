import 'package:finapp/models/transaction.dart';
import 'package:finapp/models/category.dart';
import 'package:finapp/models/account.dart';
import 'package:finapp/services/finance_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:finapp/widgets/transaction_detail_dialog.dart';
import 'package:finapp/screens/edit_transaction_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finapp/blocs/transaction/transaction_bloc.dart';

class TransactionCard extends StatelessWidget {
  final Transaction transaction;
  final Category category;
  final Account account;
  final String currencySymbol;
  final int? animationIndex;
  final bool showAccount;
  final EdgeInsetsGeometry? margin;
  final bool compact;

  const TransactionCard({
    super.key,
    required this.transaction,
    required this.category,
    required this.account,
    required this.currencySymbol,
    this.animationIndex,
    this.showAccount = true,
    this.margin,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isExpense = transaction.type == TransactionType.expense;
    final color =
        isExpense ? theme.colorScheme.error : theme.colorScheme.primary;
    final containerColor = isExpense
        ? theme.colorScheme.errorContainer
        : theme.colorScheme.primaryContainer;

    Widget card = Card(
      margin: margin ??
          (compact
              ? const EdgeInsets.symmetric(vertical: 4)
              : const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
      child: ListTile(
        contentPadding: compact
            ? const EdgeInsets.symmetric(horizontal: 12, vertical: 4)
            : null,
        leading: CircleAvatar(
          backgroundColor: containerColor,
          radius: compact ? 16 : 20,
          child: Text(
            category.icon,
            style: TextStyle(
              fontSize: compact ? 18 : 24,
              color: color,
            ),
          ),
        ),
        title: Text(
          transaction.description,
          style: theme.textTheme.titleMedium?.copyWith(
            fontSize: compact ? 14 : null,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: showAccount
            ? Text(
                '${account.name} • ${account.type}',
                style: TextStyle(fontSize: compact ? 12 : null),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : Text(
                category.name,
                style: TextStyle(fontSize: compact ? 12 : null),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
        trailing: Text(
          '${isExpense ? '-' : ''}$currencySymbol${transaction.amount.toStringAsFixed(2)}',
          style: theme.textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: compact ? 14 : null,
          ),
        ),
        onTap: () => _showTransactionDetails(context),
        onLongPress: () => _showOptions(context),
      ),
    );

    // Apply animations if animationIndex is provided
    if (animationIndex != null) {
      card = card
          .animate()
          .fadeIn(duration: 300.ms, delay: (50 * animationIndex!).ms)
          .slideX(
            begin: 0.2,
            end: 0,
            duration: 300.ms,
            delay: (50 * animationIndex!).ms,
            curve: Curves.easeOutCubic,
          );
    }

    return card;
  }

  void _showTransactionDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => TransactionDetailDialog(
        transaction: transaction,
        category: category,
        currencySymbol: currencySymbol,
      ),
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Transaction'),
              onTap: () {
                Navigator.pop(context);
                _editTransaction(context);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.delete,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(
                'Delete Transaction',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _deleteTransaction(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _editTransaction(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTransactionScreen(
          transaction: transaction,
          financeService: context.read<FinanceService>(),
        ),
      ),
    );
  }

  void _deleteTransaction(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content:
            const Text('Are you sure you want to delete this transaction?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<TransactionBloc>().add(
                    DeleteTransaction(transaction.id!),
                  );
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
