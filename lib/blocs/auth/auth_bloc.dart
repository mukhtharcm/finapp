import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:finapp/services/auth_service.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService authService;

  AuthBloc({required this.authService})
      : super(AuthState(
          isAuthenticated: authService.isAuthenticated,
          userName: authService.userName,
          preferredCurrency:
              authService.currentUser?.preferredCurrency ?? 'USD',
        )) {
    on<InitializeAuth>(_onInitializeAuth);
    on<UpdateUserName>(_onUpdateUserName);
    on<UpdatePreferredCurrency>(_onUpdatePreferredCurrency);
    on<LogoutRequested>(_onLogoutRequested);
    on<LoginRequested>(_onLoginRequested);
    on<SignUpRequested>(_onSignUpRequested);
    on<DeleteAccountRequested>(_onDeleteAccountRequested);

    // Listen to auth state changes
    authService.authStateChanges.listen((isAuthenticated) {
      if (isAuthenticated) {
        add(InitializeAuth());
      } else {
        emit(state.copyWith(
          isAuthenticated: false,
          userName: 'Guest',
          preferredCurrency: 'USD',
        ));
      }
    });
  }

  Future<void> _onInitializeAuth(
    InitializeAuth event,
    Emitter<AuthState> emit,
  ) async {
    final user = authService.currentUser;
    emit(state.copyWith(
      isAuthenticated: authService.isAuthenticated,
      userName: authService.userName,
      preferredCurrency: user?.preferredCurrency ?? 'USD',
    ));
  }

  Future<void> _onUpdateUserName(
    UpdateUserName event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await authService.updateProfile(name: event.userName);
      emit(state.copyWith(userName: event.userName));
    } catch (e) {
      // Handle error
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onUpdatePreferredCurrency(
    UpdatePreferredCurrency event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await authService.updateProfile(preferredCurrency: event.currency);
      emit(state.copyWith(preferredCurrency: event.currency));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await authService.signOut();
    emit(state.copyWith(
      isAuthenticated: false,
      userName: 'Guest',
      preferredCurrency: 'USD',
    ));
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await authService.signIn(event.email, event.password);
      add(InitializeAuth());
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onSignUpRequested(
    SignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await authService.signUp(event.email, event.password, event.name);
      add(InitializeAuth());
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onDeleteAccountRequested(
    DeleteAccountRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await authService.deleteAccount();
      emit(state.copyWith(
        isAuthenticated: false,
        userName: 'Guest',
        preferredCurrency: 'USD',
      ));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
}
