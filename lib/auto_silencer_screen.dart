import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AutoSilencerScreen extends StatefulWidget {
  const AutoSilencerScreen({super.key});

  @override
  State<AutoSilencerScreen> createState() => _AutoSilencerScreenState();
}

class _AutoSilencerScreenState extends State<AutoSilencerScreen>
    with WidgetsBindingObserver {
  static const platform = MethodChannel('silent_control');
  Timer? _statusTimer;
  bool _isSilent = false;

  // ── FIX §2.5: Track master switch awareness ──────────────────────────────
  bool _masterEnabled = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadMasterSwitch();
    _startPolling();
  }

  /// ── FIX §2.5: Load master switch from SharedPreferences ─────────────────
  Future<void> _loadMasterSwitch() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() => _masterEnabled = prefs.getBool('auto_silence') ?? true);
    }
  }

  void _startPolling() {
    _checkCurrentStatus();
    // Refresh the UI every 2 seconds to match the actual Android hardware state
    _statusTimer = Timer.periodic(
      const Duration(seconds: 2),
      (t) => _checkCurrentStatus(),
    );
  }

  void _stopPolling() {
    _statusTimer?.cancel();
    _statusTimer = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // User came back to the app — refresh master switch state AND start polling
      _loadMasterSwitch();
      _startPolling();
    } else if (state == AppLifecycleState.paused) {
      // User minimized the app, stop the timer to save battery
      _stopPolling();
    }
  }

  Future<void> _checkCurrentStatus() async {
    try {
      final bool isSilentNow = await platform.invokeMethod('getCurrentStatus');
      if (mounted) {
        setState(() => _isSilent = isSilentNow);
      }
    } catch (e) {
      debugPrint("Status check failed: $e");
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopPolling();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ── FIX §2.5: Determine what to display based on master switch ───────────
    final bool showSilent = _masterEnabled && _isSilent;
    final String statusText = !_masterEnabled
        ? "AUTO SILENCER DISABLED"
        : (_isSilent ? "SILENT MODE" : "NORMAL MODE");

    final String subtitleText = !_masterEnabled
        ? "Enable in Auto Silencer Settings to activate"
        : (_isSilent
            ? "Restoring sound automatically at end of prayer"
            : "Monitoring prayer times in background...");

    final Color iconColor = !_masterEnabled
        ? Colors.grey.shade400
        : (_isSilent ? const Color(0xFF059669) : Colors.grey);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Active Silencer",
          style: GoogleFonts.poppins(
              color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF059669),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated scaling icon for better visual feedback
            AnimatedScale(
              scale: showSilent ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: Icon(
                !_masterEnabled
                    ? Icons.volume_off_rounded
                    : (_isSilent
                        ? Icons.volume_off_rounded
                        : Icons.volume_up_rounded),
                size: 120,
                color: iconColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              statusText,
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                subtitleText,
                style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),

            // ── FIX §2.5: Show "Go to Settings" shortcut when disabled ───────
            if (!_masterEnabled) ...[
              const SizedBox(height: 32),
              OutlinedButton.icon(
                onPressed: () =>
                    Navigator.pushNamed(context, '/prayer-settings'),
                icon: const Icon(Icons.settings_rounded),
                label: Text(
                  "Open Settings",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF059669),
                  side: const BorderSide(color: Color(0xFF059669)),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
