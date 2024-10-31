import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:finapp/models/account.dart';
import 'package:finapp/services/finance_service.dart';

part 'account_event.dart';
part 'account_state.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final FinanceService financeService;

  AccountBloc({required this.financeService}) : super(AccountInitial()) {
    on<FetchAccounts>(_onFetchAccounts);
    on<AddAccount>(_onAddAccount);
    on<UpdateAccount>(_onUpdateAccount);
    on<DeleteAccount>(_onDeleteAccount);
  }

  Future<void> _onFetchAccounts(
    FetchAccounts event,
    Emitter<AccountState> emit,
  ) async {
    emit(AccountLoading());
    try {
      await financeService.fetchAccounts();
      emit(AccountSuccess(accounts: financeService.accounts));
    } catch (e) {
      emit(AccountFailure(error: e.toString()));
    }
  }

  Future<void> _onAddAccount(
    AddAccount event,
    Emitter<AccountState> emit,
  ) async {
    emit(AccountLoading());
    try {
      await financeService.addAccount(event.account);
      await _onFetchAccounts(FetchAccounts(), emit);
    } catch (e) {
      emit(AccountFailure(error: e.toString()));
    }
  }

  Future<void> _onUpdateAccount(
    UpdateAccount event,
    Emitter<AccountState> emit,
  ) async {
    emit(AccountLoading());
    try {
      await financeService.updateAccount(
        event.account,
      );
      await _onFetchAccounts(FetchAccounts(), emit);
    } catch (e) {
      emit(AccountFailure(error: e.toString()));
    }
  }

  Future<void> _onDeleteAccount(
    DeleteAccount event,
    Emitter<AccountState> emit,
  ) async {
    emit(AccountLoading());
    try {
      await financeService.deleteAccount(event.id);
      await _onFetchAccounts(FetchAccounts(), emit);
    } catch (e) {
      emit(AccountFailure(error: e.toString()));
    }
  }
}
