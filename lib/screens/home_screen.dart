import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'package:finapp/services/auth_service.dart';

class HomeScreen extends StatelessWidget {
  final AuthService authService;

  const HomeScreen({super.key, required this.authService});

  @override
  Widget build(BuildContext context) {
    final userEmail = computed(() {
      final user = authService.currentUser;
      return user?.data['email'] as String? ?? 'User';
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authService.logout(),
          ),
        ],
      ),
      body: Center(
        child: Watch((context) {
          return Text('Welcome, ${userEmail.value}!');
        }),
      ),
    );
  }
}
