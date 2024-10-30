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
}
