import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';   // path_provider: ^2.1.2
import 'package:record/record.dart';                  // record: ^5.1.2
import 'package:shared_preferences/shared_preferences.dart';
import 'app_ui_kit.dart';
import 'custom_drawer.dart';
import 'namaz_database.dart';

// ════════════════════════════════════════════════════════════════════════════
//  ⚙️  API CONFIG
//  Apna WiFi IP yahan daalo. Windows: cmd → ipconfig → IPv4 Address
//  Mac/Linux: terminal → ifconfig → en0 inet
//  Android Emulator: 10.0.2.2  |  iOS Simulator: 127.0.0.1
// ════════════════════════════════════════════════════════════════════════════
class ApiConfig {
  static const String baseUrl = 'https://hadith-chat-bot-backend-ckhhdnawdee0cvb6.canadacentral-01.azurewebsites.net';

  static const Duration timeout = Duration(seconds: 120);

  static Uri chat()          => Uri.parse('$baseUrl/chat');
  static Uri voiceToHadith() => Uri.parse('$baseUrl/voice-to-hadith');
  static Uri imageToHadith() => Uri.parse('$baseUrl/image-to-hadith');
}

// ════════════════════════════════════════════════════════════════════════════
//  📡  API SERVICE — teeno endpoints
// ════════════════════════════════════════════════════════════════════════════
class HadithApiService {

  // ── 1. Text Chat ──────────────────────────────────────────────────────────
  static Future<String> sendTextQuery({
    required String query,
    String? bookFilter,
  }) async {
    try {
      final response = await http
          .post(
            ApiConfig.chat(),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'query'      : query,
              // Send null when 'All 6 Books' selected — backend searches all books
              'book_filter': (bookFilter == null || bookFilter == 'All 6 Books')
                  ? null
                  : bookFilter,
            }),
          )
          .timeout(ApiConfig.timeout);
      return _parse(response);
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    } on SocketException {
      throw Exception(
        'Cannot connect to server.\n'
        '• Is the backend running? (python main.py)\n'
        '• Is the IP correct? (ApiConfig.baseUrl)',
      );
    }
  }

  // ── 2. Voice Chat ─────────────────────────────────────────────────────────
  // userText optional hai — agar user ne kuch type nahi kiya toh null send
  static Future<String> sendVoiceQuery({
    required String audioPath,
    String? userText,          // optional — only sent if user typed something
    String? bookFilter,
  }) async {
    try {
      final req = http.MultipartRequest('POST', ApiConfig.voiceToHadith());

      // Audio file — always required
      req.files.add(await http.MultipartFile.fromPath('file', audioPath));

      // user_text — only add when user actually typed something
      final trimmed = (userText ?? '').trim();
      if (trimmed.isNotEmpty) {
        req.fields['user_text'] = trimmed;
      }
      // book_filter — only when a specific book is selected
      if (bookFilter != null && bookFilter != 'All 6 Books') {
        req.fields['book_filter'] = bookFilter;
      }

      final streamed = await req.send().timeout(ApiConfig.timeout);
      final res      = await http.Response.fromStream(streamed);
      return _parse(res);
    } on TimeoutException {
      throw Exception('Audio processing timed out. Please try again.');
    } on SocketException {
      throw Exception('Cannot connect to server. Check if backend is running.');
    }
  }

  // ── 3. Image Chat ─────────────────────────────────────────────────────────
  // userText optional hai — agar sirf image bheja toh null
  static Future<String> sendImageQuery({
    required String imagePath,
    String? userText,          // optional
    String? bookFilter,
  }) async {
    try {
      final req = http.MultipartRequest('POST', ApiConfig.imageToHadith());

      // Image file — always required
      req.files.add(await http.MultipartFile.fromPath('file', imagePath));

      // user_text — only add when user actually typed something
      final trimmed = (userText ?? '').trim();
      if (trimmed.isNotEmpty) {
        req.fields['user_text'] = trimmed;
      }
      // book_filter
      if (bookFilter != null && bookFilter != 'All 6 Books') {
        req.fields['book_filter'] = bookFilter;
      }

      final streamed = await req.send().timeout(ApiConfig.timeout);
      final res      = await http.Response.fromStream(streamed);
      return _parse(res);
    } on TimeoutException {
      throw Exception('Image processing timed out. Please try again.');
    } on SocketException {
      throw Exception('Cannot connect to server. Check if backend is running.');
    }
  }

  // ── Common Response Parser ────────────────────────────────────────────────
  static String _parse(http.Response response) {
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200) {
      final success = body['success'] as bool? ?? false;
      if (!success) {
        return body['message'] as String? ?? 'No Hadith content detected in the image.';
      }
      return body['response'] as String? ?? 'No response received.';
    }
    final detail = body['detail'] ?? body['error'] ?? 'Unknown error';
    throw Exception('Server Error ${response.statusCode}: $detail');
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  🏠  HOME SCREEN
// ════════════════════════════════════════════════════════════════════════════
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _listController;
  late AnimationController _pulseController;

  String _hijriDate      = '';
  String _gregorianDate  = '';
  String _nextPrayerName = '';
  String _nextPrayerTime = '';

  static const _features = [
    _FeatureItem(
      title: 'Hadith',    arabic: 'الحديث',  icon: Icons.auto_stories_rounded,
      route: '/hadith-search', gradient: AppColors.cardHadith,
    ),
    _FeatureItem(
      title: 'Quran',     arabic: 'القرآن',  icon: Icons.menu_book_rounded,
      route: '/quran',         gradient: AppColors.cardQuran,
    ),
    _FeatureItem(
      title: 'Prayer',    arabic: 'الصلاة',  icon: Icons.access_time_rounded,
      route: '/prayer-times',  gradient: AppColors.cardPrayer,
    ),
    _FeatureItem(
      title: 'Utilities', arabic: 'الأدوات', icon: Icons.grid_view_rounded,
      route: '/utilities',     gradient: AppColors.cardUtils,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _listController = AnimationController(
        duration: const Duration(milliseconds: 1400), vsync: this)..forward();
    _pulseController = AnimationController(
        duration: const Duration(seconds: 3), vsync: this)..repeat(reverse: true);
    _loadDynamicData();
  }

  Future<void> _loadDynamicData() async {
    final now = DateTime.now();

    final adjustedDate = now.subtract(const Duration(days: 1));
    final hijri        = HijriCalendar.fromDate(adjustedDate);
    final hijriStr     = '${hijri.hDay} ${hijri.longMonthName} ${hijri.hYear} AH';
    final gregStr      = DateFormat('EEE, dd MMM yyyy').format(now);

    String nextName = '';
    String nextTime = '';
    try {
      final data = await NamazDatabase.instance.getTimes();
      if (data.isNotEmpty) {
        final row = data.first;
        final prayerList = [
          {'name': 'Fajr',    'time': row['fajrBefore']?.toString()    ?? '', 'on': row['fajrOn']    == 1},
          {'name': 'Dhuhr',   'time': row['dhuhrBefore']?.toString()   ?? '', 'on': row['dhuhrOn']   == 1},
          {'name': 'Asr',     'time': row['asrBefore']?.toString()     ?? '', 'on': row['asrOn']     == 1},
          {'name': 'Maghrib', 'time': row['maghribBefore']?.toString() ?? '', 'on': row['maghribOn'] == 1},
          {'name': 'Isha',    'time': row['ishaBefore']?.toString()    ?? '', 'on': row['ishaOn']    == 1},
        ];
        for (final p in prayerList) {
          final enabled = p['on'] as bool;
          final timeStr = p['time'] as String;
          if (!enabled || timeStr.isEmpty) continue;
          try {
            final DateTime parsed = timeStr.toUpperCase().contains('AM') ||
                    timeStr.toUpperCase().contains('PM')
                ? DateFormat('h:mm a').parse(timeStr)
                : DateFormat('HH:mm').parse(timeStr);
            final prayerDt = DateTime(now.year, now.month, now.day, parsed.hour, parsed.minute);
            if (prayerDt.isAfter(now)) {
              nextName = p['name'] as String;
              nextTime = timeStr;
              break;
            }
          } catch (_) {}
        }
        if (nextName.isEmpty) {
          for (final p in prayerList) {
            if (p['on'] as bool && (p['time'] as String).isNotEmpty) {
              nextName = p['name'] as String;
              nextTime = p['time'] as String;
              break;
            }
          }
        }
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _hijriDate      = hijriStr;
        _gregorianDate  = gregStr;
        _nextPrayerName = nextName;
        _nextPrayerTime = nextTime;
      });
    }
  }

  @override
  void dispose() {
    _listController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    HapticFeedback.lightImpact();
    const routes = ['/', '/hadith-search', '/quran', '/prayer-times', '/utilities'];
    if (ModalRoute.of(context)?.settings.name != routes[index]) {
      Navigator.pushNamed(context, routes[index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer: const CustomDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 28),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HadithChatBotScreen()),
              ),
              child: const GoldBadge('AI'),
            ),
          ),
        ],
      ),
      body: GradientBackground(
        isDark: isDark,
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _WelcomeCard(
                      pulseController: _pulseController,
                      hijriDate:       _hijriDate,
                      gregorianDate:   _gregorianDate,
                      nextPrayerName:  _nextPrayerName,
                      nextPrayerTime:  _nextPrayerTime,
                    ),
                    const SizedBox(height: 28),
                    const SectionHeader(title: 'Islamic Features', arabicTitle: 'خصوصیات'),
                    const SizedBox(height: 16),
                  ]),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.95,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => StaggerEntry(
                      controller: _listController,
                      index: i,
                      total: _features.length,
                      child: _FeatureCard(
                        item: _features[i],
                        onTap: () => Navigator.pushNamed(context, _features[i].route),
                      ),
                    ),
                    childCount: _features.length,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
      bottomNavigationBar: FloatingNavBar(currentIndex: 0, onTap: _onNavTap),
      floatingActionButton: const AnimatedAIButton(),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  🃏  WELCOME CARD
// ════════════════════════════════════════════════════════════════════════════
class _WelcomeCard extends StatelessWidget {
  final AnimationController pulseController;
  final String hijriDate;
  final String gregorianDate;
  final String nextPrayerName;
  final String nextPrayerTime;

  const _WelcomeCard({
    required this.pulseController,
    required this.hijriDate,
    required this.gregorianDate,
    required this.nextPrayerName,
    required this.nextPrayerTime,
  });

  @override
  Widget build(BuildContext context) {
    final hasPrayer = nextPrayerName.isNotEmpty && nextPrayerTime.isNotEmpty;
    final hasDate   = hijriDate.isNotEmpty;

    return ScaleTransition(
      scale: Tween<double>(begin: 1.0, end: 1.018).animate(
        CurvedAnimation(parent: pulseController, curve: Curves.easeInOut),
      ),
      child: GlassCard(
        blurSigma: 12,
        borderRadius: BorderRadius.circular(28),
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppColors.goldDeep, AppColors.goldBright],
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                    ),
                    boxShadow: const [BoxShadow(color: Color(0x40B07D00), blurRadius: 16, spreadRadius: 2)],
                  ),
                  child: const Icon(Icons.mosque_rounded, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Assalamu Alaikum',
                          style: GoogleFonts.poppins(
                              fontSize: 16, fontWeight: FontWeight.w700,
                              color: Colors.white, letterSpacing: 0.2)),
                      if (hasDate)
                        Text(hijriDate,
                            style: GoogleFonts.poppins(
                                fontSize: 10, color: AppColors.goldLight.withOpacity(0.9)))
                      else
                        Text('Your spiritual journey awaits',
                            style: GoogleFonts.poppins(
                                fontSize: 11, color: Colors.white.withOpacity(0.65))),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Container(
                height: 1,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, AppColors.goldPrimary, Colors.transparent],
                  ),
                ),
              ),
            ),
            Row(
              children: [
                if (hasPrayer) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.goldPrimary.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.goldPrimary.withOpacity(0.45)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.access_time_rounded, color: AppColors.goldLight, size: 13),
                        const SizedBox(width: 5),
                        Text('$nextPrayerName  $nextPrayerTime',
                            style: GoogleFonts.poppins(
                                fontSize: 11, color: AppColors.goldLight,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  const Spacer(),
                ],
                if (gregorianDate.isNotEmpty)
                  Text(gregorianDate,
                      style: GoogleFonts.poppins(
                          fontSize: 10, color: Colors.white.withOpacity(0.55))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  🃏  FEATURE CARD
// ════════════════════════════════════════════════════════════════════════════
class _FeatureCard extends StatefulWidget {
  final _FeatureItem item;
  final VoidCallback onTap;
  const _FeatureCard({required this.item, required this.onTap});
  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressCtrl;
  late Animation<double>   _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.95)
        .animate(CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() { _pressCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnim,
      child: GestureDetector(
        onTapDown: (_) => _pressCtrl.forward(),
        onTapUp: (_) { _pressCtrl.reverse(); widget.onTap(); },
        onTapCancel: () => _pressCtrl.reverse(),
        child: GlassCard(
          blurSigma: 0,
          padding: EdgeInsets.zero,
          gradient: widget.item.gradient,
          borderRadius: BorderRadius.circular(26),
          borderColor: Colors.white.withOpacity(0.12),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Icon(widget.item.icon, color: Colors.white, size: 26),
                ),
                const Spacer(),
                Text(widget.item.title,
                    style: GoogleFonts.poppins(
                        color: Colors.white, fontWeight: FontWeight.w700,
                        fontSize: 17, letterSpacing: 0.1)),
                const SizedBox(height: 2),
                Text(widget.item.arabic,
                    style: GoogleFonts.amiri(
                        color: Colors.white.withOpacity(0.7), fontSize: 14)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureItem {
  final String title;
  final String arabic;
  final IconData icon;
  final String route;
  final LinearGradient gradient;
  const _FeatureItem({
    required this.title, required this.arabic, required this.icon,
    required this.route,  required this.gradient,
  });
}

// ════════════════════════════════════════════════════════════════════════════
//  ✨  ANIMATED AI FAB
// ════════════════════════════════════════════════════════════════════════════
class AnimatedAIButton extends StatefulWidget {
  const AnimatedAIButton({super.key});
  @override
  State<AnimatedAIButton> createState() => _AnimatedAIButtonState();
}

class _AnimatedAIButtonState extends State<AnimatedAIButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat(reverse: true);
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) =>
          Transform.scale(scale: 1.0 + (_controller.value * 0.04), child: child),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(
            colors: [Color(0xFF0A4A3A), Color(0xFF0D7B62), Color(0xFF1AB590)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          boxShadow: const [
            BoxShadow(color: Color(0x380D7B62), blurRadius: 18, spreadRadius: 2, offset: Offset(0, 5)),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HadithChatBotScreen()),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.auto_awesome_rounded, color: AppColors.goldLight, size: 18),
                  const SizedBox(width: 8),
                  Text('Hadith AI',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700, color: Colors.white,
                          fontSize: 14, letterSpacing: 0.4)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  💬  HADITH CHATBOT SCREEN
// ════════════════════════════════════════════════════════════════════════════
class HadithChatBotScreen extends StatefulWidget {
  const HadithChatBotScreen({super.key});
  @override
  State<HadithChatBotScreen> createState() => _HadithChatBotScreenState();
}

class _HadithChatBotScreenState extends State<HadithChatBotScreen> {
  final TextEditingController _textController   = TextEditingController();
  final ScrollController      _scrollController = ScrollController();

  bool  _isImageSelected = false;
  bool  _isThinking      = false;
  File? _selectedImageFile;

  // ── Voice Recording State ─────────────────────────────────────────────────
  final AudioRecorder _recorder      = AudioRecorder();
  bool                _isRecording   = false;
  String?             _recordingPath; // path of the recorded audio file

  // ── Book Filter ───────────────────────────────────────────────────────────
  String _selectedBook = 'All 6 Books';
  final List<String> _bookOptions = [
    'All 6 Books', 'Sahih Bukhari', 'Sahih Muslim',
    'Sunan Abu Dawood', 'Tirmidhi', 'An-Nasai', 'Ibn Majah',
  ];

  // ── Messages ──────────────────────────────────────────────────────────────
  final List<Map<String, dynamic>> _messages = [
    {
      'isUser'  : false,
      'text'    : 'Assalamu Alaikum! I am your AI Hadith Explainer. '
                  'How can I help you explore the Sunnah today?',
      'hasImage': false,
    }
  ];

  // ── Image Picker ──────────────────────────────────────────────────────────
  final ImagePicker _imagePicker = ImagePicker();

  Future<void> _pickImageFromGallery() async {
    final XFile? pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery, imageQuality: 85, maxWidth: 1080,
    );
    if (pickedFile != null) {
      setState(() {
        _selectedImageFile = File(pickedFile.path);
        _isImageSelected   = true;
      });
    }
  }

  // ════════════════════════════════════════════════════════════════════════
  //  🎤  VOICE RECORDING — Start / Stop
  // ════════════════════════════════════════════════════════════════════════

  Future<void> _toggleRecording() async {
    HapticFeedback.lightImpact();

    if (_isRecording) {
      // ── STOP: stop recording and send to backend ────────────────────
      final path = await _recorder.stop();
      setState(() { _isRecording = false; });

      if (path != null && path.isNotEmpty) {
        await _sendVoiceMessage(path);
      }
    } else {
      // ── START: check permission then begin recording ────────────────
      final hasPermission = await _recorder.hasPermission();
      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Microphone permission required. Please allow in Settings.'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
        return;
      }

      // Build temp file path — .m4a works on all platforms
      final dir  = await getTemporaryDirectory();
      final path = '${dir.path}/hadith_voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _recorder.start(
        const RecordConfig(
          encoder    : AudioEncoder.aacLc,   // .m4a — supported by backend allowed_ext
          bitRate    : 128000,
          sampleRate : 44100,
        ),
        path: path,
      );
      setState(() {
        _isRecording   = true;
        _recordingPath = path;
      });
    }
  }

  // ════════════════════════════════════════════════════════════════════════
  //  🎤  PTT — Start recording (called on long-press start)
  // ════════════════════════════════════════════════════════════════════════
  Future<void> _startRecording() async {
    if (_isRecording) return; // already recording

    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Microphone permission required. Please allow in Settings.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return;
    }

    final dir  = await getTemporaryDirectory();
    final path = '${dir.path}/hadith_voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _recorder.start(
      const RecordConfig(
        encoder    : AudioEncoder.aacLc,
        bitRate    : 128000,
        sampleRate : 44100,
      ),
      path: path,
    );
    if (mounted) {
      setState(() {
        _isRecording   = true;
        _recordingPath = path;
      });
    }
  }

  // ════════════════════════════════════════════════════════════════════════
  //  🎤  PTT — Stop and send (called on long-press end / release)
  // ════════════════════════════════════════════════════════════════════════
  Future<void> _stopAndSendRecording() async {
    if (!_isRecording) return;

    final path = await _recorder.stop();
    if (mounted) setState(() { _isRecording = false; });

    if (path != null && path.isNotEmpty) {
      await _sendVoiceMessage(path);
    }
  }

  // ════════════════════════════════════════════════════════════════════════
  //  📤  SEND VOICE — backend ko send
  // ════════════════════════════════════════════════════════════════════════
  Future<void> _sendVoiceMessage(String audioPath) async {
    if (_isThinking) return;

    // Optional: user may have typed context text alongside voice
    final userText    = _textController.text.trim();
    final selectedBook = _selectedBook;

    setState(() {
      _isThinking = true;
      _messages.add({
        'isUser'  : true,
        'text'    : userText.isNotEmpty
            ? '🎤 Voice + "${userText.length > 40 ? userText.substring(0, 40) + "..." : userText}"'
            : '🎤 Voice message',
        'hasImage': false,
      });
      _textController.clear();
      _messages.add({'isUser': false, 'text': '...', 'isLoading': true});
    });
    _scrollToBottom();

    String aiResponse;
    try {
      aiResponse = await HadithApiService.sendVoiceQuery(
        audioPath  : audioPath,
        // Only send userText if non-empty — otherwise null
        userText   : userText.isNotEmpty ? userText : null,
        bookFilter : selectedBook,
      );
    } catch (e) {
      aiResponse = '❌ ${e.toString().replaceFirst('Exception: ', '')}';
    } finally {
      // Clean up temp audio file
      try { File(audioPath).deleteSync(); } catch (_) {}
    }

    if (mounted) {
      setState(() {
        _isThinking = false;
        _messages.removeLast();
        _messages.add({'isUser': false, 'text': aiResponse, 'hasImage': false});
      });
      _scrollToBottom();
    }
  }

  // ════════════════════════════════════════════════════════════════════════
  //  📤  SEND TEXT / IMAGE
  // ════════════════════════════════════════════════════════════════════════
  Future<void> _sendMessage() async {
    if (_isThinking) return;

    final userText = _textController.text.trim();
    final hasImage = _isImageSelected && _selectedImageFile != null;
    final hasText  = userText.isNotEmpty;

    if (!hasText && !hasImage) return;

    final imageFile    = _selectedImageFile;
    final selectedBook = _selectedBook;

    setState(() {
      _isThinking = true;
      _messages.add({
        'isUser'  : true,
        'text'    : hasText ? userText : '🖼️ Image sent',
        'hasImage': hasImage,
      });
      _textController.clear();
      _isImageSelected   = false;
      _selectedImageFile = null;
      _messages.add({'isUser': false, 'text': '...', 'isLoading': true});
    });
    _scrollToBottom();

    String aiResponse;
    try {
      if (hasImage && imageFile != null) {
        // Image API — userText is optional
        aiResponse = await HadithApiService.sendImageQuery(
          imagePath  : imageFile.path,
          userText   : hasText ? userText : null,   // only pass text if user typed something
          bookFilter : selectedBook,
        );
      } else {
        // Text-only API
        aiResponse = await HadithApiService.sendTextQuery(
          query      : userText,
          bookFilter : selectedBook,
        );
      }
    } catch (e) {
      aiResponse = '❌ ${e.toString().replaceFirst('Exception: ', '')}';
    }

    if (mounted) {
      setState(() {
        _isThinking = false;
        _messages.removeLast();
        _messages.add({'isUser': false, 'text': aiResponse, 'hasImage': false});
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve   : Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _recorder.dispose();  // ← recorder dispose zaroori hai
    super.dispose();
  }

  // ════════════════════════════════════════════════════════════════════════
  //  🏗️  BUILD
  // ════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0A4A3A), Color(0xFF0D7B62)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Row(
          children: [
            const Icon(Icons.auto_awesome_rounded, color: AppColors.goldLight, size: 18),
            const SizedBox(width: 8),
            Text('Hadith AI',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: Colors.white)),
          ],
        ),
        foregroundColor: Colors.white,
        actions: [
          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: _ConnectionBadge(),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  colors: [AppColors.sapphireAbyss, AppColors.sapphireMid],
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                )
              : const LinearGradient(
                  colors: [Color(0xFFFAFAFA), Color(0xFFF4F4F5)],
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                ),
        ),
        child: Column(
          children: [
            Expanded(
              // ── Fix: full-screen scroll by removing hit-test restrictions ──
              child: ScrollConfiguration(
                behavior: _FullScrollBehavior(),
                child: ListView.builder(
                  controller : _scrollController,
                  padding    : const EdgeInsets.fromLTRB(16, 90, 16, 16),
                  itemCount  : _messages.length,
                  physics    : const AlwaysScrollableScrollPhysics(),
                  itemBuilder: (context, i) => _buildBubble(_messages[i], isDark),
                ),
              ),
            ),
            // ── Recording indicator bar ──────────────────────────────────
            if (_isRecording) _buildRecordingBar(),
            _buildInputArea(isDark),
          ],
        ),
      ),
    );
  }

  // ── Recording indicator bar ───────────────────────────────────────────────
  Widget _buildRecordingBar() {
    return Container(
      color: Colors.redAccent.withOpacity(0.12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.fiber_manual_record, color: Colors.redAccent, size: 12),
          const SizedBox(width: 8),
          const Expanded(                              // ← Expanded fixes overflow
            child: Text(
              '🎤 Recording... Release mic button to send',
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(
                fontSize: 11,
                color: Colors.redAccent,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Chat Bubble ───────────────────────────────────────────────────────────
  Widget _buildBubble(Map<String, dynamic> msg, bool isDark) {
    final isUser = msg['isUser'] as bool;

    // ── Markdown style sheet for AI responses ──────────────────────────────
    // Matches the app's Poppins + emerald/sapphire design language exactly.
    final mdStyleSheet = MarkdownStyleSheet(
      // Body text
      p: GoogleFonts.poppins(
        fontSize: 14,
        color   : isDark ? AppColors.inkOnDark : AppColors.inkDark,
        height  : 1.6,
      ),

      // Headings — progressively larger, emerald accent
      h1: GoogleFonts.poppins(
        fontSize: 20, fontWeight: FontWeight.w700,
        color   : isDark ? Colors.white : AppColors.emeraldDeep,
        height  : 1.4,
      ),
      h2: GoogleFonts.poppins(
        fontSize: 17, fontWeight: FontWeight.w700,
        color   : isDark ? Colors.white : AppColors.emeraldDeep,
        height  : 1.4,
      ),
      h3: GoogleFonts.poppins(
        fontSize: 15, fontWeight: FontWeight.w600,
        color   : isDark ? AppColors.inkOnDark : AppColors.inkDark,
        height  : 1.4,
      ),

      // Bold / strong
      strong: GoogleFonts.poppins(
        fontSize: 14, fontWeight: FontWeight.w700,
        color   : isDark ? Colors.white : AppColors.inkDark,
      ),

      // Italic / emphasis
      em: GoogleFonts.poppins(
        fontSize: 14, fontStyle: FontStyle.italic,
        color   : isDark ? AppColors.inkOnDark : AppColors.inkDark,
      ),

      // Inline code — monospace, highlighted pill
      code: GoogleFonts.sourceCodePro(
        fontSize       : 13,
        color          : isDark ? AppColors.goldLight : AppColors.emeraldDeep,
        backgroundColor: isDark
            ? AppColors.emeraldDeep.withOpacity(0.25)
            : AppColors.emeraldPrimary.withOpacity(0.08),
      ),

      // Code block background
      codeblockDecoration: BoxDecoration(
        color        : isDark
            ? const Color(0xFF0D1F1A)
            : const Color(0xFFF0FAF5),
        borderRadius : BorderRadius.circular(12),
        border       : Border.all(
          color: isDark
              ? AppColors.emeraldDeep.withOpacity(0.4)
              : AppColors.emeraldPrimary.withOpacity(0.2),
        ),
      ),

      // Code block text
      codeblockPadding: const EdgeInsets.all(14),

      // Blockquote — left-border style
      blockquote: GoogleFonts.poppins(
        fontSize  : 13, fontStyle: FontStyle.italic,
        color     : isDark ? Colors.white70 : Colors.black54,
      ),
      blockquoteDecoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: AppColors.emeraldPrimary.withOpacity(0.6), width: 3,
          ),
        ),
        color: isDark
            ? AppColors.emeraldDeep.withOpacity(0.1)
            : AppColors.emeraldPrimary.withOpacity(0.05),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(8), bottomRight: Radius.circular(8),
        ),
      ),
      blockquotePadding: const EdgeInsets.fromLTRB(12, 8, 8, 8),

      // Bullet / ordered lists
      listBullet: GoogleFonts.poppins(
        fontSize: 14,
        color   : isDark ? AppColors.emeraldBright : AppColors.emeraldPrimary,
      ),
      listIndent: 20,

      // Horizontal rule
      horizontalRuleDecoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? AppColors.glassWhite10
                : const Color(0xFFDDDDDF),
            width: 1,
          ),
        ),
      ),

      // Spacing between blocks
      blockSpacing   : 10,
      h1Padding      : const EdgeInsets.only(top: 6, bottom: 2),
      h2Padding      : const EdgeInsets.only(top: 4, bottom: 2),
      h3Padding      : const EdgeInsets.only(top: 4, bottom: 2),
    );

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin     : const EdgeInsets.only(bottom: 12),
        // AI bubbles are wider to accommodate formatted content comfortably
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * (isUser ? 0.78 : 0.88),
        ),
        decoration: BoxDecoration(
          gradient: isUser
              ? const LinearGradient(
                  colors: [AppColors.emeraldPrimary, AppColors.emeraldBright],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                )
              : null,
          color      : isUser ? null : (isDark ? AppColors.sapphirePanel : Colors.white),
          borderRadius: BorderRadius.only(
            topLeft    : const Radius.circular(20),
            topRight   : const Radius.circular(20),
            bottomLeft : Radius.circular(isUser ? 20 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 20),
          ),
          boxShadow: [
            BoxShadow(
              color     : Colors.black.withOpacity(isUser ? 0.15 : 0.06),
              blurRadius: 8, offset: const Offset(0, 3),
            )
          ],
          border: isUser
              ? null
              : Border.all(
                  color: isDark ? AppColors.glassWhite10 : const Color(0xFFDDDDDF)),
        ),

        // ── Content: Loading | User plain text | AI Markdown ──────────────
        child: msg['isLoading'] == true

            // Loading dots
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const AIThinkingDots(),
                  const SizedBox(width: 10),
                  Text('Thinking...',
                      style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: isDark ? Colors.white54 : Colors.black45)),
                ]),
              )

            : isUser
                // User bubble — plain text, no Markdown needed
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Text(
                      msg['text'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color   : Colors.white,
                        height  : 1.5,
                      ),
                    ),
                  )

                // AI bubble — full Markdown rendering
                : Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                    child: MarkdownBody(
                      data            : msg['text'] as String,
                      styleSheet      : mdStyleSheet,
                      selectable      : true,   // keeps copy-text ability
                      softLineBreak   : true,   // preserves backend line breaks
                      shrinkWrap      : true,
                      // Render code blocks with monospace font
                      builders        : {},
                      // Open links inside the app or via url_launcher if needed
                      onTapLink       : (text, href, title) {
                        // No-op: extend here with url_launcher if desired
                      },
                    ),
                  ),
      ),
    );
  }

  // ── Input Area ────────────────────────────────────────────────────────────
  Widget _buildInputArea(bool isDark) {
    final canSend = !_isThinking && !_isRecording &&
        (_textController.text.trim().isNotEmpty || _isImageSelected);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: EdgeInsets.fromLTRB(
              12, 12, 12, MediaQuery.of(context).padding.bottom + 12),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.sapphirePanel.withOpacity(0.9)
                : Colors.white.withOpacity(0.92),
            border: Border(
              top: BorderSide(
                  color: isDark ? AppColors.glassWhite10 : const Color(0xFFDDDDDF)),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Image preview ────────────────────────────────────────────
              if (_isImageSelected && _selectedImageFile != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Stack(
                    children: [
                      Container(
                        height: 52, width: 52,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(_selectedImageFile!, fit: BoxFit.cover),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        child: GestureDetector(
                          onTap: () => setState(() {
                            _isImageSelected   = false;
                            _selectedImageFile = null;
                          }),
                          child: const CircleAvatar(
                            radius: 9,
                            backgroundColor: Colors.redAccent,
                            child: Icon(Icons.close, size: 10, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // ── Input Row ────────────────────────────────────────────────
              Row(
                children: [
                  // Image button — recording ke waqt disable
                  IconButton(
                    icon: Icon(Icons.add_photo_alternate_rounded,
                        color: _isImageSelected
                            ? AppColors.emeraldPrimary
                            : (_isRecording ? Colors.grey.withOpacity(0.3) : Colors.grey),
                        size: 22),
                    onPressed: _isRecording ? null : _pickImageFromGallery,
                  ),

                  // Book filter pill — recording ke waqt disable
                  _isRecording
                      ? const SizedBox(width: 8)
                      : _buildBookPill(isDark),

                  // Text field — recording ke waqt bhi type kar sakte hain (optional context)
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      onChanged : (_) => setState(() {}),
                      style     : GoogleFonts.poppins(
                          fontSize: 14,
                          color: isDark ? Colors.white : AppColors.inkDark),
                      decoration: InputDecoration(
                        hintText: _isRecording
                            ? 'Hold mic to record, release to send...'
                            : 'Ask about a Hadith...',
                        hintStyle: TextStyle(
                            color: _isRecording
                                ? Colors.redAccent.withOpacity(0.7)
                                : Colors.grey,
                            fontSize: 12),
                        border        : InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                  ),

                  // 🎤 Mic button — WhatsApp Push-to-Talk (hold to record, release to send)
                  GestureDetector(
                    onLongPressStart: _isThinking
                        ? null
                        : (_) async {
                            HapticFeedback.mediumImpact();
                            await _startRecording();
                          },
                    onLongPressEnd: _isThinking
                        ? null
                        : (_) async {
                            HapticFeedback.lightImpact();
                            await _stopAndSendRecording();
                          },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width : 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isRecording
                            ? Colors.redAccent
                            : (_isThinking
                                ? Colors.grey.withOpacity(0.15)
                                : Colors.grey.withOpacity(0.12)),
                        boxShadow: _isRecording
                            ? [const BoxShadow(
                                color: Color(0x55FF5252),
                                blurRadius: 12,
                                spreadRadius: 2,
                              )]
                            : null,
                      ),
                      child: Icon(
                        _isRecording ? Icons.mic_rounded : Icons.mic_none_rounded,
                        color: _isRecording
                            ? Colors.white
                            : (_isThinking ? Colors.grey.withOpacity(0.4) : Colors.grey[600]),
                        size: 22,
                      ),
                    ),
                  ),

                  // Send button — sirf text/image ke liye (voice alag handle hoti hai)
                  GestureDetector(
                    onTap: canSend ? _sendMessage : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 42, height: 42,
                      decoration: BoxDecoration(
                        gradient: canSend
                            ? const LinearGradient(
                                colors: [AppColors.emeraldPrimary, AppColors.emeraldBright],
                                begin: Alignment.topLeft, end: Alignment.bottomRight,
                              )
                            : null,
                        color    : canSend ? null : Colors.grey.withOpacity(0.2),
                        shape    : BoxShape.circle,
                        boxShadow: canSend
                            ? const [BoxShadow(color: Color(0x300D7B62), blurRadius: 8, offset: Offset(0, 3))]
                            : null,
                      ),
                      child: Icon(Icons.send_rounded,
                          color: canSend ? Colors.white : Colors.grey, size: 18),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Book Filter Pill ──────────────────────────────────────────────────────
  Widget _buildBookPill(bool isDark) {
    return PopupMenuButton<String>(
      onSelected : (v) => setState(() => _selectedBook = v),
      shape      : RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      itemBuilder: (_) => _bookOptions
          .map((b) => PopupMenuItem(
                value: b,
                child: Text(b, style: GoogleFonts.poppins(fontSize: 13)),
              ))
          .toList(),
      child: Container(
        padding   : const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color       : AppColors.emeraldDeep.withOpacity(0.12),
          borderRadius: BorderRadius.circular(14),
          border      : Border.all(color: AppColors.emeraldPrimary.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_selectedBook.split(' ').first,
                style: GoogleFonts.poppins(
                    color: AppColors.emeraldBright,
                    fontWeight: FontWeight.w700, fontSize: 11)),
            const Icon(Icons.keyboard_arrow_down_rounded,
                color: AppColors.emeraldBright, size: 14),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  📜  FULL SCROLL BEHAVIOR — removes hit-test restrictions so the entire
//       screen area (including message bubbles) can scroll the chat list.
// ════════════════════════════════════════════════════════════════════════════
class _FullScrollBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child; // removes glow indicator if desired; keep original if you want the glow
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics());
}

// ════════════════════════════════════════════════════════════════════════════
//  🟢  CONNECTION BADGE
// ════════════════════════════════════════════════════════════════════════════
class _ConnectionBadge extends StatefulWidget {
  const _ConnectionBadge();
  @override
  State<_ConnectionBadge> createState() => _ConnectionBadgeState();
}

class _ConnectionBadgeState extends State<_ConnectionBadge> {
  bool? _connected;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    try {
      final res = await http
          .get(Uri.parse('${ApiConfig.baseUrl}/health'))
          .timeout(const Duration(seconds: 5));
      if (mounted) setState(() => _connected = res.statusCode == 200);
    } catch (_) {
      if (mounted) setState(() => _connected = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_connected == null) {
      return const SizedBox(
        width: 12, height: 12,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
      );
    }
    return GestureDetector(
      onTap: () { setState(() => _connected = null); _check(); },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8, height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _connected! ? Colors.greenAccent : Colors.redAccent,
            ),
          ),
          const SizedBox(width: 4),
          Text(_connected! ? 'Live' : 'Offline',
              style: GoogleFonts.poppins(fontSize: 11, color: Colors.white70)),
        ],
      ),
    );
  }
}