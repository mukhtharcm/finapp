import 'package:finapp/screens/accounts_screen.dart';
import 'package:flutter/material.dart';
import 'package:finapp/services/auth_service.dart';
import 'package:finapp/services/finance_service.dart';
import 'package:finapp/screens/categories_screen.dart';
import 'package:finapp/screens/settings_screen.dart';
import 'package:finapp/screens/profile_settings_screen.dart';
import 'package:finapp/screens/about_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:signals/signals_flutter.dart';

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
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: Text('More', style: theme.textTheme.headlineMedium),
            expandedHeight: 160,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      theme.colorScheme.primary.withOpacity(0.1),
                      theme.colorScheme.surface,
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildUserSection(context, theme)
                      .animate()
                      .fadeIn(duration: 300.ms),
                  const SizedBox(height: 24),
                  _buildMenuSection(context, theme),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserSection(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: theme.colorScheme.primary,
            child: Watch((context) => Text(
                  authService.userName.value[0].toUpperCase(),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                  ),
                )),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Watch((context) => Text(
                      authService.userName.value,
                      style: theme.textTheme.titleLarge,
                    )),
                const SizedBox(height: 4),
                Watch((context) => Text(
                      'Currency: ${authService.preferredCurrency.value}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    )),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _navigateTo(
              context,
              ProfileSettingsScreen(authService: authService),
            ),
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context, ThemeData theme) {
    return Column(
      children: [
        _buildMenuGroup(
          theme,
          'Management',
          [
            _MenuItem(
              icon: Icons.category_outlined,
              title: 'Categories',
              subtitle: 'Manage transaction categories',
              onTap: () => _navigateTo(
                context,
                CategoriesScreen(financeService: financeService),
              ),
            ),
            _MenuItem(
              icon: Icons.account_balance_outlined,
              title: 'Accounts',
              subtitle: 'Manage your financial accounts',
              onTap: () => _navigateTo(
                context,
                AccountsScreen(financeService: financeService),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildMenuGroup(
          theme,
          'Preferences',
          [
            _MenuItem(
              icon: Icons.settings_outlined,
              title: 'Settings',
              subtitle: 'App preferences and theme',
              onTap: () => _navigateTo(
                context,
                SettingsScreen(authService: authService),
              ),
            ),
            _MenuItem(
              icon: Icons.info_outline,
              title: 'About',
              subtitle: 'App information & legal',
              onTap: () => _navigateTo(context, const AboutScreen()),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildMenuGroup(
          theme,
          'Account',
          [
            _MenuItem(
              icon: Icons.logout,
              title: 'Sign Out',
              subtitle: 'Log out of your account',
              isDestructive: true,
              onTap: () => _showSignOutDialog(context),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMenuGroup(
      ThemeData theme, String title, List<_MenuItem> menuItems) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Card(
          elevation: 0,
          color: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: theme.colorScheme.outlineVariant.withOpacity(0.5),
            ),
          ),
          child: Column(
            children: menuItems.map((item) {
              final index = menuItems.indexOf(item);
              return Column(
                children: [
                  if (index > 0)
                    Divider(
                      height: 1,
                      indent: 56,
                      endIndent: 16,
                    ),
                  ListTile(
                    leading: Icon(
                      item.icon,
                      color: item.isDestructive
                          ? theme.colorScheme.error
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    title: Text(
                      item.title,
                      style: item.isDestructive
                          ? TextStyle(color: theme.colorScheme.error)
                          : null,
                    ),
                    subtitle: Text(item.subtitle),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: item.onTap,
                  ),
                ],
              );
            }).toList(),
          ),
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
      ],
    );
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  Future<void> _showSignOutDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await authService.logout();
    }
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });
}
