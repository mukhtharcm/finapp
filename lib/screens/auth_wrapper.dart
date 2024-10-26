import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:signals/signals_flutter.dart';
import 'package:finapp/screens/login_screen.dart';
import 'package:finapp/screens/main_screen.dart';
import 'package:finapp/screens/onboarding_screen.dart';
import 'package:finapp/services/auth_service.dart';
import 'package:finapp/services/finance_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthService _authService = GetIt.instance<AuthService>();
  final FinanceService _financeService = GetIt.instance<FinanceService>();
  final isAuthenticated = signal(false);
  final hasCompletedOnboarding = signal(false);

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
    _listenToAuthChanges();
  }

  void _checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    hasCompletedOnboarding.value =
        prefs.getBool('hasCompletedOnboarding') ?? false;
  }

  void _listenToAuthChanges() {
    isAuthenticated.value = _authService.isAuthenticated;
    effect(() {
      _authService.authStateChanges.listen((event) {
        isAuthenticated.value = _authService.isAuthenticated;
        if (isAuthenticated.value) {
          _financeService.fetchCategories();
          _financeService.fetchTransactions();
        }
      });
    });
  }

  void _onOnboardingComplete() {
    setState(() {
      hasCompletedOnboarding.value = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      if (isAuthenticated.value && !hasCompletedOnboarding.value) {
        return OnboardingScreen(
          onComplete: _onOnboardingComplete,
          authService: _authService,
        );
      } else if (isAuthenticated.value) {
        return MainScreen(
          authService: _authService,
          financeService: _financeService,
        );
      } else {
        return LoginScreen(authService: _authService);
      }
    });
  }
}
