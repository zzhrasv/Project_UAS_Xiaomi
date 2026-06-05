import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../cart/data/models/cart_item_model.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../domain/entities/product_entity.dart';

class ProductDetailPage extends StatefulWidget {
  final String productId;

  const ProductDetailPage({super.key, required this.productId});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late final ProductRepositoryImpl _productRepository;
  ProductEntity? _product;
  ProductVariantEntity? _selectedVariant;
  int _quantity = 1;
  int _currentImageIndex = 0;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _productRepository = ProductRepositoryImpl(Supabase.instance.client);
    _loadProductDetail();
  }

  Future<void> _loadProductDetail() async {
    try {
      final product = await _productRepository.getProductById(widget.productId);
      if (mounted) {
        setState(() {
          _product = product;
          if (product.variants.isNotEmpty) {
            _selectedVariant = product.variants.first;
            _quantity = _selectedVariant!.stock > 0 ? 1 : 0;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading product detail: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Gagal memuat detail produk: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  double get _currentPrice {
    if (_selectedVariant != null) {
      return _selectedVariant!.price;
    }
    return _product?.basePrice ?? 0.0;
  }

  int get _currentStock {
    if (_selectedVariant != null) {
      return _selectedVariant!.stock;
    }
    return 0;
  }

  void _addToCart() {
    if (_product == null || _quantity <= 0) return;

    final cartItem = CartItemModel(
      variantId: _selectedVariant?.id ?? _product!.id, // Fallback ke product ID jika tanpa varian
      productId: _product!.id,
      productName: _product!.name,
      variantLabel: _selectedVariant?.variantLabel ?? 'Standar',
      imageUrl: _product!.thumbnailUrl,
      price: _currentPrice,
      quantity: _quantity,
    );

    CartManager.addItem(cartItem);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Berhasil menambahkan ${cartItem.productName} (${cartItem.variantLabel}) ke keranjang.'),
        backgroundColor: AppColors.success,
        action: SnackBarAction(
          label: 'LIHAT',
          textColor: Colors.white,
          onPressed: () => context.push(AppRoutes.cart),
        ),
      ),
    );
  }

  void _buyNow() {
    if (_product == null || _quantity <= 0) return;

    final cartItem = CartItemModel(
      variantId: _selectedVariant?.id ?? _product!.id,
      productId: _product!.id,
      productName: _product!.name,
      variantLabel: _selectedVariant?.variantLabel ?? 'Standar',
      imageUrl: _product!.thumbnailUrl,
      price: _currentPrice,
      quantity: _quantity,
    );

    CartManager.addItem(cartItem);
    context.push(AppRoutes.cart);
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final isOutOfStock = _selectedVariant != null && _currentStock <= 0;

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
      );
    }

    if (_errorMessage != null || _product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Produk')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              _errorMessage ?? 'Produk tidak ditemukan',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final product = _product!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Body scrollable content
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Slider
                  _buildImageSlider(product),
                  
                  // Product Info Card
                  Container(
                    width: double.infinity,
                    color: AppColors.surface,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: AppTextStyles.displayMedium.copyWith(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          currencyFormatter.format(_currentPrice),
                          style: AppTextStyles.price.copyWith(fontSize: 22),
                        ),
                        if (_selectedVariant != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _currentStock > 0
                                      ? AppColors.success.withOpacity(0.1)
                                      : AppColors.error.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  _currentStock > 0 ? 'Tersedia' : 'Stok Habis',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: _currentStock > 0 ? AppColors.success : AppColors.error,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Stok: $_currentStock pcs',
                                style: AppTextStyles.bodySmall,
                              ),
                            ],
                          ),
                        ]
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Variant Selection Section
                  if (product.variants.isNotEmpty)
                    Container(
                      width: double.infinity,
                      color: AppColors.surface,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pilih Varian',
                            style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: product.variants.map((variant) {
                              final isSelected = _selectedVariant?.id == variant.id;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedVariant = variant;
                                    _quantity = variant.stock > 0 ? 1 : 0; // Reset kuantitas ke 1 jika ganti varian dan ada stok, jika tidak 0
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primary.withOpacity(0.08)
                                        : AppColors.background,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isSelected ? AppColors.primary : AppColors.border,
                                      width: isSelected ? 1.5 : 1,
                                    ),
                                  ),
                                  child: Text(
                                    variant.variantLabel,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          )
                        ],
                      ),
                    ),
                  const SizedBox(height: 12),

                  // Kuantitas Selector Card
                  Container(
                    width: double.infinity,
                    color: AppColors.surface,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Kuantitas Belanja',
                          style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.remove_circle_outline,
                                color: isOutOfStock || _quantity <= 1 ? AppColors.textHint : AppColors.textSecondary,
                                size: 24,
                              ),
                              onPressed: isOutOfStock || _quantity <= 1
                                  ? null
                                  : () {
                                      setState(() {
                                        _quantity--;
                                      });
                                    },
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                '$_quantity',
                                style: AppTextStyles.titleLarge.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isOutOfStock ? AppColors.textHint : AppColors.textPrimary,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.add_circle_outline,
                                color: isOutOfStock || _quantity >= _currentStock ? AppColors.textHint : AppColors.primary,
                                size: 24,
                              ),
                              onPressed: isOutOfStock || _quantity >= _currentStock
                                  ? null
                                  : () {
                                      if (_selectedVariant != null && _quantity < _currentStock) {
                                        setState(() {
                                          _quantity++;
                                        });
                                      } else if (_selectedVariant == null) {
                                        setState(() {
                                          _quantity++;
                                        });
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Batas stok maksimum tercapai.')),
                                        );
                                      }
                                    },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Deskripsi Produk Card
                  if (product.description != null && product.description!.isNotEmpty)
                    Container(
                      width: double.infinity,
                      color: AppColors.surface,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Deskripsi Produk',
                            style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            product.description!,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Floating Top Navigation Icons
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCircularButton(
                  icon: Icons.arrow_back_rounded,
                  onPressed: () => context.pop(),
                ),
                _buildCircularButton(
                  icon: Icons.shopping_cart_outlined,
                  onPressed: () => context.push(AppRoutes.cart),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: _buildBottomActions(currencyFormatter),
      ),
    );
  }

  Widget _buildImageSlider(ProductEntity product) {
    final images = product.imageUrls.isNotEmpty
        ? product.imageUrls
        : ['https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=800'];

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          CarouselSlider(
            options: CarouselOptions(
              height: 320,
              viewportFraction: 1.0,
              onPageChanged: (index, reason) {
                setState(() {
                  _currentImageIndex = index;
                });
              },
            ),
            items: images.map((imageUrl) {
              return Builder(
                builder: (BuildContext context) {
                  return CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.contain,
                    width: double.infinity,
                    placeholder: (context, url) => Container(color: AppColors.surfaceVariant),
                    errorWidget: (context, url, error) => const Icon(Icons.image_outlined, size: 64, color: AppColors.textHint),
                  );
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: images.asMap().entries.map((entry) {
              return Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentImageIndex == entry.key ? AppColors.primary : AppColors.border,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildCircularButton({required IconData icon, required VoidCallback onPressed}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: AppColors.textPrimary, size: 22),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildBottomActions(NumberFormat currencyFormatter) {
    final isOutOfStock = _selectedVariant != null && _currentStock <= 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(top: BorderSide(color: AppColors.border, width: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Total Harga Preview
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Harga',
                style: AppTextStyles.bodySmall,
              ),
              Text(
                currencyFormatter.format(_currentPrice * _quantity),
                style: AppTextStyles.price.copyWith(fontSize: 15),
              ),
            ],
          ),
          const SizedBox(width: 12),
          // Buttons
          Expanded(
            flex: 3,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                minimumSize: const Size(0, 48), // Mengabaikan minimumSize double.infinity dari tema global
              ),
              onPressed: isOutOfStock ? null : _addToCart,
              child: Text(
                'Masukkan Keranjang',
                style: AppTextStyles.button.copyWith(color: AppColors.primary, fontSize: 11),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                elevation: 0,
                minimumSize: const Size(0, 48), // Mengabaikan minimumSize double.infinity dari tema global
              ),
              onPressed: isOutOfStock ? null : _buyNow,
              child: Text(
                isOutOfStock ? 'Stok Habis' : 'Beli',
                style: AppTextStyles.button.copyWith(fontSize: 11),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
