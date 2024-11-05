import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:finapp/models/transaction.dart';
import 'package:finapp/models/category.dart';
import 'package:finapp/models/account.dart';

class FinanceService {
  final PocketBase pb;
  bool isInitialized = false;

  FinanceService(this.pb);

  Future<void> initialize() async {
    try {
      await pb.collection('users').authRefresh();
    } catch (e) {
      debugPrint('Auth refresh failed: $e');
    } finally {
      isInitialized = true;
    }
  }

  String? getCurrentUserId() {
    return pb.authStore.model?.id;
  }

  Future<List<Transaction>> fetchTransactions() async {
    if (!isInitialized) await initialize();

    final records = await pb.collection('transactions').getFullList(
          sort: '-created',
          expand: 'category',
        );
    return records.map((record) => Transaction.fromRecord(record)).toList();
  }

  Stream<RecordSubscriptionEvent> transactionsStream() async* {
    final controller = StreamController<RecordSubscriptionEvent>();

    final unsubFunc = await pb.realtime.subscribe('transactions', (e) {
      if (!controller.isClosed) {
        final event = RecordSubscriptionEvent.fromJson(e.jsonData());
        controller.add(event);
      }
    });

    controller.onCancel = () {
      unsubFunc();
      controller.close();
    };

    yield* controller.stream;
  }

  Future<List<Category>> fetchCategories() async {
    if (!isInitialized) await initialize();

    final userId = getCurrentUserId();
    String filter = userId != null ? 'user = "$userId"' : '';

    final records = await pb.collection('user_categories').getFullList(
          filter: filter,
        );
    return records.map((record) => Category.fromRecord(record)).toList();
  }

  Future<List<Account>> fetchAccounts() async {
    if (!isInitialized) await initialize();
    final userId = getCurrentUserId();
    if (userId == null) return [];

    final result = await pb.collection('accounts').getList(
          filter: 'user = "$userId"',
          sort: '-created',
        );

    return result.items.map((record) => Account.fromRecord(record)).toList();
  }

  Future<void> addTransaction(Transaction transaction) async {
    if (!isInitialized) await initialize();
    await pb.collection('transactions').create(body: transaction.toJson());
  }

  Future<void> addCategory(Category category) async {
    if (!isInitialized) await initialize();
    await pb.collection('user_categories').create(body: category.toJson());
  }

  Future<void> addAccount(Account account) async {
    if (!isInitialized) await initialize();
    await pb.collection('accounts').create(body: account.toJson());
  }

  Future<void> updateAccount(Account account) async {
    if (!isInitialized) await initialize();
    if (account.id == null) return;
    await pb.collection('accounts').update(account.id!, body: account.toJson());
  }

  Future<void> deleteAccount(String accountId) async {
    if (!isInitialized) await initialize();
    await pb.collection('accounts').delete(accountId);
  }

  Future<void> updateCategory(Category category) async {
    if (!isInitialized) await initialize();
    await pb.collection('user_categories').update(
          category.id!,
          body: category.toJson(),
        );
  }

  Future<void> deleteCategory(String id) async {
    if (!isInitialized) await initialize();
    await pb.collection('user_categories').delete(id);
  }

  Future<void> updateTransaction(
      String id, Transaction updatedTransaction) async {
    if (!isInitialized) await initialize();
    await pb.collection('transactions').update(
          id,
          body: updatedTransaction.toJson(),
        );
  }

  Future<void> deleteTransaction(String id) async {
    if (!isInitialized) await initialize();
    await pb.collection('transactions').delete(id);
  }

  Map<String, double> getAccountBalance(
      String accountId, List<Transaction> transactions) {
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

  double calculateTotalIncome(List<Transaction> transactions) {
    return transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double calculateTotalExpense(List<Transaction> transactions) {
    return transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double calculateBalance(List<Transaction> transactions) {
    return calculateTotalIncome(transactions) -
        calculateTotalExpense(transactions);
  }

  Future<void> dispose() async {
    await pb.collection('transactions').unsubscribe();
    await pb.collection('user_categories').unsubscribe();
    await pb.collection('accounts').unsubscribe();
  }
}
