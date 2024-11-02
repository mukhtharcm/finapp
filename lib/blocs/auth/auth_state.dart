part of 'auth_bloc.dart';

class AuthState extends Equatable {
  final bool isAuthenticated;
  final bool isLoading;
  final String userName;
  final String preferredCurrency;
  final String userId;
  final String? error;

  const AuthState({
    required this.isAuthenticated,
    this.isLoading = false,
    required this.userName,
    required this.preferredCurrency,
    required this.userId,
    this.error,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? userName,
    String? preferredCurrency,
    String? userId,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      userName: userName ?? this.userName,
      preferredCurrency: preferredCurrency ?? this.preferredCurrency,
      userId: userId ?? this.userId,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
        isAuthenticated,
        isLoading,
        userName,
        preferredCurrency,
        userId,
        error,
      ];
}
