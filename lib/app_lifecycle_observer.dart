import 'package:flutter/material.dart';
import 'namaz_database.dart';

/// A [WidgetsBindingObserver] that reacts to app lifecycle events.
///
/// Register this in your top-level widget's initState:
///   WidgetsBinding.instance.addObserver(_lifecycleObserver);
///
/// Responsibilities:
///  • Resumes the SQLite connection when the app comes back to
///    the foreground (fixes "database is closed" errors after
///    the app is killed and reopened — a common black-screen cause).
///  • Logs lifecycle transitions for debugging.
class AppLifecycleObserver extends WidgetsBindingObserver {
  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        // Re-open the database if it was closed by the OS
        await NamazDatabase.instance.ensureOpen();
        debugPrint('[Lifecycle] App resumed — DB connection verified');
        break;

      case AppLifecycleState.paused:
        // The OS may kill the app soon; nothing to do here but log
        debugPrint('[Lifecycle] App paused');
        break;

      case AppLifecycleState.detached:
        // App process is being killed — safe to close DB
        await NamazDatabase.instance.close();
        debugPrint('[Lifecycle] App detached — DB closed');
        break;

      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        break;
    }
  }
}
