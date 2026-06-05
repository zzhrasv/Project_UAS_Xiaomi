import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../product/domain/repositories/product_repository.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final ProductRepository _productRepository;

  HomeBloc(this._productRepository) : super(const HomeInitial()) {
    on<HomeFetchRequested>(_onHomeFetchRequested);
  }

  Future<void> _onHomeFetchRequested(
    HomeFetchRequested event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());
    try {
      final categories = await _productRepository.getCategories();
      final featuredProducts = await _productRepository.getFeaturedProducts();
      
      emit(HomeLoaded(
        categories: categories,
        featuredProducts: featuredProducts,
      ));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
}
