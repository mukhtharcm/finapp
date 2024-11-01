import 'package:flutter/material.dart';
import 'package:finapp/services/auth_service.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:finapp/utils/currency_utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finapp/blocs/auth/auth_bloc.dart';

class ProfileSettingsScreen extends StatefulWidget {
  final AuthService authService;

  const ProfileSettingsScreen({super.key, required this.authService});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  bool _isLoading = false;
  String? _selectedCurrency;

  final _availableCurrencies = [
    'USD',
    'EUR',
    'GBP',
    'JPY',
    'AUD',
    'CAD',
    'CHF',
    'CNY',
    'INR',
    'NZD',
    'SGD'
  ];

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    _nameController = TextEditingController(text: authState.userName);
    _selectedCurrency = authState.preferredCurrency;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        context.read<AuthBloc>().add(UpdateUserName(_nameController.text));
        context
            .read<AuthBloc>()
            .add(UpdatePreferredCurrency(_selectedCurrency!));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update profile: $e')),
          );
        }
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update profile: ${state.error}')),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Profile Settings', style: theme.textTheme.headlineSmall),
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Text(
                        _nameController.text.isNotEmpty
                            ? _nameController.text[0].toUpperCase()
                            : 'U',
                        style: theme.textTheme.displayMedium?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    )
                        .animate()
                        .scale(duration: 300.ms, curve: Curves.easeOutBack),
                    const SizedBox(height: 24),
                    Text(
                      'Personal Information',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    )
                        .animate()
                        .fadeIn(duration: 300.ms)
                        .slideX(begin: 0.2, end: 0),
                    const SizedBox(height: 24),
                    Text(
                      'Preferences',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedCurrency,
                      decoration: InputDecoration(
                        labelText: 'Preferred Currency',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: _availableCurrencies.map((String currency) {
                        return DropdownMenuItem<String>(
                          value: currency,
                          child: Text(
                              '$currency (${CurrencyUtils.getCurrencySymbol(currency)})'),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedCurrency = newValue;
                        });
                      },
                    )
                        .animate()
                        .fadeIn(delay: 100.ms, duration: 300.ms)
                        .slideX(begin: 0.2, end: 0),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveChanges,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(),
                              )
                            : const Text('Save Changes'),
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 200.ms, duration: 300.ms)
                        .slideY(begin: 0.2, end: 0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
