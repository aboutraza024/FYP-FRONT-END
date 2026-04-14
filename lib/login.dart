// login.dart — GLOW UP v2.0
// Premium Crystal Glass login with animated Islamic pattern background
// Logic: COMPLETELY UNCHANGED (auth, validation, navigation identical)
//
// PERF:
//   1. IslamicPatternPainter.shouldRepaint returns false for same progress
//      value — avoids redundant repaints during static frames.
//   2. The glass card uses a single BackdropFilter for the ENTIRE card, not
//      per-field. This is the pattern recommended by Flutter's performance
//      guide for glassmorphism.
//   3. _bgAnimationController spins at 30s/cycle (very slow) — minimises
//      CustomPaint redraws per second while still looking animated.

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_ui_kit.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey           = GlobalKey<FormState>();
  final _emailController   = TextEditingController();
  final _passwordController= TextEditingController();
  final _nameController    = TextEditingController();

  bool _isLoginMode      = true;
  bool _obscurePassword  = true;
  bool _isLoading        = false;

  late AnimationController _bgAnimCtrl;
  late AnimationController _entranceCtrl;

  @override
  void initState() {
    super.initState();
    _bgAnimCtrl = AnimationController(
        duration: const Duration(seconds: 30), vsync: this)
      ..repeat();
    _entranceCtrl = AnimationController(
        duration: const Duration(milliseconds: 1100), vsync: this)
      ..forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _bgAnimCtrl.dispose();
    _entranceCtrl.dispose();
    super.dispose();
  }

  // LOGIC UNCHANGED ─────────────────────────────────────────────────────────
  Future<void> _handleAuthAction() async {
    if (_formKey.currentState!.validate()) {
      HapticFeedback.mediumImpact();
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.pushReplacementNamed(context, '/');
      }
    } else {
      HapticFeedback.vibrate();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // ── Background Gradient ─────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              gradient: isDark
                  ? AppColors.sapphireNight
                  : AppColors.splashGradient,
            ),
          ),

          // ── Animated Islamic geometric pattern ──────────────────────────
          // PERF: RepaintBoundary isolates the pattern painter so it
          // rasterises in its own layer and is not redrawn when the form
          // state changes.
          RepaintBoundary(
  child: AnimatedBuilder(
    animation: _bgAnimCtrl,
    builder: (_, __) => CustomPaint(
      painter: IslamicBackgroundPainter(_bgAnimCtrl.value, isDark: isDark),
      size: Size.infinite,
    ),
  ),
),

          // ── Glass form card ─────────────────────────────────────────────
          Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 40),
              child: FadeTransition(
                opacity: _entranceCtrl,
                child: SlideTransition(
                  position: Tween<Offset>(
                          begin: const Offset(0, 0.08), end: Offset.zero)
                      .animate(CurvedAnimation(
                          parent: _entranceCtrl,
                          curve: Curves.easeOutCubic)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(36),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 450),
                        curve: Curves.easeOutCubic,
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xCC1C1C1E)
                              : const Color(0xF0FFFFFF),
                          borderRadius: BorderRadius.circular(36),
                          border: Border.all(
                              color: AppColors.glassBorderC, width: 1.2),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x22000000),
                              blurRadius: 50,
                              offset: Offset(0, 24),
                            ),
                          ],
                        ),
                        child: _buildFormContent(isDark),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormContent(bool isDark) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 380),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: Form(
        key: _formKey,
        child: Column(
          key: ValueKey<bool>(_isLoginMode),
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Brand header ──────────────────────────────────────────────
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.tealDeep, AppColors.tealSoft],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x40059669),
                    blurRadius: 20,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: const Icon(Icons.mosque_rounded,
                  color: Colors.white, size: 36),
            ),
            const SizedBox(height: 18),
            Text(
              'Sirat-al-Mustaqeem',
              style: GoogleFonts.amiri(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.emeraldBright
                    : AppColors.emeraldDeep,
              ),
            ),
            const SizedBox(height: 4),
            // Gold divider accent
            Container(
              width: 60,
              height: 2,
              decoration: const BoxDecoration(
                gradient: AppColors.goldGradient,
                borderRadius: BorderRadius.all(Radius.circular(1)),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _isLoginMode
                  ? 'Sign in to continue your journey'
                  : 'Join our spiritual community',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: isDark
                    ? Colors.white54
                    : AppColors.inkDark.withOpacity(0.55),
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 30),

            // ── Fields ────────────────────────────────────────────────────
            if (!_isLoginMode) ...[
              GlassTextField(
                controller: _nameController,
                hintText: 'Full Name',
                prefixIcon: Icons.person_outline_rounded,
                isDark: isDark,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Name is required' : null,
              ),
              const SizedBox(height: 14),
            ],

            GlassTextField(
              controller: _emailController,
              hintText: 'Email Address',
              prefixIcon: Icons.alternate_email_rounded,
              isDark: isDark,
              keyboardType: TextInputType.emailAddress,
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Email is required' : null,
            ),
            const SizedBox(height: 14),

            GlassTextField(
              controller: _passwordController,
              hintText: 'Password',
              prefixIcon: Icons.lock_outline_rounded,
              isDark: isDark,
              obscureText: _obscurePassword,
              suffix: GestureDetector(
                onTap: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
                child: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  size: 18,
                  color: Colors.grey,
                ),
              ),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Password is required' : null,
            ),

            if (_isLoginMode)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/forgot-password'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 4, vertical: 4),
                  ),
                  child: Text(
                    'Forgot Password?',
                    style: GoogleFonts.poppins(
                      color: isDark
                          ? AppColors.emeraldBright
                          : AppColors.emeraldDeep,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // ── CTA Button ────────────────────────────────────────────────
            PremiumButton(
              label: _isLoginMode ? 'SIGN IN' : 'CREATE ACCOUNT',
              onPressed: _isLoading ? null : _handleAuthAction,
              isLoading: _isLoading,
            ),

            const SizedBox(height: 22),

            // ── Toggle login / register ───────────────────────────────────
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() => _isLoginMode = !_isLoginMode);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.glassWhite10
                      : AppColors.emeraldDeep.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.glassBorderC),
                ),
                child: Text.rich(
                  TextSpan(
                    text: _isLoginMode ? 'New here? ' : 'Already joined? ',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: isDark ? Colors.white54 : Colors.black45,
                    ),
                    children: [
                      TextSpan(
                        text: _isLoginMode ? 'Create Account' : 'Sign In',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.emeraldBright
                              : AppColors.emeraldDeep,
                          decoration: TextDecoration.underline,
                          decorationColor: isDark
                              ? AppColors.emeraldBright
                              : AppColors.emeraldDeep,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
