import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:finapp/models/suggested_transaction.dart';
import 'package:finapp/models/category.dart';
import 'package:finapp/utils/currency_utils.dart';

class SuggestedTransactionCard extends StatelessWidget {
  final SuggestedTransaction transaction;
  final Category? category;
  final String currencySymbol;
  final VoidCallback? onEdit;
  final VoidCallback? onAdd;
  final double opacity;

  const SuggestedTransactionCard({
    super.key,
    required this.transaction,
    required this.category,
    required this.currencySymbol,
    this.onEdit,
    this.onAdd,
    this.opacity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isValidCategory = category != null;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onEdit,
        child: Opacity(
          opacity: opacity,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: isValidCategory
                          ? (transaction.type ==
                                  SuggestedTransactionType.expense
                              ? theme.colorScheme.errorContainer
                              : theme.colorScheme.primaryContainer)
                          : theme.colorScheme.surfaceContainerHighest,
                      child: Text(
                        isValidCategory ? category!.icon : '❓',
                        style: TextStyle(
                          fontSize: 20,
                          color: isValidCategory
                              ? (transaction.type ==
                                      SuggestedTransactionType.expense
                                  ? theme.colorScheme.error
                                  : theme.colorScheme.primary)
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            transaction.description,
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isValidCategory
                                ? category!.name
                                : 'Unknown Category',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '$currencySymbol${transaction.amount.toStringAsFixed(2)}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color:
                            transaction.type == SuggestedTransactionType.expense
                                ? theme.colorScheme.error
                                : theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (!isValidCategory)
                      FilledButton.icon(
                        onPressed: onEdit,
                        style: FilledButton.styleFrom(
                          backgroundColor: theme.colorScheme.errorContainer,
                          foregroundColor: theme.colorScheme.error,
                        ),
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Fix Category'),
                      )
                    else
                      FilledButton.icon(
                        onPressed: onAdd,
                        style: FilledButton.styleFrom(
                          backgroundColor: theme.colorScheme.primaryContainer,
                          foregroundColor: theme.colorScheme.primary,
                        ),
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Add Transaction'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.1, end: 0);
  }
}
