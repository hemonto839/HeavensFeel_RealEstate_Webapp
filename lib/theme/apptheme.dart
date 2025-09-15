import 'package:flutter/material.dart';

class AppTheme {
  // Brand colors (yours)
  static const Color brandGreen = Color(0xFF41B06E);
  static const Color brandMint  = Color(0xFF8DECB4);
  static const Color bgLight    = Color(0xFFFDEBC8);

  // Ocean/Teal palette (from image, approximated)
  static const Color oceanDeep  = Color(0xFF0B1E21); // very dark teal
  static const Color ocean      = Color(0xFF10363D); // deep teal
  static const Color sea        = Color(0xFF176D74); // mid teal
  static const Color aqua       = Color(0xFF1FB5B8); // bright aqua
  static const Color mist       = Color(0xFFA8C9D3); // pale blue/grey
  static const Color slate      = Color(0xFF3E5864); // muted slate

  // Dark surfaces
  static const Color darkSurface       = Color(0xFF12272D);
  static const Color darkSurfaceLow    = Color(0xFF0F2227);

  // Material error tokens
  static const Color errorLight            = Color(0xFFBA1A1A);
  static const Color onErrorLight          = Colors.white;
  static const Color errorContainerLight   = Color(0xFFFFDAD6);
  static const Color onErrorContainerLight = Color(0xFF410002);

  static const Color errorDark             = Color(0xFFFFB4AB);
  static const Color onErrorDark           = Color(0xFF690005);
  static const Color errorContainerDark    = Color(0xFF93000A);
  static const Color onErrorContainerDark  = Color(0xFFFFDAD6);

  static const BorderRadius kRadius8  = BorderRadius.all(Radius.circular(8));
  static const BorderRadius kRadius12 = BorderRadius.all(Radius.circular(12));

  // Public themes
  static ThemeData lightTheme = _buildLightTheme();
  static ThemeData darkTheme  = _buildDarkTheme();

  /// ---------------- LIGHT THEME ----------------
  static ThemeData _buildLightTheme() {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: ocean,
      onPrimary: Colors.black,
      primaryContainer: Color(0xFFDAF1F3),
      onPrimaryContainer: Color(0xFF063237),

      secondary: brandGreen,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFD0F1DF),
      onSecondaryContainer: Color(0xFF0F3B25),

      tertiary: aqua,
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFFD1F3F4),
      onTertiaryContainer: Color(0xFF073D40),

      error: errorLight,
      onError: onErrorLight,
      errorContainer: errorContainerLight,
      onErrorContainer: onErrorContainerLight,

      background: bgLight,
      onBackground: Colors.black87,

      surface: Colors.white,
      onSurface: Colors.black87,

      surfaceVariant: Color(0xFFE6EFF2),
      onSurfaceVariant: slate,

      outline: slate,
      outlineVariant: Color(0xFFBFD2D9),

      shadow: Colors.black26,
      scrim: Colors.black54,

      inverseSurface: ocean,
      onInverseSurface: Colors.white,
      inversePrimary: brandMint,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: bgLight,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 2,
        margin: const EdgeInsets.all(8),
        shape: const RoundedRectangleBorder(borderRadius: kRadius12),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: scheme.onSurfaceVariant,
        shape: const RoundedRectangleBorder(borderRadius: kRadius12),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          shape: const RoundedRectangleBorder(borderRadius: kRadius8),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.secondary,
          foregroundColor: scheme.onSecondary,
          shape: const RoundedRectangleBorder(borderRadius: kRadius8),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          side: BorderSide(color: scheme.outline),
          shape: const RoundedRectangleBorder(borderRadius: kRadius8),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceVariant.withOpacity(0.4),
        hintStyle: TextStyle(color: scheme.onSurfaceVariant.withOpacity(0.8)),
        border: _roundedBorder(scheme.outlineVariant),
        enabledBorder: _roundedBorder(scheme.outlineVariant),
        focusedBorder: _roundedBorder(scheme.primary, width: 2),
      ),
    );
  }

  /// ---------------- DARK THEME ----------------
  static ThemeData _buildDarkTheme() {
    const scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: ocean,
      onPrimary: Colors.white,
      primaryContainer: oceanDeep,
      onPrimaryContainer: Colors.white,

      secondary: brandGreen,
      onSecondary: Colors.black,
      secondaryContainer: sea,
      onSecondaryContainer: Colors.white,

      tertiary: aqua,
      onTertiary: Colors.black,
      tertiaryContainer: sea,
      onTertiaryContainer: Colors.white,

      error: errorDark,
      onError: onErrorDark,
      errorContainer: errorContainerDark,
      onErrorContainer: onErrorContainerDark,

      background: oceanDeep,
      onBackground: Colors.white,

      surface: darkSurface,
      onSurface: Colors.white,

      surfaceVariant: darkSurfaceLow,
      onSurfaceVariant: mist,

      outline: slate,
      outlineVariant: Color(0xFF4A6672),

      shadow: Colors.black,
      scrim: Colors.black87,

      inverseSurface: Colors.white,
      onInverseSurface: Colors.black,
      inversePrimary: brandMint,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: oceanDeep,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 2,
        margin: const EdgeInsets.all(8),
        shape: const RoundedRectangleBorder(borderRadius: kRadius12),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: scheme.onSurfaceVariant,
        shape: const RoundedRectangleBorder(borderRadius: kRadius12),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          shape: const RoundedRectangleBorder(borderRadius: kRadius8),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.secondary,
          foregroundColor: scheme.onSecondary,
          shape: const RoundedRectangleBorder(borderRadius: kRadius8),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Color.fromRGBO(54, 228, 15, 1),
          side: BorderSide(color: scheme.outline),
          shape: const RoundedRectangleBorder(borderRadius: kRadius8),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceVariant.withOpacity(0.6),
        hintStyle: TextStyle(color: scheme.onSurfaceVariant.withOpacity(0.8)),
        border: _roundedBorder(scheme.outline),
        enabledBorder: _roundedBorder(scheme.outline),
        focusedBorder: _roundedBorder(Color.fromRGBO(54, 228, 15, 1), width: 2),
        floatingLabelStyle: TextStyle(color: Color.fromRGBO(54, 228, 15, 1)),
      ),
    );
  }

  /// Helper for rounded borders in forms
  static OutlineInputBorder _roundedBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: kRadius8,
      borderSide: BorderSide(color: color, width: width),
    );
  }
}