import 'dart:ui';
import 'package:flutter/material.dart';
import 'app_ui_kit.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Ensure this is in pubspec.yaml

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  
  late AnimationController _bgController;
  late AnimationController _entranceController;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat();

    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _bgController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        HapticFeedback.vibrate();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Passwords do not match!', style: GoogleFonts.poppins()), 
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      setState(() => _isLoading = true);
      HapticFeedback.mediumImpact(); 

      // --- SAVE NAME LOCALLY FOR THE DRAWER ---
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', _nameController.text.toUpperCase());

      // Simulate network request
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account Created Successfully! Welcome.'), 
            backgroundColor: AppColors.tealPrimary,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pushReplacementNamed(context, '/');
      }
    } else {
      HapticFeedback.vibrate();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const primaryTeal = AppColors.emeraldPrimary;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark 
                    ? [const Color(0xFF1F2937), const Color(0xFF111827)] 
                    : [const Color(0xFF0A4A3A), const Color(0xFF0D7B62)],
              ),
            ),
          ),
          
          RepaintBoundary(
  child: AnimatedBuilder(
    animation: _bgController,
    builder: (context, child) => CustomPaint(
      painter: IslamicBackgroundPainter(_bgController.value, isDark: isDark),
      size: Size.infinite,
    ),
  ),
),
          
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 15,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 24),
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
              },
            ),
          ),

          Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: FadeTransition(
                opacity: _entranceController,
                child: SlideTransition(
                  position: Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
                      .animate(CurvedAnimation(parent: _entranceController, curve: Curves.easeOutCubic)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(35),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0x66060D1A) : const Color(0xDDFFFFFF),
                          borderRadius: BorderRadius.circular(35),
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 40,
                              offset: const Offset(0, 20),
                            )
                          ],
                        ),
                        child: _buildRegisterForm(isDark, primaryTeal),
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

  Widget _buildRegisterForm(bool isDark, Color primary) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Create Account',
            style: GoogleFonts.amiri(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.emeraldBright : const Color(0xFF047857),
            ),
          ),
          Text(
            'Start your spiritual journey',
            style: GoogleFonts.poppins(
              fontSize: 14, 
              color: isDark ? Colors.white70 : Colors.grey[600],
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 35),
          
          _buildAnimatedField(
            index: 0,
            controller: _nameController, 
            hint: 'Full Name', 
            icon: Icons.person_outline_rounded, 
            isDark: isDark,
            primary: primary,
            validator: (val) => (val == null || val.isEmpty) ? "Please enter your name" : null,
          ),
          const SizedBox(height: 16),
          
          _buildAnimatedField(
            index: 1,
            controller: _emailController, 
            hint: 'Email Address', 
            icon: Icons.alternate_email_rounded, 
            isDark: isDark,
            primary: primary,
            keyboardType: TextInputType.emailAddress,
            validator: (val) => (val == null || !val.contains('@')) ? "Enter valid email" : null,
          ),
          const SizedBox(height: 16),
          
          _buildAnimatedField(
            index: 2,
            controller: _passwordController, 
            hint: 'Password', 
            icon: Icons.lock_open_rounded, 
            isDark: isDark, 
            primary: primary,
            isPassword: true,
            obscure: _obscurePassword,
            onToggle: () {
              HapticFeedback.lightImpact();
              setState(() => _obscurePassword = !_obscurePassword);
            },
            validator: (val) => (val == null || val.length < 6) ? "Minimum 6 characters" : null,
          ),
          const SizedBox(height: 16),

          _buildAnimatedField(
            index: 3,
            controller: _confirmPasswordController, 
            hint: 'Confirm Password', 
            icon: Icons.lock_reset_rounded, 
            isDark: isDark, 
            primary: primary,
            isPassword: true,
            obscure: _obscureConfirmPassword,
            onToggle: () {
              HapticFeedback.lightImpact();
              setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
            },
          ),
          
          const SizedBox(height: 35),
          
          FadeTransition(
            opacity: CurvedAnimation(parent: _entranceController, curve: const Interval(0.7, 1.0)),
            child: PremiumButton(
              label: 'CREATE ACCOUNT',
              onPressed: _isLoading ? null : _handleRegister,
              isLoading: _isLoading,
            ),
          ),
          
          const SizedBox(height: 25),
          
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            child: Text.rich(
              TextSpan(
                text: "Already a member? ",
                style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                children: [
                  TextSpan(
                    text: 'Login', 
                    style: TextStyle(
                      fontWeight: FontWeight.bold, 
                      color: isDark ? AppColors.emeraldBright : primary,
                      decoration: TextDecoration.underline,
                    )
                  ),
                ],
              ),
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedField({
    required int index,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isDark,
    required Color primary,
    bool isPassword = false,
    bool? obscure,
    VoidCallback? onToggle,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final fieldAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Interval(0.2 + (index * 0.1), 0.8, curve: Curves.easeOut),
    );

    return FadeTransition(
      opacity: fieldAnimation,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0.2, 0), end: Offset.zero).animate(fieldAnimation),
        child: TextFormField(
          controller: controller,
          obscureText: isPassword ? (obscure ?? true) : false,
          validator: validator,
          keyboardType: keyboardType,
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: isDark ? AppColors.emeraldBright : primary, size: 22),
            hintText: hint,
            hintStyle: GoogleFonts.poppins(color: Colors.grey[500], fontSize: 14),
            filled: true,
            fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(color: isDark ? AppColors.emeraldBright : primary, width: 2),
            ),
            suffixIcon: isPassword 
              ? IconButton(
                  icon: Icon(obscure! ? Icons.visibility_off_rounded : Icons.visibility_rounded, size: 20, color: Colors.grey),
                  onPressed: onToggle,
                ) 
              : null,
          ),
        ),
      ),
    );
  }
}