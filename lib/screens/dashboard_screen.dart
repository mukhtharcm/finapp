import 'package:finapp/screens/settings_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:finapp/services/auth_service.dart';
import 'package:finapp/services/finance_service.dart';
import 'package:finapp/widgets/balance_card.dart';
import 'package:finapp/widgets/recent_transactions.dart';
import 'package:signals/signals_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

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
        title: Text('Welcome, ${authService.userName}',
            style: theme.textTheme.headlineSmall),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          // Add dev mode menu
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
          await financeService.fetchCategories();
          await financeService.fetchTransactions();
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Watch((context) => BalanceCard(
                      balance: financeService.balance.value,
                      currency: authService.preferredCurrency,
                    ))
                .animate()
                .fadeIn(duration: 400.ms, curve: Curves.easeInOut)
                .slideY(
                    begin: 0.05,
                    end: 0,
                    duration: 400.ms,
                    curve: Curves.easeOutCubic),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _launchTelegramBot,
              icon: Icon(Icons.telegram, color: theme.colorScheme.onPrimary),
              label: Text('Open Telegram Bot',
                  style: TextStyle(color: theme.colorScheme.onPrimary)),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ).animate().fadeIn(delay: 300.ms, duration: 300.ms),
            const SizedBox(height: 24),
            Watch((context) {
              // Force rebuild when either transactions or categories change
              financeService.transactions.length;
              financeService.categories.length;
              return RecentTransactions(
                transactions: financeService.transactions,
                categories: financeService.categories,
              );
            })
                .animate()
                .fadeIn(
                    delay: 200.ms, duration: 400.ms, curve: Curves.easeInOut)
                .slideY(
                    begin: 0.05,
                    end: 0,
                    duration: 400.ms,
                    curve: Curves.easeOutCubic),
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
          content: Text('Onboarding reset. Restart the app to see changes.')),
    );
  }

  void _launchTelegramBot() async {
    final Uri url = Uri.parse('https://t.me/your_bot_username');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }
}
