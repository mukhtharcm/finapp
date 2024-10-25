import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'package:finapp/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  final AuthService authService;

  const LoginScreen({super.key, required this.authService});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final isLoading = signal(false);

  Future<void> _login() async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            Watch((context) {
              return ElevatedButton(
                onPressed: isLoading.value ? null : _login,
                child: isLoading.value
                    ? const CircularProgressIndicator()
                    : const Text('Login'),
              );
            }),
          ],
        ),
      ),
    );
  }
}
