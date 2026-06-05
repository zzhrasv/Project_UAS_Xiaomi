import 'package:flutter/material.dart';

/// Tanggung jawab: Mendefinisikan seluruh palet warna aplikasi Mi Store.
/// Sumber warna mengacu pada brand guideline Xiaomi (oranye + hitam + putih).
/// Tidak ada warna hardcode di luar file ini.
abstract final class AppColors {
  // ── Primary Brand ─────────────────────────────────────────────────────────
  static const Color primary = Color(0xFFFF6900);       // Xiaomi Orange
  static const Color primaryDark = Color(0xFFE55A00);
  static const Color primaryLight = Color(0xFFFF8C3A);

  // ── Neutral / Surface ─────────────────────────────────────────────────────
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0F0F0);
  static const Color inverseSurface = Color(0xFF1A1A1A);  // Dark card

  // ── Text ──────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color textHint = Color(0xFFB0B0B0);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ── Semantic ──────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF27AE60);
  static const Color error = Color(0xFFE74C3C);
  static const Color warning = Color(0xFFF39C12);
  static const Color info = Color(0xFF2980B9);

  // ── Border & Divider ──────────────────────────────────────────────────────
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFEEEEEE);

  // ── Mi Points Gold ────────────────────────────────────────────────────────
  static const Color miPointsGold = Color(0xFFFFB800);
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);
}
