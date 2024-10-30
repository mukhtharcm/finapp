part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class UpdateUserName extends AuthEvent {
  final String userName;

  const UpdateUserName(this.userName);

  @override
  List<Object> get props => [userName];
}

class UpdatePreferredCurrency extends AuthEvent {
  final String currency;

  const UpdatePreferredCurrency(this.currency);

  @override
  List<Object> get props => [currency];
}

class LogoutRequested extends AuthEvent {}
