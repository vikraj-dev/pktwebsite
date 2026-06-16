import 'package:flutter/material.dart';
import 'package:pktwebsite/screens/contectpage.dart';
import 'package:pktwebsite/screens/tarifpage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' as math;
import 'dart:async';
import 'aboutpage.dart';
import 'homepage.dart';
import 'header.dart';
import 'package:pktwebsite/screens/app_page.dart';
import 'package:pktwebsite/screens/reviews_page.dart';
import 'package:pktwebsite/screens/states_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Webpage extends StatefulWidget {
  const Webpage({super.key});
  @override
  State<Webpage> createState() => _WebpageState();
}

class _WebpageState extends State<Webpage> with TickerProviderStateMixin {
  // ── Section Keys ─────────────────────────────────────────────
  final homeKey        = GlobalKey();
  final aboutKey       = GlobalKey();
  final featuresKey    = GlobalKey();
  final statsKey       = GlobalKey();
  final reviewsKey     = GlobalKey();
  final tarifkey       = GlobalKey();
  final appDownloadKey = GlobalKey();
  final contectkey     = GlobalKey();

  String _contactNumber = '7667733771';

  final ScrollController scrollController = ScrollController();

  // ── Value Notifiers ──────────────────────────────────────────
  final ValueNotifier<String> _activeSection      = ValueNotifier('HOME');
  final ValueNotifier<bool>   _showScrollTop      = ValueNotifier(false);
  final ValueNotifier<bool>   _aboutVisible       = ValueNotifier(false);
  final ValueNotifier<bool>   _featuresVisible    = ValueNotifier(false);
  final ValueNotifier<bool>   _statsVisible       = ValueNotifier(false);
  final ValueNotifier<bool>   _reviewsVisible     = ValueNotifier(false);
  final ValueNotifier<bool>   _tarifVisible       = ValueNotifier(false);
  final ValueNotifier<bool>   _appDownloadVisible = ValueNotifier(false);
  final ValueNotifier<bool>   _contectVisible     = ValueNotifier(false);

  // ── Animation Controllers ────────────────────────────────────
  late final AnimationController _aboutAnim;
  late final AnimationController _featuresAnim;
  late final AnimationController _statsAnim;
  late final AnimationController _reviewsAnim;
  late final AnimationController _tarifAnim;
  late final AnimationController _appDownloadAnim;
  late final AnimationController _contectAnim;

  // ── Background: 2 separate animators for parallax depth ──────
  late final AnimationController _carFgAnim; // foreground car  – 18s
  late final AnimationController _carBgAnim; // background cars – 26s

  @override
  void initState() {
    super.initState();

    _aboutAnim       = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _featuresAnim    = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _statsAnim       = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _reviewsAnim     = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _tarifAnim       = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _appDownloadAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _contectAnim     = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));

    _carFgAnim = AnimationController(vsync: this, duration: const Duration(seconds: 18))..repeat();
    _carBgAnim = AnimationController(vsync: this, duration: const Duration(seconds: 26))..repeat();

    scrollController.addListener(_onScroll);
    _fetchContactNumber();
  }

  @override
  void dispose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    _activeSection.dispose();
    _showScrollTop.dispose();
    _aboutVisible.dispose();
    _featuresVisible.dispose();
    _statsVisible.dispose();
    _reviewsVisible.dispose();
    _tarifVisible.dispose();
    _appDownloadVisible.dispose();
    _contectVisible.dispose();
    _aboutAnim.dispose();
    _featuresAnim.dispose();
    _statsAnim.dispose();
    _reviewsAnim.dispose();
    _tarifAnim.dispose();
    _appDownloadAnim.dispose();
    _contectAnim.dispose();
    _carFgAnim.dispose();
    _carBgAnim.dispose();
    super.dispose();
  }

  // ── Scroll Listener ──────────────────────────────────────────
  void _onScroll() {
    if (!scrollController.hasClients) return;
    final double offset = scrollController.offset;

    final String section;
    if (offset < 700)       section = 'HOME';
    else if (offset < 1400) section = 'ABOUT';
    else if (offset < 2100) section = 'FEATURES';
    else if (offset < 2800) section = 'STATS';
    else if (offset < 3500) section = 'TARIFF';
    else                    section = 'CONTACT';
    if (_activeSection.value != section) _activeSection.value = section;

    final bool show = offset > 500;
    if (_showScrollTop.value != show) _showScrollTop.value = show;

    if (offset > 400  && !_aboutVisible.value)       { _aboutVisible.value = true;       _aboutAnim.forward(); }
    if (offset > 1100 && !_featuresVisible.value)    { _featuresVisible.value = true;    _featuresAnim.forward(); }
    if (offset > 1900 && !_statsVisible.value)       { _statsVisible.value = true;       _statsAnim.forward(); }
    if (offset > 2600 && !_reviewsVisible.value)     { _reviewsVisible.value = true;     _reviewsAnim.forward(); }
    if (offset > 3200 && !_tarifVisible.value)       { _tarifVisible.value = true;       _tarifAnim.forward(); }
    if (offset > 3900 && !_appDownloadVisible.value) { _appDownloadVisible.value = true; _appDownloadAnim.forward(); }
    if (offset > 4400 && !_contectVisible.value)     { _contectVisible.value = true;     _contectAnim.forward(); }
  }

  void _scrollTo(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(ctx,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  Future<void> _fetchContactNumber() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('admin').doc('app_settings').get();
      if (doc.exists) {
        final num = doc.data()?['number'];
        if (num != null) setState(() => _contactNumber = num.toString());
      }
    } catch (_) {}
  }

  Future<void> _openWhatsApp() async {
    final url = Uri.parse(
        'https://wa.me/+91$_contactNumber?text=${Uri.encodeComponent("Hello PKT Call Taxi, can you help me with your services?")}');
    if (await canLaunchUrl(url))
      await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  Future<void> _makeCall() async {
    final url = Uri.parse('tel:+91$_contactNumber');
    if (await canLaunchUrl(url))
      await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  // ── Animated Section Wrapper — fade + slide up ───────────────
  Widget _animatedSection({
    required AnimationController controller,
    required Widget child,
  }) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) => FadeTransition(
        opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: controller,
              curve: const Interval(0.0, 0.75, curve: Curves.easeOut)),
        ),
        child: SlideTransition(
          position: Tween<Offset>(
                  begin: const Offset(0, 0.07), end: Offset.zero)
              .animate(CurvedAnimation(
                  parent: controller, curve: Curves.easeOutCubic)),
          child: child,
        ),
      ),
    );
  }

  bool _isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;
  bool _isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1024;

  // ══════════════════════════════════════════════════════════════
  //  BUILD
  // ══════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final size   = MediaQuery.of(context).size;
    final mobile = _isMobile(context);
    final tablet = _isTablet(context);
    final double fabSize      = mobile ? 44 : (tablet ? 50 : 54);
    final double fabBottom    = mobile ? 24 : 30;
    final double fabLeftRight = mobile ? 16 : 30;
    final double fabIconSize  = mobile ? 20 : (tablet ? 22 : 24);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Stack(
        children: [

          // ════════════════════════════════════════════════════
          // LAYER 0A — Background depth cars (far, slow, dimmer)
          // ════════════════════════════════════════════════════
          Positioned.fill(
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: _carBgAnim,
                builder: (_, __) => CustomPaint(
                  painter: LuxuryCarBgPainter(
                    progress: _carBgAnim.value,
                    layer: CarLayer.background,
                  ),
                  size: Size(size.width, size.height),
                ),
              ),
            ),
          ),

          // ════════════════════════════════════════════════════
          // LAYER 0B — Foreground car (large, bold, clearly visible)
          // ════════════════════════════════════════════════════
          Positioned.fill(
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: _carFgAnim,
                builder: (_, __) => CustomPaint(
                  painter: LuxuryCarBgPainter(
                    progress: _carFgAnim.value,
                    layer: CarLayer.foreground,
                  ),
                  size: Size(size.width, size.height),
                ),
              ),
            ),
          ),

          // ════════════════════════════════════════════════════
          // LAYER 1 — Scrollable Content
          // ════════════════════════════════════════════════════
          Positioned.fill(
            child: SingleChildScrollView(
              controller: scrollController,
              physics: const ClampingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 72),

                  // 1️⃣ HOME
                  RepaintBoundary(child: Homepage(key: homeKey)),
                  _buildSectionDivider(),

                  // 2️⃣ ABOUT
                  RepaintBoundary(
                    child: _animatedSection(
                      controller: _aboutAnim,
                      child: AboutPage(aboutKey: aboutKey),
                    ),
                  ),
                  _buildSectionDivider(),

                  // 3️⃣ FEATURES
                  RepaintBoundary(
                    child: _animatedSection(
                      controller: _featuresAnim,
                      child: _FeaturesSection(sectionKey: featuresKey),
                    ),
                  ),
                  _buildSectionDivider(),

                  // 4️⃣ STATS
                  RepaintBoundary(
                    child: _animatedSection(
                      controller: _statsAnim,
                      child: StatsSection(sectionKey: statsKey),
                    ),
                  ),
                  _buildSectionDivider(),

                  // 5️⃣ REVIEWS
                  RepaintBoundary(
                    child: _animatedSection(
                      controller: _reviewsAnim,
                      child: ReviewsPage(reviewsKey: reviewsKey),
                    ),
                  ),
                  _buildSectionDivider(),

                  // 6️⃣ TARIFF
                  RepaintBoundary(
                    child: _animatedSection(
                      controller: _tarifAnim,
                      child: TarifPage(tarifkey: tarifkey),
                    ),
                  ),
                  _buildSectionDivider(),

                  // 7️⃣ APP DOWNLOAD
                  RepaintBoundary(
                    child: _animatedSection(
                      controller: _appDownloadAnim,
                      child: AppDownloadPage(appDownloadKey: appDownloadKey),
                    ),
                  ),
                  _buildSectionDivider(),

                  // 8️⃣ CONTACT
                  RepaintBoundary(
                    child: _animatedSection(
                      controller: _contectAnim,
                      child: Contectpage(
                        contectkey:   contectkey,
                        onHomeTap:    () => _scrollTo(homeKey),
                        onAboutTap:   () => _scrollTo(aboutKey),
                        onTarifTap:   () => _scrollTo(tarifkey),
                        onContactTap: () => _scrollTo(contectkey),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ════════════════════════════════════════════════════
          // LAYER 2 — Header
          // ════════════════════════════════════════════════════
          Positioned(
            top: 0, left: 0, right: 0,
            child: RepaintBoundary(
              child: ValueListenableBuilder<String>(
                valueListenable: _activeSection,
                builder: (_, section, __) => Header(
                  activePage:   section,
                  onHomeTap:    () => _scrollTo(homeKey),
                  onAboutTap:   () => _scrollTo(aboutKey),
                  onTarifTap:   () => _scrollTo(tarifkey),
                  onContectTap: () => _scrollTo(contectkey),
                  onGetAppTap:  () => _scrollTo(appDownloadKey),
                ),
              ),
            ),
          ),

          // ════════════════════════════════════════════════════
          // LAYER 3 — WhatsApp FAB
          // ════════════════════════════════════════════════════
          Positioned(
            bottom: fabBottom, left: fabLeftRight,
            child: ValueListenableBuilder<bool>(
              valueListenable: _showScrollTop,
              builder: (_, show, __) => AnimatedOpacity(
                opacity: show ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: AnimatedScale(
                  scale: show ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  child: GestureDetector(
                    onTap: _openWhatsApp,
                    child: Container(
                      width: fabSize, height: fabSize,
                      decoration: BoxDecoration(
                        color: const Color(0xFFC9A84C),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0x44C9A84C)),
                      ),
                      child: Center(
                        child: CustomPaint(
                          size: Size(fabIconSize, fabIconSize),
                          painter: _WhatsAppPainter(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ════════════════════════════════════════════════════
          // LAYER 4 — Call FAB
          // ════════════════════════════════════════════════════
          Positioned(
            bottom: fabBottom + fabSize + (mobile ? 10 : 12),
            left: fabLeftRight,
            child: ValueListenableBuilder<bool>(
              valueListenable: _showScrollTop,
              builder: (_, show, __) => AnimatedOpacity(
                opacity: show ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: AnimatedScale(
                  scale: show ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  child: GestureDetector(
                    onTap: _makeCall,
                    child: Container(
                      width: fabSize, height: fabSize,
                      decoration: BoxDecoration(
                        color: const Color(0xFFC9A84C),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0x44C9A84C)),
                      ),
                      child: Icon(Icons.call_rounded,
                          color: const Color(0xFF0A0A0A), size: fabIconSize),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ════════════════════════════════════════════════════
          // LAYER 5 — Scroll Top FAB
          // ════════════════════════════════════════════════════
          Positioned(
            bottom: fabBottom, right: fabLeftRight,
            child: ValueListenableBuilder<bool>(
              valueListenable: _showScrollTop,
              builder: (_, show, __) => AnimatedOpacity(
                opacity: show ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: AnimatedScale(
                  scale: show ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  child: GestureDetector(
                    onTap: () => scrollController.animateTo(0,
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeInOutCubic,
                    ),
                    child: Container(
                      width: fabSize, height: fabSize,
                      decoration: BoxDecoration(
                        color: const Color(0xFFC9A84C),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0x44C9A84C)),
                      ),
                      child: Icon(Icons.keyboard_arrow_up_rounded,
                          color: const Color(0xFF0A0A0A),
                          size: fabIconSize + 2),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 50),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(height: 0.5, width: 100, color: const Color(0x22C9A84C)),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            width: 6, height: 6,
            decoration: const BoxDecoration(
                color: Color(0xFFC9A84C), shape: BoxShape.circle),
          ),
          Container(height: 0.5, width: 100, color: const Color(0x22C9A84C)),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  CAR LAYER ENUM
// ══════════════════════════════════════════════════════════════
enum CarLayer { foreground, background }

// ══════════════════════════════════════════════════════════════
//  LUXURY CAR BACKGROUND PAINTER — BOLD VISIBLE VERSION
// ══════════════════════════════════════════════════════════════
class LuxuryCarBgPainter extends CustomPainter {
  final double progress;
  final CarLayer layer;
  const LuxuryCarBgPainter({required this.progress, required this.layer});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    if (layer == CarLayer.foreground) {
      // ── FOREGROUND: 1 large bold car, right-center ─────────
      _drawRoadLines(canvas, w, h);
      _drawLightBeams(canvas, w, h);

      // Main hero car — large, bold, clearly visible
      _drawCar3D(
        canvas,
        cx: w * 0.68 + math.sin(progress * math.pi * 2) * w * 0.03,
        cy: h * 0.40 + math.cos(progress * math.pi * 2 * 0.6) * h * 0.018,
        scale: 1.0,
        bodyOpacity: 0.38,        // ← bold body
        strokeOpacity: 0.55,      // ← bold outline
        goldOpacity: 0.45,        // ← strong gold glow
        glowBlur: 22.0,
      );

      // Second mid car — bottom left
      final p2 = (progress + 0.5) % 1.0;
      _drawCar3D(
        canvas,
        cx: w * 0.22 + math.sin(p2 * math.pi * 2) * w * 0.025,
        cy: h * 0.70 + math.cos(p2 * math.pi * 2 * 0.8) * h * 0.015,
        scale: 0.60,
        bodyOpacity: 0.28,
        strokeOpacity: 0.40,
        goldOpacity: 0.30,
        glowBlur: 14.0,
      );

      _drawSpeedLines(canvas, w, h);

    } else {
      // ── BACKGROUND: 2 smaller ghost cars for depth ─────────
      final p3 = (progress + 0.25) % 1.0;
      _drawCar3D(
        canvas,
        cx: w * 0.50 + math.sin(p3 * math.pi * 2 * 1.2) * w * 0.04,
        cy: h * 0.20 + math.cos(p3 * math.pi * 2 * 1.2) * h * 0.012,
        scale: 0.35,
        bodyOpacity: 0.12,
        strokeOpacity: 0.18,
        goldOpacity: 0.14,
        glowBlur: 8.0,
      );
      final p4 = (progress + 0.75) % 1.0;
      _drawCar3D(
        canvas,
        cx: w * 0.80 + math.sin(p4 * math.pi * 2 * 0.9) * w * 0.03,
        cy: h * 0.82 + math.cos(p4 * math.pi * 2 * 0.9) * h * 0.010,
        scale: 0.28,
        bodyOpacity: 0.10,
        strokeOpacity: 0.15,
        goldOpacity: 0.11,
        glowBlur: 6.0,
      );
    }
  }

  // ── Road lane lines ───────────────────────────────────────────
  void _drawRoadLines(Canvas canvas, double w, double h) {
    final p = Paint()
      ..color = const Color(0x18C9A84C)
      ..strokeWidth = 1.2;
    final off = (progress * 140) % 70;
    for (double x = -off; x < w + 70; x += 70) {
      canvas.drawLine(Offset(x, h * 0.91), Offset(x + 40, h * 0.91), p);
    }
    for (double x = -(off + 35) % 70; x < w + 70; x += 70) {
      canvas.drawLine(Offset(x, h * 0.95), Offset(x + 40, h * 0.95), p);
    }
  }

  // ── Gold light beam sweep ─────────────────────────────────────
  void _drawLightBeams(Canvas canvas, double w, double h) {
    final sweep = (progress * 2 * math.pi);
    final cx = w * 0.68;
    final cy = h * 0.40;

    // Headlight beam — wide cone
    final beamPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFC9A84C).withOpacity(0.18),
          const Color(0xFFC9A84C).withOpacity(0.06),
          Colors.transparent,
        ],
        stops: const [0.0, 0.4, 1.0],
      ).createShader(Rect.fromCircle(
        center: Offset(cx + w * 0.18, cy),
        radius: w * 0.35,
      ));

    final path = Path()
      ..moveTo(cx + w * 0.06, cy + h * 0.02)
      ..lineTo(cx + w * 0.55, cy - h * 0.10)
      ..lineTo(cx + w * 0.55, cy + h * 0.10)
      ..close();
    canvas.drawPath(path, beamPaint);

    // Animated sweep glint
    final glintX = cx + w * 0.08 + math.cos(sweep * 0.5) * w * 0.12;
    final glintY = cy + math.sin(sweep * 0.5) * h * 0.06;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(glintX, glintY), width: w * 0.08, height: h * 0.03),
      Paint()
        ..color = const Color(0xFFC9A84C).withOpacity(0.20)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
    );
  }

  // ── Speed lines ───────────────────────────────────────────────
  void _drawSpeedLines(Canvas canvas, double w, double h) {
    final p = Paint()
      ..color = const Color(0x12C9A84C)
      ..strokeWidth = 0.8;
    final ys = [0.12, 0.32, 0.50, 0.68, 0.85];
    for (int i = 0; i < 5; i++) {
      final ph = (progress + i * 0.2) % 1.0;
      canvas.drawLine(
        Offset(w * (ph - 0.35), h * ys[i]),
        Offset(w * (ph - 0.35) + w * 0.28, h * ys[i]),
        p,
      );
    }
  }

  // ══════════════════════════════════════════════════════════════
  //  3D CAR DRAW — all opacity params explicit
  // ══════════════════════════════════════════════════════════════
  void _drawCar3D(
    Canvas canvas, {
    required double cx,
    required double cy,
    required double scale,
    required double bodyOpacity,
    required double strokeOpacity,
    required double goldOpacity,
    required double glowBlur,
  }) {
    final u = scale * 90;

    // ── Colors ────────────────────────────────────────────────
    final gold = const Color(0xFFC9A84C);

    final strokePaint = Paint()
      ..color = gold.withOpacity(strokeOpacity.clamp(0, 1))
      ..style = PaintingStyle.stroke
      ..strokeWidth = scale * 1.4
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = gold.withOpacity((bodyOpacity * 0.35).clamp(0, 1))
      ..style = PaintingStyle.fill;

    final windowPaint = Paint()
      ..color = gold.withOpacity((bodyOpacity * 0.55).clamp(0, 1))
      ..style = PaintingStyle.fill;

    // ── Geometry points ───────────────────────────────────────
    final gL  = cx - u * 0.85;
    final gF  = cy + u * 0.55;
    final rL  = cx - u * 0.55;
    final rR  = cx + u * 0.30;
    final rT  = cy - u * 0.28;
    final rT2 = cy - u * 0.22;
    final hR  = cx + u * 0.55;
    final hM  = cy + u * 0.10;

    // ── Body silhouette ───────────────────────────────────────
    final body = Path()
      ..moveTo(gL, gF)
      ..lineTo(gL, cy + u * 0.12)
      ..quadraticBezierTo(gL - u * 0.04, cy, rL, rT + u * 0.05)
      ..lineTo(cx - u * 0.15, rT)
      ..quadraticBezierTo(cx, rT - u * 0.04, rR, rT2)
      ..lineTo(cx + u * 0.52, cy - u * 0.02)
      ..quadraticBezierTo(hR + u * 0.04, cy + u * 0.04, hR, hM)
      ..lineTo(cx + u * 0.55, gF)
      ..close();

    // ── Outer glow ────────────────────────────────────────────
    canvas.drawPath(
      body,
      Paint()
        ..color = gold.withOpacity((goldOpacity * 0.3).clamp(0, 1))
        ..style = PaintingStyle.stroke
        ..strokeWidth = scale * 6
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, glowBlur),
    );

    // ── Fill & stroke ─────────────────────────────────────────
    canvas.drawPath(body, fillPaint);
    canvas.drawPath(body, strokePaint);

    // ── Windscreen / windows ──────────────────────────────────
    canvas.drawPath(
      Path()
        ..moveTo(rL + u * 0.05, rT + u * 0.08)
        ..lineTo(cx - u * 0.13, rT + u * 0.02)
        ..lineTo(rR - u * 0.02, rT2 + u * 0.06)
        ..lineTo(cx + u * 0.48, cy - u * 0.01)
        ..lineTo(rL + u * 0.05, cy + u * 0.10)
        ..close(),
      windowPaint,
    );

    // ── Wheels ────────────────────────────────────────────────
    final wheelPaint = Paint()
      ..color = gold.withOpacity((strokeOpacity * 0.9).clamp(0, 1))
      ..style = PaintingStyle.stroke
      ..strokeWidth = scale * 2.2;

    // Rear wheel
    canvas.save();
    canvas.translate(cx - u * 0.52, gF - u * 0.01);
    canvas.scale(1.0, 0.34);
    canvas.drawCircle(Offset.zero, u * 0.20, wheelPaint);
    // Hub
    canvas.drawCircle(
      Offset.zero, u * 0.08,
      Paint()..color = gold.withOpacity((strokeOpacity * 0.6).clamp(0, 1))
             ..style = PaintingStyle.stroke
             ..strokeWidth = scale * 1.0,
    );
    canvas.restore();

    // Front wheel
    canvas.save();
    canvas.translate(cx + u * 0.28, gF - u * 0.01);
    canvas.scale(1.0, 0.36);
    canvas.drawCircle(Offset.zero, u * 0.22, wheelPaint);
    canvas.drawCircle(
      Offset.zero, u * 0.09,
      Paint()..color = gold.withOpacity((strokeOpacity * 0.6).clamp(0, 1))
             ..style = PaintingStyle.stroke
             ..strokeWidth = scale * 1.0,
    );
    canvas.restore();

    // ── Headlight glow ────────────────────────────────────────
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx + u * 0.50, cy + u * 0.07),
        width: u * 0.22, height: u * 0.10,
      ),
      Paint()
        ..color = gold.withOpacity(goldOpacity.clamp(0, 1))
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, glowBlur * 0.7),
    );

    // Headlight beam triangle
    canvas.drawPath(
      Path()
        ..moveTo(cx + u * 0.52, cy + u * 0.08)
        ..lineTo(cx + u * 1.55, cy + u * 0.28)
        ..lineTo(cx + u * 1.30, cy + u * 0.44)
        ..close(),
      Paint()
        ..color = gold.withOpacity((goldOpacity * 0.35).clamp(0, 1))
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, glowBlur * 1.2),
    );

    // ── Door line detail ──────────────────────────────────────
    canvas.drawLine(
      Offset(cx + u * 0.40, cy + u * 0.04),
      Offset(cx + u * 0.58, cy + u * 0.06),
      Paint()
        ..color = gold.withOpacity((goldOpacity * 1.1).clamp(0, 1))
        ..strokeWidth = scale * 1.1
        ..strokeCap = StrokeCap.round,
    );

    // ── Grille lines ──────────────────────────────────────────
    final gp = Paint()
      ..color = gold.withOpacity((strokeOpacity * 0.55).clamp(0, 1))
      ..strokeWidth = scale * 0.7
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 3; i++) {
      final gx = cx + u * (0.12 + i * 0.13);
      canvas.drawLine(
        Offset(gx, cy + u * 0.24),
        Offset(gx + u * 0.05, cy + u * 0.44),
        gp,
      );
    }

    // ── Roofline highlight ────────────────────────────────────
    canvas.drawLine(
      Offset(cx - u * 0.28, rT + u * 0.03),
      Offset(cx + u * 0.12, rT2 + u * 0.03),
      Paint()
        ..color = Colors.white.withOpacity((bodyOpacity * 0.5).clamp(0, 1))
        ..strokeWidth = scale * 0.6
        ..strokeCap = StrokeCap.round,
    );

    // ── Underbody ground shadow ───────────────────────────────
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx - u * 0.10, gF + u * 0.04),
        width: u * 1.5, height: u * 0.12,
      ),
      Paint()
        ..color = gold.withOpacity((bodyOpacity * 0.25).clamp(0, 1))
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, glowBlur * 0.5),
    );
  }

  @override
  bool shouldRepaint(LuxuryCarBgPainter old) =>
      old.progress != progress || old.layer != layer;
}

// ══════════════════════════════════════════════════════════════
//  FEATURES SECTION (unchanged from original)
// ══════════════════════════════════════════════════════════════
class _FeatureData {
  final IconData icon;
  final String title;
  final String description;
  final String badge;
  const _FeatureData({
    required this.icon,
    required this.title,
    required this.description,
    required this.badge,
  });
}

const _featuresList = [
  _FeatureData(icon: Icons.currency_rupee_rounded,        title: 'Transparent Pricing', description: 'Pay only for the distance. No hidden charges, no return fare. Simple and honest billing.',         badge: 'No hidden fees'),
  _FeatureData(icon: Icons.access_time_filled_rounded,    title: '24/7 Service',         description: 'Available any hour, any day. Early morning airport runs or late-night returns — always ready.',     badge: 'Always available'),
  _FeatureData(icon: Icons.flight_takeoff_rounded,        title: 'Airport Transfers',    description: 'Punctual pickups, flight-tracking, and professional service for every travel trip.',                badge: 'On-time guarantee'),
  _FeatureData(icon: Icons.directions_car_filled_rounded, title: 'Premium Fleet',        description: 'Choose from Sedan, Etios, Luxury SUV, or Innova Grand — 50+ pristine vehicles.',                   badge: '50+ vehicles'),
  _FeatureData(icon: Icons.verified_user_rounded,         title: 'Safety & Comfort',     description: 'Trained, verified drivers. Clean and sanitized vehicles before every single ride.',                badge: 'Verified drivers'),
  _FeatureData(icon: Icons.chat_rounded,                  title: 'WhatsApp Booking',     description: 'Book instantly via WhatsApp or call. No app needed — fast and hassle-free.',                      badge: 'Instant booking'),
  _FeatureData(icon: Icons.map_rounded,                   title: 'Multiple Stops',       description: 'Add multiple pickup and drop points. Flexible routing for outstation or local drops.',              badge: 'Flexible routing'),
  _FeatureData(icon: Icons.payment_rounded,               title: 'Multiple Payments',    description: 'Pay via UPI, cash, card, or online transfer. Convenient payment for every customer.',              badge: 'UPI / Cash / Card'),
  _FeatureData(icon: Icons.star_rounded,                  title: '4.9★ Rated Service',  description: 'Consistently top-rated by thousands of happy customers across Tamil Nadu.',                        badge: '12K+ happy rides'),
];

class _FeaturesSection extends StatelessWidget {
  final GlobalKey sectionKey;
  const _FeaturesSection({required this.sectionKey});
  static const double _maxW = 960;
  static const double _gap  = 14;

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final mobile  = screenW < 600;
    final cols    = mobile ? 2 : 3;

    return Container(
      key: sectionKey,
      color: Colors.transparent,
      padding: EdgeInsets.symmetric(horizontal: mobile ? 16 : 40, vertical: 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxW),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(width: 32, height: 1, color: const Color(0xFFC9A84C)),
                const SizedBox(width: 10),
                const Text('WHY CHOOSE US', style: TextStyle(fontSize: 11, letterSpacing: 3, color: Color(0xFFC9A84C), fontWeight: FontWeight.w600)),
                const SizedBox(width: 10),
                Container(width: 32, height: 1, color: const Color(0xFFC9A84C)),
              ]),
              const SizedBox(height: 16),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(fontSize: mobile ? 24 : 30, fontWeight: FontWeight.w700, color: const Color(0xFFF0E6C8), height: 1.25),
                  children: const [
                    TextSpan(text: 'Features of\n'),
                    TextSpan(text: 'PKT Call Taxi', style: TextStyle(color: Color(0xFFC9A84C))),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Premium travel from Pattukkottai.\nThe finest choice for your every journey.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Color(0xFF6A5C40), height: 1.7),
              ),
              const SizedBox(height: 36),
              LayoutBuilder(builder: (ctx, bc) {
                final availW = bc.maxWidth;
                final cardW  = (availW - _gap * (cols - 1)) / cols;
                final total  = _featuresList.length;
                final rows   = <Widget>[];
                for (int i = 0; i < total; i += cols) {
                  final end   = (i + cols > total) ? total : i + cols;
                  final items = _featuresList.sublist(i, end);
                  final miss  = cols - items.length;
                  rows.add(IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (int j = 0; j < items.length; j++) ...[
                          if (j > 0) const SizedBox(width: _gap),
                          SizedBox(width: cardW, child: _FeatureCard(item: items[j])),
                        ],
                        for (int k = 0; k < miss; k++) ...[
                          const SizedBox(width: _gap),
                          SizedBox(width: cardW),
                        ],
                      ],
                    ),
                  ));
                  if (end < total) rows.add(const SizedBox(height: _gap));
                }
                return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: rows);
              }),
              const SizedBox(height: 44),
              Container(height: 1, decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.transparent, const Color(0xFFC9A84C).withOpacity(0.35), Colors.transparent]),
              )),
              const SizedBox(height: 36),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  _StatPill(value: '4.9★', label: 'RATING'),
                  _StatPill(value: '12K+', label: 'RIDES'),
                  _StatPill(value: '50+',  label: 'VEHICLES'),
                  _StatPill(value: '24/7', label: 'SERVICE'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatefulWidget {
  final _FeatureData item;
  const _FeatureCard({required this.item});
  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _hovered ? -3 : 0, 0),
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _hovered ? const Color(0x66C9A84C) : const Color(0x22C9A84C)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(children: [
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: _hovered ? 1.0 : 0.0,
              child: Container(height: 2, decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Colors.transparent, Color(0xFFC9A84C), Colors.transparent]),
              )),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFC9A84C).withOpacity(0.10),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFC9A84C).withOpacity(0.22)),
                  ),
                  child: Icon(widget.item.icon, color: const Color(0xFFC9A84C), size: 22),
                ),
                const SizedBox(height: 16),
                Text(widget.item.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFFF0E6C8), height: 1.3)),
                const SizedBox(height: 8),
                Expanded(child: Text(widget.item.description, style: const TextStyle(fontSize: 12, color: Color(0xFF6A5C40), height: 1.65))),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC9A84C).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFC9A84C).withOpacity(0.22)),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.check_rounded, size: 11, color: Color(0xFFC9A84C)),
                    const SizedBox(width: 5),
                    Text(widget.item.badge, style: const TextStyle(fontSize: 11, color: Color(0xFFC9A84C), letterSpacing: 0.3)),
                  ]),
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String value, label;
  const _StatPill({required this.value, required this.label});
  @override
  Widget build(BuildContext context) => Column(children: [
    Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFFC9A84C))),
    const SizedBox(height: 4),
    Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF6A5C40), letterSpacing: 1.2)),
  ]);
}

// ══════════════════════════════════════════════════════════════
//  WHATSAPP PAINTER (unchanged)
// ══════════════════════════════════════════════════════════════
class _WhatsAppPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r  = size.width * 0.44;
    canvas.drawCircle(Offset(cx, cy), r, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(cx, cy), r * 0.85, Paint()..color = const Color(0xFF25D366));
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.33, size.height * 0.27)
        ..cubicTo(size.width * 0.28, size.height * 0.40, size.width * 0.28, size.height * 0.52, size.width * 0.40, size.height * 0.60)
        ..cubicTo(size.width * 0.52, size.height * 0.70, size.width * 0.62, size.height * 0.72, size.width * 0.73, size.height * 0.66),
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.09
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      Path()
        ..moveTo(cx + r * 0.3, cy + r * 0.7)
        ..lineTo(cx + r * 0.1, cy + r * 1.0)
        ..lineTo(cx + r * 0.7, cy + r * 0.65)
        ..close(),
      Paint()..color = Colors.white,
    );
  }
  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}