import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// ═══════════════════════════════════════════════════════════════
//  wudu.dart  —  Wudu Guide (10 steps)
//  Images: assets/images/Wudu/
// ═══════════════════════════════════════════════════════════════

class WuduGuideScreen extends StatelessWidget {
  const WuduGuideScreen({super.key});

  static const List<_WuduSection> _sections = [
    _WuduSection(
      number: 1,
      image: 'assets/Images/Wudu/q.png',
      title: 'Make Your Intention',
      body:
          'The first step is to understand that you are about to begin the '
          'process of wudu. Make a sincere intention in your heart to '
          'purify yourself for the sake of Allah.',
    ),
    _WuduSection(
      number: 2,
      image: 'assets/Images/Wudu/r.png',
      title: 'Say Bismillah',
      body: 'Before we begin to wash ourselves we need to say Bismillah…',
      arabicText: 'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
      transliteration: 'Bismillahir Rahmanir Raheem',
      translation: 'In the name of Allah, the Most Gracious, the Most Merciful.',
    ),
    _WuduSection(
      number: 3,
      image: 'assets/Images/Wudu/s.png',
      title: 'Wash Your Hands Three Times',
      body: 'Wash right hand three times, then left hand three times.',
    ),
    _WuduSection(
      number: 4,
      image: 'assets/Images/Wudu/y.png',
      title: 'Rinse Your Mouth Three Times',
      body: 'Take some water into your right hand and rinse your mouth three times.',
    ),
    _WuduSection(
      number: 5,
      image: 'assets/Images/Wudu/u.png',
      title: 'Sniff Water Into Your Nostrils Three Times',
      body: 'Sniff water three times.',
    ),
    _WuduSection(
      number: 6,
      image: 'assets/Images/Wudu/u.png',
      title: 'Wash Your Face Three Times',
      body: 'Wash face thoroughly three times.',
    ),
    _WuduSection(
      number: 7,
      image: 'assets/Images/Wudu/i.png',
      title: 'Wash Your Arms Three Times',
      body: 'Wash right arm three times, then left arm three times.',
    ),
    _WuduSection(
      number: 8,
      image: 'assets/Images/Wudu/O.png',
      title: 'Wipe Your Head Once',
      body: 'Move wet hands from forehead to back of head once.',
    ),
    _WuduSection(
      number: 9,
      image: 'assets/Images/Wudu/a.png',
      title: 'Clean Your Ears Once',
      body: 'Clean inside and behind ears once.',
    ),
    _WuduSection(
      number: 10,
      image: 'assets/Images/Wudu/r.png',
      title: 'Recite the Shahada and the Dua',
      body: 'When the Prophet ﷺ would complete his wudu he would say the Shahada:',
      arabicText:
          'أَشْهَدُ أَنْ لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ،\n'
          'وَأَشْهَدُ أَنَّ مُحَمَّدًا عَبْدُهُ وَرَسُولُهُ.',
      transliteration:
          "Ash-hadu an la ilaha illallahu wahdahu la sharika lahu\n"
          "wa ash-hadu anna Muhammadan 'abduhu wa Rasuluhu.",
      translation:
          '"I testify that there is no god but Allah, alone without partner,\n'
          'and I testify that Muhammad is His servant and messenger."',
      extraArabic:
          'اللَّهُمَّ اجْعَلْنِي مِنَ التَّوَّابِينَ\n'
          'وَاجْعَلْنِي مِنَ الْمُتَطَهِّرِينَ',
      extraTranslit:
          "Allahumma j'alnee mina tawabeen\nwaj-'alnee minal mutatahireen",
      extraTranslation:
          '"O Allah, make me among those who seek repentance\n'
          'and make me among those who purify themselves."\n\n'
          '✅ Your wudu is now complete. You can begin to pray.',
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
          'Wudu Guide',
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
        itemCount: _sections.length,
        itemBuilder: (context, index) {
          return Column(
            children: [
              _AnimatedWuduCard(section: _sections[index], index: index),
              SizedBox(height: index < _sections.length - 1 ? 20 : 30),
            ],
          );
        },
      ),
    );
  }
}

// ── Data Model ─────────────────────────────────────────────────

class _WuduSection {
  const _WuduSection({
    required this.number,
    required this.image,
    required this.title,
    required this.body,
    this.arabicText,
    this.transliteration,
    this.translation,
    this.extraArabic,
    this.extraTranslit,
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
  final String? extraTranslit;
  final String? extraTranslation;
}

// ── Animated Card Wrapper ──────────────────────────────────────

class _AnimatedWuduCard extends StatefulWidget {
  const _AnimatedWuduCard({required this.section, required this.index});
  final _WuduSection section;
  final int index;

  @override
  State<_AnimatedWuduCard> createState() => _AnimatedWuduCardState();
}

class _AnimatedWuduCardState extends State<_AnimatedWuduCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
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
      child: SlideTransition(position: _slide, child: _WuduCard(section: widget.section)),
    );
  }
}

// ── Wudu Card ─────────────────────────────────────────────────

class _WuduCard extends StatelessWidget {
  const _WuduCard({required this.section});
  final _WuduSection section;

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
              child: SvgPicture.asset('assets/images/Wudu/Gr1.svg', width: 52, height: 52),
            ),
            Positioned(
              bottom: 8, right: 8,
              child: SvgPicture.asset('assets/images/Wudu/Gr2.svg', width: 52, height: 52),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _StepBadge(number: section.number, color: const Color(0xFF4CAF82)),
                  const SizedBox(height: 22),

                  // Centered floating image
                  SizedBox(
                    width: double.infinity,
                    child: Center(child: _FloatingPngImage(imagePath: section.image)),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    section.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E), height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _GreenDivider(),
                  const SizedBox(height: 14),

                  Text(
                    section.body,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14.5, color: Color(0xFF555570), height: 1.65),
                  ),

                  if (section.arabicText != null) ...[
                    const SizedBox(height: 18),
                    _ArabicBox(
                      arabic: section.arabicText!,
                      translit: section.transliteration,
                      translation: section.translation,
                    ),
                  ],

                  if (section.extraArabic != null) ...[
                    const SizedBox(height: 14),
                    const _SectionDivider(label: 'Dua after Wudu'),
                    const SizedBox(height: 14),
                    _ArabicBox(
                      arabic: section.extraArabic!,
                      translit: section.extraTranslit,
                      translation: section.extraTranslation,
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

// ── Floating PNG Image  (float + scale + wobble + shimmer glow) ──

class _FloatingPngImage extends StatefulWidget {
  const _FloatingPngImage({required this.imagePath});
  final String imagePath;

  @override
  State<_FloatingPngImage> createState() => _FloatingPngImageState();
}

class _FloatingPngImageState extends State<_FloatingPngImage>
    with TickerProviderStateMixin {
  late final AnimationController _floatCtrl;
  late final AnimationController _glowCtrl;

  late final Animation<double> _float;
  late final Animation<double> _scale;
  late final Animation<double> _wobble;
  late final Animation<double> _glow;

  @override
  void initState() {
    super.initState();

    // Float + scale + wobble (2.4s)
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _float = Tween<double>(begin: 0, end: -12)
        .animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));
    _scale = Tween<double>(begin: 1.0, end: 1.07)
        .animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));
    _wobble = Tween<double>(begin: -0.018, end: 0.018)
        .animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));

    // Glow pulse (1.8s, offset)
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _glow = Tween<double>(begin: 6, end: 22)
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
                      color: const Color(0xFF4CAF82).withOpacity(0.28),
                      blurRadius: _glow.value,
                      spreadRadius: _glow.value * 0.25,
                    ),
                  ],
                ),
                child: child,
              ),
            ),
          ),
        );
      },
      child: Image.asset(
        widget.imagePath,
        height: 190,
        width: 190,
        fit: BoxFit.contain,
        alignment: Alignment.center,
        errorBuilder: (_, __, ___) => Container(
          height: 190, width: 190,
          decoration: BoxDecoration(
            color: const Color(0xFFF0FAF4),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(
            child: Icon(Icons.image_not_supported_outlined, size: 60, color: Color(0xFF4CAF82)),
          ),
        ),
      ),
    );
  }
}

// ── Shared Widgets ─────────────────────────────────────────────

class _StepBadge extends StatelessWidget {
  const _StepBadge({required this.number, required this.color});
  final int number;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44, height: 44,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.8), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Center(
        child: Text('$number',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17)),
      ),
    );
  }
}

class _GreenDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48, height: 3,
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF82),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _ArabicBox extends StatelessWidget {
  const _ArabicBox({required this.arabic, this.translit, this.translation});
  final String arabic;
  final String? translit;
  final String? translation;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FAF4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF4CAF82).withOpacity(0.25), width: 1.2),
      ),
      child: Column(
        children: [
          Text(arabic,
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                  fontSize: 18, color: Color(0xFF1B5E3B), height: 1.9, fontWeight: FontWeight.w600)),
          if (translit != null) ...[
            const SizedBox(height: 8),
            Text(translit!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 12.5, color: Color(0xFF4CAF82), fontStyle: FontStyle.italic, height: 1.5)),
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

class _SectionDivider extends StatelessWidget {
  const _SectionDivider({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFFD0D0E0))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(label,
              style: const TextStyle(
                  fontSize: 11.5, color: Color(0xFF4CAF82), fontWeight: FontWeight.w600, letterSpacing: 0.4)),
        ),
        const Expanded(child: Divider(color: Color(0xFFD0D0E0))),
      ],
    );
  }
}