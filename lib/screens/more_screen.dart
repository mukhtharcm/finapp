import 'package:finapp/screens/accounts_screen.dart';
import 'package:flutter/material.dart';
import 'package:finapp/services/auth_service.dart';
import 'package:finapp/services/finance_service.dart';
import 'package:finapp/screens/categories_screen.dart';
import 'package:finapp/screens/settings_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finapp/blocs/auth/auth_bloc.dart';

class MoreScreen extends StatelessWidget {
  final AuthService authService;
  final FinanceService financeService;

  const MoreScreen({
    super.key,
    required this.authService,
    required this.financeService,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('More', style: theme.textTheme.headlineSmall),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _navigateTo(context, SettingsScreen()),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Actions Section
            _buildSection(
              theme,
              'Quick Actions',
              [
                _buildQuickAction(
                  context,
                  icon: Icons.category_outlined,
                  label: 'Categories',
                  color: theme.colorScheme.primary,
                  onTap: () => _navigateTo(context, const CategoriesScreen()),
                ),
                _buildQuickAction(
                  context,
                  icon: Icons.account_balance_outlined,
                  label: 'Accounts',
                  color: theme.colorScheme.secondary,
                  onTap: () => _navigateTo(context, const AccountsScreen()),
                ),
                _buildQuickAction(
                  context,
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  color: theme.colorScheme.tertiary,
                  onTap: () => _navigateTo(context, SettingsScreen()),
                ),
              ],
            ),

            // Stats Section (Placeholder for future feature)
            _buildSection(
              theme,
              'Your Stats',
              [
                _buildStatCard(
                  context,
                  'Total Transactions',
                  '0',
                  Icons.receipt_long_outlined,
                  theme.colorScheme.primary,
                ),
                _buildStatCard(
                  context,
                  'Active Accounts',
                  '0',
                  Icons.account_balance_outlined,
                  theme.colorScheme.secondary,
                ),
              ],
            ),

            // Help & Support Section
            _buildSection(
              theme,
              'Help & Support',
              [
                _buildSupportTile(
                  context,
                  icon: Icons.help_outline,
                  title: 'Help Center',
                  subtitle: 'Get help with the app',
                  onTap: () {
                    // TODO: Implement Help Center
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Coming soon!')),
                    );
                  },
                ),
                _buildSupportTile(
                  context,
                  icon: Icons.bug_report_outlined,
                  title: 'Report an Issue',
                  subtitle: 'Help us improve the app',
                  onTap: () {
                    // TODO: Implement Issue Reporting
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Coming soon!')),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(ThemeData theme, String title, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildQuickAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }
}
