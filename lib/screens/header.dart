import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';

class Header extends StatelessWidget {
  final VoidCallback onHomeTap;
  final VoidCallback onTarifTap;
  final VoidCallback onContectTap;
  final VoidCallback onAboutTap;
  final VoidCallback onGetAppTap;
  final String activePage;

  static const Color kBg          = Color(0xFF0A0A0A);
  static const Color kGold        = Color(0xFFC9A84C);
  static const Color kGoldDim     = Color(0xFF7A6030);
  static const Color kTextPrimary = Color(0xFFF0E6C8);
  static const Color kTextMuted   = Color(0xFF6A5C40);
  static const Color kBorder      = Color(0x22C9A84C);
  static const Color kPanel       = Color(0xFF111111);

  const Header({
    super.key,
    required this.onHomeTap,
    required this.onTarifTap,
    required this.onContectTap,
    required this.onAboutTap,
    required this.onGetAppTap,
    this.activePage = 'HOME',
  });

  bool _isMobile(BuildContext ctx) => MediaQuery.of(ctx).size.width < 600;
  bool _isTablet(BuildContext ctx) =>
      MediaQuery.of(ctx).size.width >= 600 &&
      MediaQuery.of(ctx).size.width < 1024;

  @override
  Widget build(BuildContext context) {
    final mobile = _isMobile(context);
    final tablet = _isTablet(context);

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 72,
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Color(0xF0090909),
            border: Border(bottom: BorderSide(color: kBorder, width: 1)),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: mobile ? 16 : (tablet ? 24 : 48),
          ),
          child: Row(children: [
            _buildLogo(),
            const Spacer(),
            if (mobile) ...[
              _buildGetAppButton(context, compact: true),
              const SizedBox(width: 10),
              _buildHamburger(context),
            ] else if (tablet) ...[
              _buildNavButton('HOME',   onHomeTap,  context, compact: true),
              _buildNavButton('TARIFF', onTarifTap, context, compact: true),
              const SizedBox(width: 12),
              _buildGetAppButton(context, compact: true),
              const SizedBox(width: 12),
              _buildBookingButton(compact: true),
            ] else ...[
              _buildNavButton('HOME',   onHomeTap,  context),
              _buildNavButton('TARIFF', onTarifTap, context),
              const SizedBox(width: 28),
              _buildGetAppButton(context),
              const SizedBox(width: 16),
              _buildBookingButton(),
            ],
          ]),
        ),
      ),
    );
  }

  // ── LOGO ────────────────────────────────────────────────────

  Widget _buildLogo() {
    return InkWell(
      onTap: () => Get.toNamed('/dashboard'),
      borderRadius: BorderRadius.circular(10),
      hoverColor: kGold.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
            height: 44, width: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: kBorder, width: 1),
              color: const Color(0xFF161616),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: Image.asset(
                'assets/pktlogo.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.local_taxi, color: kGold, size: 22),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Text('PKT', style: TextStyle(
                  color: kTextPrimary, fontSize: 18,
                  fontWeight: FontWeight.w900, letterSpacing: 3, height: 1,
                )),
                const SizedBox(width: 3),
                Container(
                  width: 5, height: 5,
                  decoration: const BoxDecoration(
                    color: kGold, shape: BoxShape.circle),
                ),
              ]),
              const SizedBox(height: 3),
              const Text('CALL TAXI', style: TextStyle(
                color: kTextPrimary, fontSize: 7,
                fontWeight: FontWeight.w700, letterSpacing: 4,
              )),
            ],
          ),
        ]),
      ),
    );
  }

  // ── NAV BUTTON ──────────────────────────────────────────────

  Widget _buildNavButton(
    String title,
    VoidCallback onTap,
    BuildContext context, {
    bool compact = false,
  }) {
    final bool isActive = activePage == title;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 18),
      child: InkWell(
        onTap: onTap,
        mouseCursor: SystemMouseCursors.click,
        hoverColor: Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: TextStyle(
              color: isActive ? kGold : kTextMuted,
              fontSize: compact ? 10 : 11,
              fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
              letterSpacing: compact ? 1.2 : 2,
            )),
            const SizedBox(height: 5),
            AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              height: 1.5,
              width: isActive ? 16.0 : 0.0,
              decoration: BoxDecoration(
                color: kGold,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── GET APP BUTTON ───────────────────────────────────────────

  Widget _buildGetAppButton(BuildContext context, {bool compact = false}) {
    return _GetAppButtonAnimated(
      compact: compact,
      onTap: onGetAppTap,
    );
  }

  // ── BOOK NOW BUTTON ─────────────────────────────────────────

  Widget _buildBookingButton({bool compact = false}) {
    return _BookNowButtonAnimated(
      compact: compact,
      onTap: onHomeTap,
    );
  }

  // ── MOBILE HAMBURGER ─────────────────────────────────────────

  Widget _buildHamburger(BuildContext context) {
    return GestureDetector(
      onTap: () => _showMobileMenu(context),
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFF161616),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: kBorder),
        ),
        child: const Icon(Icons.menu_rounded, color: kGold, size: 18),
      ),
    );
  }

  void _showMobileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _MobileMenuSheet(
        activePage:  activePage,
        onHomeTap:   () { Navigator.pop(context); onHomeTap(); },
        onTarifTap:  () { Navigator.pop(context); onTarifTap(); },
        onGetAppTap: () { Navigator.pop(context); onGetAppTap(); },
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  GET APP — ANIMATED BUTTON (shimmer + pulse)
// ══════════════════════════════════════════════════════════════

class _GetAppButtonAnimated extends StatefulWidget {
  final bool compact;
  final VoidCallback onTap;
  const _GetAppButtonAnimated({required this.compact, required this.onTap});

  @override
  State<_GetAppButtonAnimated> createState() => _GetAppButtonAnimatedState();
}

class _GetAppButtonAnimatedState extends State<_GetAppButtonAnimated>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _shimmer;
  late Animation<double> _pulse;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
    _shimmer = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.7, curve: Curves.easeInOut)),
    );
    _pulse = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.6, 1.0, curve: Curves.easeInOut)),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final compact = widget.compact;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 38,
            padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 18),
            decoration: BoxDecoration(
              color: _hovered
                  ? const Color(0xFFC9A84C).withOpacity(0.12)
                  : const Color(0xFF111111),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: _hovered
                    ? const Color(0xFFC9A84C).withOpacity(0.8)
                    : const Color(0xFFC9A84C).withOpacity(0.3),
                width: _hovered ? 1.2 : 1.0,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // shimmer sweep
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.15,
                      child: Transform.translate(
                        offset: Offset(_shimmer.value * 80, 0),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                const Color(0xFFC9A84C).withOpacity(0.9),
                                Colors.transparent,
                              ],
                              stops: const [0.3, 0.5, 0.7],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // content
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    // pulsing dot
                    Container(
                      width: 6, height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFC9A84C).withOpacity(_pulse.value),
                      ),
                    ),
                    const SizedBox(width: 7),
                    const Icon(
                      Icons.download_rounded,
                      color: Color(0xFFC9A84C),
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      compact ? 'APP' : 'GET APP',
                      style: const TextStyle(
                        color: Color(0xFFC9A84C),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.8,
                      ),
                    ),
                    if (!compact) ...[
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Color(0xFFC9A84C),
                        size: 9,
                      ),
                    ],
                  ]),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  BOOK NOW — ANIMATED BUTTON (hover lift + gold glow)
// ══════════════════════════════════════════════════════════════

class _BookNowButtonAnimated extends StatefulWidget {
  final bool compact;
  final VoidCallback onTap;
  const _BookNowButtonAnimated({required this.compact, required this.onTap});

  @override
  State<_BookNowButtonAnimated> createState() => _BookNowButtonAnimatedState();
}

class _BookNowButtonAnimatedState extends State<_BookNowButtonAnimated>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _glow;
  bool _hovered  = false;
  bool _pressed  = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _glow = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final compact = widget.compact;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() { _hovered = false; _pressed = false; }),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown:   (_) => setState(() => _pressed = true),
        onTapUp:     (_) => setState(() => _pressed = false),
        onTapCancel: ()  => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _glow,
          builder: (_, __) => AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            transform: Matrix4.translationValues(
              0, _pressed ? 1 : (_hovered ? -2 : 0), 0),
            height: 38,
            padding: EdgeInsets.symmetric(horizontal: compact ? 16 : 24),
            decoration: BoxDecoration(
              color: const Color(0xFFC9A84C),
              borderRadius: BorderRadius.circular(6),
              boxShadow: _hovered
                  ? [
                      BoxShadow(
                        color: const Color(0xFFC9A84C).withOpacity(_glow.value * 0.5),
                        blurRadius: 16,
                        spreadRadius: 1,
                      ),
                    ]
                  : [],
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(
                compact ? 'BOOK' : 'BOOK NOW',
                style: const TextStyle(
                  color: Color(0xFF0A0A0A),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(width: 8),
              AnimatedSlide(
                offset: _hovered ? const Offset(0.2, 0) : Offset.zero,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                child: const Icon(
                  Icons.arrow_forward_ios,
                  size: 11,
                  color: Color(0xFF0A0A0A),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  MOBILE MENU SHEET
// ══════════════════════════════════════════════════════════════

class _MobileMenuSheet extends StatelessWidget {
  final String       activePage;
  final VoidCallback onHomeTap;
  final VoidCallback onTarifTap;
  final VoidCallback onGetAppTap;

  static const Color kBg          = Color(0xFF0A0A0A);
  static const Color kPanel       = Color(0xFF111111);
  static const Color kGold        = Color(0xFFC9A84C);
  static const Color kTextPrimary = Color(0xFFF0E6C8);
  static const Color kTextMuted   = Color(0xFF6A5C40);
  static const Color kBorder      = Color(0x22C9A84C);

  const _MobileMenuSheet({
    required this.activePage,
    required this.onHomeTap,
    required this.onTarifTap,
    required this.onGetAppTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: kPanel,
        borderRadius: BorderRadius.only(
          topLeft:  Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        border: Border(
          top:   BorderSide(color: kBorder),
          left:  BorderSide(color: kBorder),
          right: BorderSide(color: kBorder),
        ),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [

        // drag handle
        Container(
          margin: const EdgeInsets.only(top: 12, bottom: 8),
          width: 36, height: 3,
          decoration: BoxDecoration(
            color: kBorder, borderRadius: BorderRadius.circular(2)),
        ),

        // label
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
          child: Row(children: [
            Container(width: 6, height: 6,
              decoration: const BoxDecoration(
                color: kGold, shape: BoxShape.circle)),
            const SizedBox(width: 10),
            const Text('NAVIGATION', style: TextStyle(
              color: kGold, fontSize: 9,
              fontWeight: FontWeight.w900, letterSpacing: 3,
            )),
          ]),
        ),
        const SizedBox(height: 8),

        _menuItem(icon: Icons.home_outlined,        label: 'HOME',    isActive: activePage == 'HOME',   onTap: onHomeTap),
        _menuItem(icon: Icons.receipt_long_outlined, label: 'TARIFF',  isActive: activePage == 'TARIFF', onTap: onTarifTap),
        _menuItem(icon: Icons.download_rounded,      label: 'GET APP', isActive: false,                  onTap: onGetAppTap, isAppItem: true),

        const SizedBox(height: 12),

        // BOOK NOW
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: SizedBox(
            width: double.infinity, height: 48,
            child: ElevatedButton(
              onPressed: onHomeTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: kGold, foregroundColor: kBg,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.directions_car, size: 16, color: kBg),
                  SizedBox(width: 10),
                  Text('BOOK NOW', style: TextStyle(
                    color: kBg, fontSize: 13,
                    fontWeight: FontWeight.w900, letterSpacing: 2.5,
                  )),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: MediaQuery.of(context).padding.bottom),
      ]),
    );
  }

  Widget _menuItem({
    required IconData     icon,
    required String       label,
    required bool         isActive,
    required VoidCallback onTap,
    bool isAppItem = false,
  }) {
    final Color accent = kGold;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: (isActive || isAppItem)
              ? accent.withOpacity(0.10) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: (isActive || isAppItem)
                ? accent.withOpacity(0.35) : Colors.transparent,
          ),
        ),
        child: Row(children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: (isActive || isAppItem)
                  ? accent.withOpacity(0.20)
                  : const Color(0xFF161616),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: (isActive || isAppItem)
                    ? accent.withOpacity(0.4) : kBorder,
              ),
            ),
            child: Icon(icon,
              color: (isActive || isAppItem) ? accent : kTextMuted,
              size: 16),
          ),
          const SizedBox(width: 14),
          Text(label, style: TextStyle(
            color: (isActive || isAppItem) ? accent : kTextPrimary,
            fontSize: 14,
            fontWeight: (isActive || isAppItem)
                ? FontWeight.w800 : FontWeight.w500,
            letterSpacing: 2,
          )),
          const Spacer(),
          if (isActive || isAppItem)
            Container(width: 6, height: 6,
              decoration: BoxDecoration(
                color: accent, shape: BoxShape.circle)),
        ]),
      ),
    );
  }
}