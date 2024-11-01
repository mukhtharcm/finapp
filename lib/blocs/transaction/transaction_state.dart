part of 'transaction_bloc.dart';

abstract class TransactionState extends Equatable {
  const TransactionState();

  @override
  List<Object?> get props => [];
}

class TransactionInitial extends TransactionState {}

class TransactionLoading extends TransactionState {}

class TransactionSuccess extends TransactionState {
  final List<Transaction>? transactions;

  const TransactionSuccess({this.transactions});

  @override
  List<Object?> get props => [transactions];
}

class TransactionFailure extends TransactionState {
  final String error;

  const TransactionFailure({required this.error});

  @override
  List<Object> get props => [error];
}
