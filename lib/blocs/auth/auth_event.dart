part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class InitializeAuth extends AuthEvent {}

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

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested(this.email, this.password);

  @override
  List<Object> get props => [email, password];
}

class SignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;

  const SignUpRequested(this.email, this.password, this.name);

  @override
  List<Object> get props => [email, password, name];
}

class DeleteAccountRequested extends AuthEvent {}
