import 'package:flutter/material.dart';
import 'package:pktwebsite/screens/contectpage.dart';
import 'package:pktwebsite/screens/tarifpage.dart';
import 'aboutpage.dart';
import 'homepage.dart';
import 'header.dart';

// ══════════════════════════════════════════════════════════════
//  OPTIMIZED WEBPAGE — PKT CALL TAXI
//  Lag Fix:
//  1. _onScroll setState → removed, ValueNotifier use pannren
//  2. AnimatedPositioned → removed, ValueListenableBuilder use
//  3. RepaintBoundary → every section wrap pannren
//  4. ClampingScrollPhysics → web ku smoothest
//  5. Header separate ValueListenableBuilder — no full rebuild
// ══════════════════════════════════════════════════════════════

class Webpage extends StatefulWidget {
  const Webpage({super.key});

  @override
  State<Webpage> createState() => _WebpageState();
}

class _WebpageState extends State<Webpage> {

  // ── Keys (UNTOUCHED) ─────────────────────────────────────────
  final aboutKey   = GlobalKey();
  final homeKey    = GlobalKey();
  final tarifkey   = GlobalKey();
  final contectkey = GlobalKey();

  final ScrollController scrollController = ScrollController();

  // ── ValueNotifiers — NO setState on scroll! ──────────────────
  // Only the specific widget rebuilds, not the entire page
  final ValueNotifier<String> _activeSection  = ValueNotifier('HOME');
  final ValueNotifier<bool>   _showScrollTop  = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    _activeSection.dispose();
    _showScrollTop.dispose();
    super.dispose();
  }

  // ── Scroll Listener — Zero setState! ─────────────────────────
  void _onScroll() {
    if (!scrollController.hasClients) return;
    final double offset = scrollController.offset;

    // Active section detect — only notifier update, no rebuild
    final String section;
    if (offset < 700) {
      section = 'HOME';
    } else if (offset < 1500) {
      section = 'ABOUT';
    } else if (offset < 2300) {
      section = 'TARIFF';
    } else {
      section = 'CONTACT';
    }
    if (_activeSection.value != section) {
      _activeSection.value = section; // Only header rebuilds!
    }

    // Scroll to top button — only button rebuilds!
    final bool show = offset > 500;
    if (_showScrollTop.value != show) {
      _showScrollTop.value = show;
    }
  }

  // ── Scroll To (UNTOUCHED) ─────────────────────────────────────
  void _scrollTo(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  // ══════════════════════════════════════════════════════════════
  //  BUILD
  // ══════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Stack(
        children: [

          // ── 1. MAIN SCROLL CONTENT ──────────────────────────
          Positioned.fill(
            child: SingleChildScrollView(
              controller: scrollController,
              // ClampingScrollPhysics = web ku best, no rubber band
              physics: const ClampingScrollPhysics(),
              child: Column(
                children: [
                  // Header space
                  const SizedBox(height: 72),

                  // ── Each section RepaintBoundary wrap ──
                  // Scroll panna other sections repaint aagaadu!

                  RepaintBoundary(
                    child: Homepage(key: homeKey),
                  ),

                  RepaintBoundary(
                    child: AboutPage(aboutKey: aboutKey),
                  ),

                  // Gold section divider
                  RepaintBoundary(
                    child: _buildSectionDivider(),
                  ),

                  RepaintBoundary(
                    child: TarifPage(tarifkey: tarifkey),
                  ),

                  RepaintBoundary(
                    child: Contectpage(
                      contectkey:  contectkey,
                      onHomeTap:   () => _scrollTo(homeKey),
                      onAboutTap:  () => _scrollTo(aboutKey),
                      onTarifTap:  () => _scrollTo(tarifkey),
                      onContactTap: () => _scrollTo(contectkey),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── 2. FIXED HEADER — only rebuilds on section change ──
          Positioned(
            top: 0, left: 0, right: 0,
            child: RepaintBoundary(
              child: ValueListenableBuilder<String>(
                valueListenable: _activeSection,
                builder: (_, section, __) => Header(
                  activePage:     section,
                  onHomeTap:      () => _scrollTo(homeKey),
                  onAboutTap:     () => _scrollTo(aboutKey),
                  onTarifTap:     () => _scrollTo(tarifkey),
                  onContectTap:   () => _scrollTo(contectkey),
                ),
              ),
            ),
          ),

          // ── 3. SCROLL TO TOP — only rebuilds when show/hide ──
          Positioned(
            bottom: 30, right: 30,
            child: ValueListenableBuilder<bool>(
              valueListenable: _showScrollTop,
              builder: (_, show, __) => AnimatedOpacity(
                opacity: show ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: AnimatedScale(
                  scale: show ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  child: _buildScrollTopButton(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Scroll To Top Button ──────────────────────────────────────
  Widget _buildScrollTopButton() {
    return GestureDetector(
      onTap: () => scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutCubic,
      ),
      child: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFFC9A84C),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0x44C9A84C)),
        ),
        child: const Icon(
          Icons.keyboard_arrow_up_rounded,
          color: Color(0xFF0A0A0A),
          size: 22,
        ),
      ),
    );
  }

  // ── Gold Section Divider ──────────────────────────────────────
  Widget _buildSectionDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 50),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(height: 0.5, width: 100,
              color: const Color(0x22C9A84C)),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            width: 6, height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFFC9A84C),
              shape: BoxShape.circle,
            ),
          ),
          Container(height: 0.5, width: 100,
              color: const Color(0x22C9A84C)),
        ],
      ),
    );
  }
}