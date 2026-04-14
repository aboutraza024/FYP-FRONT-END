import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrayerSettingsScreen extends StatefulWidget {
  const PrayerSettingsScreen({super.key});
  @override
  State<PrayerSettingsScreen> createState() => _PrayerSettingsScreenState();
}

class _PrayerSettingsScreenState extends State<PrayerSettingsScreen>
    with WidgetsBindingObserver {
  bool _autoSilence = true;
  bool _isBatteryOptimized = false;
  bool _hasDndAccess = false;
  bool _hasExactAlarmAccess = false;

  static const platform = MethodChannel('silent_control');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadSettings();
    _checkSystemStatuses();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Re-check permissions automatically when user returns from phone settings
    if (state == AppLifecycleState.resumed) {
      _checkSystemStatuses();
    }
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() => _autoSilence = prefs.getBool('auto_silence') ?? true);
    }
  }

  Future<void> _checkSystemStatuses() async {
    try {
      final bool isIgnoring = await platform.invokeMethod('isIgnoringBatteryOptimizations');
      final bool hasDnd = await platform.invokeMethod('hasDndAccess');
      final bool hasExact = await platform.invokeMethod('hasExactAlarmPermission');

      if (mounted) {
        setState(() {
          _isBatteryOptimized = isIgnoring;
          _hasDndAccess = hasDnd;
          _hasExactAlarmAccess = hasExact;
        });
      }
    } catch (e) {
      debugPrint("Status check failed: $e");
    }
  }

  Future<void> _toggleSilence(bool val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auto_silence', val);
    if (mounted) setState(() => _autoSilence = val);

    if (val) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Auto Silencer Enabled. Open Prayer Times to sync alarms."),
          ),
        );
      }
    } else {
      // ── FIX P6: Wrap each invokeMethod call in its own try-catch ──────────
      // A single PlatformException no longer breaks the entire cancel sequence.
      final List<String> prayers = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha', 'Jumma'];
      for (String prayer in prayers) {
        try {
          await platform.invokeMethod('cancelAlarmsForPrayer', {'prayer': prayer});
        } catch (e) {
          debugPrint("cancelAlarmsForPrayer failed for $prayer: $e");
        }
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Auto Silencer Settings",
            style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: const Color(0xFF059669),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Master Switch ────────────────────────────────────────────────
          SwitchListTile(
            title: Text("Auto Silencer Master",
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            subtitle: const Text("Globally enable or disable auto-silencing"),
            value: _autoSilence,
            activeColor: const Color(0xFF059669),
            onChanged: _toggleSilence,
          ),
          const Divider(),

          // ── DND Permission ───────────────────────────────────────────────
          ListTile(
            leading: Icon(
              _hasDndAccess
                  ? Icons.do_not_disturb_off
                  : Icons.notification_important,
              color: _hasDndAccess ? Colors.green : Colors.red,
            ),
            title: Text("DND Permission",
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
            subtitle: Text(
              _hasDndAccess
                  ? "Access to change ringer mode is active"
                  : "Tap to grant Do Not Disturb access",
            ),
            trailing: _hasDndAccess
                ? const Text("ACTIVE",
                    style: TextStyle(
                        color: Colors.green, fontWeight: FontWeight.bold))
                : OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                    onPressed: () async {
                      try {
                        await platform.invokeMethod('openDndSettings');
                      } catch (e) {
                        debugPrint("openDndSettings error: $e");
                      }
                    },
                    child: const Text("FIX"),
                  ),
            onTap: !_hasDndAccess
                ? () async {
                    try {
                      await platform.invokeMethod('openDndSettings');
                    } catch (e) {
                      debugPrint("openDndSettings error: $e");
                    }
                  }
                : null,
          ),
          const Divider(),

          // ── Background Reliability (Battery) ─────────────────────────────
          ListTile(
            leading: Icon(Icons.battery_saver_rounded,
                color: _isBatteryOptimized ? Colors.green : Colors.orange),
            title: Text("Background Reliability",
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
            subtitle: const Text(
                "Allow app to run even when closed to ensure silence triggers"),
            trailing: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor:
                    _isBatteryOptimized ? Colors.green : Colors.orange,
                side: BorderSide(
                    color: _isBatteryOptimized ? Colors.green : Colors.orange),
              ),
              onPressed: () async {
                try {
                  await platform
                      .invokeMethod('requestIgnoreBatteryOptimizations');
                } catch (e) {
                  debugPrint("requestIgnoreBatteryOptimizations error: $e");
                }
              },
              child: Text(_isBatteryOptimized ? "ENABLED" : "ENABLE"),
            ),
          ),
          const Divider(),

          // ── Exact Alarms (Android 12+) ────────────────────────────────────
          ListTile(
            leading: Icon(Icons.alarm_on_rounded,
                color: _hasExactAlarmAccess ? Colors.green : Colors.orange),
            title: Text("Exact Timings",
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
            subtitle: const Text(
                "Required for Android 12+ to silence the phone exactly on the minute"),
            trailing: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor:
                    _hasExactAlarmAccess ? Colors.green : Colors.orange,
                side: BorderSide(
                    color:
                        _hasExactAlarmAccess ? Colors.green : Colors.orange),
              ),
              onPressed: () async {
                try {
                  await platform.invokeMethod('requestExactAlarmPermission');
                } catch (e) {
                  debugPrint("requestExactAlarmPermission error: $e");
                }
              },
              child: Text(_hasExactAlarmAccess ? "GRANTED" : "GRANT"),
            ),
          ),

          const SizedBox(height: 30),
          const Text(
            "Note: For the silencer to be 100% accurate, all permissions above should be active.",
            style: TextStyle(
                fontSize: 11,
                color: Colors.grey,
                fontStyle: FontStyle.italic),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
