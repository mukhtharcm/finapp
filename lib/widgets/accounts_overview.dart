import 'package:flutter/material.dart';
import 'package:finapp/services/finance_service.dart';
import 'package:finapp/utils/currency_utils.dart';
import 'package:finapp/services/auth_service.dart';
import 'package:signals/signals_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:finapp/screens/accounts_screen.dart';

class AccountsOverview extends StatelessWidget {
  final FinanceService financeService;
  final AuthService authService = GetIt.instance<AuthService>();

  AccountsOverview({
    super.key,
    required this.financeService,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencySymbol = CurrencyUtils.getCurrencySymbol(
      authService.preferredCurrency.value,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Your Accounts',
              style: theme.textTheme.titleLarge,
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AccountsScreen(
                      financeService: financeService,
                    ),
                  ),
                );
              },
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Watch((context) {
          final accounts = financeService.accounts;

          if (accounts.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.account_balance_outlined,
                      size: 48,
                      color: theme.colorScheme.outline,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No accounts yet',
                      style: theme.textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add your first account to start tracking your finances',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color:
                            theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 300.ms);
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: accounts.length,
            itemBuilder: (context, index) {
              final account = accounts[index];
              final balance = financeService.getAccountBalance(account.id!);
              final isPositive = balance['balance']! >= 0;

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
                                color: theme.colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                account.icon,
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        account.name,
                                        style: theme.textTheme.titleMedium,
                                      ),
                                      if (account.isDefault) ...[
                                        const SizedBox(width: 8),
                                        Icon(
                                          Icons.star_rounded,
                                          size: 16,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ],
                                    ],
                                  ),
                                  Text(
                                    account.type,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.outline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '$currencySymbol${balance['balance']?.abs().toStringAsFixed(2)}',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isPositive
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.error,
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
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme.error,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      isPositive ? 'Available' : 'Overdrawn',
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: isPositive
                                            ? theme.colorScheme.primary
                                            : theme.colorScheme.error,
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
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: balance['income']! /
                                (balance['income']! + balance['expenses']!),
                            backgroundColor: theme.colorScheme.errorContainer
                                .withOpacity(0.5),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              theme.colorScheme.primary.withOpacity(0.7),
                            ),
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildBalanceIndicator(
                              context,
                              label: 'Income',
                              amount: balance['income']!,
                              currencySymbol: currencySymbol,
                              color: theme.colorScheme.primary,
                            ),
                            _buildBalanceIndicator(
                              context,
                              label: 'Expenses',
                              amount: balance['expenses']!,
                              currencySymbol: currencySymbol,
                              color: theme.colorScheme.error,
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
          );
        }),
      ],
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
