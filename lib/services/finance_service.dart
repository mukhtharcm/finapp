import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:signals/signals.dart';
import 'package:finapp/models/transaction.dart';
import 'package:finapp/models/category.dart';

class FinanceService {
  final PocketBase pb;
  final transactions = ListSignal<Transaction>([]);
  final categories = ListSignal<Category>([]);
  final isInitialized = signal(false);

  FinanceService(this.pb);

  Future<void> initialize() async {
    try {
      await pb.collection('users').authRefresh();
    } catch (e) {
      debugPrint('Auth refresh failed: $e');
    } finally {
      isInitialized.value = true;
    }

    // Set up realtime subscriptions
    _subscribeToCategories();
    _subscribeToTransactions();

    // Fetch categories first, then transactions
    await fetchCategories();
    await fetchTransactions();
  }

  String? getCurrentUserId() {
    return pb.authStore.model?.id;
  }

  Future<void> fetchTransactions() async {
    if (!isInitialized.value) await initialize();

    final records = await pb.collection('transactions').getFullList(
          sort: '-timestamp', // Sort by timestamp in descending order
          expand: 'category',
        );
    transactions.value =
        records.map((record) => Transaction.fromRecord(record)).toList();
  }

  Future<void> fetchCategories() async {
    if (!isInitialized.value) await initialize();

    final userId = getCurrentUserId();
    String filter = userId != null ? 'user = "$userId"' : '';

    final records = await pb.collection('user_categories').getFullList(
          filter: filter,
        );
    categories.value =
        records.map((record) => Category.fromRecord(record)).toList();
  }

  Future<void> addTransaction(Transaction transaction) async {
    if (!isInitialized.value) await initialize();

    await pb.collection('transactions').create(body: transaction.toJson());
    // Remove the manual addition of the transaction to the list
    // The realtime subscription will handle adding the new transaction
  }

  Future<void> addCategory(Category category) async {
    if (!isInitialized.value) await initialize();

    final record =
        await pb.collection('user_categories').create(body: category.toJson());
    categories.add(Category.fromRecord(record));
  }

  void _subscribeToTransactions() {
    pb.collection('transactions').subscribe('*', (e) {
      if (e.record == null) return; // Skip if record is null

      if (e.action == 'create') {
        transactions.add(Transaction.fromRecord(e.record!));
      } else if (e.action == 'update') {
        final index = transactions.indexWhere((t) => t.id == e.record!.id);
        if (index != -1) {
          transactions[index] = Transaction.fromRecord(e.record!);
        }
      } else if (e.action == 'delete') {
        transactions.removeWhere((t) => t.id == e.record!.id);
      }

      // Re-sort transactions after any change
      transactions.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    });
  }

  void _subscribeToCategories() {
    pb.collection('user_categories').subscribe('*', (e) {
      if (e.record == null) return; // Skip if record is null

      if (e.action == 'create') {
        categories.add(Category.fromRecord(e.record!));
      } else if (e.action == 'update') {
        final index = categories.indexWhere((c) => c.id == e.record!.id);
        if (index != -1) {
          categories[index] = Category.fromRecord(e.record!);
        }
      } else if (e.action == 'delete') {
        categories.removeWhere((c) => c.id == e.record!.id);
      }
    });
  }

  ReadonlySignal<double> get totalIncome => computed(() {
        return transactions
            .where((t) => t.type == TransactionType.income)
            .fold(0.0, (sum, t) => sum + t.amount);
      });

  ReadonlySignal<double> get totalExpense => computed(() {
        return transactions
            .where((t) => t.type == TransactionType.expense)
            .fold(0.0, (sum, t) => sum + t.amount);
      });

  ReadonlySignal<double> get balance =>
      computed(() => totalIncome.value - totalExpense.value);

  void dispose() {
    pb.collection('transactions').unsubscribe();
    pb.collection('user_categories').unsubscribe();
  }
}
