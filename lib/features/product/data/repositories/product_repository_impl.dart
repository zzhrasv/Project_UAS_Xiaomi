import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../models/product_variant_model.dart';

final class ProductRepositoryImpl implements ProductRepository {
  final SupabaseClient _supabaseClient;

  ProductRepositoryImpl(this._supabaseClient);

  @override
  Future<List<CategoryEntity>> getCategories() async {
    final response = await _supabaseClient
        .from('categories')
        .select()
        .order('name', ascending: true);
    
    return (response as List)
        .map((json) => CategoryModel.fromJson(json).toEntity())
        .toList();
  }

  @override
  Future<List<ProductEntity>> getFeaturedProducts() async {
    final response = await _supabaseClient
        .from('products')
        .select('*, product_variants(*)')
        .eq('is_featured', true);

    return _parseProductsList(response as List);
  }

  @override
  Future<List<ProductEntity>> getProductsByCategory(String categoryId) async {
    final response = await _supabaseClient
        .from('products')
        .select('*, product_variants(*)')
        .eq('category_id', categoryId);

    return _parseProductsList(response as List);
  }

  @override
  Future<ProductEntity> getProductById(String productId) async {
    final response = await _supabaseClient
        .from('products')
        .select('*, product_variants(*)')
        .eq('id', productId)
        .single();

    return _parseSingleProduct(response);
  }

  @override
  Future<List<ProductEntity>> searchProducts(String query) async {
    final response = await _supabaseClient
        .from('products')
        .select('*, product_variants(*)')
        .ilike('name', '%$query%');

    return _parseProductsList(response as List);
  }

  List<ProductEntity> _parseProductsList(List<dynamic> response) {
    return response.map((json) => _parseSingleProduct(json as Map<String, dynamic>)).toList();
  }

  ProductEntity _parseSingleProduct(Map<String, dynamic> json) {
    final productModel = ProductModel.fromJson(json);
    
    final variantsList = (json['product_variants'] as List? ?? [])
        .map((vJson) => ProductVariantModel.fromJson(vJson as Map<String, dynamic>).toEntity())
        .toList();

    return ProductEntity(
      id: productModel.id,
      categoryId: productModel.categoryId,
      name: productModel.name,
      description: productModel.description,
      basePrice: productModel.basePrice,
      imageUrls: productModel.imageUrls,
      isFeatured: productModel.isFeatured,
      variants: variantsList,
    );
  }
}
