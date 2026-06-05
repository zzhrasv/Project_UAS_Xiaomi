import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/network/supabase_client.dart';
import '../bloc/auth_bloc.dart';
import 'orders_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _showAccountDetail = false;
  int _orderCount = 0;

  @override
  void initState() {
    super.initState();
    // Cek jika user sudah terautentikasi sejak awal untuk mengambil jumlah pesanan
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _fetchOrderCount(authState.profile.id);
    }
  }

  Future<void> _fetchOrderCount(String userId) async {
    if (!mounted) return;
    try {
      final response = await supabase
          .from(SupabaseTables.orders)
          .select('id')
          .eq('user_id', userId);
      
      if (mounted) {
        setState(() {
          _orderCount = response.length;
        });
      }
    } catch (e) {
      debugPrint('Error fetching order count: $e');
    }
  }

  // Helper untuk sapaan berdasarkan waktu lokal saat ini
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  // Helper untuk sensor/obfuscate email (contoh: sivzahra@gmail.com -> sivza****@gmail.com)
  String _obfuscateEmail(String? email) {
    if (email == null || !email.contains('@')) return '';
    final parts = email.split('@');
    final name = parts[0];
    final domain = parts[1];
    if (name.length > 5) {
      return '${name.substring(0, 5)}****@$domain';
    }
    return '${name}****@$domain';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _showAccountDetail
          ? null // Sembunyikan appBar bawaan saat menampilkan detail akun bergambar
          : AppBar(
              title: Text(
                'Profil Saya',
                style: AppTextStyles.headlineMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              backgroundColor: AppColors.surface,
              elevation: 0,
              centerTitle: true,
            ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            _fetchOrderCount(state.profile.id);
          }
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AuthLoading || state is AuthInitial) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          } else if (state is AuthAuthenticated) {
            try {
              return _showAccountDetail
                  ? _buildAccountDetailUI(context, state)
                  : _buildDropdownMenuUI(context, state);
            } catch (e, stack) {
              debugPrint('ProfilePage UI Error: $e\n$stack');
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.error, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        'Gagal memuat tampilan profil',
                        style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        e.toString(),
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }
          } else {
            return _buildUnauthenticatedUI(context);
          }
        },
      ),
    );
  }

  // ── DROPDOWN MENU UI (Gambar 3) ───────────────────────────────────────────
  Widget _buildDropdownMenuUI(BuildContext context, AuthAuthenticated state) {
    final profile = state.profile;
    final email = supabaseAuth.currentUser?.email;
    final initials = profile.fullName.trim().isNotEmpty
        ? profile.fullName
            .trim()
            .split(' ')
            .where((w) => w.isNotEmpty)
            .map((w) => w[0])
            .take(2)
            .join()
            .toUpperCase()
        : 'M';

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 40),
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Text(
              initials,
              style: AppTextStyles.displayMedium.copyWith(
                color: AppColors.primary,
                fontSize: 28,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            profile.fullName,
            style: AppTextStyles.headlineMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            email ?? '',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 36),

          // Dropdown menu card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                _buildDropdownItem(
                  icon: Icons.person_outline_rounded,
                  title: 'Akun Saya',
                  onTap: () {
                    setState(() {
                      _showAccountDetail = true;
                    });
                  },
                ),
                const Divider(height: 1, color: AppColors.divider),
                _buildDropdownItem(
                  icon: Icons.shopping_bag_outlined,
                  title: 'Pesanan Saya',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrdersPage(userId: profile.id),
                      ),
                    );
                  },
                ),
                const Divider(height: 1, color: AppColors.divider),
                _buildDropdownItem(
                  icon: Icons.logout_rounded,
                  title: 'Logout',
                  titleColor: AppColors.error,
                  iconColor: AppColors.error,
                  onTap: () => _showLogoutConfirmation(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildDropdownItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? titleColor,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? AppColors.textPrimary, size: 22),
      title: Text(
        title,
        style: AppTextStyles.titleMedium.copyWith(
          fontWeight: FontWeight.w600,
          color: titleColor ?? AppColors.textPrimary,
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textHint, size: 20),
      onTap: onTap,
    );
  }

  // ── ACCOUNT DETAIL UI (Gambar 1 + Gambar 2 Modified) ──────────────────────
  Widget _buildAccountDetailUI(BuildContext context, AuthAuthenticated state) {
    final profile = state.profile;
    final email = supabaseAuth.currentUser?.email;
    final initials = profile.fullName.trim().isNotEmpty
        ? profile.fullName
            .trim()
            .split(' ')
            .where((w) => w.isNotEmpty)
            .map((w) => w[0])
            .take(2)
            .join()
            .toUpperCase()
        : 'M';

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header dengan background gambar interior hangat (Gambar 1)
          Stack(
            children: [
              // Background Image
              Container(
                height: 230,
                width: double.infinity,
                child: Image.network(
                  'https://images.unsplash.com/photo-1616486338812-3dadae4b4ace?w=1000',
                  fit: BoxFit.cover,
                ),
              ),
              // Overlay Gelap
              Container(
                height: 230,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.5),
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
              // Tombol Kembali
              Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                left: 8,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                  onPressed: () {
                    setState(() {
                      _showAccountDetail = false;
                    });
                  },
                ),
              ),
              // Konten Profil & Statistik (Pesan, Kupon, Mi Poin)
              Positioned(
                bottom: 24,
                left: 20,
                right: 20,
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Avatar (Initials dengan outline putih)
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withOpacity(0.8), width: 2.5),
                          ),
                          child: CircleAvatar(
                            radius: 32,
                            backgroundColor: Colors.white24,
                            child: Text(
                              initials,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Data pengguna
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${_getGreeting()}, ${profile.fullName}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Poppins',
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'Email: ${_obfuscateEmail(email)}',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 12,
                                  fontFamily: 'Poppins',
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 5),
                              GestureDetector(
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Edit informasi akan segera hadir!')),
                                  );
                                },
                                child: Row(
                                  children: [
                                    Text(
                                      'Edit informasi',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                    Icon(
                                      Icons.chevron_right,
                                      color: Colors.white.withOpacity(0.9),
                                      size: 14,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Baris statistik (Pesan, Kupon, Mi Poin)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OrdersPage(userId: profile.id),
                              ),
                            );
                          },
                          child: _buildStatItem('Pesan', '$_orderCount'),
                        ),
                        _buildStatItem('Kupon', '0'),
                        _buildStatItem('Mi Poin', '${profile.miPoints}'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Judul bagian
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Text(
              'Aktivitas Saya',
              style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),

          // Bagian menu hanya terdiri dari 2 card (Gambar 2 modified)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.0,
              children: [
                // Card 1: Pesanan Saya
                _buildGridCard(
                  icon: Icons.assignment_outlined,
                  iconColor: AppColors.primary,
                  title: 'Pesanan Saya',
                  subtitle: 'Lacak, ubah, batalkan pesanan, pengembalian atau ulasan',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrdersPage(userId: profile.id),
                      ),
                    );
                  },
                ),
                // Card 2: Mi Poin (Poin didapatkan setelah checkout)
                _buildGridCard(
                  icon: Icons.stars_rounded,
                  iconColor: AppColors.miPointsGold,
                  title: 'Mi Poin',
                  subtitle: 'Poin loyalitas didapatkan setelah melakukan checkout: ${profile.miPoints}',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Detail akumulasi poin loyalitas Anda')),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (label == 'Mi Poin')
              const Padding(
                padding: EdgeInsets.only(right: 4),
                child: Icon(Icons.stars_rounded, color: Colors.white, size: 12),
              ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 11,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }

  Widget _buildGridCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: Text(
                subtitle,
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 10,
                  height: 1.3,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── UNAUTHENTICATED UI ────────────────────────────────────────────────────
  Widget _buildUnauthenticatedUI(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Elegant Xiaomi Logo Box
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'mi',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 36,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),

          Text(
            'Selamat Datang di Mi Store',
            style: AppTextStyles.displayMedium.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Masuk untuk menikmati pengalaman berbelanja terbaik, melacak pesanan Anda, serta mengumpulkan Mi Points secara eksklusif!',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),

          // Action Buttons
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              onPressed: () => context.push(AppRoutes.login),
              child: Text(
                'Masuk ke Akun',
                style: AppTextStyles.button,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => context.push(AppRoutes.register),
              child: Text(
                'Daftar Akun Baru',
                style: AppTextStyles.button.copyWith(color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  // ── DIALOGS ───────────────────────────────────────────────────────────────
  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Keluar Akun',
          style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Apakah Anda yakin ingin keluar dari akun Mi Anda?',
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
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AuthBloc>().add(const AuthSignOutRequested());
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Berhasil keluar dari akun'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: Text(
              'Keluar',
              style: AppTextStyles.labelLarge.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
