import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:finapp/models/transaction.dart';
import 'package:finapp/services/finance_service.dart';
import 'package:finapp/models/category.dart';
import 'package:finapp/models/account.dart';
import 'package:signals/signals_flutter.dart';
import 'package:finapp/models/suggested_transaction.dart';

class TransactionForm extends StatefulWidget {
  final Transaction? initialTransaction;
  final SuggestedTransaction? initialSuggestedTransaction;
  final FinanceService financeService;
  final Function(Transaction) onSubmit;

  const TransactionForm({
    super.key,
    this.initialTransaction,
    this.initialSuggestedTransaction,
    required this.financeService,
    required this.onSubmit,
  });

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;
  String? _selectedCategoryId;
  String? _selectedAccountId;
  late TransactionType _transactionType;

  @override
  void initState() {
    super.initState();
    final transaction = widget.initialTransaction;
    final suggestedTransaction = widget.initialSuggestedTransaction;

    if (transaction != null) {
      _amountController =
          TextEditingController(text: transaction.amount.toString());
      _descriptionController =
          TextEditingController(text: transaction.description);
      _selectedDate = transaction.timestamp;
      _selectedCategoryId = _validateCategoryId(transaction.categoryId);
      _selectedAccountId = _validateAccountId(transaction.accountId);
      _transactionType = transaction.type;
    } else if (suggestedTransaction != null) {
      _amountController =
          TextEditingController(text: suggestedTransaction.amount.toString());
      _descriptionController =
          TextEditingController(text: suggestedTransaction.description);
      _selectedDate = DateTime.now();
      _selectedCategoryId =
          _validateCategoryId(suggestedTransaction.categoryId);
      _selectedAccountId = _validateAccountId(suggestedTransaction.accountId);
      _transactionType =
          suggestedTransaction.type == SuggestedTransactionType.income
              ? TransactionType.income
              : TransactionType.expense;
    } else {
      _amountController = TextEditingController();
      _descriptionController = TextEditingController();
      _selectedDate = DateTime.now();
      _transactionType = TransactionType.expense;
    }
  }

  String? _validateCategoryId(String categoryId) {
    // Check if the category exists
    final categoryExists = widget.financeService.categories
        .any((category) => category.id == categoryId);
    return categoryExists ? categoryId : null;
  }

  String? _validateAccountId(String accountId) {
    // Check if the account exists
    final accountExists = widget.financeService.accounts
        .any((account) => account.id == accountId);
    return accountExists ? accountId : null;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_selectedCategoryId == null &&
                  widget.initialSuggestedTransaction != null)
                Card(
                  color: theme.colorScheme.errorContainer,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: theme.colorScheme.error,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'The original category is no longer available. Please select a new category.',
                            style: TextStyle(color: theme.colorScheme.error),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Amount Field
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: '\$',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description Field
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Category Dropdown
              Watch((context) {
                final categories = widget.financeService.categories;
                return DropdownButtonFormField<String>(
                  value: _selectedCategoryId,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    errorStyle: TextStyle(color: theme.colorScheme.error),
                  ),
                  items: categories
                      .map((category) => DropdownMenuItem(
                            value: category.id,
                            child: Text(category.name),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategoryId = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a category';
                    }
                    return null;
                  },
                );
              }),
              const SizedBox(height: 16),

              // Account Dropdown
              Watch((context) {
                final accounts = widget.financeService.accounts;
                return DropdownButtonFormField<String>(
                  value: _selectedAccountId,
                  decoration: InputDecoration(
                    labelText: 'Account',
                    errorStyle: TextStyle(color: theme.colorScheme.error),
                  ),
                  items: accounts
                      .map((account) => DropdownMenuItem(
                            value: account.id,
                            child: Text(account.name),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedAccountId = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select an account';
                    }
                    return null;
                  },
                );
              }),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Save Transaction'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final transaction = Transaction(
        id: widget.initialTransaction?.id,
        userId: widget.initialTransaction?.userId ?? '',
        type: _transactionType,
        amount: double.parse(_amountController.text),
        description: _descriptionController.text,
        timestamp: _selectedDate,
        categoryId: _selectedCategoryId!,
        accountId: _selectedAccountId!,
        created: widget.initialTransaction?.created ?? DateTime.now(),
      );

      widget.onSubmit(transaction);
    }
  }
}
