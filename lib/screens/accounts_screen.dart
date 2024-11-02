import 'package:finapp/models/transaction.dart';
import 'package:flutter/material.dart';
import 'package:finapp/models/account.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finapp/blocs/account/account_bloc.dart';
import 'package:finapp/blocs/transaction/transaction_bloc.dart';
import 'package:finapp/utils/error_utils.dart';
import 'package:finapp/widgets/error_widgets.dart';

class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Accounts', style: theme.textTheme.headlineSmall),
      ),
      body: BlocBuilder<AccountBloc, AccountState>(
        builder: (context, state) {
          if (state is AccountLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AccountFailure) {
            return ErrorView(
              message: ErrorUtils.getErrorMessage(state.error),
              onRetry: () {
                context.read<AccountBloc>().add(FetchAccounts());
              },
            );
          }

          if (state is AccountSuccess) {
            final accounts = state.accounts;
            if (accounts.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.account_balance_outlined,
                      size: 64,
                      color: theme.colorScheme.outline,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No accounts yet',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add your first account to start tracking your finances',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ).animate().fadeIn(duration: 300.ms),
              );
            }

            return BlocBuilder<TransactionBloc, TransactionState>(
              builder: (context, transactionState) {
                if (transactionState is TransactionFailure) {
                  return ErrorView(
                    message: ErrorUtils.getErrorMessage(transactionState.error),
                    onRetry: () {
                      context.read<TransactionBloc>().add(FetchTransactions());
                    },
                  );
                }

                if (transactionState is TransactionSuccess) {
                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<AccountBloc>().add(FetchAccounts());
                      context.read<TransactionBloc>().add(FetchTransactions());
                    },
                    child: ListView.builder(
                      itemCount: accounts.length,
                      itemBuilder: (context, index) {
                        final account = accounts[index];
                        final balance = _getAccountBalance(
                          account.id!,
                          transactionState.transactions ?? [],
                        );

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  theme.colorScheme.secondaryContainer,
                              child: Text(
                                account.icon,
                                style: TextStyle(
                                  fontSize: 24,
                                  color: theme.colorScheme.secondary,
                                ),
                              ),
                            ),
                            title: Row(
                              children: [
                                Text(account.name,
                                    style: theme.textTheme.titleMedium),
                                if (account.isDefault)
                                  Container(
                                    margin: const EdgeInsets.only(left: 8),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primaryContainer,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Default',
                                      style:
                                          theme.textTheme.labelSmall?.copyWith(
                                        color: theme
                                            .colorScheme.onPrimaryContainer,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(account.type),
                                Text(
                                  'Balance: \$${balance['balance']?.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: (balance['balance'] ?? 0) >= 0
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.error,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            isThreeLine: true,
                            trailing: IconButton(
                              icon: const Icon(Icons.more_vert),
                              onPressed: () =>
                                  _showAccountOptions(context, account, theme),
                            ),
                          ),
                        )
                            .animate()
                            .fadeIn(
                              duration: 300.ms,
                              delay: (50 * index).ms,
                            )
                            .slideX(
                              begin: 0.2,
                              end: 0,
                              duration: 300.ms,
                              delay: (50 * index).ms,
                              curve: Curves.easeOutCubic,
                            );
                      },
                    ),
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddAccountDialog(context),
        child: const Icon(Icons.add_rounded),
      ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack),
    );
  }

  Map<String, double> _getAccountBalance(
      String accountId, List<Transaction> transactions) {
    final accountTransactions =
        transactions.where((t) => t.accountId == accountId);

    double income = accountTransactions
        .where((t) => t.type == TransactionType.income)
        .fold(0, (sum, t) => sum + t.amount);

    double expenses = accountTransactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0, (sum, t) => sum + t.amount);

    return {
      'income': income,
      'expenses': expenses,
      'balance': income - expenses,
    };
  }

  void _showAccountOptions(
      BuildContext context, Account account, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!account.isDefault)
              ListTile(
                leading: const Icon(Icons.star_outline),
                title: const Text('Set as Default'),
                onTap: () {
                  Navigator.pop(context);
                  context.read<AccountBloc>().add(
                        UpdateAccount(
                          account: account.copyWith(isDefault: true),
                        ),
                      );
                },
              ),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                _showEditAccountDialog(context, account);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.delete_outline,
                color: theme.colorScheme.error,
              ),
              title: Text(
                'Delete',
                style: TextStyle(color: theme.colorScheme.error),
              ),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context, account);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddAccountDialog(BuildContext context) {
    // Implement add account dialog
  }

  void _showEditAccountDialog(BuildContext context, Account account) {
    // Implement edit account dialog
  }

  void _showDeleteConfirmation(BuildContext context, Account account) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete this account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AccountBloc>().add(DeleteAccount(account.id!));
            },
            child: Text(
              'Delete',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}
