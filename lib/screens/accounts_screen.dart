import 'package:flutter/material.dart';
import 'package:finapp/services/finance_service.dart';
import 'package:finapp/models/account.dart';
import 'package:signals/signals_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AccountsScreen extends StatelessWidget {
  final FinanceService financeService;

  const AccountsScreen({super.key, required this.financeService});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Accounts', style: theme.textTheme.headlineSmall),
      ),
      body: Watch((context) {
        final accounts = financeService.accounts;
        return ListView.builder(
          itemCount: accounts.length,
          itemBuilder: (context, index) {
            final account = accounts[index];
            final balance = financeService.getAccountBalance(account.id!);

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.secondaryContainer,
                  child: Text(
                    account.icon,
                    style: TextStyle(
                      fontSize: 24,
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                ),
                title: Row(
                  children: [
                    Text(account.name, style: theme.textTheme.titleMedium),
                    if (account.isDefault)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Default',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(account.type),
                    Text(
                      'Balance: ${balance['balance']?.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: balance['balance']! >= 0
                            ? theme.colorScheme.primary
                            : theme.colorScheme.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                isThreeLine: true,
                trailing: IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () => _showAccountOptions(context, account, theme),
                ),
              ),
            ).animate().fadeIn(duration: 300.ms, delay: (50 * index).ms).slideX(
                begin: 0.2,
                end: 0,
                duration: 300.ms,
                delay: (50 * index).ms,
                curve: Curves.easeOutCubic);
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddAccountDialog(context),
        child: const Icon(Icons.add_rounded),
      ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack),
    );
  }

  void _showAccountOptions(
      BuildContext context, Account account, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!account.isDefault)
              ListTile(
                leading: const Icon(Icons.star_outline),
                title: const Text('Set as Default'),
                onTap: () async {
                  Navigator.pop(context);
                  await financeService.updateAccount(
                    account.copyWith(isDefault: true),
                  );
                },
              ),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit Account'),
              onTap: () {
                Navigator.pop(context);
                _showEditAccountDialog(context, account);
              },
            ),
            if (!account.isDefault)
              ListTile(
                leading:
                    Icon(Icons.delete_outline, color: theme.colorScheme.error),
                title: Text('Delete Account',
                    style: TextStyle(color: theme.colorScheme.error)),
                onTap: () async {
                  Navigator.pop(context);
                  final confirmed = await _showDeleteConfirmation(context);
                  if (confirmed == true) {
                    await financeService.deleteAccount(account.id!);
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddAccountDialog(BuildContext context) async {
    final nameController = TextEditingController();
    final iconController = TextEditingController();
    String selectedType = 'cash';
    bool isDefault = false;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Account'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Account Name'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: iconController,
                decoration:
                    const InputDecoration(labelText: 'Account Icon (Emoji)'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: const InputDecoration(labelText: 'Account Type'),
                items: ['cash', 'bank', 'credit_card', 'savings']
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type.replaceAll('_', ' ').toUpperCase()),
                        ))
                    .toList(),
                onChanged: (value) => selectedType = value!,
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('Set as default account'),
                value: isDefault,
                onChanged: (value) => isDefault = value!,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  iconController.text.isNotEmpty) {
                final newAccount = Account(
                  userId: financeService.getCurrentUserId()!,
                  name: nameController.text,
                  type: selectedType,
                  icon: iconController.text,
                  isDefault: isDefault,
                );
                financeService.addAccount(newAccount);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditAccountDialog(
      BuildContext context, Account account) async {
    final nameController = TextEditingController(text: account.name);
    final iconController = TextEditingController(text: account.icon);
    String selectedType = account.type;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Account Name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: iconController,
              decoration:
                  const InputDecoration(labelText: 'Account Icon (Emoji)'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedType,
              decoration: const InputDecoration(labelText: 'Account Type'),
              items: ['cash', 'bank', 'credit_card', 'savings']
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type.replaceAll('_', ' ').toUpperCase()),
                      ))
                  .toList(),
              onChanged: (value) => selectedType = value!,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  iconController.text.isNotEmpty) {
                final updatedAccount = account.copyWith(
                  name: nameController.text,
                  icon: iconController.text,
                  type: selectedType,
                );
                financeService.updateAccount(updatedAccount);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
            'Are you sure you want to delete this account? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
