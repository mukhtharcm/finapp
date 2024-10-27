import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';
import 'package:finapp/services/finance_service.dart';
import 'package:finapp/services/auth_service.dart';
import 'package:finapp/models/transaction.dart';
import 'package:finapp/utils/currency_utils.dart';
import 'package:get_it/get_it.dart';
import 'package:signals/signals_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

class InsightsScreen extends StatelessWidget {
  final FinanceService financeService;
  final AuthService authService = GetIt.instance<AuthService>();

  InsightsScreen({super.key, required this.financeService});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencySymbol =
        CurrencyUtils.getCurrencySymbol(authService.preferredCurrency);

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Financial Insights',
            style: theme.textTheme.headlineSmall),
        elevation: 0,
      ),
      body: Watch((context) {
        final transactions = financeService.transactions;
        return RefreshIndicator(
          onRefresh: () async {
            await financeService.fetchTransactions();
            await financeService.fetchCategories();
          },
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            children: [
              _buildSummaryCard(transactions, currencySymbol, theme),
              const SizedBox(height: 32),
              _buildSectionTitle('Income vs Expenses', theme),
              _buildSimpleIncomeVsExpensesChart(
                  transactions, currencySymbol, theme),
              const SizedBox(height: 32),
              _buildSectionTitle('Where Your Money Goes', theme),
              _buildSimpleExpenseCategoriesChart(
                  transactions, currencySymbol, theme),
              const SizedBox(height: 16), // Add some bottom padding
            ]
                .animate(interval: 100.ms)
                .fadeIn(duration: 300.ms)
                .slideY(begin: 0.1, end: 0),
          ),
        );
      }),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(title,
          style: theme.textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildSummaryCard(
      List<Transaction> transactions, String currencySymbol, ThemeData theme) {
    final totalIncome = transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
    final totalExpenses = transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
    final balance = totalIncome - totalExpenses;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your Financial Summary',
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            _buildSummaryRow('Total Income', totalIncome, currencySymbol,
                theme.colorScheme.primary, theme),
            const SizedBox(height: 16),
            _buildSummaryRow('Total Expenses', totalExpenses, currencySymbol,
                theme.colorScheme.error, theme),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(thickness: 1),
            ),
            _buildSummaryRow(
                'Current Balance',
                balance,
                currencySymbol,
                balance >= 0
                    ? theme.colorScheme.primary
                    : theme.colorScheme.error,
                theme),
          ],
        ),
      ),
    ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack);
  }

  Widget _buildSummaryRow(String label, double amount, String currencySymbol,
      Color color, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.titleMedium),
        Text(
          '$currencySymbol${amount.toStringAsFixed(2)}',
          style: theme.textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleIncomeVsExpensesChart(
      List<Transaction> transactions, String currencySymbol, ThemeData theme) {
    final totalIncome = transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
    final totalExpenses = transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);

    final data = [
      {'category': 'Income', 'amount': totalIncome},
      {'category': 'Expenses', 'amount': totalExpenses},
    ];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This chart shows your total income compared to your total expenses.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: Chart(
                data: data,
                variables: {
                  'category': Variable(
                    accessor: (Map map) => map['category'] as String,
                  ),
                  'amount': Variable(
                    accessor: (Map map) => map['amount'] as num,
                  ),
                },
                marks: [
                  IntervalMark(
                    position: Varset('category') * Varset('amount'),
                    color: ColorEncode(
                      variable: 'category',
                      values: [
                        theme.colorScheme.primary,
                        theme.colorScheme.error
                      ],
                    ),
                    label: LabelEncode(
                      encoder: (tuple) => Label(
                        '${tuple['category']}\n$currencySymbol${(tuple['amount'] as num).toStringAsFixed(0)}',
                        LabelStyle(
                          textStyle: theme.textTheme.bodySmall!.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          align: Alignment.center,
                        ),
                      ),
                    ),
                  ),
                ],
                axes: [
                  Defaults.horizontalAxis,
                  Defaults.verticalAxis..label = null,
                ],
                coord: RectCoord(transposed: true),
              ),
            ),
          ],
        ),
      ),
    ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack);
  }

  Widget _buildSimpleExpenseCategoriesChart(
      List<Transaction> transactions, String currencySymbol, ThemeData theme) {
    final expensesByCategory = <String, double>{};
    for (var transaction
        in transactions.where((t) => t.type == TransactionType.expense)) {
      final category = financeService.categories
          .firstWhere((c) => c.id == transaction.categoryId)
          .name;
      expensesByCategory[category] =
          (expensesByCategory[category] ?? 0) + transaction.amount;
    }

    final data = expensesByCategory.entries
        .map((e) => {'category': e.key, 'amount': e.value})
        .toList()
      ..sort(
          (a, b) => (b['amount'] as double).compareTo(a['amount'] as double));

    final totalExpenses =
        data.fold(0.0, (sum, item) => sum + (item['amount'] as double));

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This chart shows how your expenses are distributed across different categories.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 300,
              child: Chart(
                data: data.take(5).toList(), // Show top 5 categories
                variables: {
                  'category': Variable(
                    accessor: (Map map) => map['category'] as String,
                  ),
                  'amount': Variable(
                    accessor: (Map map) => map['amount'] as num,
                  ),
                },
                marks: [
                  IntervalMark(
                    position: Varset('category') * Varset('amount'),
                    color: ColorEncode(
                      variable: 'category',
                      values: [
                        theme.colorScheme.primary,
                        theme.colorScheme.secondary,
                        theme.colorScheme.tertiary,
                        theme.colorScheme.error,
                        theme.colorScheme.primaryContainer,
                      ],
                    ),
                    label: LabelEncode(
                      encoder: (tuple) => Label(
                        '${tuple['category']}\n${((tuple['amount'] as num) / totalExpenses * 100).toStringAsFixed(1)}%',
                        LabelStyle(textStyle: theme.textTheme.bodySmall!),
                      ),
                    ),
                  ),
                ],
                coord: PolarCoord(transposed: true, dimCount: 1),
                annotations: [
                  LineAnnotation(
                    dim: Dim.y,
                    value: 0,
                    style: PaintStyle(
                      strokeColor: theme.colorScheme.onSurface.withOpacity(0.3),
                      strokeWidth: 1,
                    ),
                  ),
                ],
                selections: {
                  'tap': PointSelection(
                    on: {
                      GestureType.tap,
                      GestureType.longPress,
                    },
                    dim: Dim.x,
                  )
                },
                tooltip: TooltipGuide(
                  followPointer: [false, true],
                  align: Alignment.topLeft,
                  offset: const Offset(-20, -20),
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack);
  }
}
