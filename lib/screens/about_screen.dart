import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('About', style: theme.textTheme.headlineSmall),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const CircleAvatar(
            radius: 50,
            child: Icon(Icons.account_balance_wallet, size: 50),
          ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 16),
          Text(
            'FinApp',
            style: theme.textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 100.ms, duration: 300.ms),
          Text(
            'Version 1.0.0',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 200.ms, duration: 300.ms),
          const SizedBox(height: 32),
          _buildSection(
            theme,
            'Features',
            [
              'Track Income & Expenses',
              'Multiple Currency Support',
              'Voice Input Support',
              'Category Management',
              'Telegram Bot Integration',
            ],
          ).animate().fadeIn(delay: 300.ms, duration: 300.ms),
          const SizedBox(height: 16),
          _buildSection(
            theme,
            'Support',
            [
              'Email: support@finapp.com',
              'Website: finapp.com',
              'Twitter: @finapp',
            ],
          ).animate().fadeIn(delay: 400.ms, duration: 300.ms),
          const SizedBox(height: 16),
          _buildSection(
            theme,
            'Legal',
            [
              'Privacy Policy',
              'Terms of Service',
              'Licenses',
            ],
          ).animate().fadeIn(delay: 500.ms, duration: 300.ms),
        ],
      ),
    );
  }

  Widget _buildSection(ThemeData theme, String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(item, style: theme.textTheme.bodyMedium),
            )),
      ],
    );
  }
}
