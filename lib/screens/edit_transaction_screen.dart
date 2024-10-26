import 'package:flutter/material.dart';
import 'package:finapp/models/suggested_transaction.dart';
import 'package:finapp/services/finance_service.dart';
import 'package:finapp/models/category.dart';
import 'package:flutter_animate/flutter_animate.dart';

class EditTransactionScreen extends StatefulWidget {
  final SuggestedTransaction transaction;
  final FinanceService financeService;
  final Function(SuggestedTransaction) onEdit;

  const EditTransactionScreen({
    super.key,
    required this.transaction,
    required this.financeService,
    required this.onEdit,
  });

  @override
  _EditTransactionScreenState createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  late TextEditingController _descriptionController;
  late TextEditingController _amountController;
  late SuggestedTransactionType _transactionType;
  String? _categoryId;

  @override
  void initState() {
    super.initState();
    _descriptionController =
        TextEditingController(text: widget.transaction.description);
    _amountController =
        TextEditingController(text: widget.transaction.amount.toString());
    _transactionType = widget.transaction.type;
    _categoryId = _findValidCategoryId(widget.transaction.categoryId);
  }

  String? _findValidCategoryId(String categoryId) {
    return widget.financeService.categories.any((c) => c.id == categoryId)
        ? categoryId
        : null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Transaction', style: theme.textTheme.titleLarge),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                  _descriptionController, 'Description', Icons.description),
              const SizedBox(height: 12),
              _buildTextField(_amountController, 'Amount', Icons.attach_money,
                  keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              _buildTransactionTypeSelector(theme),
              const SizedBox(height: 12),
              _buildCategoryDropdown(theme),
              const SizedBox(height: 24),
              _buildSaveButton(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      keyboardType: keyboardType,
    ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.1, end: 0);
  }

  Widget _buildTransactionTypeSelector(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Transaction Type', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        SegmentedButton<SuggestedTransactionType>(
          segments: [
            ButtonSegment<SuggestedTransactionType>(
              value: SuggestedTransactionType.income,
              label: Text('Income'),
              icon: Icon(Icons.trending_up),
            ),
            ButtonSegment<SuggestedTransactionType>(
              value: SuggestedTransactionType.expense,
              label: Text('Expense'),
              icon: Icon(Icons.trending_down),
            ),
          ],
          selected: {_transactionType},
          onSelectionChanged: (Set<SuggestedTransactionType> newSelection) {
            setState(() {
              _transactionType = newSelection.first;
            });
          },
        ),
      ],
    )
        .animate()
        .fadeIn(delay: 200.ms, duration: 300.ms)
        .slideX(begin: -0.1, end: 0);
  }

  Widget _buildCategoryDropdown(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Category', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _categoryId,
          onChanged: (String? newValue) {
            setState(() {
              _categoryId = newValue;
            });
          },
          items: [
            DropdownMenuItem<String>(
              value: null,
              child: Text('Select a category',
                  style: TextStyle(color: theme.hintColor)),
            ),
            ...widget.financeService.categories.map((Category category) {
              return DropdownMenuItem<String>(
                value: category.id,
                child: Row(
                  children: [
                    Text(category.icon),
                    SizedBox(width: 8),
                    Text(category.name),
                  ],
                ),
              );
            }),
          ],
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          isExpanded: true,
          itemHeight: 50,
          menuMaxHeight: 300,
        ),
      ],
    )
        .animate()
        .fadeIn(delay: 300.ms, duration: 300.ms)
        .slideX(begin: -0.1, end: 0);
  }

  Widget _buildSaveButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveChanges,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text('Save Changes', style: theme.textTheme.titleMedium),
      ),
    )
        .animate()
        .fadeIn(delay: 400.ms, duration: 300.ms)
        .slideY(begin: 0.1, end: 0);
  }

  void _saveChanges() {
    if (_categoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a valid category')),
      );
      return;
    }

    final editedTransaction = SuggestedTransaction(
      amount: double.parse(_amountController.text),
      description: _descriptionController.text,
      categoryId: _categoryId!,
      type: _transactionType,
    );

    widget.onEdit(editedTransaction);
    Navigator.pop(context);
  }
}
