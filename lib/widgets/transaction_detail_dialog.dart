import 'package:flutter/material.dart';
import 'package:finapp/models/transaction.dart';
import 'package:finapp/models/category.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TransactionDetailDialog extends StatelessWidget {
  final Transaction transaction;
  final Category category;

  const TransactionDetailDialog({
    super.key,
    required this.transaction,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM d, yyyy HH:mm');

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  transaction.description,
                  style: theme.textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ).animate().fadeIn(duration: 200.ms, delay: 50.ms),
                const SizedBox(height: 20),
                _buildDetailRow(
                  context,
                  'Amount',
                  '${transaction.type == TransactionType.expense ? '-' : '+'}\$${transaction.amount.toStringAsFixed(2)}',
                  Icons.attach_money,
                  color: transaction.type == TransactionType.expense
                      ? theme.colorScheme.error
                      : theme.colorScheme.primary,
                  delay: 100.ms,
                ),
                _buildDetailRow(
                  context,
                  'Category',
                  category.name,
                  Icons.category,
                  delay: 150.ms,
                ),
                _buildDetailRow(
                  context,
                  'Date',
                  dateFormat.format(transaction.timestamp),
                  Icons.calendar_today,
                  delay: 200.ms,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ).animate().fadeIn(delay: 250.ms, duration: 200.ms),
              ],
            ),
          ),
          Positioned(
            top: -40,
            child: CircleAvatar(
              radius: 40,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Text(
                category.icon,
                style: TextStyle(
                    fontSize: 40, color: theme.colorScheme.onPrimaryContainer),
              ),
            ).animate().scale(duration: 200.ms, curve: Curves.easeOutBack),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
      BuildContext context, String label, String value, IconData icon,
      {Color? color, Duration delay = Duration.zero}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.secondary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.bodySmall),
                Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(color: color),
                ),
              ],
            ),
          ),
        ],
      )
          .animate()
          .fadeIn(delay: delay, duration: 200.ms)
          .slideX(begin: 0.1, end: 0, delay: delay, duration: 200.ms),
    );
  }
}
