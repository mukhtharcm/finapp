part of 'auth_bloc.dart';

class AuthState extends Equatable {
  final bool isAuthenticated;
  final String userName;
  final String preferredCurrency;

  const AuthState({
    required this.isAuthenticated,
    required this.userName,
    required this.preferredCurrency,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    String? userName,
    String? preferredCurrency,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      userName: userName ?? this.userName,
      preferredCurrency: preferredCurrency ?? this.preferredCurrency,
    );
  }

  @override
  List<Object> get props => [isAuthenticated, userName, preferredCurrency];
}
