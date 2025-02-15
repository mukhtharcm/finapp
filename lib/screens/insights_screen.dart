import 'package:finapp/models/category.dart';
import 'package:flutter/material.dart';
import 'package:finapp/services/finance_service.dart';
import 'package:finapp/services/auth_service.dart';
import 'package:finapp/models/transaction.dart';
import 'package:finapp/utils/currency_utils.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finapp/blocs/transaction/transaction_bloc.dart';
import 'package:finapp/blocs/category/category_bloc.dart';
import 'package:finapp/blocs/auth/auth_bloc.dart';
import 'package:finapp/utils/error_utils.dart';
import 'package:finapp/widgets/error_widgets.dart';

class InsightsScreen extends StatelessWidget {
  final FinanceService financeService;
  final AuthService authService;

  const InsightsScreen({
    super.key,
    required this.financeService,
    required this.authService,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Financial Insights', style: theme.textTheme.headlineSmall),
        elevation: 0,
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          final currencySymbol = CurrencyUtils.getCurrencySymbol(
            authState.preferredCurrency,
          );

          return BlocBuilder<TransactionBloc, TransactionState>(
            builder: (context, transactionState) {
              if (transactionState is TransactionLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (transactionState is TransactionFailure) {
                return ErrorView(
                  message: ErrorUtils.getErrorMessage(transactionState.error),
                  onRetry: () {
                    context.read<TransactionBloc>().add(FetchTransactions());
                  },
                );
              }

              if (transactionState is TransactionSuccess) {
                final transactions = transactionState.transactions ?? [];
                if (transactions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.insights_outlined,
                          size: 64,
                          color: theme.colorScheme.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No transactions yet',
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add some transactions to see insights',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(duration: 300.ms),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<TransactionBloc>().add(FetchTransactions());
                    context.read<CategoryBloc>().add(FetchCategories());
                  },
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 24,
                    ),
                    children: [
                      _buildFinancialSummary(
                          transactions, currencySymbol, theme),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Income vs Expenses', theme),
                      _buildCustomIncomeVsExpensesChart(
                        transactions,
                        currencySymbol,
                        theme,
                      ),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Top Spending Categories', theme),
                      BlocBuilder<CategoryBloc, CategoryState>(
                        builder: (context, categoryState) {
                          if (categoryState is CategoryLoading) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          if (categoryState is CategoryFailure) {
                            return InlineErrorWidget(
                              message: ErrorUtils.getErrorMessage(
                                  categoryState.error),
                              onRetry: () {
                                context
                                    .read<CategoryBloc>()
                                    .add(FetchCategories());
                              },
                            );
                          }

                          if (categoryState is CategorySuccess) {
                            return _buildCustomSpendingBreakdown(
                              transactions,
                              categoryState.categories,
                              currencySymbol,
                              theme,
                            );
                          }

                          return const SizedBox.shrink();
                        },
                      ),
                    ]
                        .animate(interval: 100.ms)
                        .fadeIn(duration: 300.ms)
                        .slideY(begin: 0.1, end: 0),
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(title,
          style: theme.textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildFinancialSummary(
      List<Transaction> transactions, String currencySymbol, ThemeData theme) {
    final totalIncome = transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
    final totalExpenses = transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
    final balance = totalIncome - totalExpenses;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Financial Summary', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            _buildSummaryRow('Total Income', totalIncome, currencySymbol,
                theme.colorScheme.primary, theme),
            const SizedBox(height: 8),
            _buildSummaryRow('Total Expenses', totalExpenses, currencySymbol,
                theme.colorScheme.error, theme),
            const Divider(height: 24),
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
          '$currencySymbol${amount.abs().toStringAsFixed(2)}',
          style: theme.textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildCustomIncomeVsExpensesChart(
      List<Transaction> transactions, String currencySymbol, ThemeData theme) {
    final totalIncome = transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
    final totalExpenses = transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
    final maxAmount = totalIncome > totalExpenses ? totalIncome : totalExpenses;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBarChart('Income', totalIncome, maxAmount, currencySymbol,
                theme.colorScheme.primary, theme),
            const SizedBox(height: 16),
            _buildBarChart('Expenses', totalExpenses, maxAmount, currencySymbol,
                theme.colorScheme.error, theme),
          ],
        ),
      ),
    ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack);
  }

  Widget _buildBarChart(String label, double amount, double maxAmount,
      String currencySymbol, Color color, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: amount / maxAmount,
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 20,
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$currencySymbol${amount.toStringAsFixed(2)}',
              style: theme.textTheme.bodySmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              '${(amount / maxAmount * 100).toStringAsFixed(1)}%',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCustomSpendingBreakdown(
    List<Transaction> transactions,
    List<Category> categories,
    String currencySymbol,
    ThemeData theme,
  ) {
    final expensesByCategory = <String, double>{};
    for (var transaction
        in transactions.where((t) => t.type == TransactionType.expense)) {
      final category = categories
          .firstWhere(
            (c) => c.id == transaction.categoryId,
            orElse: () => Category(name: 'Unknown', icon: '❓'),
          )
          .name;
      expensesByCategory[category] =
          (expensesByCategory[category] ?? 0) + transaction.amount;
    }

    final sortedExpenses = expensesByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...sortedExpenses.take(5).map((entry) => _buildCategoryBar(
                entry.key,
                entry.value,
                sortedExpenses.first.value,
                currencySymbol,
                theme)),
          ],
        ),
      ),
    ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack);
  }

  Widget _buildCategoryBar(String category, double amount, double maxAmount,
      String currencySymbol, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(category, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: amount / maxAmount,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                  minHeight: 8,
                ),
              ),
              const SizedBox(width: 8),
              Text('$currencySymbol${amount.toStringAsFixed(0)}',
                  style: theme.textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}
