import 'package:flutter/material.dart';
import 'package:finapp/models/account.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AccountCard extends StatelessWidget {
  final Account account;
  final Map<String, double> balance;
  final String currencySymbol;
  final int? animationIndex;
  final VoidCallback? onTap;

  const AccountCard({
    super.key,
    required this.account,
    required this.balance,
    required this.currencySymbol,
    this.animationIndex,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Safely get values with defaults
    final balanceAmount = balance['balance'] ?? 0.0;
    final incomeAmount = balance['income'] ?? 0.0;
    final expensesAmount = balance['expenses'] ?? 0.0;

    final isPositive = balanceAmount >= 0;
    final total = incomeAmount + expensesAmount;
    final progressValue = total > 0 ? incomeAmount / total : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
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
                        '$currencySymbol${balanceAmount.abs().toStringAsFixed(2)}',
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
                            style: theme.textTheme.bodySmall?.copyWith(
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
                  value: progressValue,
                  backgroundColor:
                      theme.colorScheme.errorContainer.withOpacity(0.5),
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
                    amount: incomeAmount,
                    currencySymbol: currencySymbol,
                    color: theme.colorScheme.primary,
                  ),
                  _buildBalanceIndicator(
                    context,
                    label: 'Expenses',
                    amount: expensesAmount,
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
          delay: animationIndex != null ? (50 * animationIndex!).ms : 0.ms,
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
