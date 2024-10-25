import 'package:flutter/material.dart';
import 'package:finapp/services/auth_service.dart';
import 'package:finapp/services/finance_service.dart';
import 'package:finapp/widgets/balance_card.dart';
import 'package:finapp/widgets/recent_transactions.dart';
import 'package:signals/signals_flutter.dart';

class DashboardScreen extends StatelessWidget {
  final AuthService authService;
  final FinanceService financeService;

  const DashboardScreen({
    super.key,
    required this.authService,
    required this.financeService,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('My Piggy Bank', style: theme.textTheme.headlineSmall),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => authService.logout(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await financeService.fetchTransactions();
          await financeService.fetchCategories();
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Watch((context) =>
                BalanceCard(balance: financeService.balance.value)),
            const SizedBox(height: 24),
            Watch((context) => RecentTransactions(
                  transactions: financeService.transactions,
                  categories: financeService.categories,
                )),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to AddTransactionScreen
        },
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}
