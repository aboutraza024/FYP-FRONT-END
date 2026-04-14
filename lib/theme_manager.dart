import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SIRAT AL MUSTAQEEM — SINGLE SOURCE OF TRUTH COLOR SYSTEM
//
// ALL screens must use AppColors.* or Theme.of(context).colorScheme.*
// NEVER declare local color constants (kPrimary, kBg, etc.) in any screen file.
// ─────────────────────────────────────────────────────────────────────────────

class AppColors {
  AppColors._();

  // ── Teal-Green Family ────────────────────────────────────────────────────
  static const Color tealDeep    = Color(0xFF0D5C4A);
  static const Color tealPrimary = Color(0xFF0F7B63);
  static const Color tealMed     = Color(0xFF1A9B7B);
  static const Color tealSoft    = Color(0xFF2EBFA0);
  static const Color tealLight   = Color(0xFFCCF0E8);
  static const Color tealMint    = Color(0xFFE6F7F3);

  // Aliases so existing code compiles without changes
  static const Color emeraldDeep    = tealDeep;
  static const Color emeraldPrimary = tealPrimary;
  static const Color emeraldBright  = tealSoft;
  static const Color emeraldLight   = tealLight;
  static const Color emeraldMint    = tealMint;

  // ── Warm Amber / Gold Family ─────────────────────────────────────────────
  static const Color amberDeep    = Color(0xFF8A5C00);
  static const Color amberPrimary = Color(0xFFB07D00);
  static const Color amberMed     = Color(0xFFD4970A);
  static const Color amberLight   = Color(0xFFFFD97A);
  static const Color amberCream   = Color(0xFFFFF4D6);

  // Aliases
  static const Color goldDeep    = amberDeep;
  static const Color goldPrimary = amberPrimary;
  static const Color goldBright  = amberMed;
  static const Color goldLight   = amberLight;
  static const Color goldCream   = amberCream;

  // ── Dark Mode — Warm Charcoal ────────────────────────────────────────────
  static const Color charcoalAbyss   = Color(0xFF141414);
  static const Color charcoalDeep    = Color(0xFF1C1C1E);
  static const Color charcoalMid     = Color(0xFF242426);
  static const Color charcoalPanel   = Color(0xFF2C2C2E);
  static const Color charcoalSurface = Color(0xFF363638);

  // Aliases
  static const Color sapphireAbyss   = charcoalAbyss;
  static const Color sapphireDeep    = charcoalDeep;
  static const Color sapphireMid     = charcoalMid;
  static const Color sapphirePanel   = charcoalPanel;
  static const Color sapphireSurface = charcoalSurface;

  // ── Light Mode Surfaces ──────────────────────────────────────────────────
  static const Color snowWhite  = Color(0xFFFAFAFA);
  static const Color softWhite  = Color(0xFFF4F4F5);
  static const Color paleGrey   = Color(0xFFEAEAEC);

  static const Color parchment     = snowWhite;
  static const Color parchmentDeep = softWhite;

  // ── Text ─────────────────────────────────────────────────────────────────
  static const Color inkDark    = Color(0xFF1A1A1A);
  static const Color inkMid     = Color(0xFF3A3A3C);
  static const Color inkSoft    = Color(0xFF6B6B6E);
  static const Color inkOnDark  = Color(0xFFF2F2F7);
  static const Color inkSubDark = Color(0xFFAEAEB2);

  // ── Glass / Overlay ───────────────────────────────────────────────────────
  static const Color glassWhite10 = Color(0x1AFFFFFF);
  static const Color glassWhite15 = Color(0x26FFFFFF);
  static const Color glassWhite20 = Color(0x33FFFFFF);
  static const Color glassBorderC = Color(0x20FFFFFF);
  static const Color glassBorderLight = Color(0x25000000);

  // ── Feature Card Gradients — BRANDED, used in BOTH home & utility grids ──
  static const LinearGradient cardQibla = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [Color(0xFFB07D00), Color(0xFF8A5C00)], // Gold — direction/guidance
  );
  static const LinearGradient cardCalendar = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [Color(0xFF1565A8), Color(0xFF0D4A82)], // Royal blue — time/dates
  );
  static const LinearGradient cardTasbeeh = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [Color(0xFF0D7A62), Color(0xFF0A5C48)], // Teal-green — dhikr/worship
  );
  static const LinearGradient cardDuas = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [Color(0xFF6B3FA0), Color(0xFF4A2A72)], // Indigo/purple — supplication
  );
  static const LinearGradient cardMiracles = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [Color(0xFF9B5C00), Color(0xFF7A4500)], // Warm amber — wonder/signs
  );
  static const LinearGradient cardNames = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [Color(0xFF7B2D8B), Color(0xFF5A1E68)], // Deep violet — divine names
  );

  // ── Home screen feature cards ─────────────────────────────────────────────
  static const LinearGradient cardHadith = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [Color(0xFF0D7A62), Color(0xFF0A5C48)],
  );
  static const LinearGradient cardQuran = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [Color(0xFF1565A8), Color(0xFF0D4A82)],
  );
  static const LinearGradient cardPrayer = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [Color(0xFF6B3FA0), Color(0xFF4A2A72)],
  );
  static const LinearGradient cardUtils = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [Color(0xFF9B5C00), Color(0xFF7A4500)],
  );

  // ── Gradient Backgrounds ─────────────────────────────────────────────────
  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [Color(0xFF0A4A3A), Color(0xFF0D7B62), Color(0xFF1AB590)],
    stops: [0.0, 0.5, 1.0],
  );
  static const LinearGradient emeraldGradient = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [Color(0xFF0D7B62), Color(0xFF0A5248)],
  );
  static const LinearGradient sapphireNight = LinearGradient(
    begin: Alignment.topCenter, end: Alignment.bottomCenter,
    colors: [Color(0xFF141414), Color(0xFF1C1C1E), Color(0xFF242426)],
    stops: [0.0, 0.5, 1.0],
  );
  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [Color(0xFF8A5C00), Color(0xFFB07D00), Color(0xFFD4970A)],
    stops: [0.0, 0.5, 1.0],
  );
  static const LinearGradient navBarGradient = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [Color(0xFF0A4A3A), Color(0xFF0D5C4A)],
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// ISLAMIC TYPOGRAPHY SCALE
// Use these constants everywhere for consistent text sizing.
// ─────────────────────────────────────────────────────────────────────────────
class AppTextScale {
  AppTextScale._();
  static const double arabicAyah      = 24.0; // Main Quranic Arabic text
  static const double arabicTitle     = 20.0; // Arabic section headers
  static const double arabicSubtitle  = 16.0; // Arabic labels, hadith arabic
  static const double arabicSmall     = 14.0; // Small arabic accents
  static const double uiHeading       = 22.0; // Screen titles
  static const double uiSubheading    = 18.0; // Card titles
  static const double uiBody          = 15.0; // Body text
  static const double uiCaption       = 13.0; // Captions, labels
  static const double uiMicro         = 11.0; // Badges, chips
}

// ─────────────────────────────────────────────────────────────────────────────
// SPACING TOKENS — Base-8 grid. Use ONLY these values.
// ─────────────────────────────────────────────────────────────────────────────
class AppSpacing {
  AppSpacing._();
  static const double xs  = 4.0;
  static const double sm  = 8.0;
  static const double md  = 16.0;
  static const double lg  = 24.0;
  static const double xl  = 32.0;
  static const double xxl = 48.0;
  static const double screenPadding = 20.0;
  static const double cardPadding   = 20.0;
}

// ─────────────────────────────────────────────────────────────────────────────
// BORDER RADIUS TOKENS
// ─────────────────────────────────────────────────────────────────────────────
class AppRadius {
  AppRadius._();
  static const double button = 24.0;
  static const double card   = 24.0;
  static const double input  = 16.0;
  static const double chip   = 12.0;
  static const double badge  = 8.0;
}

// ─────────────────────────────────────────────────────────────────────────────
// THEME EXTENSION
// ─────────────────────────────────────────────────────────────────────────────
@immutable
class IslamicColors extends ThemeExtension<IslamicColors> {
  final Color emerald;
  final Color gold;
  final Color mint;
  final Color sapphire;
  final Color cardSurface;
  final Color glassBorder;

  const IslamicColors({
    required this.emerald,
    required this.gold,
    required this.mint,
    required this.sapphire,
    required this.cardSurface,
    required this.glassBorder,
  });

  @override
  IslamicColors copyWith({Color? emerald, Color? gold, Color? mint,
      Color? sapphire, Color? cardSurface, Color? glassBorder}) {
    return IslamicColors(
      emerald:     emerald     ?? this.emerald,
      gold:        gold        ?? this.gold,
      mint:        mint        ?? this.mint,
      sapphire:    sapphire    ?? this.sapphire,
      cardSurface: cardSurface ?? this.cardSurface,
      glassBorder: glassBorder ?? this.glassBorder,
    );
  }

  @override
  IslamicColors lerp(ThemeExtension<IslamicColors>? other, double t) {
    if (other is! IslamicColors) return this;
    return IslamicColors(
      emerald:     Color.lerp(emerald,     other.emerald,     t)!,
      gold:        Color.lerp(gold,        other.gold,        t)!,
      mint:        Color.lerp(mint,        other.mint,        t)!,
      sapphire:    Color.lerp(sapphire,    other.sapphire,    t)!,
      cardSurface: Color.lerp(cardSurface, other.cardSurface, t)!,
      glassBorder: Color.lerp(glassBorder, other.glassBorder, t)!,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SYSTEM UI OVERLAY
// ─────────────────────────────────────────────────────────────────────────────
const SystemUiOverlayStyle kLightOverlay = SystemUiOverlayStyle(
  statusBarColor: Colors.transparent,
  statusBarIconBrightness: Brightness.light,
  systemNavigationBarColor: Color(0xFF0D7B62),
  systemNavigationBarIconBrightness: Brightness.light,
);

const SystemUiOverlayStyle kDarkOverlay = SystemUiOverlayStyle(
  statusBarColor: Colors.transparent,
  statusBarIconBrightness: Brightness.light,
  systemNavigationBarColor: Color(0xFF141414),
  systemNavigationBarIconBrightness: Brightness.light,
);

// ─────────────────────────────────────────────────────────────────────────────
// THEME MANAGER
// ─────────────────────────────────────────────────────────────────────────────
class ThemeManager extends ChangeNotifier {
  static final ThemeManager _instance = ThemeManager._internal();
  factory ThemeManager() => _instance;
  ThemeManager._internal();

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;
  bool get isDark => _themeMode == ThemeMode.dark;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkMode');
    if (isDark != null) {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      _applySystemUi();
      notifyListeners();
    }
  }

  void toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    _applySystemUi();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _themeMode == ThemeMode.dark);
  }

  void _applySystemUi() {
    SystemChrome.setSystemUIOverlayStyle(
      _themeMode == ThemeMode.dark ? kDarkOverlay : kLightOverlay,
    );
  }

  // ── LIGHT THEME ────────────────────────────────────────────────────────────
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary:              AppColors.tealPrimary,
      onPrimary:            Colors.white,
      primaryContainer:     AppColors.tealLight,
      onPrimaryContainer:   AppColors.tealDeep,
      secondary:            AppColors.amberPrimary,
      onSecondary:          Colors.white,
      secondaryContainer:   AppColors.amberCream,
      onSecondaryContainer: AppColors.amberDeep,
      surface:              AppColors.snowWhite,
      onSurface:            AppColors.inkDark,
      surfaceContainerHighest: AppColors.softWhite,
      error:                Color(0xFFD32F2F),
      onError:              Colors.white,
    ),
    scaffoldBackgroundColor: AppColors.snowWhite,
    extensions: const <ThemeExtension<dynamic>>[
      IslamicColors(
        emerald:     AppColors.tealPrimary,
        gold:        AppColors.amberPrimary,
        mint:        AppColors.tealLight,
        sapphire:    AppColors.inkMid,
        cardSurface: Colors.white,
        glassBorder: AppColors.glassBorderLight,
      ),
    ],
  );

  // ── DARK THEME ─────────────────────────────────────────────────────────────
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary:              AppColors.tealSoft,
      onPrimary:            AppColors.charcoalDeep,
      primaryContainer:     AppColors.charcoalPanel,
      onPrimaryContainer:   AppColors.tealSoft,
      secondary:            AppColors.amberMed,
      onSecondary:          AppColors.charcoalAbyss,
      secondaryContainer:   AppColors.amberDeep,
      onSecondaryContainer: AppColors.amberLight,
      surface:              AppColors.charcoalDeep,
      onSurface:            AppColors.inkOnDark,
      surfaceContainerHighest: AppColors.charcoalPanel,
      error:                Color(0xFFEF5350),
      onError:              Colors.white,
    ),
    scaffoldBackgroundColor: AppColors.charcoalAbyss,
    extensions: const <ThemeExtension<dynamic>>[
      IslamicColors(
        emerald:     AppColors.tealSoft,
        gold:        AppColors.amberMed,
        mint:        AppColors.charcoalPanel,
        sapphire:    AppColors.charcoalMid,
        cardSurface: AppColors.charcoalPanel,
        glassBorder: AppColors.glassBorderC,
      ),
    ],
  );
}
