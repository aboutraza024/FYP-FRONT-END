// ─────────────────────────────────────────────────────────────────────────────
// SIRAT AL MUSTAQEEM — SHARED UI KIT v3.0
//
// NEW in this version:
//   • IslamicEmptyState  — branded no-results/empty screen widget
//   • AIThinkingDots     — animated 3-dot thinking indicator (replaces CPI)
//   • IslamicScreenAppBar — consistent top app bar for all screens
//   • All widgets use AppColors/AppSpacing/AppRadius tokens exclusively
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme_manager.dart';
export 'theme_manager.dart';
import 'dart:math' as math;

// ── Shared shadow tokens ─────────────────────────────────────────────────────
const List<BoxShadow> kCardShadowLight = [
  BoxShadow(color: Color(0x1A000000), blurRadius: 24, offset: Offset(0, 8)),
  BoxShadow(color: Color(0x0D000000), blurRadius: 6,  offset: Offset(0, 2)),
];

const List<BoxShadow> kCardShadowDark = [
  BoxShadow(color: Color(0x40000000), blurRadius: 32, offset: Offset(0, 12)),
  BoxShadow(color: Color(0x1A000000), blurRadius: 8,  offset: Offset(0, 3)),
];

const List<BoxShadow> kGlowEmerald = [
  BoxShadow(color: Color(0x380D7B62), blurRadius: 20, spreadRadius: 2),
];

const List<BoxShadow> kGlowGold = [
  BoxShadow(color: Color(0x40D97706), blurRadius: 20, spreadRadius: 2),
];

// ─────────────────────────────────────────────────────────────────────────────
// GRADIENT BACKGROUND
// ─────────────────────────────────────────────────────────────────────────────
class GradientBackground extends StatelessWidget {
  final bool isDark;
  final Widget child;
  const GradientBackground({super.key, required this.isDark, required this.child});

  static const _lightGrad = AppColors.emeraldGradient;
  static const _darkGrad  = AppColors.sapphireNight;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: isDark ? _darkGrad : _lightGrad),
      child: child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GLASS CARD
// ─────────────────────────────────────────────────────────────────────────────
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final double blurSigma;
  final Color? backgroundColor;
  final Color? borderColor;
  final List<BoxShadow>? boxShadow;
  final Gradient? gradient;
  final double borderWidth;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.blurSigma = 0,
    this.backgroundColor,
    this.borderColor,
    this.boxShadow,
    this.gradient,
    this.borderWidth = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final br = borderRadius ?? BorderRadius.circular(AppRadius.card);

    final decoration = BoxDecoration(
      gradient: gradient,
      color: backgroundColor ??
          (isDark ? AppColors.glassWhite10 : AppColors.glassWhite20),
      borderRadius: br,
      border: Border.all(
        color: borderColor ?? AppColors.glassBorderC,
        width: borderWidth,
      ),
      boxShadow: boxShadow ?? (isDark ? kCardShadowDark : kCardShadowLight),
    );

    final inner = Container(
      padding: padding ?? const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: decoration,
      child: child,
    );

    if (blurSigma <= 0) {
      return ClipRRect(borderRadius: br, child: inner);
    }

    return ClipRRect(
      borderRadius: br,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: inner,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GOLD DIVIDER
// ─────────────────────────────────────────────────────────────────────────────
class GoldDivider extends StatelessWidget {
  final double indent;
  const GoldDivider({super.key, this.indent = 40});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: indent),
      child: Container(
        height: 1,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.transparent, AppColors.goldPrimary, Colors.transparent],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION HEADER
// ─────────────────────────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? arabicTitle;
  final bool onDark;
  const SectionHeader({super.key, required this.title, this.arabicTitle, this.onDark = true});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 28,
          decoration: const BoxDecoration(
            gradient: AppColors.goldGradient,
            borderRadius: BorderRadius.all(Radius.circular(2)),
          ),
        ),
        const SizedBox(width: AppSpacing.sm + 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: AppTextScale.uiHeading,
                fontWeight: FontWeight.bold,
                color: onDark ? Colors.white : AppColors.inkDark,
                letterSpacing: 0.2,
              ),
            ),
            if (arabicTitle != null)
              Text(
                arabicTitle!,
                style: GoogleFonts.amiri(
                  fontSize: AppTextScale.arabicSmall,
                  color: onDark
                      ? AppColors.goldLight.withOpacity(0.8)
                      : AppColors.goldDeep,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ISLAMIC SCREEN APP BAR — consistent header for all screens
// Replaces ad-hoc AppBar implementations in prayer, hadith, quran screens.
// ─────────────────────────────────────────────────────────────────────────────
class IslamicScreenAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? arabicSubtitle;
  final List<Widget>? actions;
  final bool showBack;
  final VoidCallback? onBack;

  const IslamicScreenAppBar({
    super.key,
    required this.title,
    this.arabicSubtitle,
    this.actions,
    this.showBack = true,
    this.onBack,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A4A3A), Color(0xFF0D7B62)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      leading: showBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 20),
              onPressed: onBack ?? () => Navigator.maybePop(context),
            )
          : null,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: AppTextScale.uiSubheading,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          if (arabicSubtitle != null)
            Text(
              arabicSubtitle!,
              style: GoogleFonts.amiri(
                fontSize: AppTextScale.arabicSmall,
                color: AppColors.goldLight.withOpacity(0.85),
              ),
            ),
        ],
      ),
      actions: actions,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FLOATING NAV BAR
// ─────────────────────────────────────────────────────────────────────────────
class FloatingNavBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const FloatingNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<FloatingNavBar> createState() => _FloatingNavBarState();
}

class _FloatingNavBarState extends State<FloatingNavBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _indicatorController;
  late Animation<double> _indicatorAnim;
  int _prevIndex = 0;

  static const _items = [
    _NavItem(icon: Icons.home_rounded,         label: 'Home'),
    _NavItem(icon: Icons.auto_stories_rounded, label: 'Hadith'),
    _NavItem(icon: Icons.menu_book_rounded,    label: 'Quran'),
    _NavItem(icon: Icons.access_time_rounded,  label: 'Prayer'),
    _NavItem(icon: Icons.grid_view_rounded,    label: 'Utils'),
  ];

  @override
  void initState() {
    super.initState();
    _prevIndex = widget.currentIndex;
    _indicatorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _indicatorAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _indicatorController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void didUpdateWidget(FloatingNavBar old) {
    super.didUpdateWidget(old);
    if (old.currentIndex != widget.currentIndex) {
      _prevIndex = old.currentIndex;
      _indicatorController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _indicatorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final double systemBottomPadding = MediaQuery.of(context).padding.bottom;

    return RepaintBoundary(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, systemBottomPadding > 0 ? systemBottomPadding : 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              height: 68,
              decoration: BoxDecoration(
                gradient: isDark
                    ? const LinearGradient(
                        colors: [Color(0xE8141414), Color(0xE81C1C1E)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : const LinearGradient(
                        colors: [Color(0xE60A4A3A), Color(0xE60D7B62)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: isDark
                      ? AppColors.glassWhite10
                      : const Color(0x33FFFFFF),
                  width: 1,
                ),
                boxShadow: isDark
                    ? const [BoxShadow(color: Color(0x66000000), blurRadius: 20, offset: Offset(0, 8))]
                    : const [BoxShadow(color: Color(0x280D7B62), blurRadius: 20, offset: Offset(0, 8))],
              ),
              child: Stack(
                children: [
                  LayoutBuilder(builder: (context, constraints) {
                    final itemWidth = constraints.maxWidth / _items.length;
                    return AnimatedBuilder(
                      animation: _indicatorAnim,
                      builder: (context, _) {
                        final from = _prevIndex * itemWidth;
                        final to   = widget.currentIndex * itemWidth;
                        final pos  = lerpDouble(from, to, _indicatorAnim.value)!;
                        return Positioned(
                          left: pos + 6,
                          top: 6,
                          width: itemWidth - 12,
                          height: 56,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.tealPrimary, AppColors.tealSoft],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x380D7B62),
                                  blurRadius: 12,
                                  spreadRadius: 1,
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }),
                  Row(
                    children: List.generate(_items.length, (i) {
                      final isSelected = i == widget.currentIndex;
                      return Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            widget.onTap(i);
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                child: Icon(
                                  _items[i].icon,
                                  key: ValueKey(isSelected),
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.55),
                                  size: isSelected ? 22 : 20,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _items[i].label,
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w400,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.5),
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

// ─────────────────────────────────────────────────────────────────────────────
// AI THINKING DOTS — replaces CircularProgressIndicator in chat screens
// Three animated dots that pulse in a staggered sequence.
// ─────────────────────────────────────────────────────────────────────────────
class AIThinkingDots extends StatefulWidget {
  final Color? color;
  const AIThinkingDots({super.key, this.color});

  @override
  State<AIThinkingDots> createState() => _AIThinkingDotsState();
}

class _AIThinkingDotsState extends State<AIThinkingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dotColor = widget.color ?? AppColors.tealSoft;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final start = i * 0.2;
        final end   = start + 0.4;
        return AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) {
            final t = CurvedAnimation(
              parent: _ctrl,
              curve: Interval(start, end.clamp(0.0, 1.0), curve: Curves.easeInOut),
            ).value;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: 7,
              height: 7 + (t * 5),
              decoration: BoxDecoration(
                color: dotColor.withOpacity(0.4 + t * 0.6),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          },
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ISLAMIC EMPTY STATE — branded no-results widget
// Use on: Hadith search, Quran search, Dua search when results are empty.
// ─────────────────────────────────────────────────────────────────────────────
class IslamicEmptyState extends StatelessWidget {
  final String message;
  final String? arabicMessage;
  final IconData icon;

  const IslamicEmptyState({
    super.key,
    this.message = 'No results found',
    this.arabicMessage = 'لا توجد نتائج',
    this.icon = Icons.mosque_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Opacity(
              opacity: 0.12,
              child: Icon(
                icon,
                size: 96,
                color: isDark ? AppColors.tealSoft : AppColors.tealDeep,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              arabicMessage ?? '',
              style: GoogleFonts.amiri(
                fontSize: AppTextScale.arabicSubtitle,
                color: AppColors.goldPrimary.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: AppTextScale.uiCaption,
                color: isDark ? AppColors.inkSubDark : AppColors.inkSoft,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PREMIUM INPUT FIELD
// ─────────────────────────────────────────────────────────────────────────────
class GlassTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final bool obscureText;
  final Widget? suffix;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool isDark;

  const GlassTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.obscureText = false,
    this.suffix,
    this.validator,
    this.keyboardType,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(
        color: isDark ? Colors.white : AppColors.inkDark,
        fontSize: AppTextScale.uiBody,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.poppins(
          color: isDark ? Colors.white38 : Colors.black38,
          fontSize: AppTextScale.uiCaption + 1,
        ),
        prefixIcon: Icon(prefixIcon,
            color: isDark ? AppColors.emeraldMint : AppColors.emeraldDeep,
            size: 20),
        suffix: suffix,
        filled: true,
        fillColor: isDark ? AppColors.glassWhite10 : const Color(0x0F065F46),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: BorderSide(
              color: isDark ? AppColors.glassBorderC : const Color(0x33059669)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: BorderSide(
              color: isDark ? AppColors.glassBorderC : const Color(0x33059669)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: const BorderSide(color: AppColors.emeraldBright, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: const BorderSide(color: Color(0xFFDC2626)),
        ),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.md),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PREMIUM BUTTON
// ─────────────────────────────────────────────────────────────────────────────
class PremiumButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Gradient? gradient;
  final double height;

  const PremiumButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.gradient,
    this.height = 56,
  });

  @override
  Widget build(BuildContext context) {
    final grad = gradient ??
        const LinearGradient(
          colors: [AppColors.tealPrimary, AppColors.tealSoft],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        );

    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: onPressed == null ? null : grad,
        color: onPressed == null ? Colors.grey.withOpacity(0.3) : null,
        borderRadius: BorderRadius.circular(AppRadius.input),
        boxShadow: onPressed == null
            ? null
            : const [
                BoxShadow(
                  color: Color(0x33059669),
                  blurRadius: 16,
                  offset: Offset(0, 6),
                )
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.input),
          onTap: isLoading ? null : onPressed,
          child: Center(
            child: isLoading
                ? const AIThinkingDots(color: Colors.white)
                : Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: AppTextScale.uiBody + 1,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STAGGER LIST WRAPPER
// ─────────────────────────────────────────────────────────────────────────────
class StaggerEntry extends StatelessWidget {
  final AnimationController controller;
  final int index;
  final int total;
  final Widget child;

  const StaggerEntry({
    super.key,
    required this.controller,
    required this.index,
    required this.total,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final start = (index / (total + 1)).clamp(0.0, 0.9);
    final end   = ((index + 1) / (total + 1) + 0.1).clamp(0.0, 1.0);
    final curve = CurvedAnimation(
      parent: controller,
      curve: Interval(start, end, curve: Curves.easeOutBack),
    );

    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: controller, curve: Interval(start, end)),
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.25),
          end: Offset.zero,
        ).animate(curve),
        child: child,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GOLD BADGE
// ─────────────────────────────────────────────────────────────────────────────
class GoldBadge extends StatelessWidget {
  final String text;
  const GoldBadge(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.goldDeep, AppColors.goldBright],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Color(0x40D97706), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: AppTextScale.uiMicro,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ISLAMIC BACKGROUND PAINTER
// ─────────────────────────────────────────────────────────────────────────────
class IslamicBackgroundPainter extends CustomPainter {
  final double progress;
  final bool isDark;

  const IslamicBackgroundPainter(this.progress, {required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    // Determine colors based on theme
    final Color primaryColor = isDark ? const Color(0xFF2EBFA0) : const Color(0xFFD4970A);
    
    final Paint fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = primaryColor.withOpacity(isDark ? 0.04 : 0.03);

    final Paint linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = primaryColor.withOpacity(isDark ? 0.12 : 0.08);

    // 1. Draw the Mosque Silhouette at the bottom
    _drawMosque(canvas, size, fillPaint, linePaint);

    // 2. Draw the Crescent Moon (Hilal)
    _drawCrescent(canvas, size, linePaint);

    // 3. Draw Floating Rub el Hizb (8-pointed stars)
    _drawFloatingStars(canvas, size, linePaint);
  }

  void _drawMosque(Canvas canvas, Size size, Paint fill, Paint stroke) {
    final path = Path();
    double w = size.width;
    double h = size.height;

    // Start from bottom left
    path.moveTo(0, h);
    path.lineTo(0, h * 0.92);
    
    // Left Minaret
    path.lineTo(w * 0.1, h * 0.92);
    path.lineTo(w * 0.1, h * 0.75); 
    path.lineTo(w * 0.12, h * 0.72); // Pointy top
    path.lineTo(w * 0.14, h * 0.75);
    path.lineTo(w * 0.14, h * 0.92);

    // Side Dome (Left)
    path.lineTo(w * 0.25, h * 0.92);
    path.quadraticBezierTo(w * 0.32, h * 0.82, w * 0.40, h * 0.92);

    // Main Central Dome
    path.lineTo(w * 0.40, h * 0.92);
    path.arcToPoint(
      Offset(w * 0.60, h * 0.92),
      radius: Radius.circular(w * 0.15),
      clockwise: true,
    );

    // Side Dome (Right)
    path.quadraticBezierTo(w * 0.68, h * 0.82, w * 0.75, h * 0.92);

    // Right Minaret
    path.lineTo(w * 0.86, h * 0.92);
    path.lineTo(w * 0.86, h * 0.75);
    path.lineTo(w * 0.88, h * 0.72);
    path.lineTo(w * 0.90, h * 0.75);
    path.lineTo(w * 0.90, h * 0.92);
    
    path.lineTo(w, h * 0.92);
    path.lineTo(w, h);
    path.close();

    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
  }

  void _drawCrescent(Canvas canvas, Size size, Paint paint) {
    final Offset center = Offset(size.width * 0.82, size.height * 0.12);
    const double radius = 22.0;

    // Correct way to use Path.combine
    final Path outerCircle = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius));
    
    final Path innerCircle = Path()
      ..addOval(Rect.fromCircle(center: center.translate(-8, -4), radius: radius));

    final Path moon = Path.combine(
      PathOperation.difference,
      outerCircle,
      innerCircle,
    );
    
    canvas.drawPath(moon, paint);
  }

  void _drawFloatingStars(Canvas canvas, Size size, Paint paint) {
    final List<Offset> positions = [
      Offset(size.width * 0.15, size.height * 0.20),
      Offset(size.width * 0.50, size.height * 0.08),
      Offset(size.width * 0.20, size.height * 0.50),
      Offset(size.width * 0.85, size.height * 0.40),
      Offset(size.width * 0.40, size.height * 0.65),
    ];

    for (int i = 0; i < positions.length; i++) {
      // Create a floating animation effect
      double yOffset = math.sin(progress * 2 * math.pi + i) * 12;
      _drawRubElHizb(
        canvas, 
        positions[i].translate(0, yOffset), 
        14.0 + (i * 4), 
        paint, 
        (progress * 0.4) + i
      );
    }
  }

  void _drawRubElHizb(Canvas canvas, Offset center, double radius, Paint paint, double rotation) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    
    final Rect rect = Rect.fromCenter(center: Offset.zero, width: radius * 2, height: radius * 2);
    
    // Draw two overlapping squares rotated by 45 degrees
    canvas.drawRect(rect, paint);
    canvas.save();
    canvas.rotate(math.pi / 4);
    canvas.drawRect(rect, paint);
    canvas.restore();
    
    // Optional: add a small circle in the middle for more detail
    canvas.drawCircle(Offset.zero, radius * 0.3, paint);
    
    canvas.restore();
  }

  @override
  bool shouldRepaint(IslamicBackgroundPainter old) =>
      old.progress != progress || old.isDark != isDark;
}