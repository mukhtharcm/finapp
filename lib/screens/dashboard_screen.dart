import 'package:finapp/screens/settings_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:finapp/services/auth_service.dart';
import 'package:finapp/services/finance_service.dart';
import 'package:finapp/widgets/balance_card.dart';
import 'package:finapp/widgets/recent_transactions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:finapp/widgets/accounts_overview.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finapp/blocs/transaction/transaction_bloc.dart';
import 'package:finapp/blocs/auth/auth_bloc.dart';

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
        title: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return Text(
              'Welcome, ${state.userName}',
              style: theme.textTheme.headlineSmall,
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(),
                ),
              );
            },
          ),
          if (kDebugMode)
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'reset_onboarding') {
                  await _resetOnboarding(context);
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'reset_onboarding',
                  child: Text('Reset Onboarding (Dev)'),
                ),
              ],
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<TransactionBloc>().add(FetchTransactions());
          // Add other refresh events as needed
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            BlocBuilder<TransactionBloc, TransactionState>(
              builder: (context, transactionState) {
                if (transactionState is TransactionSuccess) {
                  return BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, authState) {
                      final balance = financeService.calculateBalance(
                        transactionState.transactions ?? [],
                      );
                      return BalanceCard(
                        balance: balance,
                        currency: authState.preferredCurrency,
                      )
                          .animate()
                          .fadeIn(duration: 400.ms, curve: Curves.easeInOut)
                          .slideY(
                            begin: 0.05,
                            end: 0,
                            duration: 400.ms,
                            curve: Curves.easeOutCubic,
                          );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _launchTelegramBot(context),
              icon: Icon(Icons.telegram, color: theme.colorScheme.onPrimary),
              label: Text('Open Telegram Bot',
                  style: TextStyle(color: theme.colorScheme.onPrimary)),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ).animate().fadeIn(delay: 300.ms, duration: 300.ms),
            const SizedBox(height: 24),
            BlocBuilder<TransactionBloc, TransactionState>(
              builder: (context, state) {
                return Column(
                  children: [
                    AccountsOverview(
                      authService: authService,
                      financeService: financeService,
                    )
                        .animate()
                        .fadeIn(delay: 200.ms, duration: 400.ms)
                        .slideY(begin: 0.05, end: 0, duration: 400.ms),
                    const SizedBox(height: 24),
                    RecentTransactions()
                        .animate()
                        .fadeIn(
                          delay: 200.ms,
                          duration: 400.ms,
                          curve: Curves.easeInOut,
                        )
                        .slideY(
                          begin: 0.05,
                          end: 0,
                          duration: 400.ms,
                          curve: Curves.easeOutCubic,
                        ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _resetOnboarding(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasCompletedOnboarding', false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Onboarding reset. Restart the app to see changes.'),
      ),
    );
  }

  void _launchTelegramBot(BuildContext context) async {
    var botUsername = kDebugMode ? 'finmanapptestbot' : 'finmanappbot';

    // Use BlocBuilder to get the current user ID
    final state = context.read<AuthBloc>().state;
    if (!state.isAuthenticated) return;

    final Uri url = Uri.parse(
      'https://t.me/$botUsername?start=${authService.currentUser?.id}',
    );
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }
}
