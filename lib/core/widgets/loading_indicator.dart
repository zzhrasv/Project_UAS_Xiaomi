import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../constants/app_colors.dart';

/// Tanggung jawab: Menyediakan berbagai variasi loading indicator reusable.
/// Digunakan di seluruh aplikasi agar animasi loading konsisten.

/// Loading overlay penuh layar (untuk proses blocking seperti checkout)
class FullScreenLoader extends StatelessWidget {
  final String? message;

  const FullScreenLoader({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LoadingAnimationWidget.stretchedDots(
              color: AppColors.primary,
              size: 50,
            ),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message!,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Poppins',
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Inline loader kecil — dipakai di tengah konten
class InlineLoader extends StatelessWidget {
  final double size;
  final Color? color;

  const InlineLoader({super.key, this.size = 36, this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LoadingAnimationWidget.stretchedDots(
        color: color ?? AppColors.primary,
        size: size,
      ),
    );
  }
}

/// Loading indicator untuk list / page pertama kali dimuat
class PageLoader extends StatelessWidget {
  const PageLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: InlineLoader(size: 48));
  }
}
