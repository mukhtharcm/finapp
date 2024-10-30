import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:finapp/models/category.dart';
import 'package:finapp/services/finance_service.dart';

part 'category_event.dart';
part 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final FinanceService financeService;

  CategoryBloc({required this.financeService}) : super(CategoryInitial()) {
    on<FetchCategories>(_onFetchCategories);
  }

  Future<void> _onFetchCategories(
    FetchCategories event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());
    try {
      await financeService.fetchCategories();
      emit(CategorySuccess(categories: financeService.categories));
    } catch (e) {
      emit(CategoryFailure(error: e.toString()));
    }
  }
}
