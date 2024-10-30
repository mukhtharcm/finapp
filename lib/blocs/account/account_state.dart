part of 'account_bloc.dart';

abstract class AccountState extends Equatable {
  const AccountState();

  @override
  List<Object> get props => [];
}

class AccountInitial extends AccountState {}

class AccountLoading extends AccountState {}

class AccountSuccess extends AccountState {
  final List<Account> accounts;

  const AccountSuccess({required this.accounts});

  @override
  List<Object> get props => [accounts];
}

class AccountFailure extends AccountState {
  final String error;

  const AccountFailure({required this.error});

  @override
  List<Object> get props => [error];
}
