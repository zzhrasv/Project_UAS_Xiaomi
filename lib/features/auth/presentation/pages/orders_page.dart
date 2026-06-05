import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/network/supabase_client.dart';
import '../bloc/auth_bloc.dart';

class OrdersPage extends StatefulWidget {
  final String userId;

  const OrdersPage({super.key, required this.userId});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  List<dynamic> _orders = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    try {
      final response = await supabase
          .from(SupabaseTables.orders)
          .select()
          .eq('user_id', widget.userId)
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _orders = response as List<dynamic>;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching orders: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Gagal memuat riwayat pesanan: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  void _showCancelConfirmation(String orderId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Batalkan Pesanan',
          style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Apakah Anda yakin ingin membatalkan pesanan ini? Tindakan ini tidak dapat dibatalkan.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Batal',
              style: AppTextStyles.labelLarge.copyWith(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              minimumSize: const Size(0, 36),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              _cancelOrder(orderId);
            },
            child: Text(
              'Batalkan',
              style: AppTextStyles.labelLarge.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelOrder(String orderId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Hapus pesanan dari database Supabase terlebih dahulu (men-cascade delete order_items)
      final deletedRows = await supabase
          .from(SupabaseTables.orders)
          .delete()
          .eq('id', orderId)
          .select();

      if (deletedRows == null || (deletedRows as List).isEmpty) {
        throw Exception(
            'Pesanan tidak terhapus di database. Pastikan kebijakan RLS (Row Level Security) untuk tindakan DELETE pada tabel "orders" sudah aktif di Supabase Dashboard.');
      }

      // 2. Ambil poin saat ini dari profiles jika pesanan berhasil dihapus
      final profileResponse = await supabase
          .from(SupabaseTables.profiles)
          .select('mi_points')
          .eq('id', widget.userId)
          .single();

      final currentPoints = profileResponse['mi_points'] as int;
      final newPoints = (currentPoints - 10).clamp(0, 999999);

      // 3. Kurangi Mi Points pengguna (-10 Poin)
      await supabase
          .from(SupabaseTables.profiles)
          .update({'mi_points': newPoints})
          .eq('id', widget.userId);

      // 4. Refresh session AuthBloc agar poin terupdate di UI global
      if (mounted) {
        context.read<AuthBloc>().add(const AuthCheckRequested());
      }

      // 5. Tampilkan notifikasi sukses
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pesanan berhasil dibatalkan dan poin dikurangi.'),
            backgroundColor: AppColors.success,
          ),
        );
      }

      // 6. Muat ulang data pesanan
      _fetchOrders();
    } catch (e) {
      debugPrint('Error cancelling order: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membatalkan pesanan: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'paid':
        return AppColors.success;
      case 'pending':
      case 'processing':
        return AppColors.warning;
      case 'shipped':
        return AppColors.info;
      case 'cancelled':
      default:
        return AppColors.error;
    }
  }

  String _translateStatus(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'Selesai';
      case 'paid':
        return 'Sudah Dibayar';
      case 'pending':
        return 'Menunggu Pembayaran';
      case 'processing':
        return 'Sedang Diproses';
      case 'shipped':
        return 'Dalam Pengiriman';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status;
    }
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
          'Pesanan Saya',
          style: AppTextStyles.headlineMedium.copyWith(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _buildBody(currencyFormatter),
    );
  }

  Widget _buildBody(NumberFormat currencyFormatter) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _errorMessage!,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_orders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.assignment_turned_in_outlined,
                size: 72,
                color: AppColors.textHint.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'Belum Ada Pesanan',
                style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Anda belum melakukan pemesanan produk apapun.',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchOrders,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _orders.length,
        itemBuilder: (context, index) {
          final order = _orders[index];
          final id = order['id'] as String;
        final status = order['status'] as String;
        final totalPrice = (order['total_price'] as num).toDouble();
        final shippingAddress = order['shipping_address'] as String;
        
        final createdAtStr = order['created_at'] as String;
        final dateTime = DateTime.parse(createdAtStr).toLocal();
        final formattedDate = DateFormat('dd MMM yyyy, HH:mm').format(dateTime);

        return Card(
          margin: const EdgeInsets.only(bottom: 14),
          color: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: AppColors.border),
          ),
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card (ID & Status)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Order ID: ${id.substring(0, 8)}...',
                        style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _translateStatus(status),
                        style: AppTextStyles.labelSmall.copyWith(
                          color: _getStatusColor(status),
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(height: 1, color: AppColors.divider),
                const SizedBox(height: 10),

                // Info Tanggal & Total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tanggal Transaksi',
                          style: AppTextStyles.labelSmall.copyWith(fontSize: 10),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          formattedDate,
                          style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Total Pembayaran',
                          style: AppTextStyles.labelSmall.copyWith(fontSize: 10),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          currencyFormatter.format(totalPrice),
                          style: AppTextStyles.priceSmall.copyWith(fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Shipping Address
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Alamat: $shippingAddress',
                        style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                // Tombol Batalkan Pesanan jika statusnya memungkinkan
                if (status.toLowerCase() != 'cancelled' &&
                    status.toLowerCase() != 'completed' &&
                    status.toLowerCase() != 'shipped') ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: AppColors.divider),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error, width: 1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        minimumSize: const Size(0, 32),
                      ),
                      onPressed: () => _showCancelConfirmation(id),
                      child: Text(
                        'Batalkan Pesanan',
                        style: AppTextStyles.button.copyWith(
                          color: AppColors.error,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    ),
  );
}
}
