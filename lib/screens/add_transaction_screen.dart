import 'package:flutter/material.dart';
import 'package:finapp/services/finance_service.dart';
import 'package:finapp/models/transaction.dart';
import 'package:finapp/models/category.dart';
import 'package:signals/signals_flutter.dart';

class AddTransactionScreen extends StatefulWidget {
  final FinanceService financeService;
  final TransactionType transactionType;

  const AddTransactionScreen({
    super.key,
    required this.financeService,
    required this.transactionType,
  });

  @override
  _AddTransactionScreenState createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  Category? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add ${widget.transactionType == TransactionType.income ? 'Income' : 'Expense'}',
          style: theme.textTheme.headlineSmall,
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Amount',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              keyboardType: TextInputType.number,
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
            Watch((context) {
              return DropdownButtonFormField<Category>(
                value: _selectedCategory,
                items: widget.financeService.categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text('${category.icon} ${category.name}'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) {
                  if (value == null) {
                    return 'Please select a category';
                  }
                  return null;
                },
              );
            }),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Add Transaction', style: theme.textTheme.titleLarge),
            ),
          ],
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final newTransaction = Transaction(
        userId: widget.financeService.getCurrentUserId()!,
        type: widget.transactionType,
        amount: double.parse(_amountController.text),
        description: _descriptionController.text,
        timestamp: DateTime.now(),
        categoryId: _selectedCategory!.id!,
      );

      widget.financeService.addTransaction(newTransaction);
      Navigator.pop(context);
    }
  }
}
