import 'package:flutter/material.dart';
import 'package:finapp/services/auth_service.dart';
import 'package:finapp/services/theme_service.dart';
import 'package:get_it/get_it.dart';
import 'package:signals/signals_flutter.dart';

class SettingsScreen extends StatelessWidget {
  final AuthService authService;
  final ThemeService themeService = GetIt.instance<ThemeService>();

  SettingsScreen({super.key, required this.authService});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: theme.textTheme.headlineSmall),
      ),
      body: Watch((context) {
        return ListView(
          children: [
            _buildSection(
              theme,
              'Appearance',
              [
                ListTile(
                  title: const Text('Theme'),
                  leading: const Icon(Icons.palette_outlined),
                  trailing: DropdownButton<String>(
                    value: themeService.currentTheme.value,
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
                        themeService.setTheme(newValue);
                      }
                    },
                  ),
                ),
                ListTile(
                  title: const Text('Theme Mode'),
                  leading: const Icon(Icons.brightness_6_outlined),
                  trailing: DropdownButton<ThemeMode>(
                    value: themeService.themeMode.value,
                    underline: const SizedBox(),
                    items: ThemeMode.values
                        .map<DropdownMenuItem<ThemeMode>>((ThemeMode mode) {
                      return DropdownMenuItem<ThemeMode>(
                        value: mode,
                        child: Text(themeService.getThemeModeString(mode)),
                      );
                    }).toList(),
                    onChanged: (ThemeMode? newMode) {
                      if (newMode != null) {
                        themeService.setThemeMode(newMode);
                      }
                    },
                  ),
                ),
              ],
            ),
            _buildSection(
              theme,
              'Account',
              [
                ListTile(
                  title: const Text('Profile'),
                  leading: const Icon(Icons.person_outline),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Navigate to profile settings
                  },
                ),
                ListTile(
                  title: const Text('Security'),
                  leading: const Icon(Icons.security),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Navigate to security settings
                  },
                ),
              ],
            ),
            _buildSection(
              theme,
              'General',
              [
                ListTile(
                  title: const Text('Notifications'),
                  leading: const Icon(Icons.notifications_outlined),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Navigate to notification settings
                  },
                ),
                ListTile(
                  title: const Text('Help & Support'),
                  leading: const Icon(Icons.help_outline),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Navigate to help & support
                  },
                ),
                ListTile(
                  title: const Text('About'),
                  leading: const Icon(Icons.info_outline),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Navigate to about page
                  },
                ),
              ],
            ),
            _buildSection(
              theme,
              'Danger Zone',
              [
                ListTile(
                  title: Text(
                    'Sign Out',
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                  leading: Icon(
                    Icons.logout,
                    color: theme.colorScheme.error,
                  ),
                  onTap: () async {
                    await authService.logout();
                  },
                ),
              ],
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSection(ThemeData theme, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...children,
        const Divider(),
      ],
    );
  }
}
