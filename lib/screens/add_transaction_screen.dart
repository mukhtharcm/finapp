import 'package:flutter/material.dart';
import 'package:finapp/services/finance_service.dart';
import 'package:finapp/models/transaction.dart';
import 'package:finapp/models/category.dart';
import 'package:signals/signals_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
  final isLoading = signal(false);

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
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    )
                        .animate()
                        .fadeIn(duration: 300.ms)
                        .slideX(begin: -0.1, end: 0),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amountController,
                      decoration: InputDecoration(
                        labelText: 'Amount',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
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
                    )
                        .animate()
                        .fadeIn(delay: 100.ms, duration: 300.ms)
                        .slideX(begin: -0.1, end: 0),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: _showCategoryPicker,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                                _selectedCategory?.name ?? 'Select a category'),
                            Icon(_selectedCategory != null
                                ? Icons.check
                                : Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 200.ms, duration: 300.ms)
                        .slideX(begin: -0.1, end: 0),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text('Add Transaction',
                            style: theme.textTheme.titleLarge),
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 300.ms, duration: 300.ms)
                        .slideY(begin: 0.1, end: 0),
                  ],
                ),
              ),
            ),
          ),
          Watch((context) {
            if (isLoading.value) {
              return Container(
                color: Colors.black54,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.onPrimary),
                      )
                          .animate(onPlay: (controller) => controller.repeat())
                          .scaleXY(begin: 0.8, end: 1.2, duration: 600.ms)
                          .then(delay: 600.ms)
                          .scaleXY(begin: 1.2, end: 0.8, duration: 600.ms),
                      const SizedBox(height: 16),
                      Text(
                        'Adding transaction...',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(color: Colors.white),
                      )
                          .animate()
                          .fadeIn(duration: 300.ms)
                          .then()
                          .shimmer(duration: 1.seconds, color: Colors.white54),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 300.ms);
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Watch((context) {
          return ListView.builder(
            itemCount: widget.financeService.categories.length,
            itemBuilder: (context, index) {
              final category = widget.financeService.categories[index];
              return ListTile(
                leading:
                    Text(category.icon, style: const TextStyle(fontSize: 24)),
                title: Text(category.name),
                onTap: () {
                  setState(() {
                    _selectedCategory = category;
                  });
                  Navigator.pop(context);
                },
              );
            },
          );
        });
      },
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && _selectedCategory != null) {
      isLoading.value = true;
      try {
        final newTransaction = Transaction(
          userId: widget.financeService.getCurrentUserId()!,
          type: widget.transactionType,
          amount: double.parse(_amountController.text),
          description: _descriptionController.text,
          timestamp: DateTime.now(),
          categoryId: _selectedCategory!.id!,
          created: DateTime.now(), // Add this line
        );

        await widget.financeService.addTransaction(newTransaction);

        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add transaction: $e')),
        );
      } finally {
        isLoading.value = false;
      }
    } else if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
    }
  }
}
