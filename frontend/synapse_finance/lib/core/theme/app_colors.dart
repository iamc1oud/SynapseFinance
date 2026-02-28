import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary colors — dark green theme (static fallbacks / use in AppTheme only)
  static const Color primary = Color(0xFF4ADE80);
  static const Color primaryDark = Color(0xFF16A34A);
  static const Color primaryLight = Color(0xFF86EFAC);

  // Background colors
  static const Color background = Color(0xFF0A1A0A);
  static const Color surface = Color(0xFF122112);
  static const Color surfaceLight = Color(0xFF1D341D);

  // Text colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8B9E8B);
  static const Color textHint = Color(0xFF5A6E5A);

  // Border colors
  static const Color border = Color(0xFF243624);
  static const Color borderFocused = Color(0xFF4ADE80);

  // Status colors
  static const Color success = Color(0xFF4ADE80);
  static const Color error = Color(0xFFF85149);
  static const Color warning = Color(0xFFD29922);
}

// ─── Theme-adaptive color scheme ─────────────────────────────────────────────

class AppColorScheme extends ThemeExtension<AppColorScheme> {
  final Color background;
  final Color surface;
  final Color surfaceLight;
  final Color textPrimary;
  final Color textSecondary;
  final Color textHint;
  final Color border;
  final Color borderFocused;
  final Color primary;
  final Color primaryDark;
  final Color primaryLight;
  final Color success;
  final Color error;
  final Color warning;

  const AppColorScheme({
    required this.background,
    required this.surface,
    required this.surfaceLight,
    required this.textPrimary,
    required this.textSecondary,
    required this.textHint,
    required this.border,
    required this.borderFocused,
    required this.primary,
    required this.primaryDark,
    required this.primaryLight,
    required this.success,
    required this.error,
    required this.warning,
  });

  static const dark = AppColorScheme(
    background: Color(0xFF0A1A0A),
    surface: Color(0xFF122112),
    surfaceLight: Color(0xFF1D341D),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFF8B9E8B),
    textHint: Color(0xFF5A6E5A),
    border: Color(0xFF243624),
    borderFocused: Color(0xFF4ADE80),
    primary: Color(0xFF4ADE80),
    primaryDark: Color(0xFF16A34A),
    primaryLight: Color(0xFF86EFAC),
    success: Color(0xFF4ADE80),
    error: Color(0xFFF85149),
    warning: Color(0xFFD29922),
  );

  static const light = AppColorScheme(
    background: Color(0xFFF0F4F0),
    surface: Color(0xFFFFFFFF),
    surfaceLight: Color(0xFFEDF3ED),
    textPrimary: Color(0xFF0D1B0D),
    textSecondary: Color(0xFF4A5C4A),
    textHint: Color(0xFF8A9E8A),
    border: Color(0xFFD8E8D8),
    borderFocused: Color(0xFF16A34A),
    primary: Color(0xFF16A34A),
    primaryDark: Color(0xFF15803D),
    primaryLight: Color(0xFF4ADE80),
    success: Color(0xFF16A34A),
    error: Color(0xFFF85149),
    warning: Color(0xFFD29922),
  );

  @override
  AppColorScheme copyWith({
    Color? background,
    Color? surface,
    Color? surfaceLight,
    Color? textPrimary,
    Color? textSecondary,
    Color? textHint,
    Color? border,
    Color? borderFocused,
    Color? primary,
    Color? primaryDark,
    Color? primaryLight,
    Color? success,
    Color? error,
    Color? warning,
  }) {
    return AppColorScheme(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceLight: surfaceLight ?? this.surfaceLight,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textHint: textHint ?? this.textHint,
      border: border ?? this.border,
      borderFocused: borderFocused ?? this.borderFocused,
      primary: primary ?? this.primary,
      primaryDark: primaryDark ?? this.primaryDark,
      primaryLight: primaryLight ?? this.primaryLight,
      success: success ?? this.success,
      error: error ?? this.error,
      warning: warning ?? this.warning,
    );
  }

  @override
  AppColorScheme lerp(ThemeExtension<AppColorScheme>? other, double t) {
    if (other is! AppColorScheme) return this;
    return AppColorScheme(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceLight: Color.lerp(surfaceLight, other.surfaceLight, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textHint: Color.lerp(textHint, other.textHint, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderFocused: Color.lerp(borderFocused, other.borderFocused, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      primaryDark: Color.lerp(primaryDark, other.primaryDark, t)!,
      primaryLight: Color.lerp(primaryLight, other.primaryLight, t)!,
      success: Color.lerp(success, other.success, t)!,
      error: Color.lerp(error, other.error, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
    );
  }
}

// ─── Convenience extension ───────────────────────────────────────────────────

extension AppColorsX on BuildContext {
  AppColorScheme get appColors =>
      Theme.of(this).extension<AppColorScheme>()!;
}
