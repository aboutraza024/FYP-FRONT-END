// utility_module.dart — UI UPGRADED + Wudu & Namaz as inline tools
// ── ALL original logic is 100% unchanged ──
// Changes vs previous version:
//   1. Added imports for namaz.dart (SalahGuideScreen) and wudu.dart (WuduGuideScreen)
//   2. Added 'Wudu Guide' (index 6) and 'Salah Guide' (index 7) to _menuItems
//   3. _buildToolContent() cases 6 & 7 render the screens inline inside the
//      existing white rounded container — no Navigator.push used
//   4. _InlineScaffoldWrapper strips the inner Scaffold's AppBar padding so
//      the guide screens sit flush inside the parent container
//   5. Everything else untouched

import 'dart:ui' as ui;
import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'custom_drawer.dart';
import 'app_ui_kit.dart';
import 'namaz.dart'; // ← NEW: provides SalahGuideScreen
import 'wudu.dart';  // ← NEW: provides WuduGuideScreen

class UtilityModuleScreen extends StatefulWidget {
  const UtilityModuleScreen({super.key});
  @override
  State<UtilityModuleScreen> createState() => _UtilityModuleScreenState();
}

class _UtilityModuleScreenState extends State<UtilityModuleScreen>
    with TickerProviderStateMixin {
  int? _activeToolIndex;
  int _zikrCount = 0;

  final TextEditingController _duaSearchController = TextEditingController();
  String _duaSearchQuery = "";

  late AnimationController _zikrPulseController;
  late AnimationController _staggerController;

  // ── Branded menu items — indices 0-5 unchanged, 6 & 7 are new ──
  static const List<_MenuItem> _menuItems = [
    _MenuItem(title: 'Qibla Finder',     icon: Icons.explore_rounded,          gradient: AppColors.cardHadith),
    _MenuItem(title: 'Islamic Calendar', icon: Icons.event_note_rounded,       gradient: AppColors.cardQuran),
    _MenuItem(title: 'Quran Miracles',   icon: Icons.auto_awesome_rounded,     gradient: AppColors.cardHadith),
    _MenuItem(title: 'Islamic Duas',     icon: Icons.menu_book_rounded,        gradient: AppColors.cardUtils),
    _MenuItem(title: 'Digital Tasbeeh', icon: Icons.fingerprint_rounded,       gradient: AppColors.cardPrayer),
    _MenuItem(title: '99 Names',         icon: Icons.star_rounded,             gradient: AppColors.cardQuran),
    // ── NEW ──────────────────────────────────────────────────────────────────
    _MenuItem(title: 'Wudu Guide',       icon: Icons.water_drop_rounded,       gradient: AppColors.cardUtils),
    _MenuItem(title: 'Salah Guide',      icon: Icons.self_improvement_rounded, gradient: AppColors.cardPrayer),
  ];

  @override
  void initState() {
    super.initState();
    _zikrPulseController = AnimationController(
        duration: const Duration(milliseconds: 150), vsync: this);
    _staggerController = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this)
      ..forward();
  }

  @override
  void dispose() {
    _zikrPulseController.dispose();
    _staggerController.dispose();
    _duaSearchController.dispose();
    super.dispose();
  }

  void _onBottomNavTap(int index) {
    HapticFeedback.selectionClick();
    final routes = ['/', '/hadith-search', '/quran', '/prayer-times', '/utilities'];
    if (ModalRoute.of(context)?.settings.name != routes[index]) {
      Navigator.pushNamed(context, routes[index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      drawer: const CustomDrawer(),
      body: Stack(
        children: [
          GradientBackground(isDark: isDark, child: const SizedBox.expand()),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    child: _activeToolIndex == null
                        ? _buildMenuGrid(isDark)
                        : _buildToolContent(isDark),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: FloatingNavBar(
          currentIndex: 4, onTap: _onBottomNavTap),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              _activeToolIndex == null
                  ? Icons.arrow_back_ios_new_rounded
                  : Icons.close_rounded,
              color: Colors.white,
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              if (_activeToolIndex != null) {
                setState(() {
                  _activeToolIndex = null;
                  _staggerController.forward(from: 0);
                });
              } else {
                Navigator.pop(context);
              }
            },
          ),
          Expanded(
            child: Text(
              _activeToolIndex == null
                  ? 'Utilities'
                  : _menuItems[_activeToolIndex!].title,
              style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildMenuGrid(bool isDark) {
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 1.05,
      ),
      itemCount: _menuItems.length,
      itemBuilder: (context, index) {
        final animation = CurvedAnimation(
          parent: _staggerController,
          curve: Interval((0.1 * index).clamp(0.0, 1.0), 1.0,
              curve: Curves.easeOutCubic),
        );
        return SlideTransition(
          position: Tween<Offset>(
                  begin: const Offset(0, 0.2), end: Offset.zero)
              .animate(animation),
          child: FadeTransition(
            opacity: animation,
            child: _UtilityCard(
              item: _menuItems[index],
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() => _activeToolIndex = index);
              },
            ),
          ),
        );
      },
    );
  }

  // ── Tool content switcher ─────────────────────────────────────────────────
  Widget _buildToolContent(bool isDark) {
    final key = ValueKey<int>(_activeToolIndex!);

    Widget content;
    switch (_activeToolIndex) {
      case 0:
        content = const QiblaCompassWidget();
        break;
      case 1:
        content = _buildCalendarView();
        break;
      case 2:
        content = _buildZikrView();
        break;
      case 3:
        content = _buildDuaView();
        break;
      case 4:
        content = _buildMiraclesView();
        break;
      case 5:
        content = _buildNamesView();
        break;
      // ── NEW: Wudu Guide inline ─────────────────────────────────────────
      case 6:
        content = _buildInlineGuide(
          child: const WuduGuideScreen(),
          isDark: isDark,
        );
        break;
      // ── NEW: Salah Guide inline ────────────────────────────────────────
      case 7:
        content = _buildInlineGuide(
          child: const SalahGuideScreen(),
          isDark: isDark,
        );
        break;
      default:
        content = const SizedBox.shrink();
    }

    return Container(
      key: key,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(35),
          topRight: Radius.circular(35),
        ),
      ),
      child: content,
    );
  }

  /// Embeds a guide screen (WuduGuideScreen / SalahGuideScreen) inline inside
  /// the existing rounded container.
  ///
  /// Both guide screens are full Scaffolds with their own AppBar. We suppress
  /// the AppBar by wrapping in a [_InlineScaffoldWrapper] that overrides the
  /// theme so the inner Scaffold renders with zero top-padding and a matching
  /// background — the parent header already shows the tool title.
  Widget _buildInlineGuide({required Widget child, required bool isDark}) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(35),
        topRight: Radius.circular(35),
      ),
      // A nested Navigator isolates the guide screen's own route stack so its
      // internal back-button logic does not interfere with the parent navigator.
      child: Navigator(
        onGenerateRoute: (_) => MaterialPageRoute(
          builder: (_) => _InlineScaffoldWrapper(
            isDark: isDark,
            child: child,
          ),
        ),
      ),
    );
  }

  // ── Calendar — original logic, cyanAccent replaced ────────────────────────
  Widget _buildCalendarView() {
    final now = DateTime.now();
    final adjustedDate = now.subtract(const Duration(days: 1));
    final todayHijri = HijriCalendar.fromDate(adjustedDate);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(25),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0D7B62), Color(0xFF0A4A3A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x40000000),
                    blurRadius: 15,
                    offset: Offset(0, 8))
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "${todayHijri.longMonthName} ${todayHijri.hYear} AH",
                  style: GoogleFonts.poppins(
                      color: AppColors.amberLight,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2),
                ),
                const SizedBox(height: 15),
                Text(
                  "${todayHijri.hDay}",
                  style: GoogleFonts.poppins(
                      fontSize: 100,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      height: 1.1),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 50),
                  child: Divider(color: Color(0x40FFFFFF), thickness: 1),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.calendar_today,
                        color: AppColors.goldLight, size: 18),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        DateFormat('EEEE, dd MMMM yyyy').format(now),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Text(
            "Sirat Al-Mustaqeem Calendar",
            style: GoogleFonts.poppins(
                color: Colors.grey,
                fontSize: 13,
                fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  // ── Zikr — original logic unchanged ──────────────────────────────────────
  Widget _buildZikrView() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final double progress = (_zikrCount % 33) / 33;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 260,
              height: 260,
              child: CircularProgressIndicator(
                value: progress == 0 && _zikrCount > 0 ? 1.0 : progress,
                strokeWidth: 8,
                backgroundColor: const Color(0xFF0F7B63).withOpacity(0.1),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Color(0xFF0F7B63)),
              ),
            ),
            GestureDetector(
              onTap: () {
                HapticFeedback.heavyImpact();
                setState(() => _zikrCount++);
                _zikrPulseController.forward(from: 0);
              },
              child: ScaleTransition(
                scale: Tween(begin: 1.0, end: 0.95).animate(
                  CurvedAnimation(
                      parent: _zikrPulseController,
                      curve: Curves.easeInOut),
                ),
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0D7B62), Color(0xFF0A5248)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F7B63).withOpacity(0.3),
                        blurRadius: 25,
                        spreadRadius: 5,
                        offset: const Offset(0, 10),
                      ),
                      BoxShadow(
                        color: Colors.white.withOpacity(0.2),
                        blurRadius: 2,
                        spreadRadius: -5,
                        offset: const Offset(-5, -5),
                      ),
                    ],
                    border: Border.all(
                        color: Colors.white.withOpacity(0.1), width: 2),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "$_zikrCount",
                          style: GoogleFonts.poppins(
                            fontSize: 75,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -2,
                          ),
                        ),
                        Text(
                          "TAP TO COUNT",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white60,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 60),
        TextButton.icon(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
            backgroundColor: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.grey.shade100,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15)),
          ),
          onPressed: () {
            HapticFeedback.mediumImpact();
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text("Reset Counter?"),
                content:
                    const Text("Are you sure you want to clear your count?"),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel")),
                  TextButton(
                    onPressed: () {
                      setState(() => _zikrCount = 0);
                      Navigator.pop(context);
                    },
                    child: const Text("Reset",
                        style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            );
          },
          icon: const Icon(Icons.restart_alt_rounded,
              color: Colors.grey, size: 20),
          label: Text(
            "RESET COUNTER",
            style: GoogleFonts.poppins(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: 13,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ],
    );
  }

  // ── Duas — original data + logic unchanged ────────────────────────────────
  Widget _buildDuaView() {
    final List<Map<String, String>> allDuas = [
      {'t': 'Waking Up', 'a': 'الْحَمْدُ لِلَّهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُورُ'},
      {'t': 'After Eating', 'a': 'الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنَا وَسَقَانَا وَجَعَلَنَا مُسْلِمِينَ'},
      {'t': 'Entering Home', 'a': 'بِسْمِ اللَّهِ وَلَجْنَا، وَبِسْمِ اللَّهِ خَرَجْنَا، وَعَلَى رَبِّنَا تَوَكَّلْنَا'},
      {'t': 'Leaving Home', 'a': 'بِسْمِ اللَّهِ، تَوَكَّلْتُ عَلَى اللَّهِ، وَلا حَوْلَ وَلا قُوَّةَ إِلاَّ بِاللَّهِ'},
      {'t': 'Entering Masjid', 'a': 'اللَّهُمَّ افْتَحْ لِي أَبْوَابَ رَحْمَتِكَ'},
      {'t': 'Leaving Masjid', 'a': 'اللَّهُمَّ إِنِّي أَسْأَلُكَ مِنْ فَضْلِكَ'},
      {'t': 'Entering Toilet', 'a': 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْخُبُثِ وَالْخَبَائِثِ'},
      {'t': 'Leaving Toilet', 'a': 'غُفْرَانَكَ'},
      {'t': 'For Parents', 'a': 'رَّبِّ ارْحَمْهُمَا كَمَا رَبَّيَانِي صَغِيرًا'},
      {'t': 'Seeking Knowledge', 'a': 'رَّبِّ زِدْنِي عِلْمًا'},
      {'t': 'For Forgiveness', 'a': 'رَبَّنَا اغْفِرْ لِي وَلِوَالِدَيَّ وَلِلْمُؤْمِنِينَ يَوْمَ يَقُومُ الْحِسَابُ'},
      {'t': 'When in Distress', 'a': 'لا إِلَهَ إِلا أَنْتَ سُبْحَانَكَ إِنِّي كُنْتُ مِنَ الظَّالِمِينَ'},
      {'t': 'Morning Dua', 'a': 'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ وَالْحَمْدُ لِلَّهِ'},
      {'t': 'Evening Dua', 'a': 'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ وَالْحَمْدُ لِلَّهِ'},
      {'t': 'After Wudu', 'a': 'أَشْهَدُ أَنْ لا إِلَهَ إِلا اللَّهُ وَأَشْهَدُ أَنَّ مُحَمَّدًا عَبْدُهُ وَرَسُولُهُ'},
      {'t': 'Breaking Fast', 'a': 'ذَهَبَ الظَّمَأُ وَابْتَلَّتِ الْعُرُوقُ وَثَبَتَ الأَجْرُ إِنْ شَاءَ اللَّهُ'},
      {'t': 'Success (Dunya & Akhirah)', 'a': 'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ'},
      {'t': 'Before Sleeping', 'a': 'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا'},
      {'t': 'Protection from Evil', 'a': 'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ'},
      {'t': 'Steadfastness in Faith', 'a': 'يَا مُقَلِّبَ الْقُلُوبِ ثَبِّتْ قَلْبِي عَلَى دِينِكَ'},
      {'t': 'To Ease Tasks', 'a': 'اللَّهُمَّ لَا سَهْلَ إِلَّا مَا جَعَلْتَهُ سَهْلًا، وَأَنْتَ تَجْعَلُ الْحَزْنَ إِذَا شِئْتَ سَهْلًا'},
      {'t': 'For Health', 'a': 'اللَّهُمَّ عَافِنِي فِي بَدَنِي، اللَّهُمَّ عَافِنِي فِي سَمْعِي، اللَّهُمَّ عَافِنِي فِي بَصَرِي'},
      {'t': 'Guidance & Piety', 'a': 'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْهُدَى وَالتُّقَى وَالْعَفَافَ وَالْغِنَى'},
      {'t': 'Anxiety and Sorrow', 'a': 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْهَمِّ وَالْحَزَنِ، وَالْعَجْزِ وَالْكَسَلِ، وَالْبُخْلِ وَالْجُبْنِ'},
      {'t': 'Entering Market', 'a': 'لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ'},
      {'t': 'Traveling', 'a': 'سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَذَا وَمَا كُنَّا لَهُ مُقْرِنِينَ وَإِنَّا إِلَى رَبِّنَا لَمُنْقَلِبُونَ'},
      {'t': 'When it Rains', 'a': 'اللَّهُمَّ صَيِّبًا نَافِعًا'},
      {'t': 'Hearing Thunder', 'a': 'سُبْحَانَ الَّذِي يُسَبِّحُ الرَّعْدُ بِحَمْدِهِ وَالْمَلَائِكَةُ مِنْ خِيفَتِهِ'},
      {'t': 'For Family', 'a': 'رَبَّنَا هَبْ لَنَا مِنْ أَزْوَاجِنَا وَذُرِّيَّاتِنَا قُرَّةَ أَعْيُنٍ وَاجْعَلْنَا لِلْمُتَّقِينَ إِمَامًا'},
      {'t': 'Opening of Heart', 'a': 'رَبِّ اشْرَحْ لِي صَدْرِي وَيَسِّرْ لِي أَمْرِي'},
      {'t': 'Thanking Someone', 'a': 'جَزَاكَ اللَّهُ خَيْرًا'},
      {'t': 'When Angry', 'a': 'أَعُوذُ بِاللَّهِ مِنَ الشَّيْطَانِ الرَّجِيمِ'},
      {'t': 'End of Gathering', 'a': 'سُبْحَانَكَ اللَّهُمَّ وَبِحَمْدِكَ، أَشْهَدُ أَنْ لَا إِلَهَ إِلَّا أَنْتَ، أَسْتَغْفِرُكَ وَأَتُوبُ إِلَيْكَ'},
      {'t': 'Sayyidul Istighfar', 'a': 'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ'},
      {'t': 'Protection from Debt', 'a': 'اللَّهُمَّ اكْفِنِي بِحَلَالِكَ عَنْ حَرَامِكَ، وَأَغْنِنِي بِفَضْلِكَ عَمَّنْ سِوَاكَ'},
      {'t': 'Visiting the Sick', 'a': 'لَا بَأْسَ طَهُورٌ إِنْ شَاءَ اللَّهُ'},
      {'t': 'Laylatul Qadr', 'a': 'اللَّهُمَّ إِنَّكَ عَفُوٌّ تُحِبُّ الْعَفْوَ فَاعْفُ عَنِّي'},
      {'t': 'When in Pain', 'a': 'أَعُوذُ بِعِزَّةِ اللَّهِ وَقُدْرَتِهِ مِنْ شَرِّ مَا أَجِدُ وَأُحَاذِرُ'},
      {'t': 'Good Character', 'a': 'اللَّهُمَّ كَمَا حَسَّنْتَ خَلْقِي فَحَسِّنْ خُلُقِي'},
      {'t': 'Upon Sneezing', 'a': 'الْحَمْدُ لِلَّهِ'},
      {'t': 'Hearing a Sneeze', 'a': 'يَرْحَمُكَ اللَّهُ'},
      {'t': 'When Bowing (Ruku)', 'a': 'سُبْحَانَ رَبِّيَ الْعَظِيمِ'},
      {'t': 'When Prostrating (Sajdah)', 'a': 'سُبْحَانَ رَبِّيَ الْأَعْلَى'},
      {'t': 'Between Prostrations', 'a': 'رَبِّ اغْفِرْ لِي، رَبِّ اغْفِرْ لِي'},
      {'t': 'For Light (Noor)', 'a': 'اللَّهُمَّ اجْعَلْ فِي قَلْبِي نُورًا، وَفِي لِسَانِي نُورًا'},
      {'t': 'Against Poverty', 'a': 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْكُفْرِ وَالْفَقْرِ'},
      {'t': 'Beneficial Knowledge', 'a': 'اللَّهُمَّ إِنِّي أَسْأَلُكَ عِلْمًا نَافِعًا، وَرِزْقًا طَيِّبًا، وَعَمَلًا مُتَقَبَّلًا'},
      {'t': 'Protection for Kids', 'a': 'أُعِيذُكُمَا بِكَلِمَاتِ اللَّهِ التَّامَّةِ، مِنْ كُلِّ شَيْطَانٍ وَهَامَّةٍ'},
      {'t': 'Patience', 'a': 'رَبَّنَا أَفْرِغْ عَلَيْنَا صَبْرًا وَثَبِّتْ أَقْدَامَنَا وَانصُرْنَا عَلَى الْقَوْمِ الْكَافِرِينَ'},
      {'t': 'Mercy & Guidance', 'a': 'رَبَّنَا آتِنَا مِن لَّدُنكَ رَحْمَةً وَهَيِّئْ لَنَا مِنْ أَمْرِنَا رَشَدًا'},
      {'t': 'For a Good Ending', 'a': 'اللَّهُمَّ اجْعَلْ خَيْرَ عُمْرِي آخِرَهُ، وَخَيْرَ عَمَلِي خَوَاتِمَهُ'},
      {'t': 'When Facing Enemy', 'a': 'حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ'},
      {'t': 'Asking Paradise', 'a': 'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْجَنَّةَ وَأَعُوذُ بِكَ مِنَ النَّارِ'},
      {'t': 'Morning Protection', 'a': 'حَسْبِيَ اللَّهُ لَا إِلَهَ إِلَّا هُوَ عَلَيْهِ تَوَكَّلْتُ وَهُوَ رَبُّ الْعَرْشِ الْعَظِيمِ'},
      {'t': 'Upon Completing Quran', 'a': 'اللَّهُمَّ ارْحَمْنِي بِالْقُرْآنِ وَاجْعَلْهُ لِي إِمَامًا وَنُورًا وَهُدًى وَرَحْمَةً'},
      {'t': 'Gratitude for Islam', 'a': 'الْحَمْدُ لِلَّهِ الَّذِي هَدَانَا لِهَذَا وَمَا كُنَّا لِنَهْتَدِيَ لَوْلَا أَنْ هَدَانَا اللَّهُ'},
    ];

    final filteredDuas = allDuas
        .where((dua) =>
            dua['t']!.toLowerCase().contains(_duaSearchQuery.toLowerCase()))
        .toList();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: TextField(
            controller: _duaSearchController,
            onChanged: (val) => setState(() => _duaSearchQuery = val),
            style: TextStyle(
                color: isDark ? Colors.white : Colors.black87),
            decoration: InputDecoration(
              hintText: "Search Duas...",
              hintStyle: const TextStyle(color: Colors.grey),
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: isDark ? const Color(0xFF2C2C2E) : Colors.grey[100],
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none),
            ),
          ),
        ),
        Expanded(
          child: filteredDuas.isEmpty
              ? const IslamicEmptyState(message: 'No duas found')
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: filteredDuas.length,
                  itemBuilder: (context, i) => Card(
                    elevation: 0,
                    color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: BorderSide(color: Colors.grey.withOpacity(0.2)),
                    ),
                    margin: const EdgeInsets.only(bottom: 15),
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            filteredDuas[i]['a']!,
                            style: GoogleFonts.amiri(
                                fontSize: 24,
                                height: 1.8,
                                color: const Color(0xFF0F7B63),
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.right,
                          ),
                          const SizedBox(height: 10),
                          const Divider(height: 1, color: Colors.grey),
                          const SizedBox(height: 10),
                          Text(
                            filteredDuas[i]['t']!,
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? Colors.white70
                                    : Colors.black87),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  // ── Miracles — original URLs + logic, purpleAccent replaced ──────────────
  Widget _buildMiraclesView() {
    final miracles = [
      {'title': 'Balance of ط article',  'url': 'https://numericalmiraclesofquran.com/ta-balance/'},
      {'title': 'Surah An-Nahl',          'url': 'https://numericalmiraclesofquran.com/surah-an-nahl/'},
      {'title': 'Global Structure',       'url': 'https://v0-global-structure-of-quran.vercel.app/'},
      {'title': 'Twelve Surahs',          'url': 'https://v0-twelve-surah-s.vercel.app/'},
      {'title': 'Surah Ikhlas',           'url': 'https://v0-surah-ikhlas-part-1-and-2.vercel.app/'},
      {'title': 'Surah Al Fatiha',        'url': 'https://v0-surah-al-fatihah.vercel.app/'},
    ];

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      itemCount: miracles.length,
      itemBuilder: (context, i) => Card(
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 12),
        color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: Colors.grey.withOpacity(0.2)),
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.amberPrimary.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.auto_awesome,
                color: AppColors.amberPrimary),
          ),
          title: Text(miracles[i]['title']!,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87)),
          trailing:
              const Icon(Icons.open_in_new, size: 20, color: Colors.grey),
          onTap: () async {
            HapticFeedback.lightImpact();
            final url = Uri.parse(miracles[i]['url']!);
            if (!await launchUrl(url)) throw 'Could not launch $url';
          },
        ),
      ),
    );
  }

  // ── 99 Names — complete original data + logic unchanged ──────────────────
  Widget _buildNamesView() {
    final names = [
  {'ar': 'الرَّحْمَنُ', 'en': 'Ar-Rahman', 'ur': 'نہایت مہربان'},
  {'ar': 'الرَّحِيمُ', 'en': 'Ar-Rahim', 'ur': 'بڑا رحم کرنے والا'},
  {'ar': 'الْمَلِكُ', 'en': 'Al-Malik', 'ur': 'حقیقی بادشاہ'},
  {'ar': 'الْقُدُّوسُ', 'en': 'Al-Quddus', 'ur': 'نہایت پاک'},
  {'ar': 'السَّلَامُ', 'en': 'As-Salam', 'ur': 'سلامتی دینے والا'},
  {'ar': 'الْمُؤْمِنُ', 'en': 'Al-Mu\'min', 'ur': 'امن و ایمان دینے والا'},
  {'ar': 'الْمُهَيْمِنُ', 'en': 'Al-Muhaymin', 'ur': 'محافظ و نگہبان'},
  {'ar': 'الْعَزِيزُ', 'en': 'Al-Aziz', 'ur': 'سب پر غالب'},
  {'ar': 'الْجَبَّارُ', 'en': 'Al-Jabbar', 'ur': 'زبردست'},
  {'ar': 'الْمُتَكَبِّرُ', 'en': 'Al-Mutakabbir', 'ur': 'بڑائی والا'},
  {'ar': 'الْخَالِقُ', 'en': 'Al-Khaliq', 'ur': 'پیدا کرنے والا'},
  {'ar': 'الْبَارِئُ', 'en': 'Al-Bari\'', 'ur': 'جان ڈالنے والا'},
  {'ar': 'الْمُصَوِّرُ', 'en': 'Al-Musawwir', 'ur': 'صورت گری کرنے والا'},
  {'ar': 'الْغَفَّارُ', 'en': 'Al-Ghaffar', 'ur': 'بڑا بخشنے والا'},
  {'ar': 'الْقَهَّارُ', 'en': 'Al-Qahhar', 'ur': 'سب کو قابو میں رکھنے والا'},
  {'ar': 'الْوَهَّابُ', 'en': 'Al-Wahhab', 'ur': 'سب کچھ عطا کرنے والا'},
  {'ar': 'الرَّزَّاقُ', 'en': 'Ar-Razzaq', 'ur': 'رزق دینے والا'},
  {'ar': 'الْفَتَّاحُ', 'en': 'Al-Fattah', 'ur': 'مشکل کشا'},
  {'ar': 'الْعَلِيمُ', 'en': 'Al-Alim', 'ur': 'سب کچھ جاننے والا'},
  {'ar': 'الْقَابِضُ', 'en': 'Al-Qabid', 'ur': 'تنگی کرنے والا'},
  {'ar': 'الْبَاسِطُ', 'en': 'Al-Basit', 'ur': 'فراخی کرنے والا'},
  {'ar': 'الْخَافِضُ', 'en': 'Al-Khafid', 'ur': 'پست کرنے والا'},
  {'ar': 'الرَّافِعُ', 'en': 'Ar-Rafi\'', 'ur': 'بلند کرنے والا'},
  {'ar': 'الْمُعِزُّ', 'en': 'Al-Mu\'izz', 'ur': 'عزت دینے والا'},
  {'ar': 'الْمُذِلُّ', 'en': 'Al-Mudhill', 'ur': 'ذلت دینے والا'},
  {'ar': 'السَّمِيعُ', 'en': 'As-Sami\'', 'ur': 'سب کچھ سننے والا'},
  {'ar': 'الْبَصِيرُ', 'en': 'Al-Basir', 'ur': 'سب کچھ دیکھنے والا'},
  {'ar': 'الْحَكَمُ', 'en': 'Al-Hakam', 'ur': 'فیصلہ کرنے والا'},
  {'ar': 'الْعَدْلُ', 'en': 'Al-Adl', 'ur': 'سراپا انصاف'},
  {'ar': 'اللَّطِيفُ', 'en': 'Al-Latif', 'ur': 'لطف و کرم کرنے والا'},
  {'ar': 'الْخَبِيرُ', 'en': 'Al-Khabir', 'ur': 'باخبر'},
  {'ar': 'الْحَلِيمُ', 'en': 'Al-Halim', 'ur': 'بردبار'},
  {'ar': 'الْعَظِيمُ', 'en': 'Al-Azim', 'ur': 'بہت عظمت والا'},
  {'ar': 'الْغَفُورُ', 'en': 'Al-Ghafur', 'ur': 'بہت بخشنے والا'},
  {'ar': 'الشَّكُورُ', 'en': 'Ash-Shakur', 'ur': 'قدر دان'},
  {'ar': 'الْعَلِيُّ', 'en': 'Al-Aliyy', 'ur': 'بہت بلند'},
  {'ar': 'الْكَبِيرُ', 'en': 'Al-Kabir', 'ur': 'بہت بڑا'},
  {'ar': 'الْحَفِيظُ', 'en': 'Al-Hafiz', 'ur': 'حفاظت کرنے والا'},
  {'ar': 'الْمُقِيتُ', 'en': 'Al-Muqit', 'ur': 'توانائی دینے والا'},
  {'ar': 'الْحَسِيبُ', 'en': 'Al-Hasib', 'ur': 'کفایت کرنے والا'},
  {'ar': 'الْجَلِيلُ', 'en': 'Al-Jalil', 'ur': 'بزرگ و برتر'},
  {'ar': 'الْكَرِيمُ', 'en': 'Al-Karim', 'ur': 'کرم کرنے والا'},
  {'ar': 'الرَّقِيبُ', 'en': 'Ar-Raqib', 'ur': 'نگہبان'},
  {'ar': 'الْمُجِيبُ', 'en': 'Al-Mujib', 'ur': 'دعائیں قبول کرنے والا'},
  {'ar': 'الْوَاسِعُ', 'en': 'Al-Wasi\'', 'ur': 'وسعت والا'},
  {'ar': 'الْحَكِيمُ', 'en': 'Al-Hakim', 'ur': 'حکمت والا'},
  {'ar': 'الْوَدُودُ', 'en': 'Al-Wadud', 'ur': 'محبت کرنے والا'},
  {'ar': 'الْمَجِيدُ', 'en': 'Al-Majid', 'ur': 'بزرگی والا'},
  {'ar': 'الْبَاعِثُ', 'en': 'Al-Ba\'ith', 'ur': 'مردوں کو اٹھانے والا'},
  {'ar': 'الشَّهِيدُ', 'en': 'Ash-Shahid', 'ur': 'حاضر و ناظر'},
  {'ar': 'الْحَقُّ', 'en': 'Al-Haqq', 'ur': 'برحق'},
  {'ar': 'الْوَكِيلُ', 'en': 'Al-Wakil', 'ur': 'کارساز'},
  {'ar': 'الْقَوِيُّ', 'en': 'Al-Qawiyy', 'ur': 'طاقتور'},
  {'ar': 'الْمَتِينُ', 'en': 'Al-Matin', 'ur': 'نہایت مضبوط'},
  {'ar': 'الْوَلِيُّ', 'en': 'Al-Waliyy', 'ur': 'حمایتی و مددگار'},
  {'ar': 'الْحَمِيدُ', 'en': 'Al-Hamid', 'ur': 'خوبیوں والا'},
  {'ar': 'الْمُحْصِي', 'en': 'Al-Muhsi', 'ur': 'شمار کرنے والا'},
  {'ar': 'الْمُبْدِئُ', 'en': 'Al-Mubdi\'', 'ur': 'پہلی بار پیدا کرنے والا'},
  {'ar': 'الْمُعِيدُ', 'en': 'Al-Mu\'id', 'ur': 'دوبارہ پیدا کرنے والا'},
  {'ar': 'الْمُحْيِي', 'en': 'Al-Muhyi', 'ur': 'زندگی دینے والا'},
  {'ar': 'الْمُمِيتُ', 'en': 'Al-Mumit', 'ur': 'موت دینے والا'},
  {'ar': 'الْحَيُّ', 'en': 'Al-Hayy', 'ur': 'ہمیشہ زندہ رہنے والا'},
  {'ar': 'الْقَيُّومُ', 'en': 'Al-Qayyum', 'ur': 'سب کو قائم رکھنے والا'},
  {'ar': 'الْوَاجِدُ', 'en': 'Al-Wajid', 'ur': 'پانے والا'},
  {'ar': 'الْمَاجِدُ', 'en': 'Al-Majid', 'ur': 'بزرگی والا'},
  {'ar': 'الْوَاحِدُ', 'en': 'Al-Wahid', 'ur': 'اکیلا'},
  {'ar': 'الْأَحَدُ', 'en': 'Al-Ahad', 'ur': 'یکتا'},
  {'ar': 'الصَّمَدُ', 'en': 'As-Samad', 'ur': 'بے نیاز'},
  {'ar': 'الْقَادِرُ', 'en': 'Al-Qadir', 'ur': 'قدرت والا'},
  {'ar': 'الْمُقْتَدِرُ', 'en': 'Al-Muqtadir', 'ur': 'بااختیار'},
  {'ar': 'الْمُقَدِّمُ', 'en': 'Al-Muqaddim', 'ur': 'آگے کرنے والا'},
  {'ar': 'الْمُؤَخِّرُ', 'en': 'Al-Mu\'akhkhir', 'ur': 'پیچھے کرنے والا'},
  {'ar': 'الْأَوَّلُ', 'en': 'Al-Awwal', 'ur': 'سب سے پہلے'},
  {'ar': 'الْآخِرُ', 'en': 'Al-Akhir', 'ur': 'سب کے بعد'},
  {'ar': 'الظَّاهِرُ', 'en': 'Az-Zahir', 'ur': 'ظاہر'},
  {'ar': 'الْبَاطِنُ', 'en': 'Al-Batin', 'ur': 'پوشیدہ'},
  {'ar': 'الْوَالِي', 'en': 'Al-Wali', 'ur': 'مالک و مختار'},
  {'ar': 'الْمُتَعَالِي', 'en': 'Al-Muta\'ali', 'ur': 'نہایت بلند'},
  {'ar': 'الْبَرُّ', 'en': 'Al-Barr', 'ur': 'بڑا سلوک کرنے والا'},
  {'ar': 'التَّوَّابُ', 'en': 'At-Tawwab', 'ur': 'توبہ قبول کرنے والا'},
  {'ar': 'الْمُنْتَقِمُ', 'en': 'Al-Muntaqim', 'ur': 'بدلہ لینے والا'},
  {'ar': 'الْعَفُوُّ', 'en': 'Al-Afuww', 'ur': 'معاف کرنے والا'},
  {'ar': 'الرَّءُوفُ', 'en': 'Ar-Ra\'uf', 'ur': 'نہایت شفیق'},
  {'ar': 'مَالِكُ الْمُلْكِ', 'en': 'Malik-ul-Mulk', 'ur': 'سارے جہاں کا مالک'},
  {'ar': 'ذُو الْجَلَالِ وَالْإِكْرَامِ', 'en': 'Dhul-Jalali wal-Ikram', 'ur': 'عظمت اور جلال والا'},
  {'ar': 'الْمُقْسِطُ', 'en': 'Al-Muqsit', 'ur': 'انصاف کرنے والا'},
  {'ar': 'الْجَامِعُ', 'en': 'Al-Jami\'', 'ur': 'جمع کرنے والا'},
  {'ar': 'الْغَنِيُّ', 'en': 'Al-Ghaniyy', 'ur': 'بے پرواہ'},
  {'ar': 'الْمُغْنِي', 'en': 'Al-Mughni', 'ur': 'مالدار کرنے والا'},
  {'ar': 'الْمَانِعُ', 'en': 'Al-Mani\'', 'ur': 'روکنے والا'},
  {'ar': 'الضَّارُّ', 'en': 'Ad-Darr', 'ur': 'نقصان پہنچانے والا'},
  {'ar': 'النَّافِعُ', 'en': 'An-Nafi\'', 'ur': 'نفع پہنچانے والا'},
  {'ar': 'النُّورُ', 'en': 'An-Nur', 'ur': 'روشن کرنے والا'},
  {'ar': 'الْهَادِي', 'en': 'Al-Hadi', 'ur': 'ہدایت دینے والا'},
  {'ar': 'الْبَدِيعُ', 'en': 'Al-Badi\'', 'ur': 'انوکھا پیدا کرنے والا'},
  {'ar': 'الْبَاقِي', 'en': 'Al-Baqi', 'ur': 'ہمیشہ رہنے والا'},
  {'ar': 'الْوَارِثُ', 'en': 'Al-Warith', 'ur': 'وارث'},
  {'ar': 'الرَّشِيدُ', 'en': 'Ar-Rashid', 'ur': 'ہدایت پانے والا'},
  {'ar': 'الصَّبُورُ', 'en': 'As-Sabur', 'ur': 'نہایت صبر والا'},
];

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      itemCount: names.length,
      itemBuilder: (context, i) => Card(
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 12),
        color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: Colors.grey.withOpacity(0.2)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(names[i]['en']!,
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isDark ? Colors.white : Colors.black87),
                        softWrap: true),
                    const SizedBox(height: 4),
                    Text(names[i]['ur']!,
                        style: GoogleFonts.notoNastaliqUrdu(
                            color: Colors.teal, fontSize: 14),
                        softWrap: true),
                  ],
                ),
              ),
              const SizedBox(width: 15),
              Text(names[i]['ar']!,
                  style: GoogleFonts.amiri(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F7B63))),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// INLINE SCAFFOLD WRAPPER
// Renders WuduGuideScreen / SalahGuideScreen without their own AppBar by
// overriding the Theme's scaffoldBackgroundColor and zeroing out the top
// MediaQuery padding (the parent SafeArea already handles system insets).
// ─────────────────────────────────────────────────────────────────────────────
class _InlineScaffoldWrapper extends StatelessWidget {
  const _InlineScaffoldWrapper({required this.child, required this.isDark});
  final Widget child;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      // Strip the top system padding — parent SafeArea already consumed it.
      data: MediaQuery.of(context).copyWith(padding: EdgeInsets.zero),
      child: Theme(
        data: Theme.of(context).copyWith(
          // Match the parent container background so the seam is invisible.
          scaffoldBackgroundColor:
              isDark ? const Color(0xFF1C1C1E) : Colors.white,
          appBarTheme: AppBarTheme(
            // Hide the inner AppBar by collapsing it to zero height and making
            // it transparent — the parent header already shows the title.
            toolbarHeight: 0,
            elevation: 0,
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
          ),
        ),
        child: child,
      ),
    );
  }
}

// ── Utility Card — overflow-safe with FittedBox ────────────────────────────
class _UtilityCard extends StatefulWidget {
  final _MenuItem item;
  final VoidCallback onTap;
  const _UtilityCard({required this.item, required this.onTap});
  @override
  State<_UtilityCard> createState() => _UtilityCardState();
}

class _UtilityCardState extends State<_UtilityCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressCtrl;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 1.0, end: 0.94).animate(
          CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut)),
      child: GestureDetector(
        onTapDown: (_) => _pressCtrl.forward(),
        onTapUp: (_) { _pressCtrl.reverse(); widget.onTap(); },
        onTapCancel: () => _pressCtrl.reverse(),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              decoration: BoxDecoration(
                gradient: widget.item.gradient,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x30000000),
                      blurRadius: 20,
                      offset: Offset(0, 8))
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(widget.item.icon, size: 42, color: Colors.white),
                    const SizedBox(height: 12),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        widget.item.title,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14),
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
}

class _MenuItem {
  final String title;
  final IconData icon;
  final LinearGradient gradient;
  const _MenuItem({
    required this.title,
    required this.icon,
    required this.gradient,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// QIBLA COMPASS WIDGET — original logic 100% unchanged
// ─────────────────────────────────────────────────────────────────────────────
class QiblaCompassWidget extends StatefulWidget {
  const QiblaCompassWidget({super.key});
  @override
  State<QiblaCompassWidget> createState() => _QiblaCompassWidgetState();
}

class _QiblaCompassWidgetState extends State<QiblaCompassWidget>
    with SingleTickerProviderStateMixin {
  double _continuousHeading = 0.0;
  double _qiblaDirection = 0;
  Position? _position;
  StreamSubscription<CompassEvent>? _compassSubscription;
  StreamSubscription<Position>? _positionSubscription;
  double? _distanceToKaabaKm;
  String _locationError = "Loading GPS...";

  static const double _kaabaLat = 21.422487;
  static const double _kaabaLon = 39.826206;

  @override
  void initState() {
    super.initState();
    _initLocation();
    _initCompass();
  }

  double _distanceBetweenKm(double lat1, double lon1, double lat2, double lon2) {
    const double r = 6371.0;
    final double dLat = (lat2 - lat1) * pi / 180;
    final double dLon = (lon2 - lon1) * pi / 180;
    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) * cos(lat2 * pi / 180) *
            sin(dLon / 2) * sin(dLon / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return r * c;
  }

  Future<void> _initLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _locationError = "GPS is Disabled");
        await Geolocator.openLocationSettings();
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _locationError = "Permission Denied");
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() => _locationError = "Enable in Settings");
        return;
      }
      _position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      if (mounted) _updateQiblaData(_position!);
      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high, distanceFilter: 10),
      ).listen((Position position) {
        if (mounted) _updateQiblaData(position);
      });
    } catch (e) {
      debugPrint('Location Error: $e');
      setState(() => _locationError = "Location Error");
    }
  }

  void _updateQiblaData(Position position) {
    setState(() {
      _position = position;
      _qiblaDirection =
          _calculateQiblaBearing(position.latitude, position.longitude);
      _distanceToKaabaKm = _distanceBetweenKm(
          position.latitude, position.longitude, _kaabaLat, _kaabaLon);
      _locationError = "";
    });
  }

  void _initCompass() {
    _compassSubscription = FlutterCompass.events?.listen((event) {
      if (event.heading != null && mounted) {
        double rawHeading = event.heading!;
        double diff = rawHeading - (_continuousHeading % 360);
        if (diff > 180) diff -= 360;
        if (diff < -180) diff += 360;
        setState(() => _continuousHeading += diff * 0.15);
      }
    });
  }

  double _calculateQiblaBearing(double lat, double lon) {
    final latRad = lat * pi / 180;
    final lonRad = lon * pi / 180;
    final kaabaLatRad = _kaabaLat * pi / 180;
    final kaabaLonRad = _kaabaLon * pi / 180;
    final dLon = kaabaLonRad - lonRad;
    final y = sin(dLon) * cos(kaabaLatRad);
    final x = cos(latRad) * sin(kaabaLatRad) -
        sin(latRad) * cos(kaabaLatRad) * cos(dLon);
    final bearing = atan2(y, x);
    return (bearing * 180 / pi + 360) % 360;
  }

  @override
  void dispose() {
    _compassSubscription?.cancel();
    _positionSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentHeading = (_continuousHeading % 360 + 360) % 360;
    final bool isAligned =
        (currentHeading - _qiblaDirection).abs() < 5 ||
            (currentHeading - _qiblaDirection).abs() > 355;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: isAligned
                            ? const Color(0xFF0F7B63).withOpacity(0.2)
                            : Colors.black.withOpacity(0.05),
                        blurRadius: 40,
                        spreadRadius: 10,
                      )
                    ],
                  ),
                ),
                Transform.rotate(
                  angle: -_continuousHeading * (pi / 180),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(320, 320),
                        painter: CompassPainter(isDark: isDark, isAligned: isAligned),
                      ),
                      _buildQiblaMarker(),
                    ],
                  ),
                ),
                _buildCenterInfo(isDark, isAligned),
                Positioned(
                  top: 0,
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: isAligned
                        ? const Color(0xFF0F7B63)
                        : Colors.grey.withOpacity(0.5),
                    size: 40,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 50),
          _buildInstructionBox(),
        ],
      ),
    );
  }

  Widget _buildQiblaMarker() {
    final double qiblaAngle = _qiblaDirection * pi / 180;
    const double radius = 320 / 2 - 25;
    const centerX = 320 / 2;
    const centerY = 320 / 2;
    final x = centerX + radius * sin(qiblaAngle);
    final y = centerY - radius * cos(qiblaAngle);
    return Positioned(
      left: x - 25,
      top: y - 25,
      child: Image.asset('assets/Images/kabba.png',
          width: 50, height: 50, fit: BoxFit.contain),
    );
  }

  Widget _buildCenterInfo(bool isDark, bool isAligned) {
    final textColor = isDark ? Colors.white : Colors.black87;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isAligned)
          const Icon(Icons.check_circle_rounded,
              color: Color(0xFF0F7B63), size: 28),
        Text(
          '${((_continuousHeading % 360 + 360) % 360).toStringAsFixed(0)}°',
          style: GoogleFonts.poppins(
            fontSize: 44,
            fontWeight: FontWeight.bold,
            color: isAligned ? const Color(0xFF0F7B63) : textColor,
          ),
        ),
        Text('Qibla',
            style: GoogleFonts.poppins(
                fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white10
                : Colors.black.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _distanceToKaabaKm != null
                ? '${_distanceToKaabaKm!.toStringAsFixed(0)} km'
                : _locationError,
            style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: textColor),
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F7B63).withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF0F7B63).withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.vibration_rounded,
              color: Color(0xFF0F7B63), size: 18),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _initLocation,
            child: Text(
              _locationError == "GPS is Disabled" ||
                      _locationError == "Permission Denied"
                  ? "Tap here to retry GPS setup"
                  : "Wave phone in ∞ to calibrate",
              style: GoogleFonts.poppins(
                  color: const Color(0xFF0F7B63),
                  fontSize: 11,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class CompassPainter extends CustomPainter {
  final bool isDark;
  final bool isAligned;
  CompassPainter({required this.isDark, required this.isAligned});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paintDial = Paint()
      ..color = isDark
          ? Colors.white.withOpacity(0.05)
          : Colors.black.withOpacity(0.02)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius - 15, paintDial);

    final tickPaint = Paint()..strokeCap = StrokeCap.round;
    for (var i = 0; i < 360; i += 5) {
      final isMajor = i % 30 == 0;
      final tickLength = isMajor ? 12.0 : 6.0;
      tickPaint.strokeWidth = isMajor ? 2 : 1;
      tickPaint.color = isMajor
          ? (isDark ? Colors.white60 : Colors.black45)
          : (isDark ? Colors.white24 : Colors.black12);
      final angle = i * pi / 180;
      final start = Offset(
        center.dx + (radius - 20 - tickLength) * cos(angle),
        center.dy + (radius - 20 - tickLength) * sin(angle),
      );
      final end = Offset(
        center.dx + (radius - 20) * cos(angle),
        center.dy + (radius - 20) * sin(angle),
      );
      canvas.drawLine(start, end, tickPaint);
      if (isMajor && i != 0 && i != 90 && i != 180 && i != 270) {
        _drawDegreeText(canvas, center, radius - 50, i.toString());
      }
    }
    _drawCardinal(canvas, center, radius - 25, "N", Colors.redAccent);
    _drawCardinal(canvas, center, radius - 25, "E",
        isDark ? Colors.white70 : Colors.black54);
    _drawCardinal(canvas, center, radius - 25, "S",
        isDark ? Colors.white70 : Colors.black54);
    _drawCardinal(canvas, center, radius - 25, "W",
        isDark ? Colors.white70 : Colors.black54);
  }

  void _drawDegreeText(Canvas canvas, Offset center, double radius, String text) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: GoogleFonts.poppins(
            fontSize: 10,
            color: isDark ? Colors.white30 : Colors.black26,
            fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final angle = (int.parse(text) - 90) * pi / 180;
    final offset = Offset(
      center.dx + radius * cos(angle) - textPainter.width / 2,
      center.dy + radius * sin(angle) - textPainter.height / 2,
    );
    textPainter.paint(canvas, offset);
  }

  void _drawCardinal(Canvas canvas, Offset center, double radius,
      String text, Color color) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: GoogleFonts.poppins(
            fontSize: 20, color: color, fontWeight: FontWeight.w900),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    double angle;
    switch (text) {
      case "N": angle = -90; break;
      case "E": angle = 0;   break;
      case "S": angle = 90;  break;
      case "W": angle = 180; break;
      default:  angle = 0;
    }
    final rad = angle * pi / 180;
    final offset = Offset(
      center.dx + radius * cos(rad) - textPainter.width / 2,
      center.dy + radius * sin(rad) - textPainter.height / 2,
    );
    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant CompassPainter oldDelegate) =>
      oldDelegate.isDark != isDark || oldDelegate.isAligned != isAligned;
}
