import 'package:finapp/models/account.dart';
import 'package:finapp/widgets/transaction_card.dart';
import 'package:flutter/material.dart';
import 'package:finapp/services/finance_service.dart';
import 'package:finapp/services/auth_service.dart';
import 'package:finapp/models/transaction.dart';
import 'package:finapp/models/category.dart';
import 'package:finapp/screens/add_transaction_screen.dart';
import 'package:signals/signals_flutter.dart';
import 'package:finapp/widgets/transaction_detail_dialog.dart';
import 'package:finapp/utils/currency_utils.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TransactionsScreen extends StatelessWidget {
  final FinanceService financeService;
  final AuthService authService = GetIt.instance<AuthService>();

  TransactionsScreen({super.key, required this.financeService});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Transactions', style: theme.textTheme.headlineSmall),
          bottom: TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.trending_up_rounded,
                    color: theme.colorScheme.primary),
                text: 'Income',
              ),
              Tab(
                icon: Icon(Icons.trending_down_rounded,
                    color: theme.colorScheme.error),
                text: 'Expenses',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildTransactionList(
              context,
              TransactionType.income,
              theme.colorScheme.primary,
              theme.colorScheme.primaryContainer,
            ),
            _buildTransactionList(
              context,
              TransactionType.expense,
              theme.colorScheme.error,
              theme.colorScheme.errorContainer,
            ),
          ],
        ),
        floatingActionButton: _buildFloatingActionButton(context),
      ),
    );
  }

  Widget _buildTransactionList(BuildContext context, TransactionType type,
      Color textColor, Color avatarColor) {
    return Watch((context) {
      final currencySymbol =
          CurrencyUtils.getCurrencySymbol(authService.preferredCurrency.value);
      final transactions =
          financeService.transactions.where((t) => t.type == type).toList();

      return ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final transaction = transactions[index];
          final category = financeService.categories.firstWhere(
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
            animationIndex: index,
          );
        },
      );
    });
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    final theme = Theme.of(context);
    return Watch((context) {
      final tabController = DefaultTabController.of(context);
      return FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.trending_up_rounded,
                        color: theme.colorScheme.primary,
                      ),
                      title: const Text('Income'),
                      subtitle: const Text('Add money you received'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddTransactionScreen(
                              // financeService: financeService,
                              transactionType: TransactionType.income,
                            ),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.trending_down_rounded,
                        color: theme.colorScheme.error,
                      ),
                      title: const Text('Expense'),
                      subtitle: const Text('Add money you spent'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddTransactionScreen(
                              // financeService: financeService,
                              transactionType: TransactionType.expense,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        child: const Icon(Icons.add_rounded),
      ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack);
    });
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
