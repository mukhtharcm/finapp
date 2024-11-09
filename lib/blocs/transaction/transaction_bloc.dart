import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:finapp/models/transaction.dart';
import 'package:finapp/services/finance_service.dart';
import 'package:pocketbase/pocketbase.dart';

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
    on<StartTransactionStream>(_onStartTransactionStream);
  }

  Future<void> _onStartTransactionStream(
    StartTransactionStream event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      // Initial fetch
      final initialTransactions = await financeService.fetchTransactions();
      emit(TransactionSuccess(transactions: initialTransactions));

      // Listen to realtime updates
      await emit.forEach(
        financeService.transactionsStream(),
        onData: (RecordSubscriptionEvent event) {
          debugPrint('onData: $event');
          if (state is! TransactionSuccess) return state;
          final currentState = state as TransactionSuccess;
          final currentTransactions =
              List<Transaction>.from(currentState.transactions ?? []);

          switch (event.action) {
            case 'create':
              if (event.record != null) {
                final newTransaction = Transaction.fromRecord(event.record!);
                currentTransactions.insert(0, newTransaction);
              }
              break;

            case 'update':
              if (event.record != null) {
                final updatedTransaction =
                    Transaction.fromRecord(event.record!);
                final index = currentTransactions
                    .indexWhere((t) => t.id == updatedTransaction.id);
                if (index != -1) {
                  currentTransactions[index] = updatedTransaction;
                }
              }
              break;

            case 'delete':
              if (event.record?.id != null) {
                currentTransactions
                    .removeWhere((t) => t.id == event.record!.id);
              }
              break;
          }

          return TransactionSuccess(transactions: currentTransactions);
        },
        onError: (error, stackTrace) {
          return TransactionFailure(error: error.toString());
        },
      );
    } catch (e) {
      emit(TransactionFailure(error: e.toString()));
    }
  }

  Future<void> _onAddTransaction(
    AddTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      await financeService.addTransaction(event.transaction);
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
    try {
      await financeService.deleteTransaction(event.id);
    } catch (e) {
      emit(TransactionFailure(error: e.toString()));
    }
  }

  Future<void> _onUpdateTransaction(
    UpdateTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      await financeService.updateTransaction(event.id, event.transaction);
    } catch (e) {
      emit(TransactionFailure(error: e.toString()));
    }
  }
}
