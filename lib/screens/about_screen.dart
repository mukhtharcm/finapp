import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:finapp/gen/assets.gen.dart';

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
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primaryContainer,
              ),
              child: ClipOval(
                child: Assets.icon.icon.image(
                  fit: BoxFit.cover,
                ),
              ),
            ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack),
          ),
          const SizedBox(height: 24),
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              final version = snapshot.data?.version ?? '';
              final buildNumber = snapshot.data?.buildNumber ?? '';

              return Column(
                children: [
                  Text(
                    'FinApp',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  if (version.isNotEmpty)
                    Text(
                      'Version $version ($buildNumber)',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ).animate().fadeIn(delay: 200.ms, duration: 300.ms);
            },
          ),
          const SizedBox(height: 48),
          _buildSection(
            theme,
            'About FinApp',
            'A simple and intuitive app to help you manage your personal finances.',
          ),
          _buildSection(
            theme,
            'Features',
            '• Track income and expenses\n'
                '• Manage multiple accounts\n'
                '• Categorize transactions\n'
                '• View financial insights\n'
                '• Dark mode support',
          ),
          _buildSection(
            theme,
            'Credits',
            'Made with ❤️ using Flutter',
          ),
        ],
      ),
    );
  }

  Widget _buildSection(ThemeData theme, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: theme.textTheme.bodyLarge?.copyWith(
              height: 1.5,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms, duration: 300.ms);
  }
}
