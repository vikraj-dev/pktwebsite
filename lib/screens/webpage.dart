import 'package:flutter/material.dart';
import 'package:pktwebsite/screens/contectpage.dart';
import 'package:pktwebsite/screens/tarifpage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' as math;
import 'aboutpage.dart';
import 'homepage.dart';
import 'header.dart';

// ══════════════════════════════════════════════════════════════
//  PKT CALL TAXI — LUXURY 3D CAR BACKGROUND ANIMATION
//  - Front 3D angle car silhouette always moving in background
//  - Multiple cars at different depths (parallax feel)
//  - Gold headlight glow effect
//  - All existing features intact
//  - ADDED: Call button (6380177563) — responsive for all screens
// ══════════════════════════════════════════════════════════════

class Webpage extends StatefulWidget {
  const Webpage({super.key});

  @override
  State<Webpage> createState() => _WebpageState();
}

class _WebpageState extends State<Webpage> with TickerProviderStateMixin {

  // ── Keys ─────────────────────────────────────────────────────
  final aboutKey   = GlobalKey();
  final homeKey    = GlobalKey();
  final tarifkey   = GlobalKey();
  final contectkey = GlobalKey();

  final ScrollController scrollController = ScrollController();

  // ── ValueNotifiers ───────────────────────────────────────────
  final ValueNotifier<String> _activeSection = ValueNotifier('HOME');
  final ValueNotifier<bool>   _showScrollTop = ValueNotifier(false);

  // ── Section animation notifiers ──────────────────────────────
  final ValueNotifier<bool> _aboutVisible   = ValueNotifier(false);
  final ValueNotifier<bool> _tarifVisible   = ValueNotifier(false);
  final ValueNotifier<bool> _contectVisible = ValueNotifier(false);

  // ── Section AnimationControllers ─────────────────────────────
  late final AnimationController _aboutAnim;
  late final AnimationController _tarifAnim;
  late final AnimationController _contectAnim;

  // ── Car Background AnimationController ───────────────────────
  late final AnimationController _carBgAnim;

  @override
  void initState() {
    super.initState();

    _aboutAnim   = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _tarifAnim   = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _contectAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));

    // Car bg: 18 seconds full loop — slow, cinematic
    _carBgAnim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();

    scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    _activeSection.dispose();
    _showScrollTop.dispose();
    _aboutVisible.dispose();
    _tarifVisible.dispose();
    _contectVisible.dispose();
    _aboutAnim.dispose();
    _tarifAnim.dispose();
    _contectAnim.dispose();
    _carBgAnim.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;
    final double offset = scrollController.offset;

    final String section;
    if (offset < 700)       section = 'HOME';
    else if (offset < 1500) section = 'ABOUT';
    else if (offset < 2300) section = 'TARIFF';
    else                    section = 'CONTACT';
    if (_activeSection.value != section) _activeSection.value = section;

    final bool show = offset > 500;
    if (_showScrollTop.value != show) _showScrollTop.value = show;

    if (offset > 400  && !_aboutVisible.value)   { _aboutVisible.value = true;   _aboutAnim.forward(); }
    if (offset > 1200 && !_tarifVisible.value)   { _tarifVisible.value = true;   _tarifAnim.forward(); }
    if (offset > 2000 && !_contectVisible.value) { _contectVisible.value = true; _contectAnim.forward(); }
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

  Future<void> _openWhatsApp() async {
    final url = Uri.parse(
      'https://wa.me/916380177563?text=${Uri.encodeComponent("Hello PKT Call Taxi, I need a cab booking!")}',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  // ── CALL BUTTON — dials 6380177563 ───────────────────────────
  Future<void> _makeCall() async {
    final url = Uri.parse('tel:+917667733771');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Widget _animatedSection({
    required AnimationController controller,
    required Widget child,
  }) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) => FadeTransition(
        opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: controller,
            curve: const Interval(0.0, 0.8, curve: Curves.easeOut)),
        ),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.08), end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: controller, curve: Curves.easeOutCubic,
          )),
          child: child,
        ),
      ),
    );
  }

  // ── Responsive breakpoints ────────────────────────────────────
  bool _isMobile(BuildContext context)  => MediaQuery.of(context).size.width < 600;
  bool _isTablet(BuildContext context)  => MediaQuery.of(context).size.width >= 600 && MediaQuery.of(context).size.width < 1024;
  bool _isDesktop(BuildContext context) => MediaQuery.of(context).size.width >= 1024;

  // ══════════════════════════════════════════════════════════════
  //  BUILD
  // ══════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final size   = MediaQuery.of(context).size;
    final mobile  = _isMobile(context);
    final tablet  = _isTablet(context);

    // FAB button sizing — responsive
    final double fabSize    = mobile ? 44 : (tablet ? 50 : 54);
    final double fabBottom  = mobile ? 24 : 30;
    final double fabLeftRight = mobile ? 16 : 30;
    final double fabIconSize = mobile ? 20 : (tablet ? 22 : 24);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Stack(
        children: [

          // ── LAYER 0: LUXURY CAR BACKGROUND (always on) ───────
          Positioned.fill(
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: _carBgAnim,
                builder: (_, __) => CustomPaint(
                  painter: LuxuryCarBgPainter(
                    progress: _carBgAnim.value,
                  ),
                  size: Size(size.width, size.height),
                ),
              ),
            ),
          ),

          // ── LAYER 1: MAIN SCROLL CONTENT ─────────────────────
          Positioned.fill(
            child: SingleChildScrollView(
              controller: scrollController,
              physics: const ClampingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 72),

                  RepaintBoundary(child: Homepage(key: homeKey)),

                  RepaintBoundary(
                    child: _animatedSection(
                      controller: _aboutAnim,
                      child: AboutPage(aboutKey: aboutKey),
                    ),
                  ),

                  RepaintBoundary(child: _buildSectionDivider()),

                  RepaintBoundary(
                    child: _animatedSection(
                      controller: _tarifAnim,
                      child: TarifPage(tarifkey: tarifkey),
                    ),
                  ),

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

          // ── LAYER 2: FIXED HEADER ────────────────────────────
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
                ),
              ),
            ),
          ),

          // ── LAYER 3: WHATSAPP BUTTON (left side) ─────────────
          Positioned(
            bottom: fabBottom,
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

          // ── LAYER 4: CALL BUTTON (center-left of right side) ──
          // Always visible — no scroll condition
          // Positioned between WhatsApp (left) and ScrollTop (right)
          Positioned(
            bottom: fabBottom,
            left: fabLeftRight + fabSize + (mobile ? 10 : 12),
            child: _CallButton(
              onTap: _makeCall,
              size: fabSize,
              iconSize: fabIconSize,
            ),
          ),

          // ── LAYER 5: SCROLL TO TOP (right side) ──────────────
          Positioned(
            bottom: fabBottom,
            right: fabLeftRight,
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
                      child: Icon(
                        Icons.keyboard_arrow_up_rounded,
                        color: const Color(0xFF0A0A0A),
                        size: fabIconSize + 2,
                      ),
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
              color: Color(0xFFC9A84C), shape: BoxShape.circle,
            ),
          ),
          Container(height: 0.5, width: 100, color: const Color(0x22C9A84C)),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  CALL BUTTON WIDGET
//  - Always visible (no scroll gate)
//  - Pulses gently to draw attention
//  - Gold ring matches PKT brand
//  - Dials tel:+916380177563
// ══════════════════════════════════════════════════════════════

class _CallButton extends StatefulWidget {
  final VoidCallback onTap;
  final double size;
  final double iconSize;

  const _CallButton({
    required this.onTap,
    required this.size,
    required this.iconSize,
  });

  @override
  State<_CallButton> createState() => _CallButtonState();
}

class _CallButtonState extends State<_CallButton>
    with SingleTickerProviderStateMixin {

  late final AnimationController _pulse;
  late final Animation<double> _ring;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: false);

    _ring = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: SizedBox(
        width: widget.size + 20,
        height: widget.size + 20,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Pulsing ring
            AnimatedBuilder(
              animation: _ring,
              builder: (_, __) {
                final double scale = 1.0 + _ring.value * 0.5;
                final double opacity = (1.0 - _ring.value).clamp(0, 1);
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Color.fromRGBO(201, 168, 76, opacity * 0.7),
                        width: 2,
                      ),
                    ),
                  ),
                );
              },
            ),

            // Main button
            Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: const Color(0xFFC9A84C),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0x44C9A84C)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33C9A84C),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                Icons.call_rounded,
                color: const Color(0xFF0A0A0A),
                size: widget.iconSize,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  LUXURY CAR BACKGROUND PAINTER
// ══════════════════════════════════════════════════════════════

class LuxuryCarBgPainter extends CustomPainter {
  final double progress;

  const LuxuryCarBgPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    _drawRoadLines(canvas, w, h);

    final double car1X = w * 0.65 + math.sin(progress * math.pi * 2) * w * 0.04;
    final double car1Y = h * 0.38 + math.cos(progress * math.pi * 2 * 0.7) * h * 0.025;
    _drawCar3D(canvas, car1X, car1Y, scale: 1.0, opacity: 0.09, goldOpacity: 0.18);

    final double car2Phase = (progress + 0.4) % 1.0;
    final double car2X = w * 0.18 + math.sin(car2Phase * math.pi * 2) * w * 0.03;
    final double car2Y = h * 0.62 + math.cos(car2Phase * math.pi * 2) * h * 0.02;
    _drawCar3D(canvas, car2X, car2Y, scale: 0.65, opacity: 0.07, goldOpacity: 0.13);

    final double car3Phase = (progress + 0.72) % 1.0;
    final double car3X = w * 0.82 + math.sin(car3Phase * math.pi * 2 * 1.3) * w * 0.05;
    final double car3Y = h * 0.78 + math.cos(car3Phase * math.pi * 2 * 1.3) * h * 0.015;
    _drawCar3D(canvas, car3X, car3Y, scale: 0.40, opacity: 0.06, goldOpacity: 0.10);

    _drawSpeedLines(canvas, w, h);
  }

  void _drawRoadLines(Canvas canvas, double w, double h) {
    final paint = Paint()
      ..color = const Color(0x08C9A84C)
      ..strokeWidth = 1.0;

    final double dashOffset = (progress * 120) % 60;

    for (double x = -dashOffset; x < w + 60; x += 60) {
      canvas.drawLine(Offset(x, h * 0.92), Offset(x + 35, h * 0.92), paint);
    }
    for (double x = -(dashOffset + 30) % 60; x < w + 60; x += 60) {
      canvas.drawLine(Offset(x, h * 0.96), Offset(x + 35, h * 0.96), paint);
    }
  }

  void _drawSpeedLines(Canvas canvas, double w, double h) {
    final paint = Paint()
      ..color = const Color(0x05C9A84C)
      ..strokeWidth = 0.5;

    final offsets = [0.15, 0.35, 0.55, 0.72, 0.88];
    for (int i = 0; i < offsets.length; i++) {
      final double yFrac = offsets[i];
      final double phase = (progress + i * 0.2) % 1.0;
      final double xStart = w * (phase - 0.3);
      final double len    = w * 0.25;
      canvas.drawLine(Offset(xStart, h * yFrac), Offset(xStart + len, h * yFrac), paint);
    }
  }

  void _drawCar3D(
    Canvas canvas,
    double cx,
    double cy, {
    required double scale,
    required double opacity,
    required double goldOpacity,
  }) {
    final double u = scale * 90;

    final bodyPaint = Paint()
      ..color = Color.fromRGBO(201, 168, 76, opacity.clamp(0, 1))
      ..style = PaintingStyle.stroke
      ..strokeWidth = scale * 1.2
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = Color.fromRGBO(201, 168, 76, (opacity * 0.3).clamp(0, 1))
      ..style = PaintingStyle.fill;

    final double gLeft   = cx - u * 0.85;
    final double gFront  = cy + u * 0.55;
    final double rLeft   = cx - u * 0.55;
    final double rRight  = cx + u * 0.30;
    final double rTop    = cy - u * 0.28;
    final double rTop2   = cy - u * 0.22;
    final double hRight  = cx + u * 0.55;
    final double hMid    = cy + u * 0.10;

    final bodyPath = Path();
    bodyPath.moveTo(gLeft, gFront);
    bodyPath.lineTo(gLeft, cy + u * 0.12);
    bodyPath.lineTo(rLeft, rTop + u * 0.05);
    bodyPath.lineTo(cx - u * 0.15, rTop);
    bodyPath.lineTo(rRight, rTop2);
    bodyPath.lineTo(cx + u * 0.52, cy - u * 0.02);
    bodyPath.lineTo(hRight, hMid);
    bodyPath.lineTo(cx + u * 0.55, gFront);
    bodyPath.lineTo(gLeft, gFront);
    bodyPath.close();

    canvas.drawPath(bodyPath, fillPaint);
    canvas.drawPath(bodyPath, bodyPaint);

    final wsPaint = Paint()
      ..color = Color.fromRGBO(201, 168, 76, (opacity * 0.5).clamp(0, 1))
      ..style = PaintingStyle.fill;

    final wsPath = Path();
    wsPath.moveTo(rLeft + u * 0.05,  rTop + u * 0.08);
    wsPath.lineTo(cx - u * 0.14,     rTop + u * 0.02);
    wsPath.lineTo(rRight - u * 0.02, rTop2 + u * 0.06);
    wsPath.lineTo(cx + u * 0.48,     cy - u * 0.01);
    wsPath.lineTo(rLeft + u * 0.05,  cy + u * 0.10);
    wsPath.close();
    canvas.drawPath(wsPath, wsPaint);

    final wPaint = Paint()
      ..color = Color.fromRGBO(201, 168, 76, (opacity * 0.9).clamp(0, 1))
      ..style = PaintingStyle.stroke
      ..strokeWidth = scale * 2.0;

    canvas.save();
    canvas.translate(cx + u * 0.28, gFront - u * 0.01);
    canvas.scale(1.0, 0.38);
    canvas.drawCircle(Offset.zero, u * 0.22, wPaint);
    canvas.restore();

    canvas.save();
    canvas.translate(cx - u * 0.52, gFront - u * 0.01);
    canvas.scale(1.0, 0.35);
    canvas.drawCircle(Offset.zero, u * 0.20, wPaint);
    canvas.restore();

    final hlGlow = Paint()
      ..color = Color.fromRGBO(201, 168, 76, goldOpacity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx + u * 0.48, cy + u * 0.08),
        width: u * 0.18, height: u * 0.08,
      ),
      hlGlow,
    );

    final beamPaint = Paint()
      ..color = Color.fromRGBO(201, 168, 76, goldOpacity * 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);

    final beamPath = Path();
    beamPath.moveTo(cx + u * 0.50, cy + u * 0.08);
    beamPath.lineTo(cx + u * 1.40, cy + u * 0.30);
    beamPath.lineTo(cx + u * 1.20, cy + u * 0.42);
    beamPath.close();
    canvas.drawPath(beamPath, beamPaint);

    final drlPaint = Paint()
      ..color = Color.fromRGBO(201, 168, 76, (goldOpacity * 1.2).clamp(0, 1))
      ..strokeWidth = scale * 1.0
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(cx + u * 0.40, cy + u * 0.04),
      Offset(cx + u * 0.56, cy + u * 0.06),
      drlPaint,
    );

    final grillPaint = Paint()
      ..color = Color.fromRGBO(201, 168, 76, (opacity * 0.6).clamp(0, 1))
      ..strokeWidth = scale * 0.6;

    for (int i = 0; i < 3; i++) {
      final double gx = cx + u * (0.12 + i * 0.12);
      canvas.drawLine(
        Offset(gx, cy + u * 0.24),
        Offset(gx + u * 0.04, cy + u * 0.42),
        grillPaint,
      );
    }

    final refPaint = Paint()
      ..color = Color.fromRGBO(255, 255, 255, opacity * 0.4)
      ..strokeWidth = scale * 0.5
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(cx - u * 0.30, rTop + u * 0.03),
      Offset(cx + u * 0.10, rTop2 + u * 0.03),
      refPaint,
    );
  }

  @override
  bool shouldRepaint(LuxuryCarBgPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

// ══════════════════════════════════════════════════════════════
//  WHATSAPP ICON PAINTER
// ══════════════════════════════════════════════════════════════
class _WhatsAppPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2;
    final double r  = size.width * 0.44;

    canvas.drawCircle(Offset(cx, cy), r,
      Paint()..color = Colors.white..style = PaintingStyle.fill);

    canvas.drawCircle(Offset(cx, cy), r * 0.85,
      Paint()..color = const Color(0xFF25D366)..style = PaintingStyle.fill);

    final path = Path()
      ..moveTo(size.width * 0.33, size.height * 0.27)
      ..cubicTo(
        size.width * 0.28, size.height * 0.40,
        size.width * 0.28, size.height * 0.52,
        size.width * 0.40, size.height * 0.60,
      )
      ..cubicTo(
        size.width * 0.52, size.height * 0.70,
        size.width * 0.62, size.height * 0.72,
        size.width * 0.73, size.height * 0.66,
      );

    canvas.drawPath(path,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.09
        ..strokeCap = StrokeCap.round);

    final tailPath = Path()
      ..moveTo(cx + r * 0.3,  cy + r * 0.7)
      ..lineTo(cx + r * 0.1,  cy + r * 1.0)
      ..lineTo(cx + r * 0.7,  cy + r * 0.65)
      ..close();

    canvas.drawPath(tailPath,
      Paint()..color = Colors.white..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}