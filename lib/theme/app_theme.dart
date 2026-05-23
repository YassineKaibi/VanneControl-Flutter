import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppColors {
  static const Color primaryGreen = Color(0xFF156F35);
  static const Color honeydew = Color(0xFFDFEAD8);
  static const Color black = Color(0xFF101010);
  static const Color white = Color(0xFFFFFFFE);
  static const Color grayDisabled = Color(0xFFBDBDBD);
  static const Color grayIcon = Color(0xFF757575);
  static const Color grey = Color(0xFFF0F0F0);
  static const Color subtitleGray = Color(0xFF4C4E4E);
  static const Color descriptionGray = Color(0xFF666666);
  static const Color placeholderGray = Color(0xFF999999);
  static const Color separatorGray = Color(0xFF888888);
  static const Color editTextBorder = Color(0xFFD3D3D3);
  static const Color divider = Color(0xFFEEEEEE);
  static const Color valveInactiveRed = Color(0xFFFF6B6B);
  static const Color deleteRed = Color(0xFFD32F2F);
  static const Color lightGrayBg = Color(0xFFF5F5F5);
  static const Color tabUnselectedBg = Color(0xFFF0F0F0);
  static const Color veryLightText = Color(0xFFCCCCCC);

  // Stat card greens
  static const Color statDarkGreen = Color(0xFF257734);
  static const Color statMediumGreen = Color(0xFF52A433);
  static const Color statLightGreen = Color(0xFF91BC21);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: AppColors.primaryGreen,
        onPrimary: AppColors.white,
        secondary: AppColors.honeydew,
        onSecondary: AppColors.black,
        surface: AppColors.white,
        onSurface: AppColors.black,
        outline: AppColors.grayDisabled,
      ),
      scaffoldBackgroundColor: AppColors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.black,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: AppColors.white,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        titleTextStyle: TextStyle(
          color: AppColors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        color: AppColors.white,
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.black,
          side: const BorderSide(color: AppColors.black, width: 2),
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2),
          ),
          padding: const EdgeInsets.all(10),
          backgroundColor: Colors.transparent,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.black,
          elevation: 0,
          minimumSize: const Size(double.infinity, 50),
          side: const BorderSide(color: AppColors.black, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.transparent,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: const BorderSide(color: AppColors.editTextBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: const BorderSide(color: AppColors.editTextBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1),
        ),
        contentPadding: const EdgeInsets.all(12),
        hintStyle: const TextStyle(color: AppColors.placeholderGray),
        constraints: const BoxConstraints(minHeight: 50),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: AppColors.white,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.white,
        selectedColor: AppColors.white,
        labelStyle: const TextStyle(fontSize: 14, color: AppColors.black),
        secondaryLabelStyle: const TextStyle(fontSize: 14, color: AppColors.primaryGreen),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        side: WidgetStateBorderSide.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const BorderSide(color: AppColors.primaryGreen, width: 1.5);
          }
          return const BorderSide(color: AppColors.editTextBorder, width: 1);
        }),
        showCheckmark: false,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryGreen;
          }
          return AppColors.grayDisabled;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.honeydew;
          }
          return AppColors.grey;
        }),
      ),
    );
  }
}
