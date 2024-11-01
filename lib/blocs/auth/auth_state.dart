part of 'auth_bloc.dart';

class AuthState extends Equatable {
  final bool isAuthenticated;
  final String userName;
  final String preferredCurrency;
  final String? error;

  const AuthState({
    required this.isAuthenticated,
    required this.userName,
    required this.preferredCurrency,
    this.error,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    String? userName,
    String? preferredCurrency,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      userName: userName ?? this.userName,
      preferredCurrency: preferredCurrency ?? this.preferredCurrency,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
        isAuthenticated,
        userName,
        preferredCurrency,
        error,
      ];
}
