import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import 'register.dart';
import 'login.dart';
import 'forgetpassword.dart';
import 'home_screen.dart';
import 'hadith_search_screen.dart';
import 'quran_module.dart';
import 'hadith_model.dart';
import 'quran_isar_models.dart';
import 'prayer_times.dart';
import 'prayer_settings_screen.dart';
import 'utility_module.dart';
import 'theme_manager.dart';
import 'namaz_database.dart';
import 'app_ui_kit.dart';
import 'islamic_page_route.dart';

const platform = MethodChannel('silent_control');

// ── BACKGROUND SERVICE LOGIC (UNCHANGED) ─────────────────────────────────────

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  if (service is AndroidServiceInstance) service.setAsForegroundService();

  bool wasSilentLastCheck = false;
  await Future.delayed(const Duration(seconds: 3));
  final db = NamazDatabase.instance;
  await db.ensureOpen();

  Timer.periodic(const Duration(seconds: 30), (timer) async {
    final prefs = await SharedPreferences.getInstance();
    final bool autoSilenceEnabled = prefs.getBool('auto_silence') ?? true;
    if (!autoSilenceEnabled) {
      if (wasSilentLastCheck) {
        try { await platform.invokeMethod('setNormalMode'); } catch (e) { debugPrint('BG: $e'); }
        wasSilentLastCheck = false;
      }
      if (service is AndroidServiceInstance) {
        service.setForegroundNotificationInfo(
            title: 'Sirat Al Mustaqeem', content: 'Auto-Silencer is disabled');
      }
      return;
    }
    final now = DateTime.now();
    try {
      final List<Map<String, dynamic>> results = await db.getTimes();
      if (results.isEmpty) return;
      final config = results.first;
      bool shouldBeSilent = false;
      final prayers = ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha', 'jumma'];
      for (var prayer in prayers) {
        if (prayer == 'jumma' && now.weekday != DateTime.friday) continue;
        if (prayer == 'dhuhr' && now.weekday == DateTime.friday) continue;
        bool isEnabled = config['${prayer}On'] == 1;
        if (isEnabled) {
          String? startStr = config['${prayer}Before']?.toString();
          String? endStr   = config['${prayer}After']?.toString();
          if (startStr != null && startStr.isNotEmpty &&
              endStr   != null && endStr.isNotEmpty) {
            try {
              DateTime parseTime(String t) {
                t = t.trim();
                if (t.toUpperCase().contains('AM') || t.toUpperCase().contains('PM')) {
                  final parsed = DateFormat('h:mm a').parse(t);
                  return DateTime(now.year, now.month, now.day, parsed.hour, parsed.minute);
                } else {
                  final parsed = DateFormat('HH:mm').parse(t);
                  return DateTime(now.year, now.month, now.day, parsed.hour, parsed.minute);
                }
              }
              final startWindow = parseTime(startStr);
              final endWindow   = parseTime(endStr);
              if (now.isAfter(startWindow) && now.isBefore(endWindow)) {
                shouldBeSilent = true;
                break;
              }
            } catch (e) { debugPrint('BG parse error $prayer: $e'); }
          }
        }
      }
      if (shouldBeSilent && !wasSilentLastCheck) {
        try { await platform.invokeMethod('setSilentMode'); } catch (e) { debugPrint('BG: $e'); }
        wasSilentLastCheck = true;
      } else if (!shouldBeSilent && wasSilentLastCheck) {
        try { await platform.invokeMethod('setNormalMode'); } catch (e) { debugPrint('BG: $e'); }
        wasSilentLastCheck = false;
      }
      if (service is AndroidServiceInstance) {
        service.setForegroundNotificationInfo(
          title: 'Sirat Al Mustaqeem',
          content: shouldBeSilent ? 'Status: SILENT (Prayer Time)' : 'Status: Monitoring Prayer Times',
        );
      }
    } catch (e) { debugPrint('BG Loop Error: $e'); }
  });
}

Future<void> _initializeBackgroundService() async {
  final service = FlutterBackgroundService();
  final isRunning = await service.isRunning();
  if (isRunning) { debugPrint('BackgroundService already running.'); return; }

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'prayer_service_channel',
    'Sirat Al Mustaqeem Service',
    description: 'Keeps Auto-Silencer alive on Android',
    importance: Importance.low,
  );
  final FlutterLocalNotificationsPlugin plugin = FlutterLocalNotificationsPlugin();
  await plugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: false,
      isForegroundMode: true,
      notificationChannelId: 'prayer_service_channel',
      initialNotificationTitle: 'Sirat Al Mustaqeem',
      initialNotificationContent: 'Auto-Silencer is active',
      foregroundServiceTypes: [AndroidForegroundType.specialUse],
    ),
    iosConfiguration: IosConfiguration(),
  );
  service.startService();
}

// ── MAIN ──────────────────────────────────────────────────────────────────────

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final themeManager = ThemeManager();
  await themeManager.init();

  await AndroidAlarmManager.initialize();
  await _initializeBackgroundService();

  final dir = await getApplicationDocumentsDirectory();
  Isar.getInstance("sirat_al_mustaqeem_db") ??
      await Isar.open(
        [CachedChapterSchema, CachedHadithSchema, CachedAyahSchema],
        directory: dir.path,
        name: "sirat_al_mustaqeem_db",
      );

  runApp(
    ChangeNotifierProvider.value(
      value: themeManager,
      child: const SiratAlMustaqeemApp(),
    ),
  );
}

// ── APP WIDGET ────────────────────────────────────────────────────────────────

class SiratAlMustaqeemApp extends StatelessWidget {
  const SiratAlMustaqeemApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeManager(),
      builder: (context, _) {
        return MaterialApp(
          title: 'SIRAT-AL-MUSTAQEEM',
          debugShowCheckedModeBanner: false,
          themeMode: ThemeManager().themeMode,
          theme: ThemeManager.lightTheme,
          darkTheme: ThemeManager.darkTheme,
          initialRoute: '/splash',
          scrollBehavior: const _AppScrollBehavior(),
          onGenerateRoute: (settings) {
            Widget page;
            switch (settings.name) {
              case '/splash':
                page = const SplashScreen();
              case '/':
                page = const HomeScreen();
              case '/login':
                page = const LoginScreen();
              case '/register':
                page = const RegisterScreen();
              case '/forgot-password':
                page = const ForgotPasswordScreen();
              case '/hadith-search':
                page = const HadithSearchScreen();
              case '/quran':
                page = const QuranModuleScreen();
              case '/prayer-times':
                page = const PrayerTimesScreen();
              case '/prayer-settings':
                page = const PrayerSettingsScreen();
              case '/utilities':
                page = const UtilityModuleScreen();
              default:
                page = const LoginScreen();
            }
            return IslamicPageRoute(settings: settings, page: page);
          },
        );
      },
    );
  }
}

class _AppScrollBehavior extends ScrollBehavior {
  const _AppScrollBehavior();
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
}

// ─────────────────────────────────────────────────────────────────────────────
// SPLASH SCREEN — fully restored from original
// ─────────────────────────────────────────────────────────────────────────────

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _ringAnim;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;
  late Animation<double> _arabicFade;
  late Animation<double> _shimmer;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 2400),
      vsync: this,
    );

    const spring = Cubic(0.175, 0.885, 0.32, 1.275);

    _logoScale  = Tween<double>(begin: 0.6, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.45, curve: spring)));
    _logoFade   = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.3, curve: Curves.easeIn)));
    _ringAnim   = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: const Interval(0.2, 0.55, curve: Curves.easeOut)));
    _textFade   = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: const Interval(0.4, 0.65, curve: Curves.easeIn)));
    _textSlide  = Tween<Offset>(begin: const Offset(0, 0.35), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl,
            curve: const Interval(0.4, 0.7, curve: Curves.easeOutCubic)));
    _arabicFade = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl,
            curve: const Interval(0.62, 1.0, curve: Curves.easeIn)));
    _shimmer    = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl,
            curve: const Interval(0.7, 1.0, curve: Curves.easeIn)));

    _ctrl.forward();
    _ctrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 700), () {
          if (mounted) Navigator.pushReplacementNamed(context, '/login');
        });
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.splashGradient),
        child: Stack(
          children: [
            Positioned.fill(
              child: RepaintBoundary(
                child: AnimatedBuilder(
                  animation: _ctrl,
                  builder: (_, __) => CustomPaint(
                    painter: IslamicBackgroundPainter(_ctrl.value, isDark: false),
                    size: Size.infinite,
                  ),
                ),
              ),
            ),
            SizedBox.expand(
              child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _ringAnim,
                  builder: (context, child) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        Opacity(
                          opacity: _ringAnim.value * 0.4,
                          child: Container(
                            width: 180 + (20 * _ringAnim.value),
                            height: 180 + (20 * _ringAnim.value),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: AppColors.amberLight, width: 1.5),
                            ),
                          ),
                        ),
                        Opacity(
                          opacity: _ringAnim.value * 0.25,
                          child: Container(
                            width: 155,
                            height: 155,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1),
                            ),
                          ),
                        ),
                        child!,
                      ],
                    );
                  },
                  child: ScaleTransition(
                    scale: _logoScale,
                    child: FadeTransition(
                      opacity: _logoFade,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x33000000),
                              blurRadius: 30,
                              offset: Offset(0, 15),
                            ),
                            BoxShadow(
                              color: Color(0x201AB590),
                              blurRadius: 40,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(32),
                          child: Image.asset(
                            'assets/Images/app_logo.png',
                            width: 130,
                            height: 130,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                FadeTransition(
                  opacity: _textFade,
                  child: SlideTransition(
                    position: _textSlide,
                    child: Column(
                      children: [
                        Text(
                          'SIRAT-AL-MUSTAQEEM',
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 2.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: 80,
                          height: 2,
                          decoration: const BoxDecoration(
                            gradient: AppColors.goldGradient,
                            borderRadius: BorderRadius.all(Radius.circular(1)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                FadeTransition(
                  opacity: _arabicFade,
                  child: Text(
                    'صراط المستقیم',
                    style: GoogleFonts.amiri(
                      fontSize: 30,
                      color: Colors.white.withOpacity(0.88),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 64),
                FadeTransition(
                  opacity: _shimmer,
                  child: const _LoadingDots(),
                ),
              ],
            ),
            ),   // end SizedBox.expand
          ],
        ),
      ),
    );
  }
}

// ── LOADING DOTS ──────────────────────────────────────────────────────────────

class _LoadingDots extends StatefulWidget {
  const _LoadingDots();
  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        duration: const Duration(milliseconds: 900), vsync: this)..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final double delay   = i / 3;
            final double t       = ((_c.value - delay).clamp(0.0, 0.5) / 0.5);
            final double opacity = (t < 0.5 ? t * 2 : (1 - t) * 2).clamp(0.2, 1.0);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Opacity(
                opacity: opacity,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: AppColors.amberLight,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
