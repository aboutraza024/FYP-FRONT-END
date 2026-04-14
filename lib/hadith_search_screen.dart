import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'app_ui_kit.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'hadith_model.dart';
import 'quran_isar_models.dart';

class HadithSearchScreen extends StatefulWidget {
  const HadithSearchScreen({super.key});

  @override
  State<HadithSearchScreen> createState() => _HadithSearchScreenState();
}

class _HadithSearchScreenState extends State<HadithSearchScreen> with TickerProviderStateMixin {
  final String apiKey = "\$2y\$10\$z4s9ee94xMnleGYVukBMu8FpO7cqPvAAh3tRVBkr0KkxXi03VFC";
  
  Isar? isar;
  String? selectedBookSlug;
  String? selectedBookName;
  String? selectedChapterNumber;
  String? selectedChapterName;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  late AnimationController _mainFadeController;
  late AnimationController _listAnimationController;

  @override
  void initState() {
    super.initState();
    _initIsar();
    _mainFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _listAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  Future<void> _initIsar() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = Isar.getInstance("sirat_al_mustaqeem_db") ?? await Isar.open(
      [CachedChapterSchema, CachedHadithSchema, CachedAyahSchema],
      directory: dir.path,
      name: "sirat_al_mustaqeem_db",
    );
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _mainFadeController.dispose();
    _listAnimationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<List<CachedChapter>> _getChapters(String slug) async {
    if (isar == null) return [];
    final localChapters = await isar!.cachedChapters.filter().bookSlugEqualTo(slug).findAll();
    if (localChapters.isNotEmpty) return localChapters;

    try {
      final response = await http.get(Uri.parse("https://hadithapi.com/api/$slug/chapters?apiKey=$apiKey"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List chaptersRaw = data["chapters"];
        final List<CachedChapter> toCache = chaptersRaw.map((c) => CachedChapter()
          ..bookSlug = slug
          ..chapterNumber = c["chapterNumber"].toString()
          ..chapterEnglish = c["chapterEnglish"] ?? ""
          ..chapterUrdu = c["chapterUrdu"] ?? ""
          ..chapterArabic = c["chapterArabic"] ?? ""
        ).toList();
        await isar!.writeTxn(() => isar!.cachedChapters.putAll(toCache));
        return toCache;
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
    return [];
  }

  Future<List<CachedHadith>> _getHadiths(String slug, String chapterNum) async {
    if (isar == null) return [];
    final localHadiths = await isar!.cachedHadiths.filter()
        .bookSlugEqualTo(slug)
        .chapterNumberEqualTo(chapterNum)
        .findAll();
    if (localHadiths.isNotEmpty) return localHadiths;

    try {
      final response = await http.get(Uri.parse("https://hadithapi.com/public/api/hadiths?apiKey=$apiKey&book=$slug&chapter=$chapterNum&paginate=150"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List hadithsRaw = data["hadiths"]["data"];
        final List<CachedHadith> toCache = hadithsRaw.map((h) => CachedHadith()
          ..bookSlug = slug
          ..chapterNumber = chapterNum
          ..hadithNumber = h["hadithNumber"].toString()
          ..arabicText = h["hadithArabic"] ?? ""
          ..urduText = h["hadithUrdu"] ?? ""
          ..englishText = h["hadithEnglish"] ?? ""
          ..status = h["status"] ?? "Unknown"
        ).toList();
        await isar!.writeTxn(() => isar!.cachedHadiths.putAll(toCache));
        return toCache;
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
    return [];
  }

  void _onBottomNavTap(int index) {
    if (index == 1) return;
    HapticFeedback.mediumImpact();
    final routes = ['/', '/hadith-search', '/quran', '/prayer-times', '/utilities'];
    Navigator.pushReplacementNamed(context, routes[index]);
  }

  bool _handleBackPress() {
    HapticFeedback.lightImpact();
    _listAnimationController.reset();
    if (selectedChapterNumber != null) {
      setState(() => selectedChapterNumber = null);
      return false;
    } else if (selectedBookSlug != null) {
      setState(() {
        selectedBookSlug = null;
        _searchQuery = "";
        _searchController.clear();
      });
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: selectedBookSlug == null,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _handleBackPress();
      },
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0D7B62), Color(0xFF0A5248)],
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  _buildHeader(context),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        // ── FIXED: warm charcoal instead of cold blue-grey ──
                        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(35),
                          topRight: Radius.circular(35),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, -5),
                          )
                        ],
                      ),
                      child: isar == null
                        ? const Center(child: CircularProgressIndicator(color: Color(0xFF0F7B63)))
                        : AnimatedSwitcher(
                            duration: const Duration(milliseconds: 500),
                            switchInCurve: Curves.easeOutQuart,
                            child: _buildMainContent(isDark),
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: FloatingNavBar(
          currentIndex: 1,
          onTap: _onBottomNavTap,
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    String title = "Hadith Collections";
    if (selectedChapterNumber != null) title = "Hadith Text";
    else if (selectedBookSlug != null) title = selectedBookName ?? "Chapters";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 22),
            onPressed: () {
              if (selectedBookSlug == null) Navigator.pop(context);
              else _handleBackPress();
            },
          ),
          const SizedBox(width: 10),
          Expanded(
            child: FadeTransition(
              opacity: _mainFadeController,
              child: Text(
                title,
                style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(bool isDark) {
    if (selectedBookSlug == null) return _buildHadithBooksSection(isDark);
    if (selectedChapterNumber == null) return _buildChapterListSection(isDark);
    return _buildHadithContentList(isDark);
  }

  Widget _buildHadithBooksSection(bool isDark) {
    final List<Map<String, String>> books = [
      {'title': 'Sahih Bukhari',    'arabic': 'صحيح البخاري', 'slug': 'sahih-bukhari'},
      {'title': 'Sahih Muslim',     'arabic': 'صحيح مسلم',    'slug': 'sahih-muslim'},
      {'title': 'Sunan Abu Dawood', 'arabic': 'سنن أبي داود', 'slug': 'abu-dawood'},
      {'title': 'Jami` at-Tirmidhi','arabic': 'جامع ترمذی',   'slug': 'al-tirmidhi'},
      {'title': 'Sunan an-Nasai',   'arabic': 'سنن نسائی',    'slug': 'sunan-nasai'},
      {'title': 'Sunan Ibn Majah',  'arabic': 'سنن ابن ماجہ', 'slug': 'ibn-e-majah'},
    ];

    _listAnimationController.forward();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Select a Collection',
              style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : Colors.black54)),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 18,
              mainAxisSpacing: 18,
              childAspectRatio: 1.1,
            ),
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return FadeTransition(
                opacity: CurvedAnimation(
                    parent: _listAnimationController,
                    curve: Interval(index * 0.1, 1.0, curve: Curves.easeOut)),
                child: ScaleTransition(
                  scale: CurvedAnimation(
                      parent: _listAnimationController,
                      curve: Interval(index * 0.1, 1.0, curve: Curves.easeOutBack)),
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        selectedBookSlug = book['slug'];
                        selectedBookName = book['title'];
                      });
                    },
                    borderRadius: BorderRadius.circular(22),
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F7B63).withOpacity(isDark ? 0.12 : 0.06),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                            color: const Color(0xFF0F7B63).withOpacity(0.2)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(book['title']!,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: isDark ? Colors.white : Colors.black87)),
                          const SizedBox(height: 10),
                          Text(book['arabic']!,
                              style: GoogleFonts.amiri(
                                  color: const Color(0xFF0F7B63),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChapterListSection(bool isDark) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _searchQuery = value),
            style: GoogleFonts.poppins(fontSize: 14),
            decoration: InputDecoration(
              hintText: "Search Chapter...",
              prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF0F7B63)),
              filled: true,
              // ── FIXED: warm charcoal instead of cold blue-grey ──
              fillColor: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF3F4F6),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<CachedChapter>>(
            key: ValueKey("chapters_$selectedBookSlug"),
            future: _getChapters(selectedBookSlug!),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF0F7B63)));
              }
              final chapters = (snapshot.data ?? []).where((c) {
                final query = _searchQuery.toLowerCase();
                return c.chapterEnglish!.toLowerCase().contains(query) ||
                    c.chapterUrdu!.contains(query) ||
                    c.chapterNumber.contains(query);
              }).toList();

              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 10),
                itemCount: chapters.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  final chapter = chapters[index];
                  return SlideTransition(
                    position: Tween<Offset>(
                            begin: const Offset(0.5, 0), end: Offset.zero)
                        .animate(CurvedAnimation(
                            parent: _mainFadeController,
                            curve: Interval((index % 10) * 0.05, 1.0,
                                curve: Curves.easeOutCubic))),
                    child: ListTile(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() {
                          selectedChapterNumber = chapter.chapterNumber;
                          selectedChapterName = chapter.chapterEnglish;
                        });
                      },
                      leading: CircleAvatar(
                        backgroundColor:
                            const Color(0xFF0F7B63).withOpacity(0.1),
                        child: Text(chapter.chapterNumber,
                            style: const TextStyle(
                                color: Color(0xFF0F7B63),
                                fontWeight: FontWeight.bold,
                                fontSize: 12)),
                      ),
                      title: Text(chapter.chapterArabic ?? "",
                          textAlign: TextAlign.right,
                          style: GoogleFonts.amiri(
                              fontWeight: FontWeight.bold, fontSize: 19)),
                      subtitle: Text(chapter.chapterUrdu ?? "",
                          textAlign: TextAlign.right,
                          style: GoogleFonts.notoNastaliqUrdu(
                              fontSize: 14, color: Colors.grey)),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHadithContentList(bool isDark) {
    return FutureBuilder<List<CachedHadith>>(
      key: ValueKey("content_${selectedBookSlug}_$selectedChapterNumber"),
      future: _getHadiths(selectedBookSlug!, selectedChapterNumber!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: Color(0xFF0F7B63)));
        }
        final hadiths = snapshot.data ?? [];

        if (hadiths.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_off_rounded, size: 60, color: Colors.grey),
                const SizedBox(height: 15),
                Text("Chapter not Downloaded.\nInternet connection required.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 20),
          itemCount: hadiths.length,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            final h = hadiths[index];
            final bool isSahih =
                h.status?.toLowerCase().contains("sahih") ?? false;
            final statusColor =
                isSahih ? const Color(0xFF0F7B63) : Colors.orangeAccent;

            return FadeTransition(
              opacity: _mainFadeController,
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                elevation: 0,
                // ── FIXED: warm charcoal card / neutral light ──
                color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF4F4F5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(
                      color: isDark
                          ? Colors.white10
                          : Colors.black.withOpacity(0.05)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12)),
                            child: Text(h.status ?? "Unknown",
                                style: TextStyle(
                                    color: statusColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10)),
                          ),
                          Text("Hadith #${h.hadithNumber}",
                              style: GoogleFonts.poppins(
                                  color: Colors.grey,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500)),
                        ],
                      ),
                      const SizedBox(height: 25),
                      Text(h.arabicText ?? "",
                          textAlign: TextAlign.right,
                          style: GoogleFonts.amiri(
                              fontSize: 22,
                              height: 1.9,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87)),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Divider(thickness: 0.5),
                      ),
                      Text(h.urduText ?? "",
                          textAlign: TextAlign.right,
                          style: GoogleFonts.notoNastaliqUrdu(
                              fontSize: 17,
                              height: 2.3,
                              color: const Color(0xFF0F7B63))),
                      const SizedBox(height: 20),
                      Text(h.englishText ?? "",
                          style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: isDark ? Colors.white60 : Colors.black54,
                              height: 1.6)),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}