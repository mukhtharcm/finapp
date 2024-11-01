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
import 'package:finapp/utils/error_utils.dart';
import 'package:finapp/widgets/error_widgets.dart';

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
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: const CircleAvatar(child: Text('💰')),
                          title: const Text('Transaction Description'),
                          subtitle: const Text('Category'),
                          trailing: const Text('\$123.45'),
                        );
                      },
                    ),
                  );
                }

                if (transactionState is TransactionFailure) {
                  return InlineErrorWidget(
                    message: ErrorUtils.getErrorMessage(transactionState.error),
                    onRetry: () {
                      context.read<TransactionBloc>().add(FetchTransactions());
                    },
                  );
                }

                if (transactionState is TransactionSuccess &&
                    transactionState.transactions != null) {
                  return BlocBuilder<CategoryBloc, CategoryState>(
                    builder: (context, categoryState) {
                      if (categoryState is CategoryFailure) {
                        return InlineErrorWidget(
                          message:
                              ErrorUtils.getErrorMessage(categoryState.error),
                          onRetry: () {
                            context.read<CategoryBloc>().add(FetchCategories());
                          },
                        );
                      }

                      if (categoryState is CategorySuccess) {
                        return BlocBuilder<AccountBloc, AccountState>(
                          builder: (context, accountState) {
                            if (accountState is AccountFailure) {
                              return InlineErrorWidget(
                                message: ErrorUtils.getErrorMessage(
                                    accountState.error),
                                onRetry: () {
                                  context
                                      .read<AccountBloc>()
                                      .add(FetchAccounts());
                                },
                              );
                            }

                            if (accountState is AccountSuccess) {
                              final transactions =
                                  transactionState.transactions!;
                              final categories = categoryState.categories;
                              final accounts = accountState.accounts;

                              if (transactions.isEmpty) {
                                return Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(24.0),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.receipt_long_outlined,
                                          size: 48,
                                          color: theme.colorScheme.outline,
                                        ),
                                        const SizedBox(height: 16),
                                        const Text(
                                          'No transactions yet',
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
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
                            return const Center(
                                child: CircularProgressIndicator());
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
        ),
      ],
    );
  }
}
