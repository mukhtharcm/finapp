import 'package:finapp/models/account.dart';
import 'package:finapp/services/finance_service.dart';
import 'package:finapp/widgets/transaction_card.dart';
import 'package:flutter/material.dart';
import 'package:finapp/models/transaction.dart';
import 'package:finapp/models/category.dart';
import 'package:finapp/widgets/transaction_detail_dialog.dart';
import 'package:signals/signals_flutter.dart';
import 'package:finapp/utils/currency_utils.dart';
import 'package:finapp/services/auth_service.dart';
import 'package:get_it/get_it.dart';

class RecentTransactions extends StatelessWidget {
  final ListSignal<Transaction> transactions;
  final ListSignal<Category> categories;
  final AuthService authService = GetIt.instance<AuthService>();
  final FinanceService financeService;

  RecentTransactions({
    super.key,
    required this.transactions,
    required this.categories,
    required this.financeService,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencySymbol =
        CurrencyUtils.getCurrencySymbol(authService.preferredCurrency.value);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Transactions',
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Watch((context) {
          // Watch both transactions and categories
          final transactionList = transactions.toList();
          final categoryList = categories.toList();

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: transactionList.length > 5 ? 5 : transactionList.length,
            itemBuilder: (context, index) {
              final transaction = transactionList[index];
              final category = categoryList.firstWhere(
                (c) => c.id == transaction.categoryId,
                orElse: () => Category(name: 'Uncategorized', icon: '❓'),
              );
              final account = financeService.accounts.firstWhere(
                (a) => a.id == transaction.accountId,
                orElse: () => Account(
                  userId: transaction.userId,
                  name: 'Unknown',
                  type: 'unknown',
                  icon: '❓',
                ),
              );

              return TransactionCard(
                transaction: transaction,
                category: category,
                account: account,
                currencySymbol: currencySymbol,
                showAccount: false,
                compact: true, // Use compact style for dashboard
                financeService: financeService,
              );
            },
          );
        }),
      ],
    );
  }

  void _showTransactionDetails(
      BuildContext context, Transaction transaction, Category category) {
    showDialog(
      context: context,
      builder: (context) => TransactionDetailDialog(
        transaction: transaction,
        category: category,
        currencySymbol: CurrencyUtils.getCurrencySymbol(
            authService.preferredCurrency.value),
      ),
    );
  }
}
