import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'package:finapp/screens/login_screen.dart';
import 'package:finapp/screens/main_screen.dart';
import 'package:finapp/services/auth_service.dart';
import 'package:finapp/services/finance_service.dart';

class AuthWrapper extends StatelessWidget {
  final AuthService authService;
  final FinanceService financeService;

  const AuthWrapper({
    super.key,
    required this.authService,
    required this.financeService,
  });

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = signal(authService.isAuthenticated);

    effect(() {
      authService.authStateChanges.listen((event) {
        isAuthenticated.value = authService.isAuthenticated;
        if (isAuthenticated.value) {
          financeService.fetchCategories();
          financeService.fetchTransactions();
        }
      });
    });

    return Watch((context) {
      if (isAuthenticated.value) {
        return MainScreen(
          authService: authService,
          financeService: financeService,
        );
      } else {
        return LoginScreen(authService: authService);
      }
    });
  }
}
