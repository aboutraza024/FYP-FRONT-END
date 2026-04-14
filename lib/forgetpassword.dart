import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'app_ui_kit.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;
  bool _isLoading = false;

  late AnimationController _patternController;
  late AnimationController _entranceController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _patternController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat();

    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..forward();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _patternController.dispose();
    _entranceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  // LOGIC UNCHANGED ──────────────────────────────────────────────────────────
  Future<void> _handleResetPassword() async {
    if (_formKey.currentState!.validate()) {
      HapticFeedback.mediumImpact();
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() {
          _isLoading = false;
          _emailSent = true;
        });
        HapticFeedback.lightImpact();
      }
    } else {
      HapticFeedback.vibrate();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Accent colour adapts per theme for readability
    final accentColor = isDark ? AppColors.tealSoft : AppColors.tealDeep;

    return Scaffold(
      body: Stack(
        children: [
          // ── 1. Background gradient ──────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              gradient: isDark
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF141414),
                        Color(0xFF1C1C1E),
                        Color(0xFF242426),
                      ],
                    )
                  : const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF0A4A3A),
                        Color(0xFF0D7B62),
                        Color(0xFF1AB590),
                      ],
                    ),
            ),
          ),

          // ── 2. Animated Islamic background pattern ──────────────────────
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _patternController,
              builder: (context, child) => CustomPaint(
                painter: IslamicBackgroundPainter(
                  _patternController.value,
                  isDark: isDark,
                ),
                size: Size.infinite,
              ),
            ),
          ),

          // ── 3. Back button ──────────────────────────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 15,
            child: FadeTransition(
              opacity: _entranceController,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 24),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // ── 4. Glass card ───────────────────────────────────────────────
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: FadeTransition(
                  opacity: _entranceController,
                  child: SlideTransition(
                    position: Tween<Offset>(
                            begin: const Offset(0, 0.1), end: Offset.zero)
                        .animate(CurvedAnimation(
                            parent: _entranceController,
                            curve: Curves.easeOutCubic)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                        child: Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xCC1C1C1E)
                                : const Color(0xF0FFFFFF),
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(
                                color: AppColors.glassBorderC, width: 1.2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(
                                    isDark ? 0.4 : 0.12),
                                blurRadius: 40,
                                offset: const Offset(0, 20),
                              ),
                            ],
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 600),
                            transitionBuilder: (child, animation) =>
                                FadeTransition(
                              opacity: animation,
                              child: ScaleTransition(
                                  scale: animation, child: child),
                            ),
                            child: _emailSent
                                ? _buildSuccessView(isDark, accentColor)
                                : _buildFormView(isDark, accentColor),
                          ),
                        ),
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

  Widget _buildFormView(bool isDark, Color accentColor) {
    return Form(
      key: _formKey,
      child: Column(
        key: const ValueKey('form'),
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon circle
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.12),
              shape: BoxShape.circle,
              border: Border.all(color: accentColor.withOpacity(0.25)),
            ),
            child: Icon(Icons.lock_reset_rounded, size: 40, color: accentColor),
          ),
          const SizedBox(height: 22),

          // Title
          Text(
            'Reset Password',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 6),

          // Gold accent divider
          Container(
            width: 50,
            height: 2,
            decoration: const BoxDecoration(
              gradient: AppColors.goldGradient,
              borderRadius: BorderRadius.all(Radius.circular(1)),
            ),
          ),
          const SizedBox(height: 12),

          // Subtitle
          Text(
            'Enter your email to receive a recovery link',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: isDark ? AppColors.inkSubDark : AppColors.inkSoft,
            ),
          ),
          const SizedBox(height: 32),

          // Email field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: isDark ? AppColors.inkOnDark : AppColors.inkDark,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.alternate_email_rounded,
                  color: accentColor, size: 20),
              hintText: 'Your registered email',
              hintStyle: GoogleFonts.poppins(
                fontSize: 14,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
              filled: true,
              fillColor: isDark
                  ? AppColors.glassWhite10
                  : const Color(0x0A0D5C4A),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                    color: isDark
                        ? AppColors.glassBorderC
                        : accentColor.withOpacity(0.2)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                    color: isDark
                        ? AppColors.glassBorderC
                        : accentColor.withOpacity(0.2)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: accentColor, width: 1.8),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFDC2626)),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                    color: Color(0xFFDC2626), width: 1.8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 16),
            ),
            validator: (value) =>
                (value == null || !value.contains('@'))
                    ? 'Please enter a valid email address'
                    : null,
          ),
          const SizedBox(height: 28),

          // Send button
          PremiumButton(
            label: 'SEND RESET LINK',
            onPressed: _isLoading ? null : _handleResetPassword,
            isLoading: _isLoading,
            gradient: LinearGradient(
              colors: [
                isDark ? AppColors.tealMed  : AppColors.tealDeep,
                isDark ? AppColors.tealSoft : AppColors.tealPrimary,
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView(bool isDark, Color accentColor) {
    return Column(
      key: const ValueKey('success'),
      mainAxisSize: MainAxisSize.min,
      children: [
        // Pulsing mail icon
        ScaleTransition(
          scale: _pulseAnimation,
          child: Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.12),
              shape: BoxShape.circle,
              border: Border.all(color: accentColor.withOpacity(0.25)),
            ),
            child: Icon(Icons.mark_email_read_rounded,
                size: 60, color: accentColor),
          ),
        ),
        const SizedBox(height: 28),

        // Heading
        Text(
          'Check Your Inbox!',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.inkOnDark : AppColors.inkDark,
          ),
        ),
        const SizedBox(height: 10),

        // Gold divider
        Container(
          width: 50,
          height: 2,
          decoration: const BoxDecoration(
            gradient: AppColors.goldGradient,
            borderRadius: BorderRadius.all(Radius.circular(1)),
          ),
        ),
        const SizedBox(height: 16),

        // Description
        Text(
          'We have sent a secure recovery link to',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: isDark ? AppColors.inkSubDark : AppColors.inkSoft,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 6),

        // Email address — highlighted in accent colour
        Text(
          _emailController.text,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            color: accentColor,
          ),
        ),
        const SizedBox(height: 8),

        Text(
          "Check your spam folder if it doesn't arrive.",
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: isDark ? AppColors.inkSubDark : AppColors.inkSoft,
          ),
        ),
        const SizedBox(height: 36),

        // Return to login button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: accentColor, width: 1.8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              backgroundColor: accentColor.withOpacity(0.06),
            ),
            child: Text(
              'RETURN TO LOGIN',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                color: accentColor,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ),
      ],
    );
  }
}