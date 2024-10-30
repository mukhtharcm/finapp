import 'package:flutter/material.dart';
import 'package:finapp/services/finance_service.dart';
import 'package:finapp/services/auth_service.dart';
import 'package:finapp/models/transaction.dart';
import 'package:finapp/models/category.dart';
import 'package:finapp/models/account.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finapp/blocs/transaction/transaction_bloc.dart';
import 'package:finapp/utils/currency_utils.dart';
import 'package:finapp/blocs/account/account_bloc.dart';
import 'package:finapp/blocs/category/category_bloc.dart';
import 'package:finapp/blocs/auth/auth_bloc.dart';

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
  Account? _selectedAccount;

  @override
  void initState() {
    super.initState();
    // Fetch initial data
    context.read<AccountBloc>().add(FetchAccounts());
    context.read<CategoryBloc>().add(FetchCategories());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<TransactionBloc, TransactionState>(
      listener: (context, state) {
        if (state is TransactionSuccess) {
          Navigator.pop(context);
        } else if (state is TransactionFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Failed to add transaction: ${state.error}')),
          );
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          final currencySymbol =
              CurrencyUtils.getCurrencySymbol(authState.preferredCurrency);

          return Scaffold(
            appBar: AppBar(
              title: Text(
                widget.transactionType == TransactionType.income
                    ? 'Add Income'
                    : 'Add Expense',
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
                          // Account Selection
                          InkWell(
                            onTap: _showAccountPicker,
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Account',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(_selectedAccount?.name ??
                                      'Select an account'),
                                  Icon(_selectedAccount != null
                                      ? Icons.check
                                      : Icons.arrow_drop_down),
                                ],
                              ),
                            ),
                          )
                              .animate()
                              .fadeIn(duration: 300.ms)
                              .slideX(begin: -0.1, end: 0),
                          const SizedBox(height: 16),
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
                              .fadeIn(delay: 100.ms, duration: 300.ms)
                              .slideX(begin: -0.1, end: 0),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _amountController,
                            decoration: InputDecoration(
                              labelText: 'Amount',
                              prefixText: currencySymbol,
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
                              .fadeIn(delay: 200.ms, duration: 300.ms)
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(_selectedCategory?.name ??
                                      'Select a category'),
                                  Icon(_selectedCategory != null
                                      ? Icons.check
                                      : Icons.arrow_drop_down),
                                ],
                              ),
                            ),
                          )
                              .animate()
                              .fadeIn(delay: 300.ms, duration: 300.ms)
                              .slideX(begin: -0.1, end: 0),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _submitForm,
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text('Add Transaction',
                                  style: theme.textTheme.titleLarge),
                            ),
                          )
                              .animate()
                              .fadeIn(delay: 400.ms, duration: 300.ms)
                              .slideY(begin: 0.1, end: 0),
                        ],
                      ),
                    ),
                  ),
                ),
                BlocBuilder<TransactionBloc, TransactionState>(
                  builder: (context, state) {
                    if (state is TransactionLoading) {
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
                                  .animate(
                                      onPlay: (controller) =>
                                          controller.repeat())
                                  .scaleXY(
                                      begin: 0.8, end: 1.2, duration: 600.ms)
                                  .then(delay: 600.ms)
                                  .scaleXY(
                                      begin: 1.2, end: 0.8, duration: 600.ms),
                              const SizedBox(height: 16),
                              Text(
                                'Adding transaction...',
                                style: theme.textTheme.titleMedium
                                    ?.copyWith(color: Colors.white),
                              )
                                  .animate()
                                  .fadeIn(duration: 300.ms)
                                  .then()
                                  .shimmer(
                                      duration: 1.seconds,
                                      color: Colors.white54),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(duration: 300.ms);
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAccountPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return BlocBuilder<AccountBloc, AccountState>(
          builder: (context, state) {
            if (state is AccountLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is AccountFailure) {
              return Center(child: Text('Error: ${state.error}'));
            }

            if (state is AccountSuccess) {
              return ListView.builder(
                itemCount: state.accounts.length,
                itemBuilder: (context, index) {
                  final account = state.accounts[index];
                  return ListTile(
                    leading: Text(account.icon,
                        style: const TextStyle(fontSize: 24)),
                    title: Text(account.name),
                    subtitle: Text(account.type),
                    onTap: () {
                      setState(() {
                        _selectedAccount = account;
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              );
            }

            return const SizedBox.shrink();
          },
        );
      },
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() &&
        _selectedCategory != null &&
        _selectedAccount != null) {
      final newTransaction = Transaction(
        userId: widget.financeService.getCurrentUserId()!,
        type: widget.transactionType,
        amount: double.parse(_amountController.text),
        description: _descriptionController.text,
        timestamp: DateTime.now(),
        categoryId: _selectedCategory!.id!,
        accountId: _selectedAccount!.id!,
        created: DateTime.now(),
      );

      context.read<TransactionBloc>().add(AddTransaction(newTransaction));
    } else if (_selectedAccount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an account')),
      );
    } else if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
    }
  }

  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return BlocBuilder<CategoryBloc, CategoryState>(
          builder: (context, state) {
            if (state is CategoryLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is CategoryFailure) {
              return Center(child: Text('Error: ${state.error}'));
            }

            if (state is CategorySuccess) {
              return ListView.builder(
                itemCount: state.categories.length,
                itemBuilder: (context, index) {
                  final category = state.categories[index];
                  return ListTile(
                    leading: Text(category.icon,
                        style: const TextStyle(fontSize: 24)),
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
            }

            return const SizedBox.shrink();
          },
        );
      },
    );
  }
}
