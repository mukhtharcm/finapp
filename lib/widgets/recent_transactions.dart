import 'package:finapp/models/account.dart';
import 'package:finapp/widgets/transaction_card.dart';
import 'package:flutter/material.dart';
import 'package:finapp/models/category.dart';
import 'package:finapp/utils/currency_utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finapp/blocs/transaction/transaction_bloc.dart';
import 'package:finapp/blocs/category/category_bloc.dart';
import 'package:finapp/blocs/auth/auth_bloc.dart';
import 'package:finapp/blocs/account/account_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';

class RecentTransactions extends StatelessWidget {
  const RecentTransactions({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Transactions',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            final currencySymbol = CurrencyUtils.getCurrencySymbol(
              authState.preferredCurrency,
            );

            return BlocBuilder<TransactionBloc, TransactionState>(
              builder: (context, transactionState) {
                if (transactionState is TransactionLoading) {
                  return Skeletonizer(
                    enabled: true,
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 5, // Show 5 skeleton items while loading
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: CircleAvatar(child: Text('💰')),
                          title: Text('Transaction Description'),
                          subtitle: Text('Category'),
                          trailing: Text('\$123.45'),
                        );
                      },
                    ),
                  );
                }

                if (transactionState is TransactionFailure) {
                  return Center(
                      child: Text('Error: ${transactionState.error}'));
                }

                if (transactionState is TransactionSuccess &&
                    transactionState.transactions != null) {
                  return BlocBuilder<CategoryBloc, CategoryState>(
                    builder: (context, categoryState) {
                      if (categoryState is CategorySuccess) {
                        return BlocBuilder<AccountBloc, AccountState>(
                          builder: (context, accountState) {
                            if (accountState is AccountSuccess) {
                              final transactions =
                                  transactionState.transactions!;
                              final categories = categoryState.categories;
                              final accounts = accountState.accounts;

                              if (transactions.isEmpty) {
                                return const Center(
                                  child: Text('No transactions yet'),
                                );
                              }

                              return ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: transactions.length,
                                itemBuilder: (context, index) {
                                  final transaction = transactions[index];
                                  final category = categories.firstWhere(
                                    (c) => c.id == transaction.categoryId,
                                    orElse: () => Category.empty(),
                                  );
                                  final account = accounts.firstWhere(
                                    (a) => a.id == transaction.accountId,
                                    orElse: () => Account.empty(),
                                  );

                                  return TransactionCard(
                                    transaction: transaction,
                                    category: category,
                                    account: account,
                                    currencySymbol: currencySymbol,
                                    animationIndex: index,
                                    showAccount: false,
                                    compact: true,
                                  );
                                },
                              );
                            }
                            return const CircularProgressIndicator();
                          },
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            );
          },
        ),
      ],
    );
  }
}
