import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// ═══════════════════════════════════════════════════════════════
//  namaz.dart  —  Salah Guide (12 steps)
//  Images: assets/images/Salah/
//  Even index → image LEFT | Odd index → image RIGHT
// ═══════════════════════════════════════════════════════════════

class SalahGuideScreen extends StatelessWidget {
  const SalahGuideScreen({super.key});

  static const List<_SalahStep> _steps = [
    _SalahStep(
      number: 1,
      image: 'assets/Images/Salah/niyyah.svg',
      title: 'Niyyah (Intention)',
      body:
          'Begin with the proper niyyah (intention) that you want to pray. '
          'This can be done in your mind or verbally. The purpose is so that '
          'you are not heedless in prayer but are aware of the kind of '
          'salat you are about to offer.',
    ),
    _SalahStep(
      number: 2,
      image: 'assets/Images/Salah/takbeer.svg',
      title: 'Takbeer (Allahu Akbar)',
      body:
          'Stand with feet about four inches apart. Direct your gaze towards '
          'the place of your sajdah. Raise your hands to your ears (women '
          'to shoulders) with palms open and say:',
      arabicText: 'اللَّهُ أَكْبَرُ',
      transliteration: 'Allahu Akbar',
      translation: 'Allah is the Greatest.',
    ),
    _SalahStep(
      number: 3,
      image: 'assets/Images/Salah/takbeer.svg',
      title: 'After Takbeer (Sanaa)',
      body:
          'Cross your hands at chest level grabbing your left wrist with '
          'your right hand. Begin with the recitation of Thana:',
      arabicText:
          'سُبْحَانَكَ اللَّهُمَّ وَبِحَمْدِكَ، وَتَبَارَكَ اسْمُكَ،\n'
          'وَتَعَالَى جَدُّكَ، وَلَا إِلَهَ غَيْرُكَ',
      transliteration:
          "Subhanakal-lahumma wa bihamdika wa tabarakasmuka\n"
          "wa ta'ala jadduka wa la ilaha ghairuk.",
      translation:
          'Glory and praise be to You, O Allah. Blessed be Your name and '
          'exalted be Your majesty, there is none worthy of worship except You.',
      extraArabic:
          'أَعُوذُ بِاللَّهِ مِنَ الشَّيْطَانِ الرَّجِيمِ\n'
          'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
      extraLabel: "Then recite Ta'awwudh & Bismillah:",
      extraTranslation:
          "I seek Allah's protection from Satan, the accursed.\n"
          'In the name of Allah who is Kind and Merciful.',
    ),
    _SalahStep(
      number: 4,
      image: 'assets/Images/Salah/recitation.svg',
      title: 'Recitation (Surah Al-Fatiha)',
      body: 'Recite Surah Al-Fatiha:',
      arabicText:
          'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ ﴿١﴾ الرَّحْمَٰنِ الرَّحِيمِ ﴿٢﴾\n'
          'مَالِكِ يَوْمِ الدِّينِ ﴿٣﴾ إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ ﴿٤﴾\n'
          'اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ ﴿٥﴾\n'
          'صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ\n'
          'غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ',
      translation:
          'Praise be to Allah, the Cherisher and Sustainer of the worlds; '
          'Most Gracious, Most Merciful; Master of the Day of Judgment. '
          'Thee do we worship, and Thine aid we seek. Show us the straight way, '
          'the way of those on whom Thou hast bestowed Thy Grace.',
      extraArabic:
          'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ\n'
          'قُلْ هُوَ اللَّهُ أَحَدٌ ﴿١﴾ اللَّهُ الصَّمَدُ ﴿٢﴾\n'
          'لَمْ يَلِدْ وَلَمْ يُولَدْ ﴿٣﴾ وَلَمْ يَكُنْ لَهُ كُفُوًا أَحَدٌ ﴿٤﴾',
      extraLabel: 'Then recite any Surah (e.g. Surah Al-Ikhlas):',
      extraTranslation:
          'Say: He is Allah, the One. Allah the Eternal. He neither begets '
          'nor is born, nor is there anyone equal to Him.',
    ),
    _SalahStep(
      number: 5,
      image: 'assets/Images/Salah/ruku.svg',
      title: 'Ruku',
      body:
          'Say Allahu Akbar and bend down for ruku. Keep your head and back '
          'aligned and place your hands on your knees. Recite Tasbeeh '
          'three times (or any odd number):',
      arabicText: 'سُبْحَانَ رَبِّيَ الْعَظِيمِ',
      transliteration: "Subhana Rabbiyal 'Azeem",
      translation: 'Glory be to my Lord Almighty.',
    ),
    _SalahStep(
      number: 6,
      image: 'assets/Images/Salah/qaada.svg',
      title: "Qa'ada (Standing after Ruku)",
      body: 'Stand up from the bowing position and recite:',
      arabicText: 'سَمِعَ اللَّهُ لِمَنْ حَمِدَهُ',
      transliteration: "Sami' Allahu liman hamidah",
      translation: 'Allah hears those who praise Him.',
    ),
    _SalahStep(
      number: 7,
      image: 'assets/Images/Salah/sajda.svg',
      title: 'Sajda (Prostration)',
      body:
          'Say Allahu Akbar and go down for sajdah. There should be 5 points '
          'of contact with the ground: forehead, nose, palms, knees, and toes. '
          'Thumbs align with earlobes, elbows raised. Recite:',
      arabicText: 'سُبْحَانَ رَبِّيَ الْأَعْلَى',
      transliteration: "Subhana Rabbiyal A'la",
      translation: 'How Perfect is my Lord, the Highest.',
    ),
    _SalahStep(
      number: 8,
      image: 'assets/Images/Salah/jalsa.svg',
      title: 'Jalsa (Sitting between Sajdahs)',
      body:
          'Say Allahu Akbar and sit upright. Keep right foot up and lay left '
          'foot on the ground. Rest hands on thighs with fingers reaching '
          'the knees. Recite:',
      arabicText:
          'اللَّهُمَّ اغْفِرْ لِي، وَارْحَمْنِي، وَعَافِنِي،\n'
          'وَاهْدِنِي، وَارْزُقْنِي',
      transliteration:
          "Allahummaghfir li warhamni wa 'afini\nwahdini warzuqni",
      translation:
          'O Allah, forgive me, have mercy on me, grant me well-being, '
          'guide me and provide for me.',
    ),
    _SalahStep(
      number: 9,
      image: 'assets/Images/Salah/tashud.svg',
      title: 'Tash-hud',
      body:
          'After completing two rakahs, remain seated and recite Tashahhud silently:',
      arabicText:
          'التَّحِيَّاتُ لِلَّهِ وَالصَّلَوَاتُ وَالطَّيِّبَاتُ،\n'
          'السَّلَامُ عَلَيْكَ أَيُّهَا النَّبِيُّ وَرَحْمَةُ اللَّهِ وَبَرَكَاتُهُ،\n'
          'السَّلَامُ عَلَيْنَا وَعَلَى عِبَادِ اللَّهِ الصَّالِحِينَ،\n'
          'أَشْهَدُ أَنْ لَا إِلَهَ إِلَّا اللَّهُ وَأَشْهَدُ أَنَّ مُحَمَّدًا عَبْدُهُ وَرَسُولُهُ.',
      translation:
          'All compliments, prayers and pure words are for Allah. Peace be '
          'on you, O Prophet, and the mercy of Allah and His blessings. '
          'Peace be on us and on the righteous servants of Allah. I testify '
          'that there is no god but Allah, and I testify that Muhammad is '
          'His servant and Messenger.',
    ),
    _SalahStep(
      number: 10,
      image: 'assets/Images/Salah/darood.svg',
      title: 'Darood',
      body: 'Recite Darood silently:',
      arabicText:
          'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ\n'
          'كَمَا صَلَّيْتَ عَلَى إِبْرَاهِيمَ وَعَلَى آلِ إِبْرَاهِيمَ\n'
          'إِنَّكَ حَمِيدٌ مَجِيدٌ ❁\n'
          'اللَّهُمَّ بَارِكْ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ\n'
          'كَمَا بَارَكْتَ عَلَى إِبْرَاهِيمَ وَعَلَى آلِ إِبْرَاهِيمَ\n'
          'إِنَّكَ حَمِيدٌ مَجِيدٌ ❁',
      translation:
          'O Allah, bestow Your blessings upon Muhammad and the family of '
          'Muhammad, as You bestowed blessings upon Ibrahim and the family of '
          'Ibrahim. You are indeed the Most Praiseworthy, the Most Glorious.',
    ),
    _SalahStep(
      number: 11,
      image: 'assets/Images/Salah/dua.svg',
      title: 'Dua (Dua e Masura)',
      body: 'Recite Dua e Masura silently:',
      arabicText:
          'رَبِّ اجْعَلْنِي مُقِيمَ الصَّلَاةِ وَمِنْ ذُرِّيَّتِي ۚ\n'
          'رَبَّنَا وَتَقَبَّلْ دُعَاءِ رَبَّنَا اغْفِرْ لِي\n'
          'وَلِوَالِدَيَّ وَلِلْمُؤْمِنِينَ يَوْمَ يَقُومُ الْحِسَابُ',
      translation:
          'My Lord, make me an establisher of prayer, and many from my '
          'descendants. Our Lord, accept my supplication. Our Lord, forgive me '
          'and my parents and the believers the Day the account is established.',
    ),
    _SalahStep(
      number: 12,
      image: 'assets/Images/Salah/salam.svg',
      title: 'Salam',
      body:
          'Turn your face towards your right shoulder and say the Salam, '
          'then turn to the left and say it again:',
      arabicText: 'السَّلَامُ عَلَيْكُمْ وَرَحْمَةُ اللهِ',
      transliteration: "As-salamu 'alaykum wa rahmatullah",
      translation:
          'Peace and the mercy of Allah be on you.\n\n'
          '✅ This completes the two rakah salah. It is recommended to offer '
          'dua after salah, especially after fardh salah.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Color(0xFF1A1A2E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Salah Steps',
          style: TextStyle(
            color: Color(0xFF1A1A2E),
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 0.3,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE8E8F0), height: 1),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        itemCount: _steps.length,
        itemBuilder: (context, index) {
          // Step 3 (index 2) and Step 11 (index 10) → horizontal mirror flip only
          final bool flipImage = (index == 2 || index == 10);
          final bool imageOnLeft = index.isEven; // position same for all steps
          return Column(
            children: [
              _AnimatedSalahCard(
                step: _steps[index],
                index: index,
                imageOnLeft: imageOnLeft,
                flipImage: flipImage,
              ),
              SizedBox(height: index < _steps.length - 1 ? 20 : 30),
            ],
          );
        },
      ),
    );
  }
}

// ── Data Model ─────────────────────────────────────────────────

class _SalahStep {
  const _SalahStep({
    required this.number,
    required this.image,
    required this.title,
    required this.body,
    this.arabicText,
    this.transliteration,
    this.translation,
    this.extraArabic,
    this.extraLabel,
    this.extraTranslation,
  });

  final int number;
  final String image;
  final String title;
  final String body;
  final String? arabicText;
  final String? transliteration;
  final String? translation;
  final String? extraArabic;
  final String? extraLabel;
  final String? extraTranslation;
}

// ── Animated Card Wrapper ──────────────────────────────────────

class _AnimatedSalahCard extends StatefulWidget {
  const _AnimatedSalahCard({
    required this.step,
    required this.index,
    required this.imageOnLeft,
    this.flipImage = false,
  });
  final _SalahStep step;
  final int index;
  final bool imageOnLeft;
  final bool flipImage;

  @override
  State<_AnimatedSalahCard> createState() => _AnimatedSalahCardState();
}

class _AnimatedSalahCardState extends State<_AnimatedSalahCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    final double dx = widget.imageOnLeft ? -0.08 : 0.08;
    _slide = Tween<Offset>(begin: Offset(dx, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    Future.delayed(Duration(milliseconds: 80 * widget.index), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: _SalahCard(step: widget.step, imageOnLeft: widget.imageOnLeft, flipImage: widget.flipImage),
      ),
    );
  }
}

// ── Salah Card ─────────────────────────────────────────────────

class _SalahCard extends StatelessWidget {
  const _SalahCard({required this.step, required this.imageOnLeft, this.flipImage = false});
  final _SalahStep step;
  final bool imageOnLeft;
  final bool flipImage;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned(
              top: 8, left: 8,
              child: SvgPicture.asset('assets/images/Salah/topdesign.svg', width: 52, height: 52),
            ),
            Positioned(
              bottom: 8, right: 8,
              child: SvgPicture.asset('assets/images/Salah/bottomdesign.svg', width: 52, height: 52),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Step badge
                  _StepBadge(number: step.number),
                  const SizedBox(height: 20),

                  // Image + Title alternating row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: imageOnLeft
                        ? [
                            _FloatingSvgImage(imagePath: step.image, flip: flipImage),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                step.title,
                                textAlign: TextAlign.left,
                                style: const TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A1A2E), height: 1.35,
                                ),
                              ),
                            ),
                          ]
                        : [
                            Expanded(
                              child: Text(
                                step.title,
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A1A2E), height: 1.35,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            _FloatingSvgImage(imagePath: step.image, flip: flipImage),
                          ],
                  ),
                  const SizedBox(height: 16),

                  // Divider
                  Container(
                    width: 48, height: 3,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3A5BA0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Body
                  Text(
                    step.body,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14.5, color: Color(0xFF555570), height: 1.65),
                  ),

                  // Arabic box
                  if (step.arabicText != null) ...[
                    const SizedBox(height: 16),
                    _ArabicBox(
                      arabic: step.arabicText!,
                      translit: step.transliteration,
                      translation: step.translation,
                      accentColor: const Color(0xFF3A5BA0),
                    ),
                  ],

                  // Extra box
                  if (step.extraArabic != null) ...[
                    const SizedBox(height: 14),
                    if (step.extraLabel != null)
                      _SectionDivider(label: step.extraLabel!, color: const Color(0xFF3A5BA0)),
                    const SizedBox(height: 10),
                    _ArabicBox(
                      arabic: step.extraArabic!,
                      translation: step.extraTranslation,
                      accentColor: const Color(0xFF3A5BA0),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Floating SVG Image  (float + scale + shimmer glow + optional mirror flip)

class _FloatingSvgImage extends StatefulWidget {
  const _FloatingSvgImage({required this.imagePath, this.flip = false});
  final String imagePath;
  final bool flip;

  @override
  State<_FloatingSvgImage> createState() => _FloatingSvgImageState();
}

class _FloatingSvgImageState extends State<_FloatingSvgImage>
    with TickerProviderStateMixin {
  late final AnimationController _floatCtrl;
  late final AnimationController _glowCtrl;

  late final Animation<double> _float;
  late final Animation<double> _scale;
  late final Animation<double> _glow;
  late final Animation<double> _wobble;

  @override
  void initState() {
    super.initState();

    // Float + scale + wobble  (2.4s loop)
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _float = Tween<double>(begin: 0, end: -10)
        .animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));
    _scale = Tween<double>(begin: 1.0, end: 1.07)
        .animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));
    _wobble = Tween<double>(begin: -0.015, end: 0.015)
        .animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));

    // Glow pulse  (1.6s loop, offset phase)
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _glow = Tween<double>(begin: 4, end: 16)
        .animate(CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_floatCtrl, _glowCtrl]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _float.value),
          child: Transform.rotate(
            angle: _wobble.value,
            child: Transform.scale(
              scale: _scale.value,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3A5BA0).withOpacity(0.25),
                      blurRadius: _glow.value,
                      spreadRadius: _glow.value * 0.3,
                    ),
                  ],
                ),
                child: Transform(
                  alignment: Alignment.center,
                  transform: widget.flip
                      ? (Matrix4.identity()..scale(-1.0, 1.0, 1.0))
                      : Matrix4.identity(),
                  child: child,
                ),
              ),
            ),
          ),
        );
      },
      child: SvgPicture.asset(
        widget.imagePath,
        height: 110,
        width: 110,
        fit: BoxFit.contain,
        placeholderBuilder: (context) => Container(
          height: 110, width: 110,
          decoration: BoxDecoration(
            color: const Color(0xFFEEF2FF),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(
            child: Icon(Icons.self_improvement_rounded, size: 48, color: Color(0xFF3A5BA0)),
          ),
        ),
      ),
    );
  }
}

// ── Step Badge ─────────────────────────────────────────────────

class _StepBadge extends StatelessWidget {
  const _StepBadge({required this.number});
  final int number;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44, height: 44,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6B8FD4), Color(0xFF3A5BA0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3A5BA0).withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text('$number',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17)),
      ),
    );
  }
}

// ── Arabic Box ─────────────────────────────────────────────────

class _ArabicBox extends StatelessWidget {
  const _ArabicBox({
    required this.arabic,
    required this.accentColor,
    this.translit,
    this.translation,
  });

  final String arabic;
  final Color accentColor;
  final String? translit;
  final String? translation;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withOpacity(0.25), width: 1.2),
      ),
      child: Column(
        children: [
          Text(arabic,
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                  fontSize: 18, color: accentColor.withOpacity(0.9),
                  height: 1.9, fontWeight: FontWeight.w600)),
          if (translit != null) ...[
            const SizedBox(height: 8),
            Text(translit!,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 12.5, color: accentColor,
                    fontStyle: FontStyle.italic, height: 1.5)),
          ],
          if (translation != null) ...[
            const SizedBox(height: 8),
            Text(translation!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Color(0xFF666680), height: 1.55)),
          ],
        ],
      ),
    );
  }
}

// ── Section Divider ────────────────────────────────────────────

class _SectionDivider extends StatelessWidget {
  const _SectionDivider({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFFD0D0E0))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(label,
              style: TextStyle(
                  fontSize: 11.5, color: color,
                  fontWeight: FontWeight.w600, letterSpacing: 0.4)),
        ),
        const Expanded(child: Divider(color: Color(0xFFD0D0E0))),
      ],
    );
  }
}