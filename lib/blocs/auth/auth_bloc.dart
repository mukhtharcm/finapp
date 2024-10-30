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
          userName: authService.userName.value,
          preferredCurrency: authService.preferredCurrency.value,
        )) {
    on<UpdateUserName>(_onUpdateUserName);
    on<UpdatePreferredCurrency>(_onUpdatePreferredCurrency);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onUpdateUserName(
    UpdateUserName event,
    Emitter<AuthState> emit,
  ) async {
    await authService.updateUserProfile(name: event.userName);
    emit(state.copyWith(userName: event.userName));
  }

  Future<void> _onUpdatePreferredCurrency(
    UpdatePreferredCurrency event,
    Emitter<AuthState> emit,
  ) async {
    await authService.updateUserProfile(preferredCurrency: event.currency);
    emit(state.copyWith(preferredCurrency: event.currency));
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await authService.logout();
    emit(state.copyWith(isAuthenticated: false));
  }
}
