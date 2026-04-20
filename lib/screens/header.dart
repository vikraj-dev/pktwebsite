import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';

// ══════════════════════════════════════════════════════════════
//  LUXURY BLACK & GOLD HEADER — PKT CALL TAXI
//  Logic & Callbacks: 100% untouched
//  UI: Full Black & Gold luxury redesign
//  ADDED: Responsive Mobile / Tablet / Desktop
//         Mobile → Hamburger drawer menu
//         Tablet → Compact nav (no labels, icons only)
//         Desktop → Original full nav
// ══════════════════════════════════════════════════════════════

class Header extends StatelessWidget {
  final VoidCallback onAboutTap;
  final VoidCallback onHomeTap;
  final VoidCallback onTarifTap;
  final VoidCallback onContectTap;
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
    required this.onAboutTap,
    required this.onHomeTap,
    required this.onTarifTap,
    required this.onContectTap,
    this.activePage = 'HOME',
  });

  bool _isMobile(BuildContext ctx)  => MediaQuery.of(ctx).size.width < 600;
  bool _isTablet(BuildContext ctx)  => MediaQuery.of(ctx).size.width >= 600 && MediaQuery.of(ctx).size.width < 1024;
  bool _isDesktop(BuildContext ctx) => MediaQuery.of(ctx).size.width >= 1024;

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
            border: Border(
              bottom: BorderSide(color: kBorder, width: 1),
            ),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: mobile ? 16 : (tablet ? 24 : 48),
          ),
          child: Row(
            children: [
              _buildLogo(),
              const Spacer(),

              if (mobile) ...[
                // ── Mobile: Book now compact + hamburger ──────
                _buildCompactBookButton(context),
                const SizedBox(width: 10),
                _buildHamburger(context),
              ] else if (tablet) ...[
                // ── Tablet: nav text compact + book button ────
                _buildNavButton('HOME',    onHomeTap,    compact: true),
                _buildNavButton('ABOUT',   onAboutTap,   compact: true),
                _buildNavButton('TARIFF',  onTarifTap,   compact: true),
                _buildNavButton('CONTACT', onContectTap, compact: true),
                const SizedBox(width: 16),
                _buildBookingButton(compact: true),
              ] else ...[
                // ── Desktop: full original nav ─────────────────
                _buildNavButton('HOME',    onHomeTap),
                _buildNavButton('ABOUT',   onAboutTap),
                _buildNavButton('TARIFF',  onTarifTap),
                _buildNavButton('CONTACT', onContectTap),
                const SizedBox(width: 36),
                _buildBookingButton(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  LOGO
  // ══════════════════════════════════════════════════════════════

  Widget _buildLogo() {
    return InkWell(
      onTap: () => Get.toNamed('/dashboard'),
      borderRadius: BorderRadius.circular(10),
      hoverColor: kGold.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
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
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.local_taxi, color: kGold, size: 22,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Text(
                    'PKT',
                    style: TextStyle(
                      color: kTextPrimary, fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3, height: 1,
                    ),
                  ),
                  const SizedBox(width: 3),
                  Container(
                    width: 5, height: 5,
                    decoration: const BoxDecoration(
                      color: kGold, shape: BoxShape.circle,
                    ),
                  ),
                ]),
                const SizedBox(height: 3),
                const Text(
                  'CALL TAXI',
                  style: TextStyle(
                    color: kGoldDim, fontSize: 7,
                    fontWeight: FontWeight.w700, letterSpacing: 4,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  NAV BUTTON (desktop full / tablet compact)
  // ══════════════════════════════════════════════════════════════

  Widget _buildNavButton(String title, VoidCallback onTap, {bool compact = false}) {
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
            Text(
              title,
              style: TextStyle(
                color: isActive ? kGold : kTextMuted,
                fontSize: compact ? 10 : 11,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
                letterSpacing: compact ? 1.2 : 2,
              ),
            ),
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

  // ══════════════════════════════════════════════════════════════
  //  BOOK NOW BUTTON
  // ══════════════════════════════════════════════════════════════

  Widget _buildBookingButton({bool compact = false}) {
    return ElevatedButton(
      onPressed: onHomeTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: kGold,
        foregroundColor: kBg,
        elevation: 0,
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 16 : 24,
          vertical: 14,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
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
          const Icon(Icons.arrow_forward_ios, size: 11, color: Color(0xFF0A0A0A)),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  MOBILE: Compact icon-only book button
  // ══════════════════════════════════════════════════════════════

  Widget _buildCompactBookButton(BuildContext context) {
    return GestureDetector(
      onTap: onHomeTap,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: kGold,
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Center(
          child: Text(
            'BOOK',
            style: TextStyle(
              color: Color(0xFF0A0A0A),
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  MOBILE: Hamburger → Bottom Sheet Drawer
  // ══════════════════════════════════════════════════════════════

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
        activePage:   activePage,
        onHomeTap:    () { Navigator.pop(context); onHomeTap(); },
        onAboutTap:   () { Navigator.pop(context); onAboutTap(); },
        onTarifTap:   () { Navigator.pop(context); onTarifTap(); },
        onContectTap: () { Navigator.pop(context); onContectTap(); },
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  MOBILE MENU BOTTOM SHEET
// ══════════════════════════════════════════════════════════════

class _MobileMenuSheet extends StatelessWidget {
  final String activePage;
  final VoidCallback onHomeTap;
  final VoidCallback onAboutTap;
  final VoidCallback onTarifTap;
  final VoidCallback onContectTap;

  static const Color kBg          = Color(0xFF0A0A0A);
  static const Color kPanel       = Color(0xFF111111);
  static const Color kGold        = Color(0xFFC9A84C);
  static const Color kGoldDim     = Color(0xFF7A6030);
  static const Color kTextPrimary = Color(0xFFF0E6C8);
  static const Color kTextMuted   = Color(0xFF6A5C40);
  static const Color kBorder      = Color(0x22C9A84C);

  const _MobileMenuSheet({
    required this.activePage,
    required this.onHomeTap,
    required this.onAboutTap,
    required this.onTarifTap,
    required this.onContectTap,
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 36, height: 3,
            decoration: BoxDecoration(
              color: kBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header row inside sheet
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
            child: Row(children: [
              Container(
                width: 6, height: 6,
                decoration: const BoxDecoration(
                  color: kGold, shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'NAVIGATION',
                style: TextStyle(
                  color: kGold, fontSize: 9,
                  fontWeight: FontWeight.w900, letterSpacing: 3,
                ),
              ),
            ]),
          ),

          const SizedBox(height: 8),

          // Nav items
          _menuItem(
            icon: Icons.home_outlined,
            label: 'HOME',
            isActive: activePage == 'HOME',
            onTap: onHomeTap,
          ),
          _menuItem(
            icon: Icons.info_outline,
            label: 'ABOUT',
            isActive: activePage == 'ABOUT',
            onTap: onAboutTap,
          ),
          _menuItem(
            icon: Icons.receipt_long_outlined,
            label: 'TARIFF',
            isActive: activePage == 'TARIFF',
            onTap: onTarifTap,
          ),
          _menuItem(
            icon: Icons.phone_outlined,
            label: 'CONTACT',
            isActive: activePage == 'CONTACT',
            onTap: onContectTap,
          ),

          // Bottom safe area
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: onHomeTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kGold,
                  foregroundColor: kBg,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.directions_car, size: 16, color: kBg),
                    SizedBox(width: 10),
                    Text(
                      'BOOK NOW',
                      style: TextStyle(
                        color: kBg,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Device bottom padding
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isActive ? kGold.withOpacity(0.10) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? kGold.withOpacity(0.35) : Colors.transparent,
          ),
        ),
        child: Row(children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: isActive
                  ? kGold.withOpacity(0.20)
                  : const Color(0xFF161616),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isActive ? kGold.withOpacity(0.4) : kBorder,
              ),
            ),
            child: Icon(icon,
              color: isActive ? kGold : kTextMuted, size: 16),
          ),
          const SizedBox(width: 14),
          Text(
            label,
            style: TextStyle(
              color: isActive ? kGold : kTextPrimary,
              fontSize: 14,
              fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
              letterSpacing: 2,
            ),
          ),
          const Spacer(),
          if (isActive)
            Container(
              width: 6, height: 6,
              decoration: const BoxDecoration(
                color: kGold, shape: BoxShape.circle,
              ),
            ),
        ]),
      ),
    );
  }
}