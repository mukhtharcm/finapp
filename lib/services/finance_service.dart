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
      // Attempt to refresh the auth state
      await pb.collection('users').authRefresh();
    } catch (e) {
      // If refresh fails, it means there's no valid auth state
      print('Auth refresh failed: $e');
    } finally {
      isInitialized.value = true;
    }
  }

  String? getCurrentUserId() {
    return pb.authStore.model?.id;
  }

  Future<void> fetchTransactions() async {
    if (!isInitialized.value) await initialize();

    final records = await pb.collection('transactions').getFullList(
          sort: '-timestamp',
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

    final record =
        await pb.collection('transactions').create(body: transaction.toJson());
    transactions.add(Transaction.fromRecord(record));
  }

  Future<void> addCategory(Category category) async {
    if (!isInitialized.value) await initialize();

    final record =
        await pb.collection('user_categories').create(body: category.toJson());
    categories.add(Category.fromRecord(record));
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
}
