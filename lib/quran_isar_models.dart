// ============================================================
// FILE 1: quran_isar_models.dart
// Isar database models for Sirat Al Mustaqeem — Quran Module
// Shared Database Instance Logic
// ============================================================

import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'hadith_model.dart'; // REQUIRED: To access Hadith schemas for the shared instance

part 'quran_isar_models.g.dart';

// ─────────────────────────────────────────────────────────────
// ISAR COLLECTION: Cached Ayah
// ─────────────────────────────────────────────────────────────
@collection
class CachedAyah {
  // Use Isar.autoIncrement for cleaner performance in bulk downloads
  Id id = Isar.autoIncrement;

  @Index()
  late int surahNumber;

  @Index()
  late int ayahNumber;

  @Index()
  late int pageNumber;

  late int juzNumber;
  late String arabicText;
  late String englishText;
  late String urduText;
  late int numberInSurah;
}

// ─────────────────────────────────────────────────────────────
// ISAR SERVICE — Singleton Database Access
// ─────────────────────────────────────────────────────────────
class IsarService {
  static Isar? _isar;

  static Future<Isar> get db async {
    // 1. Return existing instance if open
    if (_isar != null && _isar!.isOpen) return _isar!;

    // 2. Check if the instance was already opened by the Hadith Screen
    final existingInstance = Isar.getInstance("sirat_al_mustaqeem_db");
    if (existingInstance != null) {
      _isar = existingInstance;
      return _isar!;
    }

    // 3. If no instance exists, open it with ALL schemas (Hadith + Quran)
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [
        CachedAyahSchema,     // Quran Schema
        CachedChapterSchema,  // Hadith Schema 1
        CachedHadithSchema,   // Hadith Schema 2
      ],
      directory: dir.path,
      name: 'sirat_al_mustaqeem_db', // Must match Hadith screen exactly
    );
    return _isar!;
  }

  /// Check if full Quran is already cached (6236 ayahs)
  static Future<bool> isQuranCached() async {
    final isar = await db;
    final count = await isar.cachedAyahs.count();
    return count >= 6236;
  }

  /// Save a batch of ayahs to Isar
  static Future<void> saveAyahs(List<CachedAyah> ayahs) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.cachedAyahs.putAll(ayahs);
    });
  }

  /// Get all ayahs for a specific Quran page
  static Future<List<CachedAyah>> getAyahsByPage(int pageNumber) async {
    final isar = await db;
    return isar.cachedAyahs
        .filter()
        .pageNumberEqualTo(pageNumber)
        .sortBySurahNumber()
        .thenByNumberInSurah()
        .findAll();
  }

  /// Get all ayahs for a specific Surah
  static Future<List<CachedAyah>> getAyahsBySurah(int surahNumber) async {
    final isar = await db;
    return isar.cachedAyahs
        .filter()
        .surahNumberEqualTo(surahNumber)
        .sortByNumberInSurah()
        .findAll();
  }

  /// Close database
  static Future<void> close() async {
    await _isar?.close();
  }
}