import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/network/supabase_client.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/pages/orders_page.dart';
import '../../data/models/cart_item_model.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool _isCheckingOut = false;

  double get _totalPrice {
    double total = 0;
    for (var item in CartManager.items) {
      total += item.subtotal;
    }
    return total;
  }

  Future<void> _handleCheckout(BuildContext context, AuthAuthenticated authState) async {
    if (CartManager.items.isEmpty) return;

    setState(() {
      _isCheckingOut = true;
    });

    final profile = authState.profile;

    try {
      // 1. Simpan order baru ke database Supabase
      final orderResponse = await supabase.from(SupabaseTables.orders).insert({
        'user_id': profile.id,
        'status': 'paid', // Set sebagai "paid" agar pesanan selesai dibayar
        'total_price': _totalPrice,
        'shipping_address': 'Jl. Jenderal Sudirman No. 23, Jakarta Selatan, DKI Jakarta 12190',
        'mi_points_used': 0,
      }).select().single();

      final orderId = orderResponse['id'] as String;

      // 2. Simpan semua order items ke database Supabase secara batch
      final itemsToInsert = CartManager.items.map((item) => {
        'order_id': orderId,
        'product_id': item.productId,
        'product_name': item.productName,
        'variant_label': item.variantLabel,
        'price': item.price,
        'quantity': item.quantity,
      }).toList();

      await supabase.from(SupabaseTables.orderItems).insert(itemsToInsert);

      // 3. Update Mi Points pengguna (+10 Poin per checkout)
      final newPoints = profile.miPoints + 10;
      await supabase.from(SupabaseTables.profiles).update({
        'mi_points': newPoints,
      }).eq('id', profile.id);

      // 4. Refresh session di aplikasi agar poin terupdate di UI global
      if (mounted) {
        context.read<AuthBloc>().add(const AuthCheckRequested());
      }

      // 5. Kosongkan keranjang belanja
      CartManager.clear();

      // 6. Tampilkan dialog sukses checkout
      if (mounted) {
        _showSuccessDialog(context, profile.id);
      }
    } catch (e) {
      debugPrint('Checkout error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Checkout gagal: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingOut = false;
        });
      }
    }
  }

  void _showSuccessDialog(BuildContext context, String userId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.success, size: 28),
            const SizedBox(width: 10),
            Text(
              'Pemesanan Sukses!',
              style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pembayaran Anda telah diterima.',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.miPointsGold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.stars_rounded, color: AppColors.miPointsGold),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Selamat! +10 Mi Poin ditambahkan ke akun Anda.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: const Color(0xFFD48A00),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext); // Tutup dialog
              context.pop(); // Kembali ke home
            },
            child: Text(
              'Ke Beranda',
              style: AppTextStyles.labelLarge.copyWith(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(dialogContext); // Tutup dialog
              Navigator.pop(context); // Tutup CartPage
              // Arahkan ke halaman riwayat pesanan
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OrdersPage(userId: userId),
                ),
              );
            },
            child: Text(
              'Lihat Pesanan',
              style: AppTextStyles.labelLarge.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Keranjang Belanja',
          style: AppTextStyles.headlineMedium.copyWith(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (CartManager.items.isEmpty) {
            return _buildEmptyCartUI(context);
          }

          return Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: CartManager.items.length,
                      itemBuilder: (context, index) {
                        final item = CartManager.items[index];
                        return _buildCartItemCard(context, item, currencyFormatter);
                      },
                    ),
                  ),
                  // Detail Ringkasan
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildOrderSummary(currencyFormatter),
                  ),
                  const SizedBox(height: 12),
                  // Bottom Bar Checkout
                  _buildBottomBar(context, authState, currencyFormatter),
                ],
              ),
              if (_isCheckingOut)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyCartUI(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 80,
              color: AppColors.textHint.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Keranjang Belanja Kosong',
              style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Silakan pilih produk Xiaomi impian Anda di Beranda dan tambahkan ke keranjang.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 200,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  elevation: 0,
                ),
                onPressed: () => context.pop(),
                child: Text(
                  'Mulai Belanja',
                  style: AppTextStyles.button,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItemCard(BuildContext context, CartItemModel item, NumberFormat currencyFormatter) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar produk
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              item.imageUrl.isNotEmpty
                  ? item.imageUrl
                  : 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=300',
              width: 76,
              height: 76,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 76,
                height: 76,
                color: AppColors.surfaceVariant,
                child: const Icon(Icons.image_outlined, color: AppColors.textHint),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Info item
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.productName,
                        style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                      onPressed: () {
                        setState(() {
                          CartManager.removeItem(item.variantId);
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Varian: ${item.variantLabel}',
                  style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      currencyFormatter.format(item.price),
                      style: AppTextStyles.priceSmall.copyWith(fontSize: 13),
                    ),
                    // Quantity control
                    Row(
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.remove_circle_outline, color: AppColors.textSecondary, size: 20),
                          onPressed: () {
                            if (item.quantity > 1) {
                              setState(() {
                                CartManager.updateQuantity(item.variantId, item.quantity - 1);
                              });
                            }
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            '${item.quantity}',
                            style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.add_circle_outline, color: AppColors.primary, size: 20),
                          onPressed: () {
                            setState(() {
                              CartManager.updateQuantity(item.variantId, item.quantity + 1);
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(NumberFormat currencyFormatter) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Subtotal (${CartManager.items.length} item)', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
              Text(currencyFormatter.format(_totalPrice), style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Pengiriman', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
              Text('Gratis', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.success, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Pembayaran',
                style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                currencyFormatter.format(_totalPrice),
                style: AppTextStyles.price.copyWith(fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, AuthState authState, NumberFormat currencyFormatter) {
    final isLoggedIn = authState is AuthAuthenticated;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(top: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Tagihan',
                  style: AppTextStyles.bodySmall,
                ),
                Text(
                  currencyFormatter.format(_totalPrice),
                  style: AppTextStyles.price.copyWith(fontSize: 15),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 150,
            height: 46,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              onPressed: () {
                if (!isLoggedIn) {
                  // Prompt untuk login terlebih dahulu
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Silakan login terlebih dahulu untuk melakukan checkout!'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  context.push(AppRoutes.login);
                } else {
                  context.push(AppRoutes.checkout);
                }
              },
              child: Text(
                'Checkout',
                style: AppTextStyles.button.copyWith(fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
