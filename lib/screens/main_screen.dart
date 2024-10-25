import 'package:flutter/material.dart';
import 'package:finapp/screens/dashboard_screen.dart';
import 'package:finapp/screens/income_screen.dart';
import 'package:finapp/screens/expense_screen.dart';
import 'package:finapp/screens/categories_screen.dart';
import 'package:finapp/services/auth_service.dart';
import 'package:finapp/services/finance_service.dart';

class MainScreen extends StatefulWidget {
  final AuthService authService;
  final FinanceService financeService;

  const MainScreen(
      {super.key, required this.authService, required this.financeService});

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
    return Scaffold(
      body: _screens[_selectedIndex],
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
        ],
      ),
    );
  }
}
