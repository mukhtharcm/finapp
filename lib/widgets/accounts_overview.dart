import 'package:finapp/models/account.dart';
import 'package:flutter/material.dart';
import 'package:finapp/services/finance_service.dart';
import 'package:finapp/utils/currency_utils.dart';
import 'package:finapp/services/auth_service.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:finapp/screens/accounts_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finapp/blocs/account/account_bloc.dart';
import 'package:finapp/blocs/transaction/transaction_bloc.dart';
import 'package:finapp/blocs/auth/auth_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:finapp/widgets/account_card.dart';
import 'package:finapp/utils/error_utils.dart';
import 'package:finapp/widgets/error_widgets.dart';

class AccountsOverview extends StatelessWidget {
  final AuthService authService;
  final FinanceService financeService;

  const AccountsOverview({
    super.key,
    required this.authService,
    required this.financeService,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final currencySymbol = CurrencyUtils.getCurrencySymbol(
          authState.preferredCurrency,
        );

        return BlocBuilder<AccountBloc, AccountState>(
          builder: (context, accountState) {
            if (accountState is AccountLoading) {
              return Skeletonizer(
                enabled: true,
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 3, // Show 3 skeleton items while loading
                  itemBuilder: (context, index) {
                    return AccountCard(
                      account: Account.empty(),
                      balance: {},
                      currencySymbol: currencySymbol,
                      animationIndex: index,
                    );
                  },
                ),
              );
            }

            if (accountState is AccountFailure) {
              return InlineErrorWidget(
                message: ErrorUtils.getErrorMessage(accountState.error),
                onRetry: () {
                  context.read<AccountBloc>().add(FetchAccounts());
                },
              );
            }

            if (accountState is AccountSuccess) {
              return BlocBuilder<TransactionBloc, TransactionState>(
                builder: (context, transactionState) {
                  if (transactionState is TransactionSuccess) {
                    final accounts = accountState.accounts;
                    final transactions = transactionState.transactions ?? [];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Your Accounts',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AccountsScreen(),
                                  ),
                                );
                              },
                              child: const Text('See All'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (accounts.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.account_balance_outlined,
                                    size: 48,
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No accounts yet',
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Add your first account to start tracking your finances',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.color
                                              ?.withOpacity(0.7),
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ).animate().fadeIn(duration: 300.ms)
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: accounts.length,
                            itemBuilder: (context, index) {
                              final account = accounts[index];
                              final balance = financeService.getAccountBalance(
                                account.id!,
                                transactions,
                              );

                              return AccountCard(
                                account: account,
                                balance: balance,
                                currencySymbol: currencySymbol,
                                animationIndex: index,
                                onTap: () {
                                  // Handle account tap
                                },
                              );
                            },
                          ),
                      ],
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
    );
  }
}
