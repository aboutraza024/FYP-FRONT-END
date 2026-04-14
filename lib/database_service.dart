import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'hadith_model.dart';
import 'quran_isar_models.dart';

class DatabaseService {
  static Isar? _isar;

  static Future<Isar> get db async {
    // ── FIX P5: Guard against double-open race condition ──────────────────
    // If an instance was already opened by main.dart _initializeApp(),
    // reuse it instead of throwing "Instance already exists".
    final existing = Isar.getInstance('sirat_al_mustaqeem_db');
    if (existing != null) {
      _isar = existing;
      return _isar!;
    }

    if (_isar != null && _isar!.isOpen) return _isar!;

    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [
        CachedChapterSchema,
        CachedHadithSchema,
        CachedAyahSchema,
      ],
      directory: dir.path,
      name: 'sirat_al_mustaqeem_db',
    );
    return _isar!;
  }
}
