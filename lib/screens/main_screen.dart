import 'package:finapp/models/transaction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:finapp/screens/dashboard_screen.dart';
import 'package:finapp/screens/transactions_screen.dart';
import 'package:finapp/screens/insights_screen.dart';
import 'package:finapp/screens/more_screen.dart';
import 'package:finapp/screens/voice_transaction_screen.dart';
import 'package:finapp/screens/add_transaction_screen.dart';
import 'package:finapp/services/auth_service.dart';
import 'package:finapp/services/finance_service.dart';
import 'package:finapp/screens/scan_receipt_screen.dart';

class MainScreen extends StatefulWidget {
  final AuthService authService;
  final FinanceService financeService;

  const MainScreen({
    super.key,
    required this.authService,
    required this.financeService,
  });

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _screens = [
    DashboardScreen(
      authService: widget.authService,
      financeService: widget.financeService,
    ),
    const TransactionsScreen(),
    InsightsScreen(
      financeService: widget.financeService,
      authService: widget.authService,
    ),
    MoreScreen(
      authService: widget.authService,
      financeService: widget.financeService,
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showAIOptions() {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withOpacity(0.1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Add Transaction',
                            style: theme.textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Choose how you want to add your transaction',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.textTheme.bodyLarge?.color
                                  ?.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.85,
                      ),
                      delegate: SliverChildListDelegate([
                        _buildOptionCard(
                          context,
                          title: 'Manual Entry',
                          description: 'Add transaction details manually',
                          icon: Icons.edit_rounded,
                          color: theme.colorScheme.primary,
                          onTap: () {
                            // Show a small bottom sheet for transaction type selection
                            showModalBottomSheet(
                              context: context,
                              builder: (context) => SafeArea(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ListTile(
                                        leading: Icon(
                                          Icons.trending_up_rounded,
                                          color: theme.colorScheme.primary,
                                        ),
                                        title: const Text('Income'),
                                        subtitle: const Text(
                                            'Add money you received'),
                                        onTap: () {
                                          Navigator.pop(
                                              context); // Close type selection
                                          Navigator.pop(
                                              context); // Close main bottom sheet
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  AddTransactionScreen(
                                                // financeService:
                                                //     widget.financeService,
                                                transactionType:
                                                    TransactionType.income,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      ListTile(
                                        leading: Icon(
                                          Icons.trending_down_rounded,
                                          color: theme.colorScheme.error,
                                        ),
                                        title: const Text('Expense'),
                                        subtitle:
                                            const Text('Add money you spent'),
                                        onTap: () {
                                          Navigator.pop(
                                              context); // Close type selection
                                          Navigator.pop(
                                              context); // Close main bottom sheet
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  AddTransactionScreen(
                                                // financeService:
                                                //     widget.financeService,
                                                transactionType:
                                                    TransactionType.expense,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        _buildOptionCard(
                          context,
                          title: 'Just Talk',
                          description: 'Tell me what you spent',
                          icon: Icons.mic,
                          color: theme.colorScheme.secondary,
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VoiceTransactionScreen(
                                  financeService: widget.financeService,
                                ),
                              ),
                            );
                          },
                        ),
                        _buildOptionCard(
                          context,
                          title: 'Scan Receipt',
                          description: 'Take a photo of your receipt',
                          icon: Icons.document_scanner,
                          color: theme.colorScheme.tertiary,
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ScanReceiptScreen(
                                  financeService: widget.financeService,
                                ),
                              ),
                            );
                          },
                        ),
                        _buildOptionCard(
                          context,
                          title: 'Type Naturally',
                          description: 'Write it like you\'d tell a friend',
                          icon: Icons.chat_bubble_outline,
                          color: theme.colorScheme.error,
                          isComingSoon: true,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Coming soon! ✨'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                      ]),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 24),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isComingSoon = false,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: color.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.color
                          ?.withOpacity(0.7),
                    ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (isComingSoon) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Coming Soon',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: _screens[_selectedIndex]
          .animate()
          .fadeIn(duration: 200.ms, curve: Curves.easeInOut)
          .slideX(
              begin: 0.02, end: 0, duration: 200.ms, curve: Curves.easeInOut),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_rounded),
            label: 'Transactions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insights_rounded),
            label: 'Insights',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz),
            label: 'More',
          ),
        ],
      ).animate().fadeIn(duration: 300.ms, curve: Curves.easeIn),
      floatingActionButton: _buildAIButton(theme),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildAIButton(ThemeData theme) {
    return FloatingActionButton(
      mini: false,
      heroTag: 'aiButtonTag',
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(100),
      ),
      onPressed: _showAIOptions,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.secondary,
            ],
          ),
        ),
        child: Icon(
          Icons.auto_awesome,
          size: 30,
          color: theme.colorScheme.onPrimary,
        ),
      ),
    )
        .animate()
        .scale(delay: 400.ms, duration: 200.ms, curve: Curves.easeOutBack);
  }
}
