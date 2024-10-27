import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:finapp/screens/dashboard_screen.dart';
import 'package:finapp/screens/income_screen.dart';
import 'package:finapp/screens/expense_screen.dart';
import 'package:finapp/screens/categories_screen.dart';
import 'package:finapp/screens/insights_screen.dart';
import 'package:finapp/screens/voice_transaction_screen.dart';
import 'package:finapp/services/auth_service.dart';
import 'package:finapp/services/finance_service.dart';

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

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      DashboardScreen(
          authService: widget.authService,
          financeService: widget.financeService),
      IncomeScreen(financeService: widget.financeService),
      ExpenseScreen(financeService: widget.financeService),
      CategoriesScreen(financeService: widget.financeService),
      InsightsScreen(financeService: widget.financeService),
    ];

    // Fetch initial data
    widget.financeService.fetchTransactions();
    widget.financeService.fetchCategories();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
              icon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
          BottomNavigationBarItem(
              icon: Icon(Icons.trending_up_rounded), label: 'Income'),
          BottomNavigationBarItem(
              icon: Icon(Icons.trending_down_rounded), label: 'Expenses'),
          BottomNavigationBarItem(
              icon: Icon(Icons.category_rounded), label: 'Categories'),
          BottomNavigationBarItem(
              icon: Icon(Icons.insights_rounded), label: 'Insights'),
        ],
      ).animate().fadeIn(duration: 300.ms, curve: Curves.easeIn),
      floatingActionButton: _buildAIButton(theme),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildAIButton(ThemeData theme) {
    return FloatingActionButton(
      mini: false,
      // shape set as circle
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(100),
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                VoiceTransactionScreen(financeService: widget.financeService),
          ),
        );
      },
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
