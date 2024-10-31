import 'package:finapp/models/account.dart';
import 'package:finapp/widgets/transaction_card.dart';
import 'package:flutter/material.dart';
import 'package:finapp/models/transaction.dart';
import 'package:finapp/models/category.dart';
import 'package:finapp/screens/add_transaction_screen.dart';
import 'package:finapp/widgets/transaction_detail_dialog.dart';
import 'package:finapp/utils/currency_utils.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finapp/blocs/transaction/transaction_bloc.dart';
import 'package:finapp/blocs/category/category_bloc.dart';
import 'package:finapp/blocs/account/account_bloc.dart';
import 'package:finapp/blocs/auth/auth_bloc.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TransactionBloc>().add(FetchTransactions());
    context.read<CategoryBloc>().add(FetchCategories());
    context.read<AccountBloc>().add(FetchAccounts());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Transactions', style: theme.textTheme.headlineSmall),
          bottom: TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.trending_up_rounded,
                    color: theme.colorScheme.primary),
                text: 'Income',
              ),
              Tab(
                icon: Icon(Icons.trending_down_rounded,
                    color: theme.colorScheme.error),
                text: 'Expenses',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildTransactionList(
              context,
              TransactionType.income,
              theme.colorScheme.primary,
              theme.colorScheme.primaryContainer,
            ),
            _buildTransactionList(
              context,
              TransactionType.expense,
              theme.colorScheme.error,
              theme.colorScheme.errorContainer,
            ),
          ],
        ),
        floatingActionButton: _buildFloatingActionButton(context),
      ),
    );
  }

  Widget _buildTransactionList(BuildContext context, TransactionType type,
      Color textColor, Color avatarColor) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final currencySymbol =
            CurrencyUtils.getCurrencySymbol(authState.preferredCurrency);

        return BlocBuilder<TransactionBloc, TransactionState>(
          builder: (context, transactionState) {
            if (transactionState is TransactionLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (transactionState is TransactionFailure) {
              return Center(child: Text('Error: ${transactionState.error}'));
            }

            if (transactionState is TransactionSuccess &&
                transactionState.transactions != null) {
              final transactions = transactionState.transactions!
                  .where((t) => t.type == type)
                  .toList();

              return BlocBuilder<CategoryBloc, CategoryState>(
                builder: (context, categoryState) {
                  if (categoryState is CategorySuccess) {
                    return BlocBuilder<AccountBloc, AccountState>(
                      builder: (context, accountState) {
                        if (accountState is AccountSuccess) {
                          if (transactions.isEmpty) {
                            return Center(
                              child: Text(
                                'No ${type == TransactionType.income ? 'income' : 'expenses'} yet',
                              ),
                            );
                          }

                          return ListView.builder(
                            itemCount: transactions.length,
                            itemBuilder: (context, index) {
                              final transaction = transactions[index];
                              final category =
                                  categoryState.categories.firstWhere(
                                (c) => c.id == transaction.categoryId,
                                orElse: () => Category(
                                  name: 'Uncategorized',
                                  icon: '❓',
                                ),
                              );
                              final account = accountState.accounts.firstWhere(
                                (a) => a.id == transaction.accountId,
                                orElse: () => Account(
                                  userId: transaction.userId,
                                  name: 'Unknown',
                                  type: 'unknown',
                                  icon: '❓',
                                ),
                              );

                              return TransactionCard(
                                transaction: transaction,
                                category: category,
                                account: account,
                                compact: false,
                                showAccount: true,
                                currencySymbol: currencySymbol,
                                animationIndex: index,
                              );
                            },
                          );
                        }
                        return const Center(child: CircularProgressIndicator());
                      },
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              );
            }
            return const SizedBox.shrink();
          },
        );
      },
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    final theme = Theme.of(context);
    return FloatingActionButton(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          builder: (context) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.trending_up_rounded,
                      color: theme.colorScheme.primary,
                    ),
                    title: const Text('Income'),
                    subtitle: const Text('Add money you received'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddTransactionScreen(
                            transactionType: TransactionType.income,
                          ),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.trending_down_rounded,
                      color: theme.colorScheme.error,
                    ),
                    title: const Text('Expense'),
                    subtitle: const Text('Add money you spent'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddTransactionScreen(
                            transactionType: TransactionType.expense,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
      child: const Icon(Icons.add_rounded),
    ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack);
  }
}
