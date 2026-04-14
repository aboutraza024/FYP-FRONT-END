import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'app_ui_kit.dart';
import 'theme_manager.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});
  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _pulseController;
  String _userName = 'GUEST USER';

  static const _mainNavItems = [
    _DrawerItem(title: 'Home',      arabic: 'الرئيسية', icon: Icons.home_rounded,         route: '/'),
    _DrawerItem(title: 'Hadith',    arabic: 'الحديث',   icon: Icons.auto_stories_rounded, route: '/hadith-search'),
    _DrawerItem(title: 'Quran',     arabic: 'القرآن',   icon: Icons.menu_book_rounded,    route: '/quran'),
    _DrawerItem(title: 'Prayer',    arabic: 'الصلاة',   icon: Icons.access_time_rounded,  route: '/prayer-times'),
    _DrawerItem(title: 'Utilities', arabic: 'الأدوات',  icon: Icons.grid_view_rounded,    route: '/utilities'),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _mainController  = AnimationController(duration: const Duration(milliseconds: 900), vsync: this)..forward();
    _pulseController = AnimationController(duration: const Duration(seconds: 3), vsync: this)..repeat(reverse: true);
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) setState(() => _userName = prefs.getString('user_name') ?? 'GUEST USER');
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  String _currentRoute() => ModalRoute.of(context)?.settings.name ?? '/';

  // ── LOGOUT ────────────────────────────────────────────────────────────────
  // Captures NavigatorState BEFORE popping the drawer so the context
  // remains valid after the async gap (showDialog + SharedPreferences).
  Future<void> _handleLogout() async {
    // 1. Capture navigator reference before any pops
    final navigator = Navigator.of(context);

    // 2. Close the drawer
    navigator.pop();

    // 3. Ask user to confirm
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppColors.charcoalPanel : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Logout',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppColors.inkDark,
            ),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: GoogleFonts.poppins(
              color: isDark ? AppColors.inkSubDark : AppColors.inkSoft,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(color: AppColors.tealPrimary),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(
                'Logout',
                style: GoogleFonts.poppins(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );

    // 4. If confirmed — clear prefs and go to login
    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_name');
      await prefs.remove('user_email');
      // Use the captured navigator — safe after async gap, no mounted check needed
      navigator.pushNamedAndRemoveUntil('/login', (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      backgroundColor: Colors.transparent,
      elevation: 0,
      width: MediaQuery.of(context).size.width * 0.80,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
        child: Stack(
          children: [
            // ── Glass background ─────────────────────────────────────────
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: isDark
                        ? const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xF0141414), Color(0xF01C1C1E)],
                          )
                        : const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xF0F0FBF7), Color(0xF0E8F7F2)],
                          ),
                    border: Border(
                      right: BorderSide(color: AppColors.glassBorderC),
                    ),
                  ),
                ),
              ),
            ),

            // ── Decorative watermark ──────────────────────────────────────
            Positioned(
              right: -30,
              top: 80,
              child: Opacity(
                opacity: 0.04,
                child: Icon(
                  Icons.mosque_rounded,
                  size: 220,
                  color: isDark ? AppColors.emeraldBright : AppColors.emeraldDeep,
                ),
              ),
            ),

            // ── Content ───────────────────────────────────────────────────
            SafeArea(
              child: Column(
                children: [
                  _buildHeader(isDark),
                  const GoldDivider(),
                  const SizedBox(height: 12),

                  // Navigation label
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Navigation',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.goldPrimary,
                          letterSpacing: 1.4,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Scrollable list
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      physics: const BouncingScrollPhysics(),
                      children: [
                        ..._mainNavItems.asMap().entries.map(
                          (e) => _buildNavTile(e.value, e.key, isDark),
                        ),

                        const SizedBox(height: 16),

                        // Account label
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            'Account',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.goldPrimary,
                              letterSpacing: 1.4,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        _buildActionTile(
                          icon: Icons.lock_reset_rounded,
                          title: 'Change Password',
                          isDark: isDark,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.pop(context);
                            Navigator.pushNamed(context, '/forgot-password');
                          },
                        ),

                        _buildActionTile(
                          icon: Icons.logout_rounded,
                          title: 'Logout',
                          isDark: isDark,
                          isDestructive: true,
                          onTap: _handleLogout,
                        ),
                      ],
                    ),
                  ),

                  _buildFooter(isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(bool isDark) {
    return FadeTransition(
      opacity: CurvedAnimation(
          parent: _mainController, curve: const Interval(0.0, 0.6)),
      child: SlideTransition(
        position: Tween<Offset>(
                begin: const Offset(0, -0.15), end: Offset.zero)
            .animate(CurvedAnimation(
                parent: _mainController,
                curve: const Interval(0.0, 0.6,
                    curve: Curves.easeOutCubic))),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 36, 24, 20),
          child: Column(
            children: [
              ScaleTransition(
                scale: Tween<double>(begin: 1.0, end: 1.025).animate(
                    CurvedAnimation(
                        parent: _pulseController,
                        curve: Curves.easeInOut)),
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                        colors: [AppColors.goldDeep, AppColors.goldBright]),
                    boxShadow: const [
                      BoxShadow(
                          color: Color(0x50D97706),
                          blurRadius: 20,
                          spreadRadius: 3),
                    ],
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: Colors.white),
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: isDark
                          ? AppColors.sapphirePanel
                          : AppColors.emeraldLight,
                      child: Icon(
                        Icons.person_rounded,
                        size: 46,
                        color: isDark
                            ? AppColors.emeraldBright
                            : AppColors.emeraldDeep,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Assalamu Alaikum',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.goldPrimary,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _userName,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppColors.inkDark,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Nav tile ──────────────────────────────────────────────────────────────
  Widget _buildNavTile(_DrawerItem item, int index, bool isDark) {
    final isActive = _currentRoute() == item.route;

    final animation = CurvedAnimation(
      parent: _mainController,
      curve: Interval(
        (0.1 + index * 0.07).clamp(0.0, 0.9),
        (0.1 + index * 0.07 + 0.35).clamp(0.0, 1.0),
        curve: Curves.easeOutCubic,
      ),
    );

    return SlideTransition(
      position: Tween<Offset>(
              begin: const Offset(-0.3, 0), end: Offset.zero)
          .animate(animation),
      child: FadeTransition(
        opacity: animation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
                if (_currentRoute() != item.route) {
                  Navigator.pushNamed(context, item.route);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 11),
                decoration: BoxDecoration(
                  color: isActive
                      ? (isDark
                          ? AppColors.tealPrimary.withOpacity(0.25)
                          : AppColors.tealMint)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: isActive
                      ? Border.all(
                          color: AppColors.tealPrimary.withOpacity(0.4))
                      : null,
                ),
                child: Row(
                  children: [
                    Icon(
                      item.icon,
                      size: 20,
                      color: isActive
                          ? (isDark
                              ? AppColors.tealSoft
                              : AppColors.tealDeep)
                          : (isDark ? Colors.white60 : AppColors.inkMid),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item.title,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: isActive
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: isActive
                                  ? (isDark
                                      ? AppColors.tealSoft
                                      : AppColors.tealDeep)
                                  : (isDark
                                      ? Colors.white
                                      : AppColors.inkDark),
                            ),
                          ),
                          if (item.arabic.isNotEmpty)
                            Text(
                              item.arabic,
                              style: GoogleFonts.amiri(
                                fontSize: 12,
                                color: isDark
                                    ? AppColors.goldLight.withOpacity(0.5)
                                    : AppColors.goldDeep.withOpacity(0.6),
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (isActive)
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.goldPrimary,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Action tile (Change Password / Logout) ────────────────────────────────
  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required bool isDark,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive
        ? Colors.redAccent
        : (isDark ? Colors.white60 : AppColors.inkMid);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 11),
            child: Row(
              children: [
                Icon(icon, size: 20, color: color),
                const SizedBox(width: 14),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Footer — dark mode toggle + version ───────────────────────────────────
  Widget _buildFooter(bool isDark) {
    final themeManager = Provider.of<ThemeManager>(context, listen: false);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const GoldDivider(indent: 20),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 12),
          child: Row(
            children: [
              Icon(
                isDark ? Icons.nightlight_round : Icons.wb_sunny_rounded,
                size: 18,
                color: isDark ? AppColors.goldLight : AppColors.goldDeep,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  isDark ? 'Dark Mode' : 'Light Mode',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: isDark ? Colors.white70 : AppColors.inkMid,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  themeManager.toggleTheme();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 44,
                  height: 24,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: isDark
                        ? const LinearGradient(colors: [
                            AppColors.tealPrimary,
                            AppColors.tealSoft,
                          ])
                        : null,
                    color: isDark ? null : AppColors.paleGrey,
                  ),
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutBack,
                    alignment: isDark
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.all(3),
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: Colors.white),
                      child: Icon(
                        isDark
                            ? Icons.nightlight_round
                            : Icons.wb_sunny_rounded,
                        size: 10,
                        color: isDark
                            ? AppColors.tealDeep
                            : AppColors.goldPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Text(
            'Sirat Al Mustaqeem v1.0.0',
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: isDark ? Colors.white24 : Colors.black26,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Data class ────────────────────────────────────────────────────────────────
class _DrawerItem {
  final String title;
  final String arabic;
  final IconData icon;
  final String route;
  const _DrawerItem({
    required this.title,
    required this.arabic,
    required this.icon,
    required this.route,
  });
}
