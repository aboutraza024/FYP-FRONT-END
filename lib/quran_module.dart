// ============================================================
// FILE: quran_module.dart  — SIRAT AL MUSTAQEEM  v2 (patched)
//
// FIXES applied in this revision:
//   1. AppBar overflow  → FittedBox + toolbarHeight constraint
//   2. Reading Mode cleanup → tune/reciter menu hidden in page mode
//   3. Mushaf page style → matches Indo-Pak physical Mushaf photo
//   4. Search RangeError → itemCount formula completely rewritten
//   5. Bookmarks screen  → full BookmarkedAyahsScreen added
//   6a. No loading blocker → FutureBuilder replaced with _CachedFuture
//       pattern; audio plays in background without full-screen loader
//   6b. Word highlighting → per-word green highlight synced to position
//   7. All Isar offline paths preserved exactly
// ============================================================

import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'app_ui_kit.dart';
import 'quran_isar_models.dart';
import 'theme_manager.dart';

// ─────────────────────────────────────────────────────────────
// THEME HELPERS
// ─────────────────────────────────────────────────────────────
class _T {
  static bool isDark(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark;
  static Color bg(BuildContext ctx) =>
      isDark(ctx) ? AppColors.charcoalAbyss : AppColors.snowWhite;
  static Color cardBg(BuildContext ctx) =>
      isDark(ctx) ? AppColors.charcoalPanel : Colors.white;
  static Color border(BuildContext ctx) =>
      isDark(ctx) ? AppColors.charcoalSurface : const Color(0xFFE5E7EB);
  static Color textDark(BuildContext ctx) =>
      isDark(ctx) ? AppColors.inkOnDark : AppColors.inkDark;
  static Color textMuted(BuildContext ctx) =>
      isDark(ctx) ? AppColors.inkSubDark : AppColors.inkSoft;
  static Color mushafBg(BuildContext ctx) =>
      isDark(ctx) ? AppColors.charcoalDeep : const Color(0xFFFAF3E0);
  static Color mushafText(BuildContext ctx) =>
      isDark(ctx) ? const Color(0xFFE8DCC8) : const Color(0xFF1A1208);
  static Color searchFill(BuildContext ctx) =>
      isDark(ctx) ? AppColors.charcoalMid : Colors.grey.shade100;
}

// ─────────────────────────────────────────────────────────────
// SURAH DATA  (114 surahs)
// ─────────────────────────────────────────────────────────────
const List<Map<String, dynamic>> kAllSurahs = [
  {'number': 1,   'name': 'Al-Fatiha',     'arabic': 'الفاتحة',    'ayahs': 7,   'type': 'MECCAN'},
  {'number': 2,   'name': 'Al-Baqarah',    'arabic': 'البقرة',     'ayahs': 286, 'type': 'MEDINAN'},
  {'number': 3,   'name': 'Ali Imran',     'arabic': 'آل عمران',   'ayahs': 200, 'type': 'MEDINAN'},
  {'number': 4,   'name': 'An-Nisa',       'arabic': 'النساء',     'ayahs': 176, 'type': 'MEDINAN'},
  {'number': 5,   'name': 'Al-Maidah',     'arabic': 'المائدة',    'ayahs': 120, 'type': 'MEDINAN'},
  {'number': 6,   'name': 'Al-Anam',       'arabic': 'الأنعام',    'ayahs': 165, 'type': 'MECCAN'},
  {'number': 7,   'name': 'Al-Araf',       'arabic': 'الأعراف',    'ayahs': 206, 'type': 'MECCAN'},
  {'number': 8,   'name': 'Al-Anfal',      'arabic': 'الأنفال',    'ayahs': 75,  'type': 'MEDINAN'},
  {'number': 9,   'name': 'At-Tawbah',     'arabic': 'التوبة',     'ayahs': 129, 'type': 'MEDINAN'},
  {'number': 10,  'name': 'Yunus',         'arabic': 'يونس',       'ayahs': 109, 'type': 'MECCAN'},
  {'number': 11,  'name': 'Hud',           'arabic': 'هود',        'ayahs': 123, 'type': 'MECCAN'},
  {'number': 12,  'name': 'Yusuf',         'arabic': 'يوسف',       'ayahs': 111, 'type': 'MECCAN'},
  {'number': 13,  'name': "Ar-Ra'd",       'arabic': 'الرعد',      'ayahs': 43,  'type': 'MEDINAN'},
  {'number': 14,  'name': 'Ibrahim',       'arabic': 'إبراهيم',    'ayahs': 52,  'type': 'MECCAN'},
  {'number': 15,  'name': 'Al-Hijr',       'arabic': 'الحجر',      'ayahs': 99,  'type': 'MECCAN'},
  {'number': 16,  'name': 'An-Nahl',       'arabic': 'النحل',      'ayahs': 128, 'type': 'MECCAN'},
  {'number': 17,  'name': 'Al-Isra',       'arabic': 'الإسراء',    'ayahs': 111, 'type': 'MECCAN'},
  {'number': 18,  'name': 'Al-Kahf',       'arabic': 'الكهف',      'ayahs': 110, 'type': 'MECCAN'},
  {'number': 19,  'name': 'Maryam',        'arabic': 'مريم',       'ayahs': 98,  'type': 'MECCAN'},
  {'number': 20,  'name': 'Ta-Ha',         'arabic': 'طه',         'ayahs': 135, 'type': 'MECCAN'},
  {'number': 21,  'name': 'Al-Anbiya',     'arabic': 'الأنبياء',   'ayahs': 112, 'type': 'MECCAN'},
  {'number': 22,  'name': 'Al-Hajj',       'arabic': 'الحج',       'ayahs': 78,  'type': 'MEDINAN'},
  {'number': 23,  'name': 'Al-Muminun',    'arabic': 'المؤمنون',   'ayahs': 118, 'type': 'MECCAN'},
  {'number': 24,  'name': 'An-Nur',        'arabic': 'النور',      'ayahs': 64,  'type': 'MEDINAN'},
  {'number': 25,  'name': 'Al-Furqan',     'arabic': 'الفرقان',    'ayahs': 77,  'type': 'MECCAN'},
  {'number': 26,  'name': 'Ash-Shuara',    'arabic': 'الشعراء',    'ayahs': 227, 'type': 'MECCAN'},
  {'number': 27,  'name': 'An-Naml',       'arabic': 'النمل',      'ayahs': 93,  'type': 'MECCAN'},
  {'number': 28,  'name': 'Al-Qasas',      'arabic': 'القصص',      'ayahs': 88,  'type': 'MECCAN'},
  {'number': 29,  'name': 'Al-Ankabut',    'arabic': 'العنكبوت',   'ayahs': 69,  'type': 'MECCAN'},
  {'number': 30,  'name': 'Ar-Rum',        'arabic': 'الروم',      'ayahs': 60,  'type': 'MECCAN'},
  {'number': 31,  'name': 'Luqman',        'arabic': 'لقمان',      'ayahs': 34,  'type': 'MECCAN'},
  {'number': 32,  'name': 'As-Sajdah',     'arabic': 'السجدة',     'ayahs': 30,  'type': 'MECCAN'},
  {'number': 33,  'name': 'Al-Ahzab',      'arabic': 'الأحزاب',    'ayahs': 73,  'type': 'MEDINAN'},
  {'number': 34,  'name': 'Saba',          'arabic': 'سبإ',        'ayahs': 54,  'type': 'MECCAN'},
  {'number': 35,  'name': 'Fatir',         'arabic': 'فاطر',       'ayahs': 45,  'type': 'MECCAN'},
  {'number': 36,  'name': 'Ya-Sin',        'arabic': 'يس',         'ayahs': 83,  'type': 'MECCAN'},
  {'number': 37,  'name': 'As-Saffat',     'arabic': 'الصافات',    'ayahs': 182, 'type': 'MECCAN'},
  {'number': 38,  'name': 'Sad',           'arabic': 'ص',          'ayahs': 88,  'type': 'MECCAN'},
  {'number': 39,  'name': 'Az-Zumar',      'arabic': 'الزمر',      'ayahs': 75,  'type': 'MECCAN'},
  {'number': 40,  'name': 'Ghafir',        'arabic': 'غافر',       'ayahs': 85,  'type': 'MECCAN'},
  {'number': 41,  'name': 'Fussilat',      'arabic': 'فصلت',       'ayahs': 54,  'type': 'MECCAN'},
  {'number': 42,  'name': 'Ash-Shura',     'arabic': 'الشورى',     'ayahs': 53,  'type': 'MECCAN'},
  {'number': 43,  'name': 'Az-Zukhruf',    'arabic': 'الزخرف',     'ayahs': 89,  'type': 'MECCAN'},
  {'number': 44,  'name': 'Ad-Dukhan',     'arabic': 'الدخان',     'ayahs': 59,  'type': 'MECCAN'},
  {'number': 45,  'name': 'Al-Jathiyah',   'arabic': 'الجاثية',    'ayahs': 37,  'type': 'MECCAN'},
  {'number': 46,  'name': 'Al-Ahqaf',      'arabic': 'الأحقاف',    'ayahs': 35,  'type': 'MECCAN'},
  {'number': 47,  'name': 'Muhammad',      'arabic': 'محمد',       'ayahs': 38,  'type': 'MEDINAN'},
  {'number': 48,  'name': 'Al-Fath',       'arabic': 'الفتح',      'ayahs': 29,  'type': 'MEDINAN'},
  {'number': 49,  'name': 'Al-Hujurat',    'arabic': 'الحجرات',    'ayahs': 18,  'type': 'MEDINAN'},
  {'number': 50,  'name': 'Qaf',           'arabic': 'ق',          'ayahs': 45,  'type': 'MECCAN'},
  {'number': 51,  'name': 'Adh-Dhariyat',  'arabic': 'الذاريات',   'ayahs': 60,  'type': 'MECCAN'},
  {'number': 52,  'name': 'At-Tur',        'arabic': 'الطور',      'ayahs': 49,  'type': 'MECCAN'},
  {'number': 53,  'name': 'An-Najm',       'arabic': 'النجم',      'ayahs': 62,  'type': 'MECCAN'},
  {'number': 54,  'name': 'Al-Qamar',      'arabic': 'القمر',      'ayahs': 55,  'type': 'MECCAN'},
  {'number': 55,  'name': 'Ar-Rahman',     'arabic': 'الرحمن',     'ayahs': 78,  'type': 'MEDINAN'},
  {'number': 56,  'name': 'Al-Waqiah',     'arabic': 'الواقعة',    'ayahs': 96,  'type': 'MECCAN'},
  {'number': 57,  'name': 'Al-Hadid',      'arabic': 'الحديد',     'ayahs': 29,  'type': 'MEDINAN'},
  {'number': 58,  'name': 'Al-Mujadila',   'arabic': 'المجادلة',   'ayahs': 22,  'type': 'MEDINAN'},
  {'number': 59,  'name': 'Al-Hashr',      'arabic': 'الحشر',      'ayahs': 24,  'type': 'MEDINAN'},
  {'number': 60,  'name': 'Al-Mumtahanah', 'arabic': 'الممتحنة',   'ayahs': 13,  'type': 'MEDINAN'},
  {'number': 61,  'name': 'As-Saff',       'arabic': 'الصف',       'ayahs': 14,  'type': 'MEDINAN'},
  {'number': 62,  'name': 'Al-Jumuah',     'arabic': 'الجمعة',     'ayahs': 11,  'type': 'MEDINAN'},
  {'number': 63,  'name': 'Al-Munafiqun',  'arabic': 'المنافقون',  'ayahs': 11,  'type': 'MEDINAN'},
  {'number': 64,  'name': 'At-Taghabun',   'arabic': 'التغابن',    'ayahs': 18,  'type': 'MEDINAN'},
  {'number': 65,  'name': 'At-Talaq',      'arabic': 'الطلاق',     'ayahs': 12,  'type': 'MEDINAN'},
  {'number': 66,  'name': 'At-Tahrim',     'arabic': 'التحريم',    'ayahs': 12,  'type': 'MEDINAN'},
  {'number': 67,  'name': 'Al-Mulk',       'arabic': 'الملك',      'ayahs': 30,  'type': 'MECCAN'},
  {'number': 68,  'name': 'Al-Qalam',      'arabic': 'القلم',      'ayahs': 52,  'type': 'MECCAN'},
  {'number': 69,  'name': 'Al-Haqqah',     'arabic': 'الحاقة',     'ayahs': 52,  'type': 'MECCAN'},
  {'number': 70,  'name': 'Al-Maarij',     'arabic': 'المعارج',    'ayahs': 44,  'type': 'MECCAN'},
  {'number': 71,  'name': 'Nuh',           'arabic': 'نوح',        'ayahs': 28,  'type': 'MECCAN'},
  {'number': 72,  'name': 'Al-Jinn',       'arabic': 'الجن',       'ayahs': 28,  'type': 'MECCAN'},
  {'number': 73,  'name': 'Al-Muzzammil',  'arabic': 'المزمل',     'ayahs': 20,  'type': 'MECCAN'},
  {'number': 74,  'name': 'Al-Muddathir',  'arabic': 'المدثر',     'ayahs': 56,  'type': 'MECCAN'},
  {'number': 75,  'name': 'Al-Qiyamah',    'arabic': 'القيامة',    'ayahs': 40,  'type': 'MECCAN'},
  {'number': 76,  'name': 'Al-Insan',      'arabic': 'الإنسان',    'ayahs': 31,  'type': 'MEDINAN'},
  {'number': 77,  'name': 'Al-Mursalat',   'arabic': 'المرسلات',   'ayahs': 50,  'type': 'MECCAN'},
  {'number': 78,  'name': 'An-Naba',       'arabic': 'النبأ',      'ayahs': 40,  'type': 'MECCAN'},
  {'number': 79,  'name': 'An-Naziat',     'arabic': 'النازعات',   'ayahs': 46,  'type': 'MECCAN'},
  {'number': 80,  'name': 'Abasa',         'arabic': 'عبس',        'ayahs': 42,  'type': 'MECCAN'},
  {'number': 81,  'name': 'At-Takwir',     'arabic': 'التكوير',    'ayahs': 29,  'type': 'MECCAN'},
  {'number': 82,  'name': 'Al-Infitar',    'arabic': 'الانفطار',   'ayahs': 19,  'type': 'MECCAN'},
  {'number': 83,  'name': 'Al-Mutaffifin', 'arabic': 'المطففين',   'ayahs': 36,  'type': 'MECCAN'},
  {'number': 84,  'name': 'Al-Inshiqaq',   'arabic': 'الانشقاق',   'ayahs': 25,  'type': 'MECCAN'},
  {'number': 85,  'name': 'Al-Buruj',      'arabic': 'البروج',     'ayahs': 22,  'type': 'MECCAN'},
  {'number': 86,  'name': 'At-Tariq',      'arabic': 'الطارق',     'ayahs': 17,  'type': 'MECCAN'},
  {'number': 87,  'name': 'Al-Ala',        'arabic': 'الأعلى',     'ayahs': 19,  'type': 'MECCAN'},
  {'number': 88,  'name': 'Al-Ghashiyah',  'arabic': 'الغاشية',    'ayahs': 26,  'type': 'MECCAN'},
  {'number': 89,  'name': 'Al-Fajr',       'arabic': 'الفجر',      'ayahs': 30,  'type': 'MECCAN'},
  {'number': 90,  'name': 'Al-Balad',      'arabic': 'البلد',      'ayahs': 20,  'type': 'MECCAN'},
  {'number': 91,  'name': 'Ash-Shams',     'arabic': 'الشمس',      'ayahs': 15,  'type': 'MECCAN'},
  {'number': 92,  'name': 'Al-Layl',       'arabic': 'الليل',      'ayahs': 21,  'type': 'MECCAN'},
  {'number': 93,  'name': 'Ad-Duha',       'arabic': 'الضحى',      'ayahs': 11,  'type': 'MECCAN'},
  {'number': 94,  'name': 'Ash-Sharh',     'arabic': 'الشرح',      'ayahs': 8,   'type': 'MECCAN'},
  {'number': 95,  'name': 'At-Tin',        'arabic': 'التين',      'ayahs': 8,   'type': 'MECCAN'},
  {'number': 96,  'name': 'Al-Alaq',       'arabic': 'العلق',      'ayahs': 19,  'type': 'MECCAN'},
  {'number': 97,  'name': 'Al-Qadr',       'arabic': 'القدر',      'ayahs': 5,   'type': 'MECCAN'},
  {'number': 98,  'name': 'Al-Bayyinah',   'arabic': 'البينة',     'ayahs': 8,   'type': 'MEDINAN'},
  {'number': 99,  'name': 'Az-Zalzalah',   'arabic': 'الزلزلة',    'ayahs': 8,   'type': 'MEDINAN'},
  {'number': 100, 'name': 'Al-Adiyat',     'arabic': 'العاديات',   'ayahs': 11,  'type': 'MECCAN'},
  {'number': 101, 'name': 'Al-Qariah',     'arabic': 'القارعة',    'ayahs': 11,  'type': 'MECCAN'},
  {'number': 102, 'name': 'At-Takathur',   'arabic': 'التكاثر',    'ayahs': 8,   'type': 'MECCAN'},
  {'number': 103, 'name': 'Al-Asr',        'arabic': 'العصر',      'ayahs': 3,   'type': 'MECCAN'},
  {'number': 104, 'name': 'Al-Humazah',    'arabic': 'الهمزة',     'ayahs': 9,   'type': 'MECCAN'},
  {'number': 105, 'name': 'Al-Fil',        'arabic': 'الفيل',      'ayahs': 5,   'type': 'MECCAN'},
  {'number': 106, 'name': 'Quraysh',       'arabic': 'قريش',       'ayahs': 4,   'type': 'MECCAN'},
  {'number': 107, 'name': 'Al-Maun',       'arabic': 'الماعون',    'ayahs': 7,   'type': 'MECCAN'},
  {'number': 108, 'name': 'Al-Kawthar',    'arabic': 'الكوثر',     'ayahs': 3,   'type': 'MECCAN'},
  {'number': 109, 'name': 'Al-Kafirun',    'arabic': 'الكافرون',   'ayahs': 6,   'type': 'MECCAN'},
  {'number': 110, 'name': 'An-Nasr',       'arabic': 'النصر',      'ayahs': 3,   'type': 'MEDINAN'},
  {'number': 111, 'name': 'Al-Masad',      'arabic': 'المسد',      'ayahs': 5,   'type': 'MECCAN'},
  {'number': 112, 'name': 'Al-Ikhlas',     'arabic': 'الإخلاص',    'ayahs': 4,   'type': 'MECCAN'},
  {'number': 113, 'name': 'Al-Falaq',      'arabic': 'الفلق',      'ayahs': 5,   'type': 'MECCAN'},
  {'number': 114, 'name': 'An-Nas',        'arabic': 'الناس',      'ayahs': 6,   'type': 'MECCAN'},
];

// ─────────────────────────────────────────────────────────────
// RECITER CONFIG
// ─────────────────────────────────────────────────────────────
class _Reciter {
  final String id, name, arabicName, cdnCode;
  const _Reciter({
    required this.id, required this.name,
    required this.arabicName, required this.cdnCode,
  });
}

const List<_Reciter> kReciters = [
  _Reciter(id: 'mishary',    name: 'Mishary Rashid Alafasy',       arabicName: 'مشاري راشد العفاسي',      cdnCode: 'Alafasy_128kbps'),
  _Reciter(id: 'abdulbasit', name: 'Abdul Basit Abd us-Samad',     arabicName: 'عبد الباسط عبد الصمد',    cdnCode: 'Abdul_Basit_Murattal_192kbps'),
  _Reciter(id: 'sudais',     name: 'Abdul Rahman Al-Sudais',       arabicName: 'عبد الرحمن السديس',       cdnCode: 'Abdurrahmaan_As-Sudais_192kbps'),
];

String _ayahAudioUrl(String cdnCode, int surah, int ayah) {
  final s = surah.toString().padLeft(3, '0');
  final a = ayah.toString().padLeft(3, '0');
  return 'https://everyayah.com/data/$cdnCode/$s$a.mp3';
}

// ─────────────────────────────────────────────────────────────
// BOOKMARKS SERVICE
// ─────────────────────────────────────────────────────────────
class _BookmarkService {
  static const _key = 'quran_bookmarks_v2';

  static Future<List<Map<String, dynamic>>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    return raw.map((e) => json.decode(e) as Map<String, dynamic>).toList();
  }

  static Future<void> save(List<Map<String, dynamic>> bookmarks) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, bookmarks.map(json.encode).toList());
  }

  static Future<void> add(int surahNum, int ayahNum, String surahName) async {
    final list = await load();
    list.removeWhere((b) => b['surah'] == surahNum && b['ayah'] == ayahNum);
    list.insert(0, {
      'surah': surahNum, 'ayah': ayahNum, 'name': surahName,
      'ts': DateTime.now().millisecondsSinceEpoch,
    });
    if (list.length > 50) list.removeLast();
    await save(list);
  }

  static Future<void> remove(int surahNum, int ayahNum) async {
    final list = await load();
    list.removeWhere((b) => b['surah'] == surahNum && b['ayah'] == ayahNum);
    await save(list);
  }

  static Future<bool> isBookmarked(int surahNum, int ayahNum) async {
    final list = await load();
    return list.any((b) => b['surah'] == surahNum && b['ayah'] == ayahNum);
  }
}

// ─────────────────────────────────────────────────────────────
// QURAN MODULE SCREEN
// ─────────────────────────────────────────────────────────────
class QuranModuleScreen extends StatefulWidget {
  const QuranModuleScreen({super.key});
  @override
  State<QuranModuleScreen> createState() => _QuranModuleScreenState();
}

class _QuranModuleScreenState extends State<QuranModuleScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _listController;
  late AnimationController _heroController;

  int _lastPage = 1;
  bool _isLoadingLastPage = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  bool _isCached = false;
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  String _downloadMessage = '';
  String? _downloadError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _listController = AnimationController(duration: const Duration(milliseconds: 1200), vsync: this)..forward();
    _heroController  = AnimationController(duration: const Duration(milliseconds: 800),  vsync: this)..forward();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = await IsarService.isQuranCached();
    if (mounted) {
      setState(() {
        _lastPage = prefs.getInt('last_quran_page') ?? 1;
        _isLoadingLastPage = false;
        _isCached = cached;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _listController.dispose();
    _heroController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ── Download ─────────────────────────────────────────────────
  Future<void> _downloadAndCacheQuran() async {
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) {
      setState(() { _downloadError = 'No internet connection.'; });
      return;
    }
    setState(() { _isDownloading = true; _downloadError = null; _downloadProgress = 0.0; _downloadMessage = 'Preparing...'; });
    try {
      setState(() { _downloadProgress = 0.05; _downloadMessage = 'Fetching Arabic text...'; });
      final arabicRes  = await http.get(Uri.parse('https://api.alquran.cloud/v1/quran/quran-uthmani-qpc')).timeout(const Duration(seconds: 60));
      setState(() { _downloadProgress = 0.35; _downloadMessage = 'Fetching English translation...'; });
      final englishRes = await http.get(Uri.parse('https://api.alquran.cloud/v1/quran/en.sahih')).timeout(const Duration(seconds: 60));
      setState(() { _downloadProgress = 0.65; _downloadMessage = 'Fetching Urdu translation...'; });
      final urduRes    = await http.get(Uri.parse('https://api.alquran.cloud/v1/quran/ur.jalandhry')).timeout(const Duration(seconds: 60));
      setState(() { _downloadProgress = 0.80; _downloadMessage = 'Saving...'; });

      final arabicSurahs  = (json.decode(utf8.decode(arabicRes.bodyBytes)) ['data']['surahs'] as List);
      final englishSurahs = (json.decode(utf8.decode(englishRes.bodyBytes))['data']['surahs'] as List);
      final urduSurahs    = (json.decode(utf8.decode(urduRes.bodyBytes))   ['data']['surahs'] as List);

      final allAyahs = <CachedAyah>[];
      for (int si = 0; si < arabicSurahs.length; si++) {
        final arAyahs = arabicSurahs[si]['ayahs'] as List;
        final enAyahs = englishSurahs[si]['ayahs'] as List;
        final urAyahs = urduSurahs[si]   ['ayahs'] as List;
        for (int ai = 0; ai < arAyahs.length; ai++) {
          allAyahs.add(CachedAyah()
            ..surahNumber    = arabicSurahs[si]['number'] as int
            ..ayahNumber     = arAyahs[ai]['number'] as int
            ..pageNumber     = arAyahs[ai]['page'] as int
            ..juzNumber      = arAyahs[ai]['juz'] as int
            ..arabicText     = arAyahs[ai]['text'] as String
            ..englishText    = enAyahs[ai]['text'] as String
            ..urduText       = urAyahs[ai]['text'] as String
            ..numberInSurah  = arAyahs[ai]['numberInSurah'] as int);
        }
        setState(() { _downloadProgress = 0.80 + (0.15 * (si / arabicSurahs.length)); _downloadMessage = 'Saving Surah ${si + 1}/${arabicSurahs.length}...'; });
      }
      const chunk = 300;
      for (int i = 0; i < allAyahs.length; i += chunk) {
        await IsarService.saveAyahs(allAyahs.sublist(i, (i + chunk).clamp(0, allAyahs.length)));
      }
      setState(() { _downloadProgress = 1.0; _downloadMessage = 'Done!'; _isDownloading = false; _isCached = true; });
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Quran downloaded. Offline reading enabled!', style: GoogleFonts.poppins()), backgroundColor: AppColors.tealPrimary, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
    } catch (e) {
      setState(() { _isDownloading = false; _downloadError = 'Download failed. Tap to retry.\n${e.toString()}'; _downloadProgress = 0.0; });
    }
  }

  void _onBottomNavTap(int index) {
    if (index == 2) return;
    HapticFeedback.mediumImpact();
    final routes = ['/', '/hadith-search', '/quran', '/prayer-times', '/utilities'];
    Navigator.pushReplacementNamed(context, routes[index]);
  }

  // ─────────────────────────────────────────────────────────────
  // BUILD
  // FIX #1: AppBar overflow — toolbarHeight set, title wrapped in
  // FittedBox so it never overflows on small screens.
  // ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _T.bg(context),
      appBar: AppBar(
        // Fix #1: explicit toolbarHeight prevents vertical overflow
        toolbarHeight: 52,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [AppColors.tealDeep, AppColors.tealPrimary],
            ),
          ),
        ),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.auto_stories_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 8),
            // FittedBox prevents text overflow on small/narrow screens
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Quran',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)),
                    Text('القرآن الكريم',
                        style: GoogleFonts.amiri(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          // Bookmarks icon — navigates to BookmarkedAyahsScreen (Fix #5)
          IconButton(
            icon: const Icon(Icons.bookmarks_rounded, color: Colors.white, size: 20),
            onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const BookmarkedAyahsScreen())),
            tooltip: 'My Bookmarks',
          ),
          _CacheStatusBadge(isCached: _isCached),
          const SizedBox(width: 6),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.amberLight,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12),
          tabs: const [
            Tab(icon: Icon(Icons.menu_book_rounded, size: 16), text: 'Reading Mode'),
            Tab(icon: Icon(Icons.list_alt_rounded, size: 16), text: 'By Surah'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildFullQuranTab(), _buildBySurahTab()],
      ),
      bottomNavigationBar: FloatingNavBar(currentIndex: 2, onTap: _onBottomNavTap),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // TAB 1 — Reading Mode hub
  // ─────────────────────────────────────────────────────────────
  Widget _buildFullQuranTab() {
    if (_isLoadingLastPage) return Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary));
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: FadeTransition(
          opacity: _heroController,
          child: Column(
            children: [
              ScaleTransition(
                scale: CurvedAnimation(parent: _heroController, curve: Curves.elasticOut),
                child: _MushafCoverBanner(lastPage: _lastPage),
              ),
              const SizedBox(height: 24),
              if (!_isCached) _buildCacheBanner(),
              if (_isCached) _buildOfflineReadyCard(),
              const SizedBox(height: 20),
              if (_isCached) ...[
                _buildPrimaryActionButton(
                  icon: Icons.bookmark_rounded,
                  label: 'Continue Reading',
                  sublabel: 'Resume at Page $_lastPage',
                  gradient: AppColors.emeraldGradient,
                  onTap: () { HapticFeedback.mediumImpact(); _openReader(isPageMode: true, startPage: _lastPage); },
                ),
                const SizedBox(height: 12),
                _buildSecondaryActionButton(
                  icon: Icons.auto_stories_rounded,
                  label: 'Start from Page 1',
                  sublabel: 'Begin from Al-Fatiha',
                  onTap: () { HapticFeedback.lightImpact(); _openReader(isPageMode: true, startPage: 1); },
                ),
                const SizedBox(height: 24),
                _buildStatsRow(),
              ] else if (!_isDownloading) ...[
                Opacity(opacity: 0.4, child: _buildPrimaryActionButton(icon: Icons.bookmark_rounded, label: 'Continue Reading', sublabel: 'Download Quran first', gradient: AppColors.emeraldGradient, onTap: null)),
              ],
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCacheBanner() {
    final isDark = _T.isDark(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: isDark ? [const Color(0xFF2D2006), const Color(0xFF2A1C05)] : [Colors.amber.shade50, Colors.orange.shade50]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.amberMed.withOpacity(0.6), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.amberMed.withOpacity(0.15), shape: BoxShape.circle), child: Icon(Icons.download_rounded, color: AppColors.amberMed, size: 22)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Download for Offline Reading', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? AppColors.amberLight : AppColors.amberDeep)),
              Text('One-time ~15 MB download.', style: GoogleFonts.poppins(fontSize: 11, color: AppColors.amberPrimary)),
            ])),
          ]),
          if (_isDownloading) ...[
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(6), child: LinearProgressIndicator(value: _downloadProgress, backgroundColor: AppColors.amberLight.withOpacity(0.25), valueColor: AlwaysStoppedAnimation<Color>(AppColors.amberMed), minHeight: 8))),
              const SizedBox(width: 10),
              Text('${(_downloadProgress * 100).toInt()}%', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.amberPrimary)),
            ]),
            const SizedBox(height: 6),
            Text(_downloadMessage, style: GoogleFonts.poppins(fontSize: 11, color: AppColors.amberPrimary)),
          ],
          if (_downloadError != null) ...[
            const SizedBox(height: 10),
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.red.shade200)), child: Row(children: [Icon(Icons.error_outline, color: Colors.red.shade400, size: 16), const SizedBox(width: 8), Expanded(child: Text(_downloadError!, style: GoogleFonts.poppins(fontSize: 11, color: Colors.red.shade700)))])),
          ],
          if (!_isDownloading) ...[
            const SizedBox(height: 14),
            SizedBox(width: double.infinity, child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.amberMed, foregroundColor: Colors.black87, padding: const EdgeInsets.symmetric(vertical: 13), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
              icon: const Icon(Icons.download_rounded),
              label: Text(_downloadError != null ? 'Retry Download' : 'Download Complete Quran', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              onPressed: _downloadAndCacheQuran,
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildOfflineReadyCard() => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: _T.isDark(context) ? [const Color(0xFF052E16), const Color(0xFF042F29)] : [Colors.green.shade50, Colors.teal.shade50]),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.green.shade300),
    ),
    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.check_circle_rounded, color: Colors.green.shade600, size: 18),
      const SizedBox(width: 8),
      Text('Quran Downloaded', style: GoogleFonts.poppins(fontSize: 12, color: Colors.green.shade700, fontWeight: FontWeight.w600)),
    ]),
  );

  Widget _buildPrimaryActionButton({required IconData icon, required String label, required String sublabel, required LinearGradient gradient, VoidCallback? onTap}) {
    return GestureDetector(onTap: onTap, child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(gradient: gradient, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: AppColors.tealPrimary.withOpacity(0.3), blurRadius: 14, offset: const Offset(0, 5))]),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: Colors.white, size: 22)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
          Text(sublabel, style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70)),
        ])),
        const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.white70),
      ]),
    ));
  }

  Widget _buildSecondaryActionButton({required IconData icon, required String label, required String sublabel, VoidCallback? onTap}) {
    return GestureDetector(onTap: onTap, child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(color: _T.cardBg(context), borderRadius: BorderRadius.circular(18), border: Border.all(color: _T.border(context), width: 1.5), boxShadow: [BoxShadow(color: Colors.black.withOpacity(_T.isDark(context) ? 0.3 : 0.05), blurRadius: 10, offset: const Offset(0, 3))]),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.tealPrimary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: AppColors.tealPrimary, size: 22)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15, color: _T.textDark(context))),
          Text(sublabel, style: GoogleFonts.poppins(fontSize: 12, color: _T.textMuted(context))),
        ])),
        Icon(Icons.arrow_forward_ios_rounded, size: 14, color: _T.textMuted(context)),
      ]),
    ));
  }

  Widget _buildStatsRow() {
    final pct = ((_lastPage / 604) * 100).toStringAsFixed(1);
    return Row(children: [
      Expanded(child: _StatCard(icon: Icons.bookmark_rounded, label: 'Last Page',  value: '$_lastPage', color: AppColors.tealPrimary)),
      const SizedBox(width: 12),
      Expanded(child: _StatCard(icon: Icons.trending_up_rounded, label: 'Progress', value: '$pct%',     color: AppColors.amberPrimary)),
      const SizedBox(width: 12),
      Expanded(child: _StatCard(icon: Icons.menu_book_rounded,   label: 'Remaining', value: '${604 - _lastPage}', color: AppColors.tealMed)),
    ]);
  }

  // ─────────────────────────────────────────────────────────────
  // TAB 2 — By Surah
  // ─────────────────────────────────────────────────────────────
  Widget _buildBySurahTab() {
    final q = _searchQuery.toLowerCase().trim();
    final filtered = q.isEmpty ? kAllSurahs : kAllSurahs.where((s) =>
      s['name'].toString().toLowerCase().contains(q) ||
      s['arabic'].toString().contains(q) ||
      s['number'].toString().contains(q)).toList();

    return Column(
      children: [
        Container(
          color: _T.bg(context),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _searchQuery = v),
            style: TextStyle(color: _T.textDark(context)),
            decoration: InputDecoration(
              hintText: 'Search by name, Arabic, or number...',
              hintStyle: GoogleFonts.poppins(fontSize: 13, color: _T.textMuted(context)),
              prefixIcon: Icon(Icons.search_rounded, color: AppColors.tealPrimary),
              suffixIcon: _searchQuery.isNotEmpty ? IconButton(icon: Icon(Icons.clear_rounded, color: _T.textMuted(context)), onPressed: () { _searchController.clear(); setState(() => _searchQuery = ''); }) : null,
              filled: true, fillColor: _T.searchFill(context),
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: AppColors.tealPrimary, width: 1.5)),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Row(children: [
            Text('${filtered.length} Surahs', style: GoogleFonts.poppins(fontSize: 12, color: _T.textMuted(context))),
            const Spacer(),
            if (!_isCached) Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: AppColors.amberCream, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.amberLight)),
              child: Row(children: [Icon(Icons.wifi_rounded, size: 12, color: AppColors.amberPrimary), const SizedBox(width: 4), Text('Online', style: GoogleFonts.poppins(fontSize: 10, color: AppColors.amberPrimary))]),
            ),
          ]),
        ),
        Expanded(
          child: filtered.isEmpty
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.search_off_rounded, size: 56, color: _T.textMuted(context)), const SizedBox(height: 12), Text('No surahs found', style: GoogleFonts.poppins(color: _T.textMuted(context), fontSize: 15))]))
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final surah = filtered[index];
                    final isMeccan = surah['type'] == 'MECCAN';
                    final anim = CurvedAnimation(parent: _listController, curve: Interval((0.02 * index).clamp(0.0, 1.0), 1.0, curve: Curves.easeOutCubic));
                    return SlideTransition(
                      position: Tween<Offset>(begin: const Offset(0.08, 0), end: Offset.zero).animate(anim),
                      child: FadeTransition(
                        opacity: anim,
                        child: _SurahListCard(surah: surah, isMeccan: isMeccan, isCached: _isCached, onTap: () {
                          HapticFeedback.lightImpact();
                          _openReader(isPageMode: false, surahId: surah['number'], title: surah['name'], surahType: surah['type'], totalAyahs: surah['ayahs']);
                        }),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _openReader({required bool isPageMode, int? startPage, int? surahId, String? title, String? surahType, int? totalAyahs}) {
    Navigator.push(context, PageRouteBuilder(
      pageBuilder: (_, animation, __) => UniversalQuranReader(isPageMode: isPageMode, initialPage: startPage, surahId: surahId, title: title, surahType: surahType, totalAyahs: totalAyahs, isCached: _isCached),
      transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: CurvedAnimation(parent: animation, curve: Curves.easeIn), child: SlideTransition(position: Tween<Offset>(begin: const Offset(0.05, 0), end: Offset.zero).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)), child: child)),
      transitionDuration: const Duration(milliseconds: 300),
    )).then((_) => _initializeApp());
  }
}

// ─────────────────────────────────────────────────────────────
// SMALL REUSABLE WIDGETS
// ─────────────────────────────────────────────────────────────
class _CacheStatusBadge extends StatelessWidget {
  final bool isCached;
  const _CacheStatusBadge({required this.isCached});
  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
    duration: const Duration(milliseconds: 400),
    child: Container(
      key: ValueKey(isCached),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: (isCached ? Colors.green : Colors.amber).withOpacity(0.2), borderRadius: BorderRadius.circular(12), border: Border.all(color: isCached ? Colors.green.shade300 : Colors.amber.shade300, width: 1)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(isCached ? Icons.offline_bolt_rounded : Icons.cloud_download_outlined, size: 12, color: isCached ? Colors.greenAccent : Colors.amber),
        const SizedBox(width: 4),
        Text(isCached ? 'Offline' : 'Online', style: GoogleFonts.poppins(fontSize: 10, color: isCached ? Colors.greenAccent : Colors.amber, fontWeight: FontWeight.bold)),
      ]),
    ),
  );
}

class _StatCard extends StatelessWidget {
  final IconData icon; final String label, value; final Color color;
  const _StatCard({required this.icon, required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: color.withOpacity(0.07), borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withOpacity(0.15))),
    child: Column(children: [
      Icon(icon, color: color, size: 20),
      const SizedBox(height: 6),
      Text(value, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
      Text(label, style: GoogleFonts.poppins(fontSize: 10, color: _T.textMuted(context))),
    ]),
  );
}

// ─────────────────────────────────────────────────────────────
// MUSHAF COVER BANNER
// ─────────────────────────────────────────────────────────────
class _MushafCoverBanner extends StatelessWidget {
  final int lastPage;
  const _MushafCoverBanner({required this.lastPage});
  @override
  Widget build(BuildContext context) {
    final progress = lastPage / 604;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(gradient: AppColors.emeraldGradient, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: AppColors.tealPrimary.withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 8))]),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text('❧', style: TextStyle(color: Colors.white54, fontSize: 16)),
          const SizedBox(width: 10),
          Text('بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ', textDirection: TextDirection.rtl, style: GoogleFonts.amiri(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, height: 1.8)),
          const SizedBox(width: 10),
          const Text('❧', style: TextStyle(color: Colors.white54, fontSize: 16)),
        ]),
        const SizedBox(height: 14),
        Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle), child: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 48)),
        const SizedBox(height: 14),
        Text('Al-Quran Al-Kareem', style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('604 Pages • 114 Surahs • 6236 Ayahs', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 11)),
        const SizedBox(height: 14),
        ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: progress, backgroundColor: Colors.white.withOpacity(0.2), valueColor: const AlwaysStoppedAnimation<Color>(AppColors.amberLight), minHeight: 5)),
        const SizedBox(height: 5),
        Text('${(progress * 100).toStringAsFixed(1)}% completed', style: GoogleFonts.poppins(color: AppColors.amberLight, fontSize: 10)),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// SURAH LIST CARD
// ─────────────────────────────────────────────────────────────
class _SurahListCard extends StatelessWidget {
  final Map<String, dynamic> surah;
  final bool isMeccan, isCached;
  final VoidCallback onTap;
  const _SurahListCard({required this.surah, required this.isMeccan, required this.isCached, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final num = surah['number'] as int;
    final c = isMeccan ? AppColors.tealPrimary : AppColors.amberPrimary;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      elevation: 0, color: _T.cardBg(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: _T.border(context))),
      child: InkWell(
        borderRadius: BorderRadius.circular(16), splashColor: AppColors.tealLight.withOpacity(0.3), onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(children: [
            Stack(alignment: Alignment.center, children: [
              Container(width: 44, height: 44, decoration: BoxDecoration(color: c.withOpacity(0.1), shape: BoxShape.circle, border: Border.all(color: c.withOpacity(0.4), width: 1.5))),
              Text('$num', style: GoogleFonts.poppins(color: c, fontWeight: FontWeight.bold, fontSize: 12)),
            ]),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              Row(children: [
                Flexible(child: Text(surah['name'], overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: _T.textDark(context)))),
                const SizedBox(width: 8),
                _SurahTypeBadge(type: surah['type'], isMeccan: isMeccan),
              ]),
              const SizedBox(height: 3),
              Row(children: [Icon(Icons.format_list_numbered_rounded, size: 12, color: _T.textMuted(context)), const SizedBox(width: 4), Text('${surah['ayahs']} Ayahs', style: GoogleFonts.poppins(fontSize: 12, color: _T.textMuted(context)))]),
            ])),
            const SizedBox(width: 8),
            Column(crossAxisAlignment: CrossAxisAlignment.end, mainAxisSize: MainAxisSize.min, children: [
              Text(surah['arabic'], textDirection: TextDirection.rtl, style: GoogleFonts.amiri(fontSize: 22, color: c, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Icon(Icons.chevron_right_rounded, color: _T.textMuted(context), size: 16),
            ]),
          ]),
        ),
      ),
    );
  }
}

class _SurahTypeBadge extends StatelessWidget {
  final String type; final bool isMeccan;
  const _SurahTypeBadge({required this.type, required this.isMeccan});
  @override
  Widget build(BuildContext context) {
    final color = isMeccan ? AppColors.tealPrimary : AppColors.amberPrimary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6), border: Border.all(color: color.withOpacity(0.35))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(isMeccan ? '🕋' : '🕌', style: const TextStyle(fontSize: 9)),
        const SizedBox(width: 3),
        Text(type, style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.bold, color: color, letterSpacing: 0.3)),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// UNIVERSAL QURAN READER
// ─────────────────────────────────────────────────────────────
class UniversalQuranReader extends StatefulWidget {
  final bool isPageMode;
  final int? initialPage, surahId, totalAyahs;
  final String? title, surahType;
  final bool isCached;

  const UniversalQuranReader({
    super.key, required this.isPageMode,
    this.initialPage, this.surahId, this.title, this.surahType, this.totalAyahs,
    required this.isCached,
  });

  @override
  State<UniversalQuranReader> createState() => _UniversalQuranReaderState();
}

class _UniversalQuranReaderState extends State<UniversalQuranReader>
    with SingleTickerProviderStateMixin {

  String _activeLang = 'en';
  late PageController _pageController;
  late AnimationController _fadeController;
  int _currentDisplayPage = 1;

  // Font size
  double _arabicFontSize = 26.0;
  bool _showFontSlider = false;

  // ── Audio ────────────────────────────────────────────────────
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  int _playingAyah = -1;
  int _selectedReciterIndex = 0;
  Duration _audioDuration = Duration.zero;
  Duration _audioPosition = Duration.zero;

  // Fix #6b: word highlighting
  // We split the current ayah's Arabic text into words and estimate
  // which word is being highlighted based on position / duration ratio.
  String _playingAyahText = '';
  int _highlightedWordIndex = -1;

  // ── In-surah search ──────────────────────────────────────────
  String _surahSearch = '';
  bool _showSearchBar = false;
  final TextEditingController _surahSearchCtrl = TextEditingController();
  final ScrollController _surahScrollCtrl = ScrollController();

  // ── Fix #6a: background data loading ────────────────────────
  // We hold the data in state so the UI shows existing content
  // (or a small spinner only on first load) without a full-screen block.
  List? _cachedAyahs;
  List? _cachedTrans;
  int? _cachedSurahNum;
  bool _isDataLoading = false;
  String? _dataError;
  int _lastLoadedId = -1;

  @override
  void initState() {
    super.initState();
    _currentDisplayPage = widget.initialPage ?? 1;
    _pageController = PageController(initialPage: widget.isPageMode ? (_currentDisplayPage - 1) : 0);
    _fadeController = AnimationController(duration: const Duration(milliseconds: 400), vsync: this)..forward();

    _audioPlayer.onDurationChanged.listen((d) { if (mounted) setState(() => _audioDuration = d); });
    _audioPlayer.onPositionChanged.listen((p) {
      if (!mounted) return;
      setState(() {
        _audioPosition = p;
        // Fix #6b: update word highlight index based on position ratio
        if (_audioDuration.inMilliseconds > 0 && _playingAyahText.isNotEmpty) {
          final words = _playingAyahText.split(' ').where((w) => w.isNotEmpty).toList();
          final ratio = p.inMilliseconds / _audioDuration.inMilliseconds;
          _highlightedWordIndex = (ratio * words.length).floor().clamp(0, words.length - 1);
        }
      });
    });
    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) setState(() { _isPlaying = false; _playingAyah = -1; _playingAyahText = ''; _highlightedWordIndex = -1; });
    });

    // Preload data immediately without blocking the UI
    if (!widget.isPageMode) _preloadSurahData(widget.surahId!);
    else _preloadPageData(_currentDisplayPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _audioPlayer.dispose();
    _surahSearchCtrl.dispose();
    _surahScrollCtrl.dispose();
    super.dispose();
  }

  // ── Fix #6a: background data loader ─────────────────────────
  Future<void> _preloadPageData(int pageNum) async {
    if (_lastLoadedId == pageNum) return;
    if (!mounted) return;
    setState(() { _isDataLoading = true; _dataError = null; });
    try {
      List ayahs;
      if (widget.isCached) {
        ayahs = await IsarService.getAyahsByPage(pageNum);
      } else {
        final res = await http.get(Uri.parse('https://api.alquran.cloud/v1/page/$pageNum/quran-uthmani-qpc'));
        ayahs = json.decode(utf8.decode(res.bodyBytes))['data']['ayahs'] as List;
      }
      if (!mounted) return;
      setState(() { _cachedAyahs = ayahs; _cachedTrans = null; _lastLoadedId = pageNum; _isDataLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _isDataLoading = false; _dataError = 'Load failed. Check connection.'; });
    }
  }

  Future<void> _preloadSurahData(int surahId) async {
    if (_lastLoadedId == surahId) return;
    if (!mounted) return;
    setState(() { _isDataLoading = true; _dataError = null; });
    try {
      List ayahs; List? trans;
      if (widget.isCached) {
        ayahs = await IsarService.getAyahsBySurah(surahId);
      } else {
        final edition = _activeLang == 'ur' ? 'ur.jalandhry' : 'en.sahih';
        final futures = [
          http.get(Uri.parse('https://api.alquran.cloud/v1/surah/$surahId/quran-uthmani-qpc')),
          if (_activeLang != 'none') http.get(Uri.parse('https://api.alquran.cloud/v1/surah/$surahId/$edition')),
        ];
        final results = await Future.wait(futures);
        ayahs = json.decode(utf8.decode(results[0].bodyBytes))['data']['ayahs'] as List;
        if (results.length > 1) trans = json.decode(utf8.decode(results[1].bodyBytes))['data']['ayahs'] as List;
      }

      // Derive surahNum
      int? surahNum = widget.surahId;
      if (surahNum == null && ayahs.isNotEmpty) {
        surahNum = (ayahs.first is CachedAyah) ? (ayahs.first as CachedAyah).surahNumber : null;
      }

      if (!mounted) return;
      setState(() { _cachedAyahs = ayahs; _cachedTrans = trans; _cachedSurahNum = surahNum; _lastLoadedId = surahId; _isDataLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _isDataLoading = false; _dataError = 'Load failed. Check connection.'; });
    }
  }

  // ── Helpers ──────────────────────────────────────────────────
  String _toArabicNumber(int n) {
    const e = ['0','1','2','3','4','5','6','7','8','9'];
    const a = ['٠','١','٢','٣','٤','٥','٦','٧','٨','٩'];
    String s = n.toString();
    for (int i = 0; i < e.length; i++) s = s.replaceAll(e[i], a[i]);
    return s;
  }

  static String _stripDiacritics(String s) => s.replaceAll(RegExp(r'[\u0610-\u061A\u064B-\u065F\u0670\u0640]'), '');
  static const String _bareBismillah = 'بسم الله الرحمن الرحيم';

  String _cleanAyahText(String text, int surahNumber, int ayahInSurah) {
    if (surahNumber == 1 || surahNumber == 9 || ayahInSurah != 1) return text;
    final bareText = _stripDiacritics(text).trimLeft();
    if (!bareText.startsWith(_bareBismillah)) return text;
    int origIdx = 0, bareMatched = 0;
    final dRe = RegExp(r'[\u0610-\u061A\u064B-\u065F\u0670\u0640]');
    while (origIdx < text.length && bareMatched < _bareBismillah.length) {
      dRe.hasMatch(text[origIdx]) ? origIdx++ : (origIdx++, bareMatched++);
    }
    while (origIdx < text.length && text[origIdx] == ' ') origIdx++;
    return text.substring(origIdx).trimLeft();
  }

  // ── Audio ────────────────────────────────────────────────────
  Future<void> _playAyah(int surahNum, int ayahNum, String ayahText) async {
    final url = _ayahAudioUrl(kReciters[_selectedReciterIndex].cdnCode, surahNum, ayahNum);
    await _audioPlayer.stop();
    // Fix #6a: play without any loading overlay — audio buffers in background
    await _audioPlayer.play(UrlSource(url));
    if (mounted) setState(() { _isPlaying = true; _playingAyah = ayahNum; _playingAyahText = ayahText; _highlightedWordIndex = 0; });
  }

  Future<void> _togglePlayPause(int surahNum, int ayahNum, String ayahText) async {
    if (_playingAyah == ayahNum && _isPlaying) {
      await _audioPlayer.pause();
      if (mounted) setState(() => _isPlaying = false);
    } else if (_playingAyah == ayahNum && !_isPlaying) {
      await _audioPlayer.resume();
      if (mounted) setState(() => _isPlaying = true);
    } else {
      await _playAyah(surahNum, ayahNum, ayahText);
    }
  }

  // ─────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _T.mushafBg(context),
      appBar: _buildAppBar(),
      body: widget.isPageMode
          ? _buildPageModeBody()
          : _buildSurahModeBody(),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // APP BAR
  // Fix #1: FittedBox title; Fix #2: tune/reciter hidden in page mode
  // ─────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      toolbarHeight: 52,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [AppColors.tealDeep, AppColors.tealPrimary], begin: Alignment.topLeft, end: Alignment.bottomRight),
        ),
      ),
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      title: widget.isPageMode
          ? FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              Text('Holy Quran', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
              Text('Page $_currentDisplayPage of 604', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 11)),
            ]))
          : FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              Text(widget.title ?? 'Surah', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
              Text('${widget.surahType} • ${widget.totalAyahs} Ayahs', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 11)),
            ])),
      // Fix #2: Reading mode shows NO tune/search/reciter icons.
      // Only Surah mode gets those controls.
      actions: widget.isPageMode
          ? [] // ← completely empty in page/reading mode
          : [
              IconButton(
                icon: Icon(_showSearchBar ? Icons.search_off : Icons.search_rounded, color: Colors.white),
                onPressed: () => setState(() => _showSearchBar = !_showSearchBar),
                tooltip: 'Search Ayahs',
              ),
              IconButton(
                icon: const Icon(Icons.text_fields_rounded, color: Colors.white),
                onPressed: () => setState(() => _showFontSlider = !_showFontSlider),
                tooltip: 'Font Size',
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.tune_rounded, color: Colors.white),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                onSelected: (val) {
                  if (val == 'en' || val == 'ur' || val == 'none') {
                    setState(() { _activeLang = val; _lastLoadedId = -1; });
                    _preloadSurahData(widget.surahId!);
                  } else if (val.startsWith('reciter_')) {
                    setState(() => _selectedReciterIndex = int.parse(val.split('_')[1]));
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'none', child: Text('Arabic Only')),
                  const PopupMenuItem(value: 'en',   child: Text('+ English Translation')),
                  const PopupMenuItem(value: 'ur',   child: Text('+ Urdu Translation')),
                  const PopupMenuDivider(),
                  const PopupMenuItem(enabled: false, child: Text('Reciter', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  for (int i = 0; i < kReciters.length; i++)
                    PopupMenuItem(value: 'reciter_$i', child: Row(children: [
                      Icon(Icons.mic_rounded, size: 16, color: _selectedReciterIndex == i ? AppColors.tealPrimary : Colors.grey),
                      const SizedBox(width: 8),
                      Text(kReciters[i].name, style: TextStyle(fontWeight: _selectedReciterIndex == i ? FontWeight.bold : FontWeight.normal)),
                    ])),
                ],
              ),
            ],
      bottom: (!widget.isPageMode && (_showSearchBar || _showFontSlider))
          ? PreferredSize(
              preferredSize: Size.fromHeight(_showSearchBar ? 56 : 48),
              child: Container(
                color: AppColors.tealDeep,
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                child: _showSearchBar ? _buildInSurahSearchBar() : _buildFontSizeSlider(),
              ),
            )
          : null,
    );
  }

  Widget _buildInSurahSearchBar() => TextField(
    controller: _surahSearchCtrl, autofocus: true,
    onChanged: (v) => setState(() => _surahSearch = v),
    style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
    decoration: InputDecoration(
      hintText: 'Search ayah number or keyword...',
      hintStyle: GoogleFonts.poppins(color: Colors.white54, fontSize: 13),
      prefixIcon: const Icon(Icons.search_rounded, color: Colors.white60, size: 20),
      suffixIcon: _surahSearch.isNotEmpty ? IconButton(icon: const Icon(Icons.clear_rounded, color: Colors.white60, size: 18), onPressed: () { _surahSearchCtrl.clear(); setState(() => _surahSearch = ''); }) : null,
      filled: true, fillColor: Colors.white.withOpacity(0.12),
      contentPadding: const EdgeInsets.symmetric(vertical: 0),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
    ),
  );

  Widget _buildFontSizeSlider() => Row(children: [
    const Icon(Icons.text_decrease_rounded, color: Colors.white60, size: 18),
    Expanded(child: Slider(value: _arabicFontSize, min: 18, max: 38, divisions: 10, activeColor: AppColors.amberLight, inactiveColor: Colors.white24, onChanged: (v) => setState(() => _arabicFontSize = v))),
    const Icon(Icons.text_increase_rounded, color: Colors.white60, size: 18),
    const SizedBox(width: 8),
    Text('${_arabicFontSize.toInt()}px', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 11)),
  ]);

  // ─────────────────────────────────────────────────────────────
  // PAGE MODE BODY
  // Fix #6a: PageView with background loading — no full-screen blocker
  // ─────────────────────────────────────────────────────────────
  Widget _buildPageModeBody() {
    return PageView.builder(
      reverse: true,
      itemCount: 604,
      controller: _pageController,
      physics: const BouncingScrollPhysics(),
      onPageChanged: (p) async {
        setState(() => _currentDisplayPage = p + 1);
        _fadeController.reset();
        _fadeController.forward();
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('last_quran_page', p + 1);
        // Load page data in background
        _preloadPageData(p + 1);
      },
      itemBuilder: (context, index) {
        final pageNum = index + 1;
        // Trigger load if this page isn't cached yet
        if (_lastLoadedId != pageNum && !_isDataLoading) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _preloadPageData(pageNum));
        }
        return FadeTransition(
          opacity: Tween<double>(begin: 0.6, end: 1.0).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn)),
          child: _buildPageContent(pageNum),
        );
      },
    );
  }

  Widget _buildPageContent(int pageNum) {
    if (_lastLoadedId != pageNum) {
      // Non-blocking skeleton — just a small centered indicator
      return _buildPageLoadingPlaceholder();
    }
    if (_dataError != null) return _buildErrorWidget();
    if (_cachedAyahs == null || _cachedAyahs!.isEmpty) {
      return Center(child: Text('No ayahs on this page.', style: GoogleFonts.poppins(color: _T.textMuted(context))));
    }
    return _buildPhysicalMushafPage(_cachedAyahs!, pageNum);
  }

  Widget _buildPageLoadingPlaceholder() => Container(
    color: _T.mushafBg(context),
    child: Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 2.5, color: const Color(0xFFA87820).withOpacity(0.6))),
        const SizedBox(height: 12),
        Text('جاري التحميل...', style: GoogleFonts.amiri(color: _T.textMuted(context), fontSize: 14)),
      ]),
    ),
  );

  // ─────────────────────────────────────────────────────────────
  // SURAH MODE BODY  (Fix #6a: no blocking FutureBuilder)
  // ─────────────────────────────────────────────────────────────
  Widget _buildSurahModeBody() {
    if (_cachedAyahs == null && _isDataLoading) {
      // First ever load: small centered spinner only
      return Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary));
    }
    if (_dataError != null && _cachedAyahs == null) return _buildErrorWidget();
    if (_cachedAyahs == null) return const SizedBox.shrink();
    return _buildSurahCardView(_cachedAyahs!, _cachedTrans, _cachedSurahNum);
  }

  Widget _buildErrorWidget() => Center(
    child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.wifi_off_rounded, size: 48, color: _T.textMuted(context)),
      const SizedBox(height: 12),
      Text('Unable to load content.', style: GoogleFonts.poppins(color: _T.textDark(context), fontWeight: FontWeight.bold)),
      const SizedBox(height: 6),
      Text('Please check your connection.', style: GoogleFonts.poppins(color: _T.textMuted(context), fontSize: 13)),
      const SizedBox(height: 20),
      ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.tealPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        onPressed: () {
          setState(() { _dataError = null; _lastLoadedId = -1; });
          if (widget.isPageMode) _preloadPageData(_currentDisplayPage);
          else _preloadSurahData(widget.surahId!);
        },
        child: Text('Retry', style: GoogleFonts.poppins(color: Colors.white)),
      ),
    ])),
  );

  // ─────────────────────────────────────────────────────────────
  // FIX #3: Physical Mushaf Page — matching the screenshot style
  //
  // Screenshot analysis:
  //   • Clean white/off-white parchment background
  //   • Single bold rectangular outer border (no rounded corners)
  //   • Header row: "الم" right side,  page number center, "البقرة ٢" left side
  //   • Text flows RTL, justified, Naskh style, tight line-height
  //   • Ayah markers: Arabic numerals inside ﴾﴿ ornamental brackets
  //   • Ruku marker "ع" in right margin
  //   • Footer: "منزل ١" centered
  //   • NO color badges, NO gradient surah headers, NO emoji
  // ─────────────────────────────────────────────────────────────
  Widget _buildPhysicalMushafPage(List ayahs, int pageNum) {
    final Set<int> surahNums = {};
    for (final a in ayahs) surahNums.add((a is CachedAyah) ? a.surahNumber : 1);

    final isDark = _T.isDark(context);
    // Ink and border color — black on parchment (dark: warm cream on dark)
    final inkColor  = isDark ? const Color(0xFFE8DCC8) : const Color(0xFF1A1208);
    final bgColor   = isDark ? AppColors.charcoalDeep  : const Color(0xFFFAF3E0);
    final borderClr = isDark ? const Color(0xFF8A7050)  : const Color(0xFF2C2215);

    return SafeArea(
      child: Container(
        color: bgColor,
        // Outer margin
        padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
        child: Column(
          children: [
            // ── Above-border header row (like the screenshot) ────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Row(
                children: [
                  // Right side: Juz / Para marker (we show page-based juz from first ayah)
                  _pageHeaderLabel(_juzLabel(ayahs), inkColor, TextDirection.rtl),
                  const Spacer(),
                  // Center: page number in Arabic
                  Text(_toArabicNumber(pageNum),
                      style: TextStyle(fontFamily: 'Amiri', fontSize: 13, color: inkColor.withOpacity(0.7), fontWeight: FontWeight.bold)),
                  const Spacer(),
                  // Left side: Surah name + number
                  _pageHeaderLabel(_surahHeaderLabel(surahNums), inkColor, TextDirection.ltr),
                ],
              ),
            ),

            // ── The bordered Mushaf frame ─────────────────────────
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  // Fix #3: solid rectangular border (no borderRadius) matching photo
                  border: Border.all(color: borderClr, width: 1.8),
                ),
                child: Container(
                  // Inner inset border (double-line effect in Mushafs)
                  margin: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    border: Border.all(color: borderClr.withOpacity(0.5), width: 0.8),
                  ),
                  child: Stack(
                    children: [
                      // ── Main text area ─────────────────────────
                      Padding(
                        padding: const EdgeInsets.fromLTRB(22, 6, 10, 6),
                        child: LayoutBuilder(builder: (context, constraints) {
                          return _AutoFitMushafText(
                            ayahs: ayahs,
                            availableWidth: constraints.maxWidth,
                            availableHeight: constraints.maxHeight,
                            mushafTextColor: inkColor,
                            accentColor: inkColor, // black on parchment — no gold
                            cleanAyahText: _cleanAyahText,
                            toArabicNumber: _toArabicNumber,
                          );
                        }),
                      ),
                      // ── Ruku marker in right margin ────────────
                      Positioned(
                        right: 0,
                        top: 10,
                        child: RotatedBox(
                          quarterTurns: 1,
                          child: Text('ع', style: TextStyle(fontFamily: 'Amiri', fontSize: 11, color: inkColor.withOpacity(0.5), fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Below-border footer (like "منزل ١" in screenshot) ──
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Text(_manzilLabel(ayahs),
                  style: TextStyle(fontFamily: 'Amiri', fontSize: 11, color: inkColor.withOpacity(0.6))),
            ),
          ],
        ),
      ),
    );
  }

  // Page header helpers
  Widget _pageHeaderLabel(String text, Color color, TextDirection dir) => Text(
    text,
    textDirection: dir,
    style: TextStyle(fontFamily: 'Amiri', fontSize: 12, color: color, fontWeight: FontWeight.bold),
  );

  String _juzLabel(List ayahs) {
    if (ayahs.isEmpty) return '';
    final juz = (ayahs.first is CachedAyah) ? (ayahs.first as CachedAyah).juzNumber : 1;
    return 'الجزء ${_toArabicNumber(juz)}';
  }

  String _surahHeaderLabel(Set<int> surahNums) {
    if (surahNums.isEmpty) return '';
    final sn = surahNums.last; // last (leftmost) surah on page
    final data = kAllSurahs.firstWhere((s) => s['number'] == sn, orElse: () => kAllSurahs.first);
    return '${data['arabic']} ${_toArabicNumber(sn)}';
  }

  String _manzilLabel(List ayahs) {
    // Manzil is roughly juz/4; placeholder since API doesn't give manzil
    if (ayahs.isEmpty) return '';
    final juz = (ayahs.first is CachedAyah) ? (ayahs.first as CachedAyah).juzNumber : 1;
    final manzil = ((juz - 1) ~/ 4) + 1;
    return 'منزل ${_toArabicNumber(manzil)}';
  }

  // ─────────────────────────────────────────────────────────────
  // SURAH MODE — Card View
  // FIX #4: RangeError — fully rewritten itemCount logic
  // ─────────────────────────────────────────────────────────────
  Widget _buildSurahCardView(List ayahs, List? trans, int? surahNum) {
    final bool hasBismillah = (surahNum != 1 && surahNum != 9);
    final q = _surahSearch.trim().toLowerCase();

    // Build filtered index list — always safe indices into `ayahs`
    final List<int> filteredIdxs = [];
    for (int i = 0; i < ayahs.length; i++) {
      if (q.isEmpty) {
        filteredIdxs.add(i);
        continue;
      }
      final a = ayahs[i];
      final num  = (a is CachedAyah) ? a.numberInSurah  : (a['numberInSurah'] as int);
      final text = (a is CachedAyah) ? a.arabicText      : (a['text'] as String? ?? '');
      if (num.toString() == q) { filteredIdxs.add(i); continue; }
      if (text.contains(q))    { filteredIdxs.add(i); continue; }
      // translation match (only when trans available and index is valid)
      if (trans != null && i < trans.length) {
        final tr = trans[i]['text']?.toString() ?? '';
        if (tr.toLowerCase().contains(q)) { filteredIdxs.add(i); continue; }
      }
    }

    // ─── itemCount breakdown (Fix #4) ───────────────────────────
    // When search is empty:
    //   [0]            = Bismillah banner (if hasBismillah)
    //   [1..N]         = ayah cards
    // When search is active AND results exist:
    //   [0..M-1]       = filtered ayah cards  (no bismillah)
    // When search is active AND no results:
    //   [0]            = "no results" message  (exactly 1 item)
    //
    // There is NO extra "+1" for the no-results message mixed with
    // filteredIdxs.length — these are mutually exclusive paths.

    final bool isSearching = q.isNotEmpty;
    final bool noResults   = isSearching && filteredIdxs.isEmpty;

    // Determine count
    int itemCount;
    if (noResults) {
      itemCount = 1; // only the "no results" card
    } else if (!isSearching) {
      itemCount = (hasBismillah ? 1 : 0) + filteredIdxs.length;
    } else {
      itemCount = filteredIdxs.length; // no bismillah row while searching
    }

    return Column(
      children: [
        // ── Audio Player Bar (shown only when playing) ──────────
        if (_playingAyah >= 0) _buildAudioPlayerBar(surahNum ?? 1),

        // ── Ayah List ───────────────────────────────────────────
        Expanded(
          child: ListView.builder(
            controller: _surahScrollCtrl,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: itemCount,
            itemBuilder: (context, listIndex) {
              // ── "No results" single card ─────────────────────
              if (noResults) {
                return Center(child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text('No ayahs found for "$_surahSearch"',
                      style: GoogleFonts.poppins(color: _T.textMuted(context)), textAlign: TextAlign.center),
                ));
              }

              // ── Bismillah banner (search-empty mode only) ─────
              if (!isSearching && hasBismillah && listIndex == 0) {
                return _buildBismillahBanner();
              }

              // ── Compute ayah index safely ─────────────────────
              // offset = 1 only when bismillah is shown and this is index ≥ 1
              final int offset = (!isSearching && hasBismillah) ? 1 : 0;
              final int filteredPos = listIndex - offset;

              // Guard: should never be out of range after the rewrite,
              // but this is a safety net to avoid the red screen.
              if (filteredPos < 0 || filteredPos >= filteredIdxs.length) {
                return const SizedBox.shrink();
              }

              final int ayahIdx = filteredIdxs[filteredPos];
              final dynamic a   = ayahs[ayahIdx];

              final int num = (a is CachedAyah) ? a.numberInSurah  : (a['numberInSurah'] as int);
              final int sn  = (a is CachedAyah) ? a.surahNumber     : (surahNum ?? 1);
              final String rawText = (a is CachedAyah) ? a.arabicText : (a['text'] as String);
              final String cleaned = _cleanAyahText(rawText, sn, num);

              // Translation: use cached translation when available, else
              // fall back per-ayah index (guarded against null/range)
              final String? translation;
              if (a is CachedAyah) {
                translation = _activeLang == 'en' ? a.englishText : a.urduText;
              } else if (trans != null && ayahIdx < trans.length) {
                translation = trans[ayahIdx]['text'] as String?;
              } else {
                translation = null;
              }

              // Word highlighting for this ayah
              final bool isThisPlaying = _playingAyah == num && _isPlaying;
              final int  hlWord = (isThisPlaying) ? _highlightedWordIndex : -1;

              return _PremiumAyahCard(
                index: ayahIdx,
                numberInSurah: num,
                arabicText: cleaned,
                translationText: _activeLang == 'none' ? null : translation,
                isUrdu: _activeLang == 'ur',
                arabicNumeral: _toArabicNumber(num),
                surahNumber: sn,
                isPlaying: isThisPlaying,
                isCurrentAudio: _playingAyah == num,
                arabicFontSize: _arabicFontSize,
                highlightedWordIndex: hlWord,   // Fix #6b
                onPlayTap: () => _togglePlayPause(sn, num, cleaned),
                onBookmarkTap: () {
                  final surahName = kAllSurahs.firstWhere(
                    (s) => s['number'] == sn, orElse: () => kAllSurahs.first)['name'] as String;
                  _showBookmarkDialog(sn, num, surahName);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Audio Player Bar ─────────────────────────────────────────
  Widget _buildAudioPlayerBar(int surahNum) {
    final reciter = kReciters[_selectedReciterIndex];
    final total   = _audioDuration.inSeconds > 0 ? _audioDuration.inSeconds : 1;
    final pos     = _audioPosition.inSeconds.clamp(0, total);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.tealDeep, AppColors.tealPrimary]),
        boxShadow: [BoxShadow(color: AppColors.tealDeep.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(children: [
          CircleAvatar(radius: 18, backgroundColor: Colors.white.withOpacity(0.2), child: const Icon(Icons.mic_rounded, color: Colors.white, size: 18)),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(reciter.name, style: GoogleFonts.poppins(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
            Text(reciter.arabicName, style: GoogleFonts.amiri(color: Colors.white70, fontSize: 11)),
          ])),
          GestureDetector(
            onTap: () => _togglePlayPause(surahNum, _playingAyah, _playingAyahText),
            child: Container(width: 36, height: 36, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle), child: Icon(_isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.white, size: 22)),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () async { await _audioPlayer.stop(); if (mounted) setState(() { _isPlaying = false; _playingAyah = -1; _playingAyahText = ''; _highlightedWordIndex = -1; }); },
            child: const Icon(Icons.stop_circle_rounded, color: Colors.white60, size: 28),
          ),
        ]),
        const SizedBox(height: 6),
        Row(children: [
          Text(_formatDuration(_audioPosition), style: GoogleFonts.poppins(color: Colors.white60, fontSize: 10)),
          Expanded(child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: SliderTheme(
              data: SliderThemeData(
                trackHeight: 2,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
                activeTrackColor: AppColors.amberLight,
                inactiveTrackColor: Colors.white24,
                thumbColor: AppColors.amberLight,
                overlayColor: AppColors.amberLight.withOpacity(0.2),
              ),
              child: Slider(value: pos.toDouble(), min: 0, max: total.toDouble(), onChanged: (v) async => await _audioPlayer.seek(Duration(seconds: v.toInt()))),
            ),
          )),
          Text(_formatDuration(_audioDuration), style: GoogleFonts.poppins(color: Colors.white60, fontSize: 10)),
        ]),
      ]),
    );
  }

  String _formatDuration(Duration d) {
    return '${d.inMinutes.remainder(60).toString().padLeft(2,'0')}:${d.inSeconds.remainder(60).toString().padLeft(2,'0')}';
  }

  Widget _buildBismillahBanner() => Container(
    margin: const EdgeInsets.only(bottom: 24, top: 8),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(gradient: AppColors.emeraldGradient, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: AppColors.tealPrimary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))]),
    child: Stack(alignment: Alignment.center, children: [
      Opacity(opacity: 0.06, child: const Text('﷽', style: TextStyle(fontSize: 80, color: Colors.white))),
      Text('بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ', textDirection: TextDirection.rtl, textAlign: TextAlign.center, style: GoogleFonts.amiri(fontSize: 26, color: Colors.white, fontWeight: FontWeight.bold, height: 1.6)),
    ]),
  );

  // ── Bookmark ─────────────────────────────────────────────────
  void _showBookmarkDialog(int surahNum, int ayahNum, String surahName) async {
    final isAlready = await _BookmarkService.isBookmarked(surahNum, ayahNum);
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: _T.cardBg(context),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: _T.border(ctx), borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          Icon(isAlready ? Icons.bookmark_remove_rounded : Icons.bookmark_add_rounded, color: AppColors.amberPrimary, size: 36),
          const SizedBox(height: 12),
          Text(isAlready ? 'Remove Bookmark' : 'Add Bookmark', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 6),
          Text('$surahName • Ayah $ayahNum', style: GoogleFonts.poppins(color: _T.textMuted(ctx), fontSize: 13)),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: OutlinedButton(style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: GoogleFonts.poppins()))),
            const SizedBox(width: 12),
            Expanded(child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.amberPrimary, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              onPressed: () async {
                Navigator.pop(ctx);
                isAlready ? await _BookmarkService.remove(surahNum, ayahNum) : await _BookmarkService.add(surahNum, ayahNum, surahName);
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isAlready ? 'Bookmark removed.' : 'Ayah $ayahNum bookmarked!', style: GoogleFonts.poppins()), backgroundColor: AppColors.tealPrimary, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
              },
              child: Text(isAlready ? 'Remove' : 'Bookmark', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
            )),
          ]),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// FIX #5: BOOKMARKED AYAHS SCREEN
// A dedicated screen that lists saved bookmarks.
// Navigate to it from the main appbar bookmarks icon.
// ─────────────────────────────────────────────────────────────
class BookmarkedAyahsScreen extends StatefulWidget {
  const BookmarkedAyahsScreen({super.key});
  @override
  State<BookmarkedAyahsScreen> createState() => _BookmarkedAyahsScreenState();
}

class _BookmarkedAyahsScreenState extends State<BookmarkedAyahsScreen> {
  List<Map<String, dynamic>> _bookmarks = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await _BookmarkService.load();
    if (mounted) setState(() { _bookmarks = list; _loading = false; });
  }

  Future<void> _remove(int surahNum, int ayahNum) async {
    await _BookmarkService.remove(surahNum, ayahNum);
    await _load();
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Bookmark removed.', style: GoogleFonts.poppins()), backgroundColor: AppColors.tealPrimary, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _T.bg(context),
      appBar: AppBar(
        toolbarHeight: 52,
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [AppColors.tealDeep, AppColors.tealPrimary], begin: Alignment.topLeft, end: Alignment.bottomRight))),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Text('My Bookmarks', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
          Text('المرجعيات المحفوظة', style: GoogleFonts.amiri(color: Colors.white70, fontSize: 11)),
        ])),
        actions: [
          if (_bookmarks.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded, color: Colors.white70),
              tooltip: 'Clear all bookmarks',
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text('Clear all?', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                    content: Text('This will remove all ${_bookmarks.length} bookmarks.', style: GoogleFonts.poppins()),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                      TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Clear', style: TextStyle(color: Colors.red))),
                    ],
                  ),
                );
                if (confirm == true) {
                  await _BookmarkService.save([]);
                  await _load();
                }
              },
            ),
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary))
          : _bookmarks.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: _bookmarks.length,
                  itemBuilder: (context, index) => _buildBookmarkCard(_bookmarks[index]),
                ),
    );
  }

  Widget _buildEmptyState() => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.bookmarks_outlined, size: 72, color: _T.textMuted(context)),
      const SizedBox(height: 16),
      Text('No Bookmarks Yet', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: _T.textDark(context))),
      const SizedBox(height: 8),
      Text('Tap the 🔖 icon on any Ayah\nto save it here.', style: GoogleFonts.poppins(color: _T.textMuted(context), fontSize: 14), textAlign: TextAlign.center),
    ]),
  );

  Widget _buildBookmarkCard(Map<String, dynamic> bm) {
    final surahNum = bm['surah'] as int;
    final ayahNum  = bm['ayah']  as int;
    final name     = bm['name']  as String? ?? '';
    final ts       = bm['ts']    as int? ?? 0;
    final date     = ts > 0 ? _formatTs(ts) : '';
    final isMeccan = kAllSurahs.firstWhere((s) => s['number'] == surahNum, orElse: () => kAllSurahs.first)['type'] == 'MECCAN';
    final c        = isMeccan ? AppColors.tealPrimary : AppColors.amberPrimary;

    return Dismissible(
      key: Key('bm_${surahNum}_$ayahNum'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(color: Colors.red.shade400, borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      confirmDismiss: (_) async => true,
      onDismissed: (_) => _remove(surahNum, ayahNum),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 5),
        elevation: 0,
        color: _T.cardBg(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: _T.border(context))),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => UniversalQuranReader(
            isPageMode: false,
            surahId: surahNum,
            title: name,
            surahType: isMeccan ? 'MECCAN' : 'MEDINAN',
            totalAyahs: kAllSurahs.firstWhere((s) => s['number'] == surahNum, orElse: () => kAllSurahs.first)['ayahs'] as int,
            isCached: true, // assume cached for bookmark navigation
          ))),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            child: Row(children: [
              // Surah number badge
              Container(width: 44, height: 44, decoration: BoxDecoration(color: c.withOpacity(0.1), shape: BoxShape.circle, border: Border.all(color: c.withOpacity(0.4), width: 1.5)),
                child: Center(child: Text('$surahNum', style: GoogleFonts.poppins(color: c, fontWeight: FontWeight.bold, fontSize: 12)))),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: _T.textDark(context))),
                const SizedBox(height: 3),
                Row(children: [
                  Icon(Icons.format_quote_rounded, size: 12, color: _T.textMuted(context)),
                  const SizedBox(width: 4),
                  Text('Ayah $ayahNum', style: GoogleFonts.poppins(fontSize: 12, color: _T.textMuted(context))),
                  if (date.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    const Text('•', style: TextStyle(color: Colors.grey, fontSize: 10)),
                    const SizedBox(width: 8),
                    Text(date, style: GoogleFonts.poppins(fontSize: 10, color: _T.textMuted(context))),
                  ],
                ]),
              ])),
              Icon(Icons.chevron_right_rounded, color: _T.textMuted(context), size: 18),
            ]),
          ),
        ),
      ),
    );
  }

  String _formatTs(int ms) {
    final dt = DateTime.fromMillisecondsSinceEpoch(ms);
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

// ─────────────────────────────────────────────────────────────
// PREMIUM AYAH CARD  (Surah Mode)
// Fix #6b: accepts highlightedWordIndex for green word highlight
// ─────────────────────────────────────────────────────────────
class _PremiumAyahCard extends StatelessWidget {
  final int index, numberInSurah, surahNumber;
  final String arabicText, arabicNumeral;
  final String? translationText;
  final bool isUrdu, isPlaying, isCurrentAudio;
  final double arabicFontSize;
  final int highlightedWordIndex; // -1 = no highlight
  final VoidCallback onPlayTap;
  final VoidCallback onBookmarkTap;

  const _PremiumAyahCard({
    required this.index,
    required this.numberInSurah,
    required this.arabicText,
    required this.arabicNumeral,
    required this.surahNumber,
    this.translationText,
    required this.isUrdu,
    required this.isPlaying,
    required this.isCurrentAudio,
    required this.arabicFontSize,
    required this.highlightedWordIndex,
    required this.onPlayTap,
    required this.onBookmarkTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark      = _T.isDark(context);
    final goldColor   = isDark ? const Color(0xFFD4A942) : const Color(0xFFA87820);
    final isHighlighted = isCurrentAudio;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isHighlighted ? AppColors.tealPrimary.withOpacity(isDark ? 0.12 : 0.06) : _T.cardBg(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isHighlighted ? AppColors.tealPrimary.withOpacity(0.4) : _T.border(context), width: isHighlighted ? 1.5 : 1),
        boxShadow: isHighlighted ? [BoxShadow(color: AppColors.tealPrimary.withOpacity(0.1), blurRadius: 12, offset: const Offset(0, 4))] : [],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        // ── Card header ─────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isHighlighted ? AppColors.tealPrimary.withOpacity(0.08) : goldColor.withOpacity(isDark ? 0.08 : 0.04),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border(bottom: BorderSide(color: goldColor.withOpacity(0.25), width: 0.8)),
          ),
          child: Row(children: [
            _AyahNumberBadge(number: arabicNumeral, goldColor: goldColor),
            const SizedBox(width: 10),
            Expanded(child: Text('Ayah $numberInSurah', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.tealPrimary))),
            // Play button
            GestureDetector(onTap: onPlayTap, child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppColors.tealPrimary.withOpacity(isPlaying ? 0.15 : 0.07), borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.tealPrimary.withOpacity(isPlaying ? 0.5 : 0.2))),
              child: Icon(isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded, color: AppColors.tealPrimary, size: 22),
            )),
            const SizedBox(width: 6),
            // Bookmark button
            GestureDetector(onTap: onBookmarkTap, child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppColors.amberPrimary.withOpacity(0.07), borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.amberPrimary.withOpacity(0.2))),
              child: Icon(Icons.bookmark_border_rounded, color: AppColors.amberPrimary, size: 20),
            )),
          ]),
        ),

        // ── Arabic Text with word highlighting (Fix #6b) ─────────
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
          child: highlightedWordIndex >= 0
              ? _buildHighlightedArabicText(context)
              : Text(arabicText, textAlign: TextAlign.justify, textDirection: TextDirection.rtl,
                  style: GoogleFonts.amiri(fontSize: arabicFontSize, height: 1.9, fontWeight: FontWeight.w500, color: _T.mushafText(context))),
        ),

        // ── Translation ──────────────────────────────────────────
        if (translationText != null) ...[
          Container(margin: const EdgeInsets.symmetric(horizontal: 16), height: 0.8, decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.transparent, goldColor.withOpacity(0.3), Colors.transparent]))),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
            child: Text(translationText!, textAlign: isUrdu ? TextAlign.right : TextAlign.left, textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
              style: isUrdu
                  ? GoogleFonts.notoNastaliqUrdu(fontSize: 16, height: 2.2, color: _T.textDark(context))
                  : GoogleFonts.poppins(fontSize: 14, height: 1.7, color: _T.textMuted(context))),
          ),
        ],
      ]),
    );
  }

  // Fix #6b: render Arabic text word-by-word with green highlight
  Widget _buildHighlightedArabicText(BuildContext context) {
    final words = arabicText.split(' ').where((w) => w.isNotEmpty).toList();
    return RichText(
      textAlign: TextAlign.justify,
      textDirection: TextDirection.rtl,
      text: TextSpan(
        children: List.generate(words.length, (i) {
          final isHl = i == highlightedWordIndex;
          return TextSpan(
            text: '${words[i]} ',
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: arabicFontSize,
              height: 1.9,
              fontWeight: FontWeight.w500,
              color: isHl ? Colors.green.shade700 : _T.mushafText(context),
              backgroundColor: isHl ? Colors.green.withOpacity(0.12) : Colors.transparent,
            ),
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// AYAH NUMBER BADGE (ornamental diamond)
// ─────────────────────────────────────────────────────────────
class _AyahNumberBadge extends StatelessWidget {
  final String number;
  final Color goldColor;
  const _AyahNumberBadge({required this.number, required this.goldColor});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 36, height: 36,
    child: Stack(alignment: Alignment.center, children: [
      Transform.rotate(angle: 0.785398, child: Container(width: 26, height: 26, decoration: BoxDecoration(border: Border.all(color: goldColor, width: 1.5), borderRadius: BorderRadius.circular(4), color: goldColor.withOpacity(0.08)))),
      Text(number, style: TextStyle(fontFamily: 'Amiri', fontSize: 11, fontWeight: FontWeight.bold, color: goldColor)),
    ]),
  );
}

// ─────────────────────────────────────────────────────────────
// _AutoFitMushafText — binary-search font fitter (unchanged logic)
// ─────────────────────────────────────────────────────────────
class _AutoFitMushafText extends StatelessWidget {
  final List ayahs;
  final double availableWidth, availableHeight;
  final Color mushafTextColor, accentColor;
  final String Function(String, int, int) cleanAyahText;
  final String Function(int) toArabicNumber;

  const _AutoFitMushafText({
    required this.ayahs,
    required this.availableWidth,
    required this.availableHeight,
    required this.mushafTextColor,
    required this.accentColor,
    required this.cleanAyahText,
    required this.toArabicNumber,
  });

  TextSpan _buildSpan(double fontSize) {
    const lineH = 2.0;
    return TextSpan(children: ayahs.map((a) {
      final raw     = (a is CachedAyah) ? a.arabicText     : (a['text'] as String);
      final num     = (a is CachedAyah) ? a.numberInSurah  : (a['numberInSurah'] as int);
      final sn      = (a is CachedAyah) ? a.surahNumber    : 1;
      final cleaned = cleanAyahText(raw, sn, num);
      return TextSpan(children: [
        TextSpan(text: '$cleaned ', style: TextStyle(fontFamily: 'Amiri', fontSize: fontSize, height: lineH, color: mushafTextColor, fontWeight: FontWeight.w500)),
        TextSpan(text: '\uFD3E${toArabicNumber(num)}\uFD3F ', style: TextStyle(fontFamily: 'Amiri', fontSize: fontSize * 0.75, height: lineH, color: accentColor, fontWeight: FontWeight.bold)),
      ]);
    }).toList());
  }

  bool _fits(double fontSize) {
    final tp = TextPainter(text: _buildSpan(fontSize), textDirection: TextDirection.rtl, textAlign: TextAlign.justify);
    tp.layout(maxWidth: availableWidth);
    return tp.height <= availableHeight;
  }

  double _computeBestFontSize() {
    double lo = 8.0, hi = 26.0;
    if (!_fits(lo)) return lo;
    if (_fits(hi)) return hi;
    while (hi - lo > 0.5) {
      final mid = (lo + hi) / 2;
      _fits(mid) ? lo = mid : hi = mid;
    }
    return lo;
  }

  @override
  Widget build(BuildContext context) {
    final fontSize = _computeBestFontSize();
    return SizedBox(
      width: availableWidth, height: availableHeight,
      child: RichText(text: _buildSpan(fontSize), textDirection: TextDirection.rtl, textAlign: TextAlign.justify, softWrap: true),
    );
  }
}
