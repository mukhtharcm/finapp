import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:finapp/models/transaction.dart';
import 'package:finapp/services/finance_service.dart';

part 'transaction_event.dart';
part 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final FinanceService financeService;

  TransactionBloc({required this.financeService})
      : super(TransactionInitial()) {
    on<AddTransaction>(_onAddTransaction);
    on<FetchTransactions>(_onFetchTransactions);
    on<DeleteTransaction>(_onDeleteTransaction);
    on<UpdateTransaction>(_onUpdateTransaction);
  }

  Future<void> _onAddTransaction(
    AddTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    try {
      await financeService.addTransaction(event.transaction);
      final transactions = await financeService.fetchTransactions();
      emit(TransactionSuccess(transactions: transactions));
    } catch (e) {
      emit(TransactionFailure(error: e.toString()));
    }
  }

  Future<void> _onFetchTransactions(
    FetchTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    try {
      final transactions = await financeService.fetchTransactions();
      emit(TransactionSuccess(transactions: transactions));
    } catch (e) {
      emit(TransactionFailure(error: e.toString()));
    }
  }

  Future<void> _onDeleteTransaction(
    DeleteTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    try {
      await financeService.deleteTransaction(event.id);
      final transactions = await financeService.fetchTransactions();
      emit(TransactionSuccess(transactions: transactions));
    } catch (e) {
      emit(TransactionFailure(error: e.toString()));
    }
  }

  Future<void> _onUpdateTransaction(
    UpdateTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    try {
      await financeService.updateTransaction(event.id, event.transaction);
      final transactions = await financeService.fetchTransactions();
      emit(TransactionSuccess(transactions: transactions));
    } catch (e) {
      emit(TransactionFailure(error: e.toString()));
    }
  }
}
