import 'package:equatable/equatable.dart';
import '../../../product/domain/entities/category_entity.dart';
import '../../../product/domain/entities/product_entity.dart';

sealed class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  final List<CategoryEntity> categories;
  final List<ProductEntity> featuredProducts;

  const HomeLoaded({
    required this.categories,
    required this.featuredProducts,
  });

  @override
  List<Object?> get props => [categories, featuredProducts];
}

class HomeError extends HomeState {
  final String errorMessage;

  const HomeError(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
