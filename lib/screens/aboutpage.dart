import 'package:flutter/material.dart';
import 'dart:math' as math;

// ══════════════════════════════════════════════════════════════
//  PKT CALL TAXI — LUXURY ANIMATED ABOUT PAGE
//  • Animated gold ring rotation
//  • Fade + slide-in on load
//  • Shimmer on stats
//  • Hover glow on badges (desktop)
//  • Particle dots in background
//  • Fully responsive Mobile / Tablet / Desktop
// ══════════════════════════════════════════════════════════════

class AboutPage extends StatefulWidget {
  final Key? aboutKey;
  const AboutPage({super.key, this.aboutKey});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage>
    with TickerProviderStateMixin {

  // ── Animation Controllers ─────────────────────────────────
  late final AnimationController _ringCtrl;    // ring slow rotate
  late final AnimationController _entryCtrl;   // page fade+slide in
  late final AnimationController _shimmerCtrl; // stat shimmer

  late final Animation<double> _fadeAnim;
  late final Animation<Offset>  _slideAnim;

  // ── Luxury Color Palette ──────────────────────────────────
  static const Color kBg          = Color(0xFF0A0A0A);
  static const Color kPanel       = Color(0xFF111111);
  static const Color kCardBg      = Color(0xFF161616);
  static const Color kGold        = Color(0xFFC9A84C);
  static const Color kGoldLight   = Color(0xFFE0BC66);
  static const Color kGoldDim     = Color(0xFF7A6030);
  static const Color kTextPrimary = Color(0xFFF0E6C8);
  static const Color kTextMuted   = Color(0xFF6A5C40);
  static const Color kBorder      = Color(0x22C9A84C);

  // ── Breakpoints ───────────────────────────────────────────
  static bool _isMobile(BuildContext ctx)  => MediaQuery.of(ctx).size.width < 600;
  static bool _isTablet(BuildContext ctx)  => MediaQuery.of(ctx).size.width >= 600
                                           && MediaQuery.of(ctx).size.width < 1024;

  @override
  void initState() {
    super.initState();

    // Ring: continuous slow rotate (30s per revolution)
    _ringCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();

    // Entry: fade + slide up (1.2s, starts immediately)
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnim = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic));

    // Shimmer: repeating (2s)
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    // Start entry after a tiny delay so widget is mounted
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _entryCtrl.forward();
    });
  }

  @override
  void dispose() {
    _ringCtrl.dispose();
    _entryCtrl.dispose();
    _shimmerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mobile  = _isMobile(context);
    final tablet  = _isTablet(context);
    final double hPad = mobile ? 20 : (tablet ? 32 : 50);
    final double vPad = mobile ? 60 : (tablet ? 80 : 100);

    return Container(
      key: widget.aboutKey,
      width: double.infinity,
      color: kBg,
      child: Stack(
        children: [
          // ── Animated background particles ─────────────────
          ..._buildParticles(),

          // ── Ambient glow blobs ────────────────────────────
          Positioned(
            top: -80, left: -80,
            child: _GlowBlob(size: 400, opacity: 0.03, color: kGold),
          ),
          Positioned(
            bottom: -60, right: -60,
            child: _GlowBlob(size: 300, opacity: 0.04, color: kGold),
          ),
          Positioned(
            top: 200, right: 100,
            child: _GlowBlob(size: 200, opacity: 0.02, color: kGoldLight),
          ),

          // ── Main content (fade + slide) ───────────────────
          FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: vPad, horizontal: hPad),
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: mobile
                        ? _buildMobileLayout(context)
                        : tablet
                            ? _buildTabletLayout(context)
                            : _buildDesktopLayout(context),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Background floating particles ─────────────────────────
  List<Widget> _buildParticles() {
    final positions = [
      [0.1, 0.15], [0.85, 0.1], [0.25, 0.8],
      [0.7, 0.75], [0.5, 0.4],  [0.9, 0.5],
    ];
    return positions.asMap().entries.map((e) {
      final delay = e.key * 600;
      return _FloatingDot(
        leftFraction: e.value[0],
        topFraction: e.value[1],
        delay: Duration(milliseconds: delay),
        color: kGold,
      );
    }).toList();
  }

  // ══════════════════════════════════════════════════════════
  //  LAYOUTS
  // ══════════════════════════════════════════════════════════

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(flex: 1, child: _buildImagePanel(size: 420)),
        const SizedBox(width: 80),
        Expanded(flex: 1, child: _buildContent(context, headingSize: 46, descSize: 16)),
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(flex: 1, child: _buildImagePanel(size: 300)),
        const SizedBox(width: 40),
        Expanded(flex: 1, child: _buildContent(context, headingSize: 32, descSize: 14)),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildImagePanel(size: 260),
        const SizedBox(height: 40),
        _buildContent(context, headingSize: 28, descSize: 14),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════
  //  IMAGE PANEL — animated ring
  // ══════════════════════════════════════════════════════════

  Widget _buildImagePanel({required double size}) {
    final double innerSize   = size * 0.857;
    final double imageSize   = size * 0.762;
    final double badgeBottom = size * 0.071;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer glow ring (pulsing)
        _PulsingRing(size: size + 20, color: kGold),

        // Rotating dashed ring
        AnimatedBuilder(
          animation: _ringCtrl,
          builder: (_, __) => Transform.rotate(
            angle: _ringCtrl.value * 2 * math.pi,
            child: Container(
              height: size, width: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: kGold.withOpacity(0.15), width: 1,
                ),
              ),
              child: CustomPaint(painter: _DashedRingPainter(color: kGold)),
            ),
          ),
        ),

        // Counter-rotating inner ring (slower)
        AnimatedBuilder(
          animation: _ringCtrl,
          builder: (_, __) => Transform.rotate(
            angle: -_ringCtrl.value * 2 * math.pi * 0.4,
            child: Container(
              height: innerSize, width: innerSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kCardBg,
                border: Border.all(color: kGold.withOpacity(0.12), width: 1),
              ),
            ),
          ),
        ),

        // Animated gold dot accents on ring
        AnimatedBuilder(
          animation: _ringCtrl,
          builder: (_, __) => _RotatingDots(
            size: size,
            angle: _ringCtrl.value * 2 * math.pi,
            color: kGold,
          ),
        ),

        // Car image with subtle float
        _FloatingCar(imageSize: imageSize),

        // Bottom badge
        Positioned(
          bottom: badgeBottom,
          child: _GlowBadge(
            icon: Icons.star,
            label: 'PREMIUM FLEET',
            color: kGold,
            bg: kPanel,
            border: kBorder,
          ),
        ),

        // Top badge (extra flair)
        Positioned(
          top: badgeBottom,
          child: _GlowBadge(
            icon: Icons.shield_outlined,
            label: 'VERIFIED SERVICE',
            color: kGold,
            bg: kPanel,
            border: kBorder,
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════
  //  CONTENT SECTION
  // ══════════════════════════════════════════════════════════

  Widget _buildContent(BuildContext context, {
    required double headingSize,
    required double descSize,
  }) {
    final mobile = _isMobile(context);
    final double statValueSize = mobile ? 22 : 28;
    final double statLabelSize = mobile ? 9  : 10;
    final double statDivMx     = mobile ? 16 : 28;
    final double badgeIconSize = mobile ? 12 : 14;
    final double badgeFontSize = mobile ? 10 : 11;
    final double badgeHPad     = mobile ? 10 : 14;
    final double badgeVPad     = mobile ? 8  : 10;
    final double badgeGap      = mobile ? 8  : 14;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // Section tag with animated line
        _AnimatedSectionTag(color: kGold),

        const SizedBox(height: 24),

        // Main heading — stagger per line
        _StaggeredHeading(
          lines: const [
            'Experience the',
            'Pinnacle of',
            'Professional Travel',
          ],
          fontSize: headingSize,
          color: kTextPrimary,
          goldColor: kGold,
        ),

        // Gold underline accent
        Container(
          margin: const EdgeInsets.only(top: 16, bottom: 32),
          height: 2, width: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [kGold, kGoldLight, kGold.withOpacity(0)],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),

        // Description
        _buildDescription(
          "At PKT Call Taxi, we don't just provide rides; we deliver excellence. "
          "Specializing in reliable, convenient, and premium one-way taxi services "
          "tailored for your journey.",
          fontSize: descSize,
        ),

        const SizedBox(height: 20),

        _buildDescription(
          "Whether it's an airport transfer or a corporate meeting, our fleet of "
          "pristine vehicles and elite drivers ensure you arrive not just on time, "
          "but in comfort and style.",
          fontSize: descSize,
        ),

        SizedBox(height: mobile ? 32 : 48),

        // Stats row — shimmer animation
        Row(children: [
          _ShimmerStat(
            value: '4.9★', label: 'Rating',
            shimmerCtrl: _shimmerCtrl,
            valueSize: statValueSize, labelSize: statLabelSize,
            goldColor: kGold, mutedColor: kTextMuted,
          ),
          _buildStatDivider(mx: statDivMx),
          _ShimmerStat(
            value: '12K+', label: 'Rides',
            shimmerCtrl: _shimmerCtrl,
            valueSize: statValueSize, labelSize: statLabelSize,
            goldColor: kGold, mutedColor: kTextMuted,
            shimmerDelay: 0.33,
          ),
          _buildStatDivider(mx: statDivMx),
          _ShimmerStat(
            value: '50+', label: 'Vehicles',
            shimmerCtrl: _shimmerCtrl,
            valueSize: statValueSize, labelSize: statLabelSize,
            goldColor: kGold, mutedColor: kTextMuted,
            shimmerDelay: 0.66,
          ),
        ]),

        SizedBox(height: mobile ? 28 : 40),

        // Feature badges — hover glow
        mobile
            ? Wrap(
                spacing: badgeGap, runSpacing: badgeGap,
                children: _featureBadges(badgeIconSize, badgeFontSize, badgeHPad, badgeVPad),
              )
            : Row(
                children: _featureBadges(badgeIconSize, badgeFontSize, badgeHPad, badgeVPad)
                    .expand((w) => [w, SizedBox(width: badgeGap)])
                    .toList()..removeLast(),
              ),
      ],
    );
  }

  List<Widget> _featureBadges(double iconSize, double fontSize, double hPad, double vPad) => [
    _HoverGlowBadge(
      icon: Icons.verified_user_outlined, label: 'Safety First',
      iconSize: iconSize, fontSize: fontSize, hPad: hPad, vPad: vPad,
      gold: kGold, cardBg: kCardBg, border: kBorder, textColor: kTextPrimary,
    ),
    _HoverGlowBadge(
      icon: Icons.timer_outlined, label: '24/7 Service',
      iconSize: iconSize, fontSize: fontSize, hPad: hPad, vPad: vPad,
      gold: kGold, cardBg: kCardBg, border: kBorder, textColor: kTextPrimary,
    ),
    _HoverGlowBadge(
      icon: Icons.workspace_premium_outlined, label: 'Premium',
      iconSize: iconSize, fontSize: fontSize, hPad: hPad, vPad: vPad,
      gold: kGold, cardBg: kCardBg, border: kBorder, textColor: kTextPrimary,
    ),
  ];

  Widget _buildDescription(String text, {double fontSize = 16}) => Text(
    text,
    style: TextStyle(
      fontSize: fontSize, height: 1.9,
      color: kTextMuted, fontWeight: FontWeight.w400, letterSpacing: 0.3,
    ),
  );

  Widget _buildStatDivider({double mx = 28}) => Container(
    margin: EdgeInsets.symmetric(horizontal: mx),
    width: 1, height: 36, color: kBorder,
  );
}

// ══════════════════════════════════════════════════════════════
//  SUB-WIDGETS
// ══════════════════════════════════════════════════════════════

// ── Floating Car (bobs up/down) ───────────────────────────────
class _FloatingCar extends StatefulWidget {
  final double imageSize;
  const _FloatingCar({required this.imageSize});
  @override
  State<_FloatingCar> createState() => _FloatingCarState();
}
class _FloatingCarState extends State<_FloatingCar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, child) => Transform.translate(
        offset: Offset(0, _anim.value),
        child: child,
      ),
      child: Hero(
        tag: 'car_image',
        child: Image.asset(
          'assets/sedan.png',
          fit: BoxFit.contain,
          height: widget.imageSize,
          errorBuilder: (_, __, ___) => Icon(
            Icons.directions_car_rounded,
            color: const Color(0xFFC9A84C),
            size: widget.imageSize * 0.4,
          ),
        ),
      ),
    );
  }
}

// ── Pulsing outer ring ────────────────────────────────────────
class _PulsingRing extends StatefulWidget {
  final double size;
  final Color color;
  const _PulsingRing({required this.size, required this.color});
  @override
  State<_PulsingRing> createState() => _PulsingRingState();
}
class _PulsingRingState extends State<_PulsingRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.03, end: 0.12).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: widget.size, height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: widget.color.withOpacity(_anim.value), width: 1.5,
          ),
        ),
      ),
    );
  }
}

// ── Dashed ring painter ───────────────────────────────────────
class _DashedRingPainter extends CustomPainter {
  final Color color;
  const _DashedRingPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.25)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;
    const dashCount = 24;
    const gap = 0.06;

    for (int i = 0; i < dashCount; i++) {
      final start = (i / dashCount) * 2 * math.pi;
      final end   = start + (2 * math.pi / dashCount) - gap;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start, end - start, false, paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DashedRingPainter old) => old.color != color;
}

// ── Rotating dot accents ──────────────────────────────────────
class _RotatingDots extends StatelessWidget {
  final double size;
  final double angle;
  final Color color;
  const _RotatingDots({required this.size, required this.angle, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size, height: size,
      child: Stack(
        alignment: Alignment.center,
        children: List.generate(6, (i) {
          final a = angle + (i / 6) * 2 * math.pi;
          final r = size / 2 - 4;
          final x = math.cos(a) * r;
          final y = math.sin(a) * r;
          final dotSize = i % 2 == 0 ? 7.0 : 5.0;
          return Transform.translate(
            offset: Offset(x, y),
            child: Container(
              width: dotSize, height: dotSize,
              decoration: BoxDecoration(
                color: color.withOpacity(i % 2 == 0 ? 0.9 : 0.4),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: color.withOpacity(0.4), blurRadius: 6),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Glow badge (bottom/top of ring) ──────────────────────────
class _GlowBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color, bg, border;
  const _GlowBadge({
    required this.icon, required this.label,
    required this.color, required this.bg, required this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [BoxShadow(color: color.withOpacity(0.15), blurRadius: 20)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 11),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(
            color: color, fontSize: 9,
            fontWeight: FontWeight.w800, letterSpacing: 2.5,
          )),
        ],
      ),
    );
  }
}

// ── Animated section tag ──────────────────────────────────────
class _AnimatedSectionTag extends StatefulWidget {
  final Color color;
  const _AnimatedSectionTag({required this.color});
  @override
  State<_AnimatedSectionTag> createState() => _AnimatedSectionTagState();
}
class _AnimatedSectionTagState extends State<_AnimatedSectionTag>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _width;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 800),
    );
    _width = Tween<double>(begin: 0, end: 28).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _ctrl.forward();
    });
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      AnimatedBuilder(
        animation: _width,
        builder: (_, __) => Container(
          width: _width.value, height: 1, color: widget.color,
        ),
      ),
      const SizedBox(width: 10),
      Text('ABOUT US', style: TextStyle(
        color: widget.color, fontSize: 10,
        fontWeight: FontWeight.w700, letterSpacing: 3,
      )),
    ]);
  }
}

// ── Staggered heading ─────────────────────────────────────────
class _StaggeredHeading extends StatefulWidget {
  final List<String> lines;
  final double fontSize;
  final Color color, goldColor;
  const _StaggeredHeading({
    required this.lines, required this.fontSize,
    required this.color, required this.goldColor,
  });
  @override
  State<_StaggeredHeading> createState() => _StaggeredHeadingState();
}
class _StaggeredHeadingState extends State<_StaggeredHeading>
    with TickerProviderStateMixin {
  final List<AnimationController> _ctrls = [];
  final List<Animation<Offset>>    _slides = [];
  final List<Animation<double>>    _fades  = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.lines.length; i++) {
      final ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700),
      );
      _ctrls.add(ctrl);
      _slides.add(Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero)
          .animate(CurvedAnimation(parent: ctrl, curve: Curves.easeOutCubic)));
      _fades.add(Tween<double>(begin: 0, end: 1)
          .animate(CurvedAnimation(parent: ctrl, curve: Curves.easeOut)));

      Future.delayed(Duration(milliseconds: 300 + i * 150), () {
        if (mounted) ctrl.forward();
      });
    }
  }

  @override
  void dispose() {
    for (final c in _ctrls) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.lines.asMap().entries.map((e) {
        final i = e.key;
        final line = e.value;
        // Last line gets gold color
        final isLast = i == widget.lines.length - 1;
        return ClipRect(
          child: SlideTransition(
            position: _slides[i],
            child: FadeTransition(
              opacity: _fades[i],
              child: Text(
                line,
                style: TextStyle(
                  fontSize: widget.fontSize,
                  fontWeight: FontWeight.w900,
                  color: isLast ? widget.goldColor : widget.color,
                  height: 1.15,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Shimmer stat counter ──────────────────────────────────────
class _ShimmerStat extends StatelessWidget {
  final String value, label;
  final AnimationController shimmerCtrl;
  final double valueSize, labelSize, shimmerDelay;
  final Color goldColor, mutedColor;

  const _ShimmerStat({
    required this.value, required this.label,
    required this.shimmerCtrl,
    required this.valueSize, required this.labelSize,
    required this.goldColor, required this.mutedColor,
    this.shimmerDelay = 0,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: shimmerCtrl,
      builder: (_, __) {
        final t = ((shimmerCtrl.value + shimmerDelay) % 1.0);
        final shimmer = (math.sin(t * math.pi * 2) + 1) / 2;
        final color = Color.lerp(goldColor, const Color(0xFFFFE680), shimmer)!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: TextStyle(
              color: color, fontSize: valueSize,
              fontWeight: FontWeight.w900, letterSpacing: -0.5,
            )),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(
              color: mutedColor, fontSize: labelSize,
              letterSpacing: 2, fontWeight: FontWeight.w500,
            )),
          ],
        );
      },
    );
  }
}

// ── Hover glow badge ──────────────────────────────────────────
class _HoverGlowBadge extends StatefulWidget {
  final IconData icon;
  final String label;
  final double iconSize, fontSize, hPad, vPad;
  final Color gold, cardBg, border, textColor;

  const _HoverGlowBadge({
    required this.icon, required this.label,
    required this.iconSize, required this.fontSize,
    required this.hPad, required this.vPad,
    required this.gold, required this.cardBg,
    required this.border, required this.textColor,
  });
  @override
  State<_HoverGlowBadge> createState() => _HoverGlowBadgeState();
}
class _HoverGlowBadgeState extends State<_HoverGlowBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _glow;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 200),
    );
    _glow = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) { setState(() => _hovered = true);  _ctrl.forward(); },
      onExit:  (_) { setState(() => _hovered = false); _ctrl.reverse(); },
      child: GestureDetector(
        onTap: () {},
        child: AnimatedBuilder(
          animation: _glow,
          builder: (_, child) => Container(
            padding: EdgeInsets.symmetric(horizontal: widget.hPad, vertical: widget.vPad),
            decoration: BoxDecoration(
              color: Color.lerp(widget.cardBg, widget.gold.withOpacity(0.08), _glow.value),
              border: Border.all(
                color: widget.gold.withOpacity(0.15 + _glow.value * 0.35),
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: widget.gold.withOpacity(0.1 * _glow.value),
                  blurRadius: 16,
                ),
              ],
            ),
            child: child,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: widget.iconSize, color: widget.gold),
              const SizedBox(width: 8),
              Text(widget.label, style: TextStyle(
                color: widget.textColor,
                fontWeight: FontWeight.w600,
                fontSize: widget.fontSize,
                letterSpacing: 0.5,
              )),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Floating background dot ───────────────────────────────────
class _FloatingDot extends StatefulWidget {
  final double leftFraction, topFraction;
  final Duration delay;
  final Color color;
  const _FloatingDot({
    required this.leftFraction, required this.topFraction,
    required this.delay, required this.color,
  });
  @override
  State<_FloatingDot> createState() => _FloatingDotState();
}
class _FloatingDotState extends State<_FloatingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 3000 + widget.delay.inMilliseconds % 1000),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: -6, end: 6).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Positioned(
      left: widget.leftFraction * size.width,
      top: widget.topFraction * size.height,
      child: AnimatedBuilder(
        animation: _anim,
        builder: (_, __) => Transform.translate(
          offset: Offset(0, _anim.value),
          child: Container(
            width: 4, height: 4,
            decoration: BoxDecoration(
              color: widget.color.withOpacity(0.25),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: widget.color.withOpacity(0.2), blurRadius: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Glow blob background ──────────────────────────────────────
class _GlowBlob extends StatelessWidget {
  final double size, opacity;
  final Color color;
  const _GlowBlob({required this.size, required this.opacity, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(opacity),
      ),
    );
  }
}