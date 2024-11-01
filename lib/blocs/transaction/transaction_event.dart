part of 'transaction_bloc.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object> get props => [];
}

class AddTransaction extends TransactionEvent {
  final Transaction transaction;

  const AddTransaction(this.transaction);

  @override
  List<Object> get props => [transaction];
}

class FetchTransactions extends TransactionEvent {}

class DeleteTransaction extends TransactionEvent {
  final String id;

  const DeleteTransaction(this.id);

  @override
  List<Object> get props => [id];
}

class UpdateTransaction extends TransactionEvent {
  final String id;
  final Transaction transaction;

  const UpdateTransaction({
    required this.id,
    required this.transaction,
  });

  @override
  List<Object> get props => [id, transaction];
}
