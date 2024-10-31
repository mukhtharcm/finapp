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
import 'package:get_it/get_it.dart';

class AccountsOverview extends StatefulWidget {
  final AuthService authService = GetIt.instance<AuthService>();
  final FinanceService financeService = GetIt.instance<FinanceService>();

  AccountsOverview({
    super.key,
  });

  @override
  _AccountsOverviewState createState() => _AccountsOverviewState();
}

class _AccountsOverviewState extends State<AccountsOverview> {
  @override
  void initState() {
    super.initState();
    context.read<AccountBloc>().add(FetchAccounts());
    context.read<TransactionBloc>().add(FetchTransactions());
  }

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
              return const Center(child: CircularProgressIndicator());
            }

            if (accountState is AccountFailure) {
              return Center(child: Text('Error: ${accountState.error}'));
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
                              final balance = widget.financeService
                                  .getAccountBalance(account.id!);
                              final isPositive = balance['balance']! >= 0;

                              final total =
                                  balance['income']! + balance['expenses']!;
                              final progressValue =
                                  total > 0 ? balance['income']! / total : 0.0;

                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () {
                                    // TODO: Show account details/transactions
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primaryContainer,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                account.icon,
                                                style: const TextStyle(
                                                    fontSize: 24),
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text(
                                                        account.name,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .titleMedium,
                                                      ),
                                                      if (account
                                                          .isDefault) ...[
                                                        const SizedBox(
                                                            width: 8),
                                                        Icon(
                                                          Icons.star_rounded,
                                                          size: 16,
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .primary,
                                                        ),
                                                      ],
                                                    ],
                                                  ),
                                                  Text(
                                                    account.type,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall
                                                        ?.copyWith(
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .outline,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  '$currencySymbol${balance['balance']?.abs().toStringAsFixed(2)}',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleMedium
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: isPositive
                                                            ? Theme.of(context)
                                                                .colorScheme
                                                                .primary
                                                            : Theme.of(context)
                                                                .colorScheme
                                                                .error,
                                                      ),
                                                ),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      isPositive
                                                          ? Icons.trending_up
                                                          : Icons.trending_down,
                                                      size: 16,
                                                      color: isPositive
                                                          ? Theme.of(context)
                                                              .colorScheme
                                                              .primary
                                                          : Theme.of(context)
                                                              .colorScheme
                                                              .error,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      isPositive
                                                          ? 'Available'
                                                          : 'Overdrawn',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodySmall
                                                          ?.copyWith(
                                                            color: isPositive
                                                                ? Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .primary
                                                                : Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .error,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: LinearProgressIndicator(
                                            value: progressValue,
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .errorContainer
                                                .withOpacity(0.5),
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                                  .withOpacity(0.7),
                                            ),
                                            minHeight: 8,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            _buildBalanceIndicator(
                                              context,
                                              label: 'Income',
                                              amount: balance['income']!,
                                              currencySymbol: currencySymbol,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                            ),
                                            _buildBalanceIndicator(
                                              context,
                                              label: 'Expenses',
                                              amount: balance['expenses']!,
                                              currencySymbol: currencySymbol,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .error,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ).animate().fadeIn(
                                    duration: 300.ms,
                                    delay: (50 * index).ms,
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

  Widget _buildBalanceIndicator(
    BuildContext context, {
    required String label,
    required double amount,
    required String currencySymbol,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: color),
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.color
                        ?.withOpacity(0.7),
                  ),
            ),
            Text(
              '$currencySymbol${amount.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}
