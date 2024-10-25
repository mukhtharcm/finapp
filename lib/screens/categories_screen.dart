import 'package:flutter/material.dart';
import 'package:finapp/services/finance_service.dart';
import 'package:finapp/models/category.dart';
import 'package:signals/signals_flutter.dart';

class CategoriesScreen extends StatelessWidget {
  final FinanceService financeService;

  const CategoriesScreen({super.key, required this.financeService});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Categories', style: theme.textTheme.headlineSmall),
      ),
      body: Watch((context) {
        final categories = financeService.categories;
        return ListView.builder(
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.secondaryContainer,
                  child: Text(
                    category.icon,
                    style: TextStyle(
                        fontSize: 24, color: theme.colorScheme.secondary),
                  ),
                ),
                title: Text(category.name, style: theme.textTheme.titleMedium),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCategoryDialog(context),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    final nameController = TextEditingController();
    final iconController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Category Name'),
            ),
            TextField(
              controller: iconController,
              decoration:
                  const InputDecoration(labelText: 'Category Icon (Emoji)'),
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
                final newCategory = Category(
                  name: nameController.text,
                  icon: iconController.text,
                  userId: financeService.getCurrentUserId(),
                );
                financeService.addCategory(newCategory);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
