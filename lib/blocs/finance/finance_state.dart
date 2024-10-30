part of 'finance_bloc.dart';

abstract class FinanceState extends Equatable {
  const FinanceState();

  @override
  List<Object> get props => [];
}

class FinanceInitial extends FinanceState {}

class FinanceLoading extends FinanceState {}

class FinanceSuccess extends FinanceState {}

class FinanceFailure extends FinanceState {
  final String error;

  const FinanceFailure({required this.error});

  @override
  List<Object> get props => [error];
}
