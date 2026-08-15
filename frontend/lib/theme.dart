import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Global theme brightness flag. Screens read it through [AppColors]
/// getters, and [AppTheme] builds the matching [ThemeData].
class ThemeController {
  ThemeController._();
  static const _key = 'theme_dark';
  static final ValueNotifier<bool> isDark = ValueNotifier(false);

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    isDark.value = prefs.getBool(_key) ?? false;
  }

  static Future<void> setDark(bool value) async {
    isDark.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, value);
  }
}

class AppColors {
  static bool get _dark => ThemeController.isDark.value;

  // Invoiz palette: deep teal + warm amber. Warm, trustworthy, distinctive.
  static Color get primary => _dark ? const Color(0xFF5FB8C5) : const Color(0xFF16697A);
  static Color get primaryDark => _dark ? const Color(0xFF2E7B88) : const Color(0xFF0E4A57);
  static Color get secondary => _dark ? const Color(0xFFFFC53D) : const Color(0xFFF0A202);
  static Color get accent => _dark ? const Color(0xFF16363E) : const Color(0xFFEAF4F3);
  static Color get background => _dark ? const Color(0xFF11171B) : const Color(0xFFF7F6F2);
  static Color get card => _dark ? const Color(0xFF1B2429) : Colors.white;
  static Color get textPrimary => _dark ? const Color(0xFFECEFF1) : const Color(0xFF1B1B1E);
  static Color get textSecondary => _dark ? const Color(0xFFA8B4BC) : const Color(0xFF6E6E73);
  static Color get success => _dark ? const Color(0xFF4CAF7D) : const Color(0xFF2E8B57);
  static Color get warning => _dark ? const Color(0xFFF07B58) : const Color(0xFFE05A33);
  static Color get gold => _dark ? const Color(0xFFFFC53D) : const Color(0xFFF5A623);
  static Color get border => _dark ? const Color(0xFF2C3A42) : const Color(0xFFE8E6E0);
  static Color get surfaceSoft => _dark ? const Color(0xFF243038) : const Color(0xFFF0EEE9);
}

class AppTheme {
  static ThemeData get light => _build();
  static ThemeData get dark => _build();

  static ThemeData _build() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.card,
      brightness: ThemeController.isDark.value ? Brightness.dark : Brightness.light,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Segoe UI',
    );

    return base.copyWith(
      textTheme: base.textTheme.copyWith(
        displaySmall: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.5),
        headlineSmall: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.3),
        titleLarge: const TextStyle(fontWeight: FontWeight.w600),
        titleMedium: const TextStyle(fontWeight: FontWeight.w600),
        bodyMedium: const TextStyle(height: 1.4),
        labelLarge: const TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.2),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.card,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: AppColors.border),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(64, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: BorderSide(color: AppColors.primary),
          minimumSize: const Size(64, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceSoft,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: TextStyle(color: AppColors.textSecondary),
        labelStyle: TextStyle(color: AppColors.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.card,
        selectedColor: AppColors.accent,
        side: BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        labelStyle: TextStyle(fontSize: 13, color: AppColors.textPrimary),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.card,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dividerTheme: DividerThemeData(color: AppColors.border, thickness: 1),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: AppColors.primary),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.card,
        indicatorColor: AppColors.accent,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }
}