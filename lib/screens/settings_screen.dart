import 'package:finapp/screens/about_screen.dart';
import 'package:finapp/screens/profile_settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:finapp/services/auth_service.dart';
import 'package:finapp/services/theme_service.dart';
import 'package:get_it/get_it.dart';
import 'package:signals/signals_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
                ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.2, end: 0),
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
                )
                    .animate()
                    .fadeIn(delay: 100.ms, duration: 300.ms)
                    .slideX(begin: 0.2, end: 0),
              ],
            ),
            _buildSection(
              theme,
              'Account',
              [
                ListTile(
                  title: const Text('Profile'),
                  subtitle:
                      Watch((context) => Text(authService.userName.value)),
                  leading: const Icon(Icons.person_outline),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileSettingsScreen(
                          authService: authService,
                        ),
                      ),
                    );
                  },
                )
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 300.ms)
                    .slideX(begin: 0.2, end: 0),
              ],
            ),
            _buildSection(
              theme,
              'General',
              [
                ListTile(
                  title: const Text('About'),
                  subtitle: const Text('App information & legal'),
                  leading: const Icon(Icons.info_outline),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AboutScreen(),
                      ),
                    );
                  },
                )
                    .animate()
                    .fadeIn(delay: 300.ms, duration: 300.ms)
                    .slideX(begin: 0.2, end: 0),
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
                  subtitle: const Text('Log out of your account'),
                  leading: Icon(
                    Icons.logout,
                    color: theme.colorScheme.error,
                  ),
                  onTap: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Sign Out'),
                        content:
                            const Text('Are you sure you want to sign out?'),
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
                  },
                )
                    .animate()
                    .fadeIn(delay: 400.ms, duration: 300.ms)
                    .slideX(begin: 0.2, end: 0),
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
