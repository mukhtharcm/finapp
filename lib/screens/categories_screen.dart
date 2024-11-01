import 'package:flutter/material.dart';
import 'package:finapp/services/finance_service.dart';
import 'package:finapp/models/category.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finapp/blocs/category/category_bloc.dart';

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
      body: BlocBuilder<CategoryBloc, CategoryState>(
        builder: (context, state) {
          if (state is CategoryLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CategoryFailure) {
            return Center(child: Text('Error: ${state.error}'));
          }

          if (state is CategorySuccess) {
            final categories = state.categories;
            return ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: theme.colorScheme.secondaryContainer,
                      child: Text(
                        category.icon,
                        style: TextStyle(
                          fontSize: 24,
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                    ),
                    title: Text(
                      category.name,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(duration: 300.ms, delay: (50 * index).ms)
                    .slideX(
                      begin: 0.2,
                      end: 0,
                      duration: 300.ms,
                      delay: (50 * index).ms,
                      curve: Curves.easeOutCubic,
                    );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCategoryDialog(context),
        child: const Icon(Icons.add_rounded),
      ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack),
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
                context.read<CategoryBloc>().add(AddCategory(newCategory));
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
