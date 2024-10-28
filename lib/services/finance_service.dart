import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:signals/signals.dart';
import 'package:finapp/models/transaction.dart';
import 'package:finapp/models/category.dart';
import 'package:finapp/models/account.dart';

class FinanceService {
  final PocketBase pb;
  final transactions = ListSignal<Transaction>([]);
  final categories = ListSignal<Category>([]);
  final accounts = ListSignal<Account>([]);
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
    _subscribeToAccounts();
    _subscribeToTransactions();

    // Fetch data
    await fetchCategories();
    await fetchAccounts();
    await fetchTransactions();
  }

  String? getCurrentUserId() {
    return pb.authStore.model?.id;
  }

  Future<void> fetchTransactions() async {
    if (!isInitialized.value) await initialize();

    final records = await pb.collection('transactions').getFullList(
          sort: '-created', // Sort by created field in descending order
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

      // print the action of the event
      debugPrint('Transaction event: ${e.action}');

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
      transactions.sort((a, b) => b.created.compareTo(a.created));
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

  void _subscribeToAccounts() {
    final userId = getCurrentUserId();
    if (userId == null) return;

    pb.collection('accounts').subscribe('*', (e) {
      if (e.action == 'create') {
        accounts.add(Account.fromRecord(e.record!));
      } else if (e.action == 'update') {
        final index = accounts.toList().indexWhere((a) => a.id == e.record!.id);
        if (index != -1) {
          accounts[index] = Account.fromRecord(e.record!);
        }
      } else if (e.action == 'delete') {
        accounts.removeWhere((a) => a.id == e.record!.id);
      }
    });
  }

  Future<void> fetchAccounts() async {
    if (!isInitialized.value) await initialize();
    final userId = getCurrentUserId();
    if (userId == null) return;

    final result = await pb.collection('accounts').getList(
          filter: 'user = "$userId"',
          sort: '-created',
        );

    accounts.value =
        result.items.map((record) => Account.fromRecord(record)).toList();
  }

  Future<void> addAccount(Account account) async {
    if (!isInitialized.value) await initialize();
    await pb.collection('accounts').create(body: account.toJson());
  }

  Future<void> updateAccount(Account account) async {
    if (!isInitialized.value) await initialize();
    if (account.id == null) return;
    await pb.collection('accounts').update(account.id!, body: account.toJson());
  }

  Future<void> deleteAccount(String accountId) async {
    if (!isInitialized.value) await initialize();
    await pb.collection('accounts').delete(accountId);
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

  Map<String, double> getAccountBalance(String accountId) {
    final accountTransactions =
        transactions.where((t) => t.accountId == accountId);

    double income = accountTransactions
        .where((t) => t.type == TransactionType.income)
        .fold(0, (sum, t) => sum + t.amount);

    double expenses = accountTransactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0, (sum, t) => sum + t.amount);

    return {
      'income': income,
      'expenses': expenses,
      'balance': income - expenses,
    };
  }

  void dispose() {
    pb.collection('transactions').unsubscribe();
    pb.collection('user_categories').unsubscribe();
    pb.collection('accounts').unsubscribe();
  }
}
