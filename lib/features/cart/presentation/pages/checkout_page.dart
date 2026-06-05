import 'dart:io';
import 'dart:convert';
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

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _detailAddressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  // Loading state
  bool _isPlacingOrder = false;

  // Dropdown States for API fetching
  List<Map<String, dynamic>> _provinces = [];
  List<Map<String, dynamic>> _cities = [];
  List<Map<String, dynamic>> _districts = [];

  bool _isLoadingProvinces = false;
  bool _isLoadingCities = false;
  bool _isLoadingDistricts = false;

  // Selections
  String? _selectedProvince;
  String? _selectedProvinceId;
  String? _selectedCity;
  String? _selectedCityId;
  String? _selectedDistrict;
  String? _selectedDistrictId;

  // Shipping Method
  String _selectedShipping = 'standard';
  double _shippingCost = 0.0;

  // Payment Method
  String _selectedPaymentBank = 'BCA'; // BCA, BNI, BRI, Mandiri

  @override
  void initState() {
    super.initState();
    // Load provinces list on start
    _loadProvinces();
    
    // Prefill name only from current user profile if available
    // Phone and email are left empty for manual input as requested
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _nameController.text = authState.profile.fullName;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _streetController.dispose();
    _detailAddressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // Formatting helper to convert API uppercase names to Title Case
  String _capitalizeText(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  // Fetch Provinces from static Indonesian regions API
  Future<void> _loadProvinces() async {
    if (!mounted) return;
    setState(() {
      _isLoadingProvinces = true;
    });

    try {
      final client = HttpClient();
      final uri = Uri.parse('https://www.emsifa.com/api-wilayah-indonesia/api/provinces.json');
      final request = await client.getUrl(uri);
      final response = await request.close();
      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final List<dynamic> data = json.decode(responseBody);
        
        if (mounted) {
          setState(() {
            _provinces = data.map((item) => {
              'id': item['id'].toString(),
              'name': _capitalizeText(item['name'].toString()),
            }).toList();
            _isLoadingProvinces = false;
          });
        }
      } else {
        throw Exception();
      }
    } catch (_) {
      // Fallback local list of provinces in case API is down
      if (mounted) {
        setState(() {
          _provinces = [
            {'id': '31', 'name': 'DKI Jakarta'},
            {'id': '32', 'name': 'Jawa Barat'},
            {'id': '33', 'name': 'Jawa Tengah'},
            {'id': '34', 'name': 'DI Yogyakarta'},
            {'id': '35', 'name': 'Jawa Timur'},
            {'id': '51', 'name': 'Bali'},
            {'id': '73', 'name': 'Sulawesi Selatan'},
            {'id': '12', 'name': 'Sumatera Utara'},
          ];
          _isLoadingProvinces = false;
        });
      }
    }
  }

  // Fetch Cities based on selected Province ID
  Future<void> _loadCities(String provinceId) async {
    if (!mounted) return;
    setState(() {
      _isLoadingCities = true;
      _cities = [];
      _selectedCity = null;
      _selectedCityId = null;
      _districts = [];
      _selectedDistrict = null;
      _selectedDistrictId = null;
    });

    try {
      final client = HttpClient();
      final uri = Uri.parse('https://www.emsifa.com/api-wilayah-indonesia/api/regencies/$provinceId.json');
      final request = await client.getUrl(uri);
      final response = await request.close();
      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final List<dynamic> data = json.decode(responseBody);
        
        if (mounted) {
          setState(() {
            _cities = data.map((item) => {
              'id': item['id'].toString(),
              'name': _capitalizeText(item['name'].toString()),
            }).toList();
            _isLoadingCities = false;
          });
        }
      } else {
        throw Exception();
      }
    } catch (_) {
      // Local fallback
      if (mounted) {
        setState(() {
          if (provinceId == '31') {
            _cities = [
              {'id': '3174', 'name': 'Kota Jakarta Selatan'},
              {'id': '3171', 'name': 'Kota Jakarta Pusat'},
            ];
          } else if (provinceId == '32') {
            _cities = [
              {'id': '3273', 'name': 'Kota Bandung'},
              {'id': '3275', 'name': 'Kota Bekasi'},
            ];
          } else if (provinceId == '33') {
            _cities = [
              {'id': '3374', 'name': 'Kota Semarang'},
              {'id': '3372', 'name': 'Kota Surakarta'},
            ];
          } else if (provinceId == '35') {
            _cities = [
              {'id': '3578', 'name': 'Kota Surabaya'},
              {'id': '3573', 'name': 'Kota Malang'},
            ];
          } else {
            _cities = [
              {'id': '101', 'name': 'Kota Utama A'},
              {'id': '102', 'name': 'Kota Utama B'},
            ];
          }
          _isLoadingCities = false;
        });
      }
    }
  }

  // Fetch Districts based on selected City ID
  Future<void> _loadDistricts(String cityId) async {
    if (!mounted) return;
    setState(() {
      _isLoadingDistricts = true;
      _districts = [];
      _selectedDistrict = null;
      _selectedDistrictId = null;
    });

    try {
      final client = HttpClient();
      final uri = Uri.parse('https://www.emsifa.com/api-wilayah-indonesia/api/districts/$cityId.json');
      final request = await client.getUrl(uri);
      final response = await request.close();
      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final List<dynamic> data = json.decode(responseBody);
        
        if (mounted) {
          setState(() {
            _districts = data.map((item) => {
              'id': item['id'].toString(),
              'name': _capitalizeText(item['name'].toString()),
            }).toList();
            _isLoadingDistricts = false;
          });
        }
      } else {
        throw Exception();
      }
    } catch (_) {
      // Local fallback
      if (mounted) {
        setState(() {
          if (cityId == '3174') {
            _districts = [
              {'id': '317401', 'name': 'Kebayoran Baru'},
              {'id': '317402', 'name': 'Cilandak'},
            ];
          } else if (cityId == '3273') {
            _districts = [
              {'id': '327301', 'name': 'Coblong'},
              {'id': '327302', 'name': 'Lengkong'},
            ];
          } else if (cityId == '3374') {
            _districts = [
              {'id': '337401', 'name': 'Tembalang'},
              {'id': '337402', 'name': 'Banyumanik'},
            ];
          } else if (cityId == '3578') {
            _districts = [
              {'id': '357801', 'name': 'Tegalsari'},
              {'id': '357802', 'name': 'Gubeng'},
            ];
          } else {
            _districts = [
              {'id': '201', 'name': 'Kecamatan Utama 1'},
              {'id': '202', 'name': 'Kecamatan Utama 2'},
            ];
          }
          _isLoadingDistricts = false;
        });
      }
    }
  }

  double get _totalPrice {
    double total = 0;
    for (var item in CartManager.items) {
      total += item.subtotal;
    }
    return total;
  }

  String get _paymentPrefix {
    switch (_selectedPaymentBank) {
      case 'BCA':
        return '014';
      case 'BNI':
        return '009';
      case 'BRI':
        return '002';
      case 'Mandiri':
        return '008';
      default:
        return '014';
    }
  }

  String get _paymentBankName {
    switch (_selectedPaymentBank) {
      case 'BCA':
        return 'BCA Virtual Account';
      case 'BNI':
        return 'BNI Virtual Account';
      case 'BRI':
        return 'BRI Virtual Account';
      case 'Mandiri':
        return 'Mandiri Virtual Account';
      default:
        return 'BCA Virtual Account';
    }
  }

  Color _getBankColor(String bank) {
    switch (bank) {
      case 'BCA':
        return const Color(0xFF005A9C); // BCA Blue
      case 'BNI':
        return const Color(0xFF005E6A); // BNI Teal
      case 'BRI':
        return const Color(0xFF00529C); // BRI Blue
      case 'Mandiri':
        return const Color(0xFF002D62); // Mandiri Navy
      default:
        return AppColors.primary;
    }
  }

  Future<void> _processCheckout(BuildContext context, AuthAuthenticated authState) async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap lengkapi semua bidang bertanda *!'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_selectedProvince == null ||
        _selectedCity == null ||
        _selectedDistrict == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap pilih provinsi, kota, dan kecamatan Anda!'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isPlacingOrder = true;
    });

    final profile = authState.profile;
    final concatenatedAddress = 
        '${_detailAddressController.text.trim()}, ${_streetController.text.trim()}, Kecamatan $_selectedDistrict, Kota $_selectedCity, Provinsi $_selectedProvince';

    final vaNumber = '$_paymentPrefix${_phoneController.text.trim().replaceAll(' ', '')}';

    try {
      // 1. Simpan order baru ke database Supabase
      final orderResponse = await supabase.from(SupabaseTables.orders).insert({
        'user_id': profile.id,
        'status': 'paid', // Langsung 'paid' karena simulasi VA sukses
        'total_price': _totalPrice + _shippingCost,
        'shipping_address': concatenatedAddress,
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
        _showSuccessDialog(context, profile.id, vaNumber);
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
          _isPlacingOrder = false;
        });
      }
    }
  }

  void _showSuccessDialog(BuildContext context, String userId, String vaNumber) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.success, size: 30),
            const SizedBox(width: 10),
            Text(
              'Pembelian Sukses!',
              style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pembayaran Virtual Account Anda telah diterima dan pesanan diproses.',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _getBankColor(_selectedPaymentBank).withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _getBankColor(_selectedPaymentBank).withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _paymentBankName,
                        style: TextStyle(
                          color: _getBankColor(_selectedPaymentBank),
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                          fontSize: 14,
                        ),
                      ),
                      const Icon(Icons.payment, size: 18, color: AppColors.textSecondary),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Nomor Virtual Account:',
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 2),
                  SelectableText(
                    vaNumber,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: _getBankColor(_selectedPaymentBank),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
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
              context.pop(); // Kembali ke CartPage
              context.pop(); // Kembali ke Beranda
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
              context.pop(); // Kembali ke CartPage
              context.pop(); // Kembali ke Beranda/Profile
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
          'Checkout',
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
          if (authState is! AuthAuthenticated) {
            return const Center(child: Text('Silakan login untuk checkout'));
          }

          return Stack(
            children: [
              Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Progress Tracker Header
                      _buildProgressTracker(),
                      const SizedBox(height: 20),

                      // 2. Alamat Pengiriman Section
                      _buildAddressSection(),
                      const SizedBox(height: 20),

                      // 3. Metode Pengiriman Section
                      _buildShippingSection(),
                      const SizedBox(height: 20),

                      // 4. Metode Pembayaran Section
                      _buildPaymentSection(),
                      const SizedBox(height: 20),

                      // 5. Ringkasan Pesanan Section
                      _buildOrderSummarySection(currencyFormatter),
                      const SizedBox(height: 80), // Padding bottom untuk checkout bar
                    ],
                  ),
                ),
              ),
              if (_isPlacingOrder)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
              // Bottom Action Bar
              Align(
                alignment: Alignment.bottomCenter,
                child: _buildBottomActionBar(context, authState, currencyFormatter),
              ),
            ],
          );
        },
      ),
    );
  }

  // 1. Progress Tracker Widget (Gambar 2 Header)
  Widget _buildProgressTracker() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTrackerStep('1', 'Keranjang belanja', false),
          Container(
            width: 30,
            height: 1,
            color: AppColors.textSecondary.withOpacity(0.3),
            margin: const EdgeInsets.symmetric(horizontal: 8),
          ),
          _buildTrackerStep('2', 'Checkout', true),
          Container(
            width: 30,
            height: 1,
            color: AppColors.textSecondary.withOpacity(0.3),
            margin: const EdgeInsets.symmetric(horizontal: 8),
          ),
          _buildTrackerStep('3', 'Ulasan', false, isLast: true),
        ],
      ),
    );
  }

  Widget _buildTrackerStep(String number, String label, bool isActive, {bool isLast = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? Colors.black : Colors.white,
            border: Border.all(color: isActive ? Colors.black : AppColors.textHint),
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: TextStyle(
              color: isActive ? Colors.white : AppColors.textHint,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.black : AppColors.textSecondary,
            fontSize: 11,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }

  // 2. Alamat Pengiriman Form (Gambar 2)
  Widget _buildAddressSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Alamat pengiriman',
            style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Nama *
          _buildFieldLabel('Nama *'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _nameController,
            style: AppTextStyles.bodyMedium,
            decoration: const InputDecoration(
              hintText: 'Nama Lengkap Penerima',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) return 'Nama wajib diisi';
              return null;
            },
          ),
          const SizedBox(height: 14),

          // Provinsi * & Kota * (Row)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel('Provinsi *'),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: _selectedProvinceId,
                      isExpanded: true,
                      hint: _isLoadingProvinces 
                          ? const SizedBox(
                              height: 14,
                              width: 14,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                            )
                          : const Text('Provinsi'),
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      items: _provinces.map((province) {
                        return DropdownMenuItem<String>(
                          value: province['id'],
                          child: Text(province['name']),
                        );
                      }).toList(),
                      onChanged: _isLoadingProvinces ? null : (val) {
                        if (val != null) {
                          final selected = _provinces.firstWhere((element) => element['id'] == val);
                          setState(() {
                            _selectedProvinceId = val;
                            _selectedProvince = selected['name'];
                            _selectedCity = null;
                            _selectedCityId = null;
                            _selectedDistrict = null;
                            _selectedDistrictId = null;
                          });
                          _loadCities(val);
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel('Kota *'),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: _selectedCityId,
                      isExpanded: true,
                      hint: _isLoadingCities
                          ? const SizedBox(
                              height: 14,
                              width: 14,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                            )
                          : const Text('Kota'),
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      items: _cities.map((city) {
                        return DropdownMenuItem<String>(
                          value: city['id'],
                          child: Text(city['name']),
                        );
                      }).toList(),
                      onChanged: _selectedProvinceId == null || _isLoadingCities ? null : (val) {
                        if (val != null) {
                          final selected = _cities.firstWhere((element) => element['id'] == val);
                          setState(() {
                            _selectedCityId = val;
                            _selectedCity = selected['name'];
                            _selectedDistrict = null;
                            _selectedDistrictId = null;
                          });
                          _loadDistricts(val);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Distrik/Kecamatan * & Jalan * (Row)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel('Distrik *'),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: _selectedDistrictId,
                      isExpanded: true,
                      hint: _isLoadingDistricts
                          ? const SizedBox(
                              height: 14,
                              width: 14,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                            )
                          : const Text('Distrik'),
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      items: _districts.map((district) {
                        return DropdownMenuItem<String>(
                          value: district['id'],
                          child: Text(district['name']),
                        );
                      }).toList(),
                      onChanged: _selectedCityId == null || _isLoadingDistricts ? null : (val) {
                        if (val != null) {
                          final selected = _districts.firstWhere((element) => element['id'] == val);
                          setState(() {
                            _selectedDistrictId = val;
                            _selectedDistrict = selected['name'];
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel('Jalan *'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _streetController,
                      style: AppTextStyles.bodyMedium,
                      decoration: const InputDecoration(
                        hintText: 'Nama Jalan / Gang',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Jalan wajib diisi';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Alamat * (Detail)
          _buildFieldLabel('Alamat Lengkap *'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _detailAddressController,
            style: AppTextStyles.bodyMedium,
            decoration: const InputDecoration(
              hintText: 'Nomor rumah dan nama jalan',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) return 'Alamat detail wajib diisi';
              return null;
            },
          ),
          const SizedBox(height: 14),

          // Nomor telepon *
          _buildFieldLabel('Nomor telepon *'),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  '+62',
                  style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: _phoneController,
                  style: AppTextStyles.bodyMedium,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    hintText: '812xxxxxxxx',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Nomor telepon wajib diisi';
                    if (!RegExp(r'^[0-9]+$').hasMatch(value)) return 'Hanya angka';
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Alamat Email *
          _buildFieldLabel('Alamat Email *'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _emailController,
            style: AppTextStyles.bodyMedium,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'nama@domain.com',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) return 'Email wajib diisi';
              if (!value.contains('@') || !value.contains('.')) return 'Email tidak valid';
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: AppTextStyles.titleMedium.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
    );
  }

  // 3. Metode Pengiriman (Gambar 3)
  Widget _buildShippingSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Metode pengiriman',
            style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Option 1: Motorcycle (Selectable, Rp 15.000)
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedShipping = 'motorcycle';
                _shippingCost = 15000.0;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
              decoration: BoxDecoration(
                color: _selectedShipping == 'motorcycle'
                    ? AppColors.primary.withOpacity(0.04)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _selectedShipping == 'motorcycle'
                      ? AppColors.primary
                      : AppColors.border,
                  width: _selectedShipping == 'motorcycle' ? 1.5 : 1.0,
                ),
              ),
              child: Row(
                children: [
                  Radio<String>(
                    value: 'motorcycle',
                    groupValue: _selectedShipping,
                    onChanged: (val) {
                      setState(() {
                        _selectedShipping = val!;
                        _shippingCost = 15000.0;
                      });
                    },
                    activeColor: AppColors.primary,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pengiriman sepeda motor',
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '1-2 jam setelah pembayaran',
                          style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Text(
                      'Rp 15.000',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Option 2: Standard Shipping (Selected & Free)
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedShipping = 'standard';
                _shippingCost = 0.0;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
              decoration: BoxDecoration(
                color: _selectedShipping == 'standard' 
                    ? AppColors.primary.withOpacity(0.04) 
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _selectedShipping == 'standard' 
                      ? AppColors.primary 
                      : AppColors.border,
                  width: _selectedShipping == 'standard' ? 1.5 : 1.0,
                ),
              ),
              child: Row(
                children: [
                  Radio<String>(
                    value: 'standard',
                    groupValue: _selectedShipping,
                    onChanged: (val) {
                      setState(() {
                        _selectedShipping = val!;
                        _shippingCost = 0.0;
                      });
                    },
                    activeColor: AppColors.primary,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pengiriman standar',
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '2-5 hari setelah pembayaran',
                          style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Text(
                      'Gratis',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Warning Text at bottom (Gambar 3 Footer)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline_rounded, size: 14, color: AppColors.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Dipengaruhi oleh cuaca dan festival, pengiriman akan tertunda',
                  style: TextStyle(
                    color: AppColors.primary.withOpacity(0.9),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 4. Metode Pembayaran (User request: BNI, BCA, BRI, Mandiri Virtual Account)
  Widget _buildPaymentSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Metode Pembayaran',
            style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Silakan pilih Virtual Account Bank pembayaran Anda:',
            style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
          ),
          const SizedBox(height: 16),

          _buildBankRadioCard('BCA', 'BCA Virtual Account', '014'),
          const SizedBox(height: 10),
          _buildBankRadioCard('BNI', 'BNI Virtual Account', '009'),
          const SizedBox(height: 10),
          _buildBankRadioCard('BRI', 'BRI Virtual Account', '002'),
          const SizedBox(height: 10),
          _buildBankRadioCard('Mandiri', 'Mandiri Virtual Account', '008'),
        ],
      ),
    );
  }

  Widget _buildBankLogo(String bankCode) {
    String assetPath;
    switch (bankCode) {
      case 'BCA':
        assetPath = 'assets/images/bca_logo.png';
        break;
      case 'BNI':
        assetPath = 'assets/images/bni_logo.png';
        break;
      case 'BRI':
        assetPath = 'assets/images/bri_logo.png';
        break;
      case 'Mandiri':
        assetPath = 'assets/images/mandiri_logo.png';
        break;
      default:
        assetPath = '';
    }

    return Container(
      width: 75,
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade200, width: 1.0),
      ),
      alignment: Alignment.center,
      child: assetPath.isNotEmpty
          ? Image.asset(
              assetPath,
              fit: BoxFit.contain,
            )
          : Text(
              bankCode,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
    );
  }

  Widget _buildBankRadioCard(String bankCode, String bankName, String prefix) {
    final isSelected = _selectedPaymentBank == bankCode;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentBank = bankCode;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? _getBankColor(bankCode).withOpacity(0.04) : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? _getBankColor(bankCode) : AppColors.border,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: bankCode,
              groupValue: _selectedPaymentBank,
              onChanged: (val) {
                setState(() {
                  _selectedPaymentBank = val!;
                });
              },
              activeColor: _getBankColor(bankCode),
            ),
            _buildBankLogo(bankCode),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bankName,
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Kode Bank: $prefix',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 5. Ringkasan Pesanan Section
  Widget _buildOrderSummarySection(NumberFormat currencyFormatter) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ringkasan pesanan',
            style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            '${CartManager.items.length} item',
            style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          // Items List
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: CartManager.items.length,
            itemBuilder: (context, index) {
              final item = CartManager.items[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item.imageUrl.isNotEmpty
                            ? item.imageUrl
                            : 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=300',
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 48,
                          height: 48,
                          color: AppColors.surfaceVariant,
                          child: const Icon(Icons.image_outlined, size: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.productName,
                            style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Varian: ${item.variantLabel} | Jumlah: ${item.quantity}',
                            style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      currencyFormatter.format(item.subtotal),
                      style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(height: 20, color: AppColors.divider),

          // Pricing calculation breakdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Subtotal', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
              Text(currencyFormatter.format(_totalPrice), style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Biaya pengiriman', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
              Text(
                _shippingCost == 0.0 ? 'Gratis' : currencyFormatter.format(_shippingCost),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: _shippingCost == 0.0 ? AppColors.success : AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(height: 20, color: AppColors.divider),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold)),
              Text(
                currencyFormatter.format(_totalPrice + _shippingCost),
                style: AppTextStyles.price.copyWith(fontSize: 16, color: AppColors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Bottom Fixed Action Bar
  Widget _buildBottomActionBar(BuildContext context, AuthAuthenticated authState, NumberFormat currencyFormatter) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
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
                  style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
                ),
                const SizedBox(height: 2),
                Text(
                  currencyFormatter.format(_totalPrice + _shippingCost),
                  style: AppTextStyles.price.copyWith(fontSize: 16, color: AppColors.primary),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 160,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              onPressed: () => _processCheckout(context, authState),
              child: Text(
                'Buat Pesanan',
                style: AppTextStyles.button.copyWith(fontSize: 14, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
