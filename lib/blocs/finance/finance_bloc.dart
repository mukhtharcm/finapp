import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:finapp/services/finance_service.dart';

part 'finance_event.dart';
part 'finance_state.dart';

class FinanceBloc extends Bloc<FinanceEvent, FinanceState> {
  final FinanceService financeService;

  FinanceBloc({required this.financeService}) : super(FinanceInitial()) {
    on<InitializeFinance>(_onInitializeFinance);
  }

  Future<void> _onInitializeFinance(
    InitializeFinance event,
    Emitter<FinanceState> emit,
  ) async {
    emit(FinanceLoading());
    try {
      await financeService.initialize();
      emit(FinanceSuccess());
    } catch (e) {
      emit(FinanceFailure(error: e.toString()));
    }
  }
}
