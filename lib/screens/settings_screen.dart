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
      body: ListView(
        children: [
          _buildSection(
            theme,
            'Appearance',
            [
              BlocBuilder<ThemeBloc, ThemeState>(
                builder: (context, state) {
                  return ListTile(
                    title: const Text('Theme'),
                    leading: const Icon(Icons.palette_outlined),
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
                          context.read<ThemeBloc>().add(ChangeTheme(newValue));
                        }
                      },
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 300.ms)
                      .slideX(begin: 0.2, end: 0);
                },
              ),
              BlocBuilder<ThemeBloc, ThemeState>(
                builder: (context, state) {
                  return ListTile(
                    title: const Text('Theme Mode'),
                    leading: const Icon(Icons.brightness_6_outlined),
                    trailing: DropdownButton<ThemeMode>(
                      value: state.themeMode,
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
                          context
                              .read<ThemeBloc>()
                              .add(ChangeThemeMode(newMode));
                        }
                      },
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 100.ms, duration: 300.ms)
                      .slideX(begin: 0.2, end: 0);
                },
              ),
            ],
          ),
          _buildSection(
            theme,
            'Account',
            [
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  return ListTile(
                    title: const Text('Profile'),
                    subtitle: Text(state.userName),
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
                      .slideX(begin: 0.2, end: 0);
                },
              ),
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

                  if (confirmed == true && context.mounted) {
                    context.read<AuthBloc>().add(LogoutRequested());
                  }
                },
              )
                  .animate()
                  .fadeIn(delay: 400.ms, duration: 300.ms)
                  .slideX(begin: 0.2, end: 0),
            ],
          ),
        ],
      ),
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
