import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'app_ui_kit.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:app_settings/app_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'namaz_database.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});
  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  static const platform = MethodChannel('silent_control');

  late AnimationController _listController;
  late AnimationController _glowController;
  late Animation<double> _scaleAnimation;

  Timer? _realTimeTimer;
  String _displayClock = "";
  String _countdownText = "Calculating...";
  bool _autoSilent = true;
  bool _isCurrentlySilent = false;

  DateTime? _lastSettingsChange;

  final List<Map<String, dynamic>> _prayers = [
    {'name': 'Fajr',    'start': '05:30 AM', 'end': '05:50 AM', 'icon': Icons.wb_twilight_rounded,  'enabled': true},
    {'name': 'Dhuhr',   'start': '01:30 PM', 'end': '01:50 PM', 'icon': Icons.wb_sunny_rounded,     'enabled': true},
    {'name': 'Asr',     'start': '04:30 PM', 'end': '04:50 PM', 'icon': Icons.wb_sunny_outlined,    'enabled': true},
    {'name': 'Maghrib', 'start': '07:30 PM', 'end': '07:50 PM', 'icon': Icons.nights_stay_rounded,  'enabled': true},
    {'name': 'Isha',    'start': '09:00 PM', 'end': '09:20 PM', 'icon': Icons.bedtime_rounded,      'enabled': true},
    {'name': 'Jumma',   'start': '01:30 PM', 'end': '02:00 PM', 'icon': Icons.mosque_rounded,       'enabled': true},
  ];

  // ─── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _listController = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this)..forward();
    _glowController = AnimationController(
        duration: const Duration(seconds: 3), vsync: this)..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _initScreenData();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkPermissions());
    _startRealTimeLogic();
  }

  Future<void> _initScreenData() async {
    await _loadMasterSwitch();
    await _loadDataFromDb();
  }

  Future<void> _loadMasterSwitch() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) setState(() => _autoSilent = prefs.getBool('auto_silence') ?? true);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _evaluateSilentState(DateTime.now());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _realTimeTimer?.cancel();
    _listController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  // ─── Database ──────────────────────────────────────────────────────────────

  Future<void> _loadDataFromDb() async {
    final data = await NamazDatabase.instance.getTimes();
    if (!mounted) return;

    if (data.isNotEmpty) {
      final dbRow = data.first;
      setState(() {
        _prayers[0]['start'] = dbRow['fajrBefore'];    _prayers[0]['end'] = dbRow['fajrAfter'];    _prayers[0]['enabled'] = dbRow['fajrOn'] == 1;
        _prayers[1]['start'] = dbRow['dhuhrBefore'];   _prayers[1]['end'] = dbRow['dhuhrAfter'];   _prayers[1]['enabled'] = dbRow['dhuhrOn'] == 1;
        _prayers[2]['start'] = dbRow['asrBefore'];     _prayers[2]['end'] = dbRow['asrAfter'];     _prayers[2]['enabled'] = dbRow['asrOn'] == 1;
        _prayers[3]['start'] = dbRow['maghribBefore']; _prayers[3]['end'] = dbRow['maghribAfter']; _prayers[3]['enabled'] = dbRow['maghribOn'] == 1;
        _prayers[4]['start'] = dbRow['ishaBefore'];    _prayers[4]['end'] = dbRow['ishaAfter'];    _prayers[4]['enabled'] = dbRow['ishaOn'] == 1;
        _prayers[5]['start'] = dbRow['jummaBefore'];   _prayers[5]['end'] = dbRow['jummaAfter'];   _prayers[5]['enabled'] = dbRow['jummaOn'] == 1;
      });
      if (_autoSilent) await _scheduleAllAlarmsForToday();
    } else {
      await _syncToDatabase();
    }
  }

  Future<void> _syncToDatabase() async {
    final model = NamazTimeModel(
      fajrBefore:    _prayers[0]['start'], fajrAfter:    _prayers[0]['end'], fajrOn:    _prayers[0]['enabled'] ? 1 : 0,
      dhuhrBefore:   _prayers[1]['start'], dhuhrAfter:   _prayers[1]['end'], dhuhrOn:   _prayers[1]['enabled'] ? 1 : 0,
      asrBefore:     _prayers[2]['start'], asrAfter:     _prayers[2]['end'], asrOn:     _prayers[2]['enabled'] ? 1 : 0,
      maghribBefore: _prayers[3]['start'], maghribAfter: _prayers[3]['end'], maghribOn: _prayers[3]['enabled'] ? 1 : 0,
      ishaBefore:    _prayers[4]['start'], ishaAfter:    _prayers[4]['end'], ishaOn:    _prayers[4]['enabled'] ? 1 : 0,
      jummaBefore:   _prayers[5]['start'], jummaAfter:   _prayers[5]['end'], jummaOn:   _prayers[5]['enabled'] ? 1 : 0,
    );
    await NamazDatabase.instance.saveTimes(model);
    if (_autoSilent) await _scheduleAllAlarmsForToday();
  }

  // ─── Real-time logic ───────────────────────────────────────────────────────

  void _startRealTimeLogic() {
    _realTimeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      final now = DateTime.now();
      _evaluateSilentState(now);

      if (now.second == 0 && _autoSilent) {
        final lastChange = _lastSettingsChange;
        final recentChange = lastChange != null &&
            now.difference(lastChange).inSeconds < 90;
        if (!recentChange) {
          _checkNamazTimes(now);
        }
      }
    });
  }

  void _evaluateSilentState(DateTime now) {
    if (!mounted) return;
    bool isSilentNow = false;
    if (_autoSilent) {
      for (var prayer in _prayers) {
        if (!prayer['enabled']) continue;
        if (prayer['name'] == 'Jumma' && now.weekday != DateTime.friday) continue;
        if (prayer['name'] == 'Dhuhr' && now.weekday == DateTime.friday) continue;
        final DateTime start = _convertToDateTime(prayer['start']);
        final DateTime end   = _convertToDateTime(prayer['end']);
        if (now.isAfter(start) && now.isBefore(end)) { isSilentNow = true; break; }
      }
    }
    setState(() {
      _displayClock      = DateFormat('hh:mm:ss a').format(now);
      _isCurrentlySilent = isSilentNow;
      _countdownText     = isSilentNow ? "Silent Mode On" : _calculateCountdown(now);
    });
  }

  Future<void> _checkNamazTimes(DateTime now) async {
    for (var prayer in _prayers) {
      if (!prayer['enabled']) continue;
      if (prayer['name'] == 'Jumma' && now.weekday != DateTime.friday) continue;
      if (prayer['name'] == 'Dhuhr' && now.weekday == DateTime.friday) continue;
      final DateTime startDt = _convertToDateTime(prayer['start']);
      final DateTime endDt   = _convertToDateTime(prayer['end']);
      if (now.hour == startDt.hour && now.minute == startDt.minute) await _enableSilentMode();
      if (now.hour == endDt.hour   && now.minute == endDt.minute)   await _disableSilentMode();
    }
  }

  Future<void> _enableSilentMode() async {
    try { await platform.invokeMethod('setSilentMode'); } catch (e) { debugPrint("setSilentMode: $e"); }
  }

  Future<void> _disableSilentMode() async {
    try { await platform.invokeMethod('setNormalMode'); } catch (e) { debugPrint("setNormalMode: $e"); }
  }

  // ─── FIXED: Schedule alarms with correct day-of-week logic ────────────────

  Future<void> _scheduleAllAlarmsForToday() async {
    final now = DateTime.now();

    for (var prayer in _prayers) {
      final prayerName = prayer['name'] as String;
      try {
        await platform.invokeMethod('cancelAlarmsForPrayer', {'prayer': prayerName});
      } catch (e) {
        debugPrint("cancel error $prayerName: $e");
      }
      if (!prayer['enabled'] || !_autoSilent) continue;

      DateTime silentTime = _convertToDateTime(prayer['start']);
      DateTime normalTime = _convertToDateTime(prayer['end']);

      if (prayerName == 'Jumma') {
        // ── JUMMA: must only ever fire on Friday ──────────────────────────
        // BUG WAS: on Thursday at 11AM, Jumma at 1:30PM is still in the
        // future so no +1 was added — alarm fired on Thursday, not Friday.
        // FIX: compute exact days to next Friday, always push forward.
        final daysUntilFriday = (DateTime.friday - now.weekday + 7) % 7;
        if (daysUntilFriday == 0) {
          // Today IS Friday — only reschedule to next week if already passed
          if (silentTime.isBefore(now)) {
            silentTime = silentTime.add(const Duration(days: 7));
            normalTime = normalTime.add(const Duration(days: 7));
          }
        } else {
          // Today is NOT Friday — always push to next Friday, no exceptions
          silentTime = silentTime.add(Duration(days: daysUntilFriday));
          normalTime = normalTime.add(Duration(days: daysUntilFriday));
        }
      } else if (prayerName == 'Dhuhr') {
        // ── DHUHR: must never fire on Friday (Jumma replaces it) ──────────
        if (now.weekday == DateTime.friday) {
          // Today is Friday — push Dhuhr to Saturday
          silentTime = silentTime.add(const Duration(days: 1));
          normalTime = normalTime.add(const Duration(days: 1));
        } else {
          // Normal day — add +1 only if already passed
          if (silentTime.isBefore(now)) silentTime = silentTime.add(const Duration(days: 1));
          if (normalTime.isBefore(now)) normalTime = normalTime.add(const Duration(days: 1));
          // If +1 lands on Friday, skip EACH independently to Saturday
          if (silentTime.weekday == DateTime.friday) {
            silentTime = silentTime.add(const Duration(days: 1));
          }
          if (normalTime.weekday == DateTime.friday) {
            normalTime = normalTime.add(const Duration(days: 1));
          }
        }
      } else {
        // ── ALL OTHER PRAYERS: standard rule ──────────────────────────────
        if (silentTime.isBefore(now)) silentTime = silentTime.add(const Duration(days: 1));
        if (normalTime.isBefore(now)) normalTime = normalTime.add(const Duration(days: 1));
      }

      try {
        await platform.invokeMethod('scheduleEnable',  {'timestamp': silentTime.millisecondsSinceEpoch, 'prayerName': prayerName});
        await platform.invokeMethod('scheduleDisable', {'timestamp': normalTime.millisecondsSinceEpoch, 'prayerName': prayerName});
        debugPrint("Scheduled $prayerName: silent at $silentTime, normal at $normalTime");
      } catch (e) {
        debugPrint("schedule error $prayerName: $e");
      }
    }
  }

  bool _isCurrentlyInAnyPrayerWindow() {
    final now = DateTime.now();
    for (var prayer in _prayers) {
      if (!prayer['enabled']) continue;
      if (prayer['name'] == 'Jumma' && now.weekday != DateTime.friday) continue;
      if (prayer['name'] == 'Dhuhr' && now.weekday == DateTime.friday) continue;
      final start = _convertToDateTime(prayer['start']);
      final end   = _convertToDateTime(prayer['end']);
      if (now.isAfter(start) && now.isBefore(end)) return true;
    }
    return false;
  }

  bool _isPrayerCurrentlyActive(int index) {
    final now    = DateTime.now();
    final prayer = _prayers[index];
    if (prayer['name'] == 'Jumma' && now.weekday != DateTime.friday) return false;
    if (prayer['name'] == 'Dhuhr' && now.weekday == DateTime.friday) return false;
    final start = _convertToDateTime(prayer['start']);
    final end   = _convertToDateTime(prayer['end']);
    return now.isAfter(start) && now.isBefore(end);
  }

  String _calculateCountdown(DateTime now) {
    Duration minDiff = const Duration(days: 8); // sentinel larger than any real gap
    String nextName = "None";
    for (var prayer in _prayers) {
      if (!prayer['enabled']) continue;
      // Dhuhr is replaced by Jumma on Friday — skip it today
      if (prayer['name'] == 'Dhuhr' && now.weekday == DateTime.friday) continue;

      DateTime pDt = _convertToDateTime(prayer['start']);

      if (prayer['name'] == 'Jumma') {
        // Jumma only ever fires on Friday — compute exact next Friday
        if (now.weekday != DateTime.friday) {
          final daysUntilFriday = (DateTime.friday - now.weekday + 7) % 7;
          pDt = pDt.add(Duration(days: daysUntilFriday));
        } else {
          // Today IS Friday but Jumma time already passed — next week
          if (pDt.isBefore(now)) pDt = pDt.add(const Duration(days: 7));
        }
      } else {
        // All other prayers: roll to tomorrow if already passed today
        if (pDt.isBefore(now)) pDt = pDt.add(const Duration(days: 1));
        // Dhuhr must not land on Friday — skip another day if so
        if (prayer['name'] == 'Dhuhr' && pDt.weekday == DateTime.friday) {
          pDt = pDt.add(const Duration(days: 1));
        }
      }

      final diff = pDt.difference(now);
      if (diff.isNegative) continue;
      if (diff < minDiff) { minDiff = diff; nextName = prayer['name']; }
    }

    if (nextName == "None") return "No active prayers scheduled";
    if (minDiff.inDays >= 1) {
      return "$nextName in ${minDiff.inDays}d ${minDiff.inHours % 24}h";
    }
    return "$nextName in ${minDiff.inHours}h ${minDiff.inMinutes % 60}m";
  }

  DateTime _convertToDateTime(String timeStr) {
    final now = DateTime.now();
    try {
      final parsed = DateFormat("h:mm a", "en_US").parse(timeStr.trim());
      return DateTime(now.year, now.month, now.day, parsed.hour, parsed.minute);
    } catch (e) {
      debugPrint("_convertToDateTime parse error '$timeStr': $e");
      return DateTime(now.year, now.month, now.day, 0, 0);
    }
  }

  TimeOfDay _stringToTimeOfDay(String timeStr) {
    try {
      final t = DateFormat("h:mm a", "en_US").parse(timeStr.trim());
      return TimeOfDay(hour: t.hour, minute: t.minute);
    } catch (_) {
      return TimeOfDay.now();
    }
  }

  String _timeOfDayToFixedString(TimeOfDay tod) {
    final dt = DateTime(0, 1, 1, tod.hour, tod.minute);
    return DateFormat("h:mm a", "en_US").format(dt);
  }

  // ─── Permissions ───────────────────────────────────────────────────────────

  Future<void> _checkPermissions() async {
    try { await platform.invokeMethod('requestExactAlarmPermission'); }
    catch (e) { debugPrint("requestExactAlarmPermission: $e"); }
    try {
      final bool hasAccess = await platform.invokeMethod('hasDndAccess');
      if (!hasAccess && mounted) _showPermissionDialog();
    } catch (e) { debugPrint("hasDndAccess: $e"); }
  }

  void _showPermissionDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF2C2C2E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "DND Access Required",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
          ),
        ),
        content: Text(
          "To automatically silence your phone during Namaz, please grant 'Do Not Disturb' access.",
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: isDark ? const Color(0xFFAEAEB2) : const Color(0xFF3A3A3C),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              "Later",
              style: GoogleFonts.poppins(
                color: isDark ? const Color(0xFFAEAEB2) : Colors.grey,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F7B63),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              platform.invokeMethod('openDndSettings');
              Navigator.pop(ctx);
            },
            child: Text(
              "Grant Access",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Time picker ───────────────────────────────────────────────────────────

  Future<void> _pickStartAndEndTime(int index) async {
    final TimeOfDay? startPicked = await showTimePicker(
      context: context,
      barrierDismissible: false,
      helpText: "SELECT START TIME",
      initialTime: _stringToTimeOfDay(_prayers[index]['start']),
    );
    if (startPicked == null || !mounted) return;

    final TimeOfDay? endPicked = await showTimePicker(
      context: context,
      barrierDismissible: false,
      helpText: "SELECT END TIME",
      initialTime: _stringToTimeOfDay(_prayers[index]['end']),
    );
    if (endPicked == null || !mounted) return;

    setState(() {
      _prayers[index]['start'] = _timeOfDayToFixedString(startPicked);
      _prayers[index]['end']   = _timeOfDayToFixedString(endPicked);
      _lastSettingsChange = DateTime.now();
    });
    await _syncToDatabase();
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [Color(0xFF0D7B62), Color(0xFF0A5248)],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(35), topRight: Radius.circular(35),
                      ),
                    ),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                      child: Column(
                        children: [
                          _buildAnimatedTimeCard(),
                          const SizedBox(height: 25),
                          _buildReliabilityCard(isDark),
                          _buildMasterToggle(isDark),
                          const SizedBox(height: 30),
                          _buildStaggeredPrayerList(isDark),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: FloatingNavBar(
        currentIndex: 3,
        onTap: _onBottomNavTap,
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 22),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 10),
          Text('Auto Silent',
              style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildAnimatedTimeCard() {
    final Color cardColorA = _isCurrentlySilent ? const Color(0xFF991B1B) : const Color(0xFF0A4A3A);
    final Color cardColorB = _isCurrentlySilent ? const Color(0xFFDC2626) : const Color(0xFF0D7B62);
    final Color glowColor  = _isCurrentlySilent ? Colors.red : const Color(0xFF0D7B62);
    final Color badgeBg    = _isCurrentlySilent ? Colors.red.withOpacity(0.25) : Colors.green.withOpacity(0.25);
    final Color badgeText  = _isCurrentlySilent ? Colors.red[100]! : Colors.green[100]!;
    final String statusLabel = _isCurrentlySilent ? "🔇  Silent Mode On" : "🔔  Normal Mode";

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(colors: [cardColorA, cardColorB]),
          boxShadow: [BoxShadow(color: glowColor.withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 10))],
        ),
        child: Column(
          children: [
            Text('CURRENT TIME', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13, letterSpacing: 1.5)),
            const SizedBox(height: 8),
            Text(_displayClock, style: GoogleFonts.poppins(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 12),
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
              decoration: BoxDecoration(
                color: badgeBg,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: _isCurrentlySilent ? Colors.red.withOpacity(0.5) : Colors.green.withOpacity(0.5),
                  width: 1.2,
                ),
              ),
              child: Text(statusLabel,
                  style: GoogleFonts.poppins(color: badgeText, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 0.3)),
            ),
            const SizedBox(height: 10),
            Text(_countdownText, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildReliabilityCard(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 25),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(isDark ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(children: [
            const Icon(Icons.security_rounded, color: Colors.orange, size: 24),
            const SizedBox(width: 10),
            Expanded(child: Text("Critical Setup",
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold, fontSize: 15,
                    color: isDark ? Colors.orange[200] : Colors.orange[900]))),
          ]),
          const SizedBox(height: 8),
          Text("To prevent the system from stopping the silencer: Set Battery to 'Unrestricted'",
              style: GoogleFonts.poppins(fontSize: 11, color: isDark ? Colors.white70 : Colors.black87)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange, elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              onPressed: () async {
                try { await platform.invokeMethod('openAutoStartSettings'); }
                catch (e) { debugPrint("openAutoStart: $e"); }
                await AppSettings.openAppSettings(type: AppSettingsType.batteryOptimization);
              },
              child: Text("FIX BACKGROUND SETTINGS",
                  style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMasterToggle(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_mode_rounded, color: Color(0xFF0F7B63), size: 28),
          const SizedBox(width: 15),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("Auto-Silencer", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
              Text("Master Controller", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
            ]),
          ),
          Switch.adaptive(
            value: _autoSilent,
            activeColor: const Color(0xFF0F7B63),
            onChanged: (v) async {
              HapticFeedback.lightImpact();
              setState(() {
                _autoSilent = v;
                _lastSettingsChange = DateTime.now();
              });

              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('auto_silence', v);

              if (v) {
                await _scheduleAllAlarmsForToday();
              } else {
                for (var p in _prayers) {
                  try {
                    await platform.invokeMethod('cancelAlarmsForPrayer', {'prayer': p['name']});
                  } catch (e) {
                    debugPrint("cancel ${p['name']}: $e");
                  }
                }
                if (_isCurrentlyInAnyPrayerWindow()) {
                  await _disableSilentMode();
                }
              }
              await _syncToDatabase();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStaggeredPrayerList(bool isDark) {
    return Column(
      children: List.generate(_prayers.length, (i) {
        final animation = CurvedAnimation(
            parent: _listController, curve: Interval((0.1 * i), 1.0, curve: Curves.easeOutCubic));
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(animation),
          child: FadeTransition(opacity: animation, child: _buildPrayerCard(i, isDark)),
        );
      }),
    );
  }

  Widget _buildPrayerCard(int index, bool isDark) {
    final prayer   = _prayers[index];
    final now      = DateTime.now();
    final start    = _convertToDateTime(prayer['start']);
    final end      = _convertToDateTime(prayer['end']);

    // FIX: Respect day-of-week — Jumma only activates on Friday,
    // Dhuhr must NOT activate on Friday (Jumma replaces it).
    final bool isDayValidForCard = (() {
      if (prayer['name'] == 'Jumma' && now.weekday != DateTime.friday) return false;
      if (prayer['name'] == 'Dhuhr' && now.weekday == DateTime.friday) return false;
      return true;
    })();
    final isActive = prayer['enabled'] && isDayValidForCard && now.isAfter(start) && now.isBefore(end);

    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 0,
      color: isActive
          ? (isDark ? const Color(0xFF3B0A0A) : Colors.red.shade50)
          : (isDark ? const Color(0xFF2C2C2E) : Colors.grey.shade50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(
            color: isActive ? Colors.red.withOpacity(0.4) : Colors.grey.withOpacity(0.1),
            width: isActive ? 1.5 : 1.0),
      ),
      child: InkWell(
        onTap: () { HapticFeedback.selectionClick(); _pickStartAndEndTime(index); },
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (isActive ? Colors.red : const Color(0xFF0F7B63)).withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(prayer['icon'], color: isActive ? Colors.red : const Color(0xFF0F7B63), size: 26),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Text(prayer['name'], style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 17)),
                    if (isActive) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                        child: Text("ACTIVE",
                            style: GoogleFonts.poppins(
                                fontSize: 9, fontWeight: FontWeight.bold, color: Colors.red, letterSpacing: 0.5)),
                      ),
                    ],
                  ]),
                  Text("${prayer['start']} — ${prayer['end']}",
                      style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade600)),
                ]),
              ),
              Switch.adaptive(
                value: prayer['enabled'],
                activeColor: const Color(0xFF0F7B63),
                onChanged: (val) async {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _prayers[index]['enabled'] = val;
                    _lastSettingsChange = DateTime.now();
                  });
                  if (!val && _isPrayerCurrentlyActive(index)) {
                    await _disableSilentMode();
                  }
                  await _syncToDatabase();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onBottomNavTap(int index) {
    HapticFeedback.mediumImpact();
    if (index == 3) return;
    final routes = ['/', '/hadith-search', '/quran', '/prayer-times', '/utilities'];
    Navigator.pushReplacementNamed(context, routes[index]);
  }
}