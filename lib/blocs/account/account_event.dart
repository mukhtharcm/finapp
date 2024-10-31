part of 'account_bloc.dart';

abstract class AccountEvent extends Equatable {
  const AccountEvent();

  @override
  List<Object> get props => [];
}

class FetchAccounts extends AccountEvent {}

class AddAccount extends AccountEvent {
  final Account account;

  const AddAccount(this.account);

  @override
  List<Object> get props => [account];
}

class UpdateAccount extends AccountEvent {
  final Account account;

  const UpdateAccount({
    required this.account,
  });

  @override
  List<Object> get props => [account];
}

class DeleteAccount extends AccountEvent {
  final String id;

  const DeleteAccount(this.id);

  @override
  List<Object> get props => [id];
}
