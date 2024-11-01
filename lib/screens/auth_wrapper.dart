import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:finapp/screens/login_screen.dart';
import 'package:finapp/screens/main_screen.dart';
import 'package:finapp/screens/onboarding_screen.dart';
import 'package:finapp/services/auth_service.dart';
import 'package:finapp/services/finance_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finapp/blocs/auth/auth_bloc.dart';
import 'package:finapp/blocs/transaction/transaction_bloc.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthService _authService = GetIt.instance<AuthService>();
  final FinanceService _financeService = GetIt.instance<FinanceService>();
  bool _hasCompletedOnboarding = false;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
    _initializeAuth();
  }

  void _checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _hasCompletedOnboarding =
          prefs.getBool('hasCompletedOnboarding') ?? false;
    });
  }

  void _initializeAuth() {
    context.read<AuthBloc>().add(InitializeAuth());
  }

  void _onOnboardingComplete() {
    setState(() {
      _hasCompletedOnboarding = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.isAuthenticated) {
          // Fetch initial data when authenticated
          context.read<TransactionBloc>().add(FetchTransactions());
        } else {
          // Clear navigation stack when logging out
          Navigator.popUntil(context, (route) => route.isFirst);
        }
      },
      builder: (context, state) {
        if (state.isAuthenticated && !_hasCompletedOnboarding) {
          return OnboardingScreen(
            onComplete: _onOnboardingComplete,
            authService: _authService,
          );
        } else if (state.isAuthenticated) {
          return MainScreen(
            authService: _authService,
            financeService: _financeService,
          );
        } else {
          return LoginScreen(authService: _authService);
        }
      },
    );
  }
}
