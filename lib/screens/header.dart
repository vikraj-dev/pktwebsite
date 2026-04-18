import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';

// ══════════════════════════════════════════════════════════════
//  LUXURY BLACK & GOLD HEADER — PKT CALL TAXI
//  Logic & Callbacks: 100% untouched
//  UI: Full Black & Gold luxury redesign
// ══════════════════════════════════════════════════════════════

class Header extends StatelessWidget {
  final VoidCallback onAboutTap;
  final VoidCallback onHomeTap;
  final VoidCallback onTarifTap;
  final VoidCallback onContectTap;
  final String activePage;

  // ── Luxury Color Palette (matches Homepage) ───────────────────
  static const Color kBg          = Color(0xFF0A0A0A);
  static const Color kGold        = Color(0xFFC9A84C);
  static const Color kGoldDim     = Color(0xFF7A6030);
  static const Color kTextPrimary = Color(0xFFF0E6C8);
  static const Color kTextMuted   = Color(0xFF6A5C40);
  static const Color kBorder      = Color(0x22C9A84C);
  static const Color kBorderHov   = Color(0x55C9A84C);

  const Header({
    super.key,
    required this.onAboutTap,
    required this.onHomeTap,
    required this.onTarifTap,
    required this.onContectTap,
    this.activePage = 'HOME',
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 72,
          width: double.infinity,
          decoration: BoxDecoration(
            // Deep black with very subtle gold tint
            color: const Color(0xF0090909),
            border: const Border(
              bottom: BorderSide(color: kBorder, width: 1),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 48),
          child: Row(
            children: [
              _buildLogo(),
              const Spacer(),
              _buildNavButton('HOME',    onHomeTap),
              _buildNavButton('ABOUT',   onAboutTap),
              _buildNavButton('TARIFF',  onTarifTap),
              _buildNavButton('CONTACT', onContectTap),
              const SizedBox(width: 36),
              _buildBookingButton(),
            ],
          ),
        ),
      ),
    );
  }

  // ── Logo ──────────────────────────────────────────────────────
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
            // Logo image container with gold border
            Container(
              height: 44,
              width: 44,
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
                    Icons.local_taxi,
                    color: kGold,
                    size: 22,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Brand name
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // PKT with gold accent dot
                Row(
                  children: [
                    const Text(
                      'PKT',
                      style: TextStyle(
                        color: kTextPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 3,
                        height: 1,
                      ),
                    ),
                    const SizedBox(width: 3),
                    // Tiny gold dot accent
                    Container(
                      width: 5, height: 5,
                      decoration: const BoxDecoration(
                        color: kGold, shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                const Text(
                  'CALL TAXI',
                  style: TextStyle(
                    color: kGoldDim,
                    fontSize: 7,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 4,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Nav Button ────────────────────────────────────────────────
  Widget _buildNavButton(String title, VoidCallback onTap) {
    final bool isActive = activePage == title;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
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
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 5),
            // Gold active underline indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              height: 1.5,
              width: isActive ? 20.0 : 0.0,
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

  // ── Book Now Button ───────────────────────────────────────────
  Widget _buildBookingButton() {
    return ElevatedButton(
      onPressed: onHomeTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: kGold,
        foregroundColor: kBg,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Text(
            'BOOK NOW',
            style: TextStyle(
              color: Color(0xFF0A0A0A),
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          SizedBox(width: 10),
          Icon(Icons.arrow_forward_ios, size: 11, color: Color(0xFF0A0A0A)),
        ],
      ),
    );
  }
}