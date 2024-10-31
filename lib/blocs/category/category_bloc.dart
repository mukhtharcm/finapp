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
    on<AddCategory>(_onAddCategory);
    on<UpdateCategory>(_onUpdateCategory);
    on<DeleteCategory>(_onDeleteCategory);
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

  Future<void> _onAddCategory(
    AddCategory event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());
    try {
      await financeService.addCategory(event.category);
      await _onFetchCategories(FetchCategories(), emit);
    } catch (e) {
      emit(CategoryFailure(error: e.toString()));
    }
  }

  Future<void> _onUpdateCategory(
    UpdateCategory event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());
    try {
      await financeService.updateCategory(event.category);
      await _onFetchCategories(FetchCategories(), emit);
    } catch (e) {
      emit(CategoryFailure(error: e.toString()));
    }
  }

  Future<void> _onDeleteCategory(
    DeleteCategory event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());
    try {
      await financeService.deleteCategory(event.id);
      await _onFetchCategories(FetchCategories(), emit);
    } catch (e) {
      emit(CategoryFailure(error: e.toString()));
    }
  }
}
