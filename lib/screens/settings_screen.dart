import 'package:flutter/material.dart';
import 'package:finapp/services/auth_service.dart';
import 'package:finapp/utils/currency_utils.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get_it/get_it.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _authService = GetIt.instance<AuthService>();
  late String _selectedCurrency;
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _selectedCurrency = _authService.preferredCurrency;
    // TODO: Implement actual dark mode detection
    _isDarkMode = false;
  }

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
            'Account',
            [
              _buildListTile(
                icon: Icons.person,
                title: 'Profile',
                subtitle: _authService.userName,
                onTap: () {
                  // TODO: Implement profile editing
                },
              ),
              _buildListTile(
                icon: Icons.email,
                title: 'Email',
                subtitle:
                    _authService.currentUser?.data['email'] as String? ?? '',
                onTap: () {
                  // TODO: Implement email changing
                },
              ),
            ],
          ),
          _buildSection(
            'Preferences',
            [
              _buildListTile(
                icon: Icons.monetization_on,
                title: 'Currency',
                subtitle: _selectedCurrency,
                onTap: _showCurrencyPicker,
              ),
              SwitchListTile(
                secondary:
                    Icon(Icons.brightness_6, color: theme.colorScheme.primary),
                title: Text('Dark Mode', style: theme.textTheme.titleMedium),
                value: _isDarkMode,
                onChanged: (value) {
                  setState(() {
                    _isDarkMode = value;
                  });
                  // TODO: Implement actual theme changing
                },
              ),
            ],
          ),
          _buildSection(
            'Support',
            [
              _buildListTile(
                icon: Icons.help,
                title: 'Help & FAQ',
                onTap: () {
                  // TODO: Implement Help & FAQ screen
                },
              ),
              _buildListTile(
                icon: Icons.contact_support,
                title: 'Contact Us',
                onTap: () {
                  // TODO: Implement Contact Us functionality
                },
              ),
            ],
          ),
          _buildSection(
            'About',
            [
              _buildListTile(
                icon: Icons.info,
                title: 'App Version',
                subtitle: '1.0.0',
              ),
              _buildListTile(
                icon: Icons.description,
                title: 'Terms of Service',
                onTap: () {
                  // TODO: Implement Terms of Service screen
                },
              ),
              _buildListTile(
                icon: Icons.privacy_tip,
                title: 'Privacy Policy',
                onTap: () {
                  // TODO: Implement Privacy Policy screen
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: () => _authService.logout(),
              style: ElevatedButton.styleFrom(
                foregroundColor: theme.colorScheme.onError,
                backgroundColor: theme.colorScheme.error,
              ),
              child: const Text('Log Out'),
            ),
          ),
          const SizedBox(height: 24),
        ]
            .animate(interval: 50.ms)
            .fadeIn(duration: 300.ms)
            .slideY(begin: 0.1, end: 0),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: onTap != null ? Icon(Icons.chevron_right) : null,
      onTap: onTap,
    );
  }

  void _showCurrencyPicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Currency'),
          content: DropdownButton<String>(
            value: _selectedCurrency,
            items: CurrencyUtils.getAllCurrencyCodes().map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child:
                    Text('$value (${CurrencyUtils.getCurrencySymbol(value)})'),
              );
            }).toList(),
            onChanged: (newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedCurrency = newValue;
                });
                _authService.updateUserProfile(preferredCurrency: newValue);
                Navigator.of(context).pop();
              }
            },
          ),
        );
      },
    );
  }
}
