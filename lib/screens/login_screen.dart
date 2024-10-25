import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'package:finapp/services/auth_service.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LoginScreen extends StatefulWidget {
  final AuthService authService;

  const LoginScreen({super.key, required this.authService});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final isLoading = signal(false);

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      isLoading.value = true;
      try {
        await widget.authService.login(
          _emailController.text,
          _passwordController.text,
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: $e')),
        );
      } finally {
        isLoading.value = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Text(
                'Welcome',
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),
              Text(
                'Sign in to continue',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ).animate().fadeIn(delay: 300.ms, duration: 600.ms),
              const SizedBox(height: 48),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon:
                            Icon(Icons.email, color: theme.colorScheme.primary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        return null;
                      },
                    ).animate().fadeIn(delay: 600.ms, duration: 600.ms),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon:
                            Icon(Icons.lock, color: theme.colorScheme.primary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ).animate().fadeIn(delay: 900.ms, duration: 600.ms),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Watch((context) {
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading.value ? null : _login,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: theme.colorScheme.onPrimary,
                      backgroundColor: theme.colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: isLoading.value
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  theme.colorScheme.onPrimary),
                            ),
                          )
                        : Text(
                            'Sign In',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                );
              }).animate().fadeIn(delay: 1200.ms, duration: 600.ms),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
