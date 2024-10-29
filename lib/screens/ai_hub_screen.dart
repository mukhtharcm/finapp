import 'package:flutter/material.dart';
import 'package:finapp/services/finance_service.dart';
import 'package:finapp/screens/voice_transaction_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AIHubScreen extends StatelessWidget {
  final FinanceService financeService;

  const AIHubScreen({
    super.key,
    required this.financeService,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('AI Assistant', style: theme.textTheme.headlineSmall),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How would you like to add transactions?',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            _buildAIOption(
              context,
              title: 'Voice Recording',
              description: 'Record your transactions using voice commands',
              icon: Icons.mic,
              color: theme.colorScheme.primary,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      VoiceTransactionScreen(financeService: financeService),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildAIOption(
              context,
              title: 'Scan Receipt',
              description:
                  'Take a picture or upload a receipt to add transactions',
              icon: Icons.document_scanner,
              color: theme.colorScheme.secondary,
              onTap: () {
                // TODO: Implement receipt scanning
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Coming soon!')),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildAIOption(
              context,
              title: 'Natural Language',
              description: 'Type your transactions in plain English',
              icon: Icons.chat_bubble_outline,
              color: theme.colorScheme.tertiary,
              onTap: () {
                // TODO: Implement natural language input
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Coming soon!')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIOption(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.color
                                ?.withOpacity(0.7),
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.color
                    ?.withOpacity(0.3),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(
          begin: 0.2,
          end: 0,
          duration: 300.ms,
          curve: Curves.easeOutCubic,
        );
  }
}
