import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'package:finapp/services/auth_service.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SignUpScreen extends StatefulWidget {
  final AuthService authService;

  const SignUpScreen({super.key, required this.authService});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final isLoading = signal(false);

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      isLoading.value = true;
      try {
        await widget.authService.signUp(
          _emailController.text,
          _passwordController.text,
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign up failed: $e')),
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
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                Text(
                  'Create Account',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),
                const SizedBox(height: 48),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon:
                        Icon(Icons.email, color: theme.colorScheme.primary),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
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
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters long';
                    }
                    return null;
                  },
                ).animate().fadeIn(delay: 900.ms, duration: 600.ms),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon:
                        Icon(Icons.lock, color: theme.colorScheme.primary),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ).animate().fadeIn(delay: 1200.ms, duration: 600.ms),
                const SizedBox(height: 32),
                Watch((context) {
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading.value ? null : _signUp,
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
                              'Sign Up',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: theme.colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  );
                }).animate().fadeIn(delay: 1500.ms, duration: 600.ms),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
