import 'package:finapp/screens/about_screen.dart';
import 'package:finapp/screens/profile_settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:finapp/services/auth_service.dart';
import 'package:finapp/services/theme_service.dart';
import 'package:finapp/blocs/theme/theme_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:finapp/blocs/auth/auth_bloc.dart';

class SettingsScreen extends StatelessWidget {
  final ThemeService themeService = GetIt.instance<ThemeService>();
  final AuthService authService = GetIt.instance<AuthService>();
  SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: theme.textTheme.headlineSmall),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Card
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                return Card(
                  margin: const EdgeInsets.all(16),
                  child: InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileSettingsScreen(
                          authService: authService,
                        ),
                      ),
                    ),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: theme.colorScheme.primaryContainer,
                            child: Text(
                              state.userName[0].toUpperCase(),
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  state.userName,
                                  style: theme.textTheme.titleLarge,
                                ),
                                Text(
                                  'Tap to edit profile',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
                  ),
                ).animate().fadeIn(duration: 200.ms).scale(
                      begin: const Offset(0.95, 0.95),
                      end: const Offset(1, 1),
                    );
              },
            ),

            // Settings Groups
            _buildSettingsGroup(
              theme,
              'Appearance',
              [
                // Theme Selector
                BlocBuilder<ThemeBloc, ThemeState>(
                  builder: (context, state) {
                    return _buildSettingTile(
                      theme,
                      title: 'Theme',
                      icon: Icons.palette_outlined,
                      trailing: DropdownButton<String>(
                        value: state.currentTheme,
                        underline: const SizedBox(),
                        items: themeService.availableThemes
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            context
                                .read<ThemeBloc>()
                                .add(ChangeTheme(newValue));
                          }
                        },
                      ),
                    );
                  },
                ),

                // Theme Mode Selector
                BlocBuilder<ThemeBloc, ThemeState>(
                  builder: (context, state) {
                    return _buildSettingTile(
                      theme,
                      title: 'Dark Mode',
                      icon: Icons.dark_mode_outlined,
                      trailing: Switch(
                        value: state.themeMode == ThemeMode.dark,
                        onChanged: (bool value) {
                          context.read<ThemeBloc>().add(
                                ChangeThemeMode(
                                  value ? ThemeMode.dark : ThemeMode.light,
                                ),
                              );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),

            _buildSettingsGroup(
              theme,
              'General',
              [
                _buildSettingTile(
                  theme,
                  title: 'About',
                  subtitle: 'App information & legal',
                  icon: Icons.info_outline,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AboutScreen()),
                  ),
                ),
              ],
            ),

            _buildSettingsGroup(
              theme,
              'Account',
              [
                _buildSettingTile(
                  theme,
                  title: 'Sign Out',
                  icon: Icons.logout,
                  iconColor: theme.colorScheme.error,
                  textColor: theme.colorScheme.error,
                  onTap: () => _showSignOutDialog(context),
                ),
              ],
            ),

            // Version info at bottom
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Version 1.0.0',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(
    ThemeData theme,
    String title,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(children: children),
        ),
      ],
    ).animate().fadeIn(duration: 200.ms).slideX(
          begin: 0.05,
          end: 0,
          curve: Curves.easeOut,
        );
  }

  Widget _buildSettingTile(
    ThemeData theme, {
    required String title,
    String? subtitle,
    required IconData icon,
    Color? iconColor,
    Color? textColor,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(color: textColor),
      ),
      subtitle: subtitle != null ? Text(subtitle) : null,
      leading: Icon(icon, color: iconColor ?? theme.colorScheme.primary),
      trailing:
          trailing ?? (onTap != null ? const Icon(Icons.chevron_right) : null),
      onTap: onTap,
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
            child: Text(
              'Sign Out',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<AuthBloc>().add(LogoutRequested());
    }
  }
}
