import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'package:finapp/screens/login_screen.dart';
import 'package:finapp/screens/main_screen.dart';
import 'package:finapp/screens/onboarding_screen.dart';
import 'package:finapp/services/auth_service.dart';
import 'package:finapp/services/finance_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthWrapper extends StatefulWidget {
  final AuthService authService;
  final FinanceService financeService;

  const AuthWrapper({
    super.key,
    required this.authService,
    required this.financeService,
  });

  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
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
    isAuthenticated.value = widget.authService.isAuthenticated;
    effect(() {
      widget.authService.authStateChanges.listen((event) {
        isAuthenticated.value = widget.authService.isAuthenticated;
        if (isAuthenticated.value) {
          widget.financeService.fetchCategories();
          widget.financeService.fetchTransactions();
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
          onComplete: () {
            setState(() {
              hasCompletedOnboarding.value = true;
            });
          },
          authService: widget.authService,
        );
      } else if (isAuthenticated.value) {
        return MainScreen(
          authService: widget.authService,
          financeService: widget.financeService,
        );
      } else {
        return LoginScreen(authService: widget.authService);
      }
    });
  }
}
