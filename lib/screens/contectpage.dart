import 'package:flutter/material.dart';

// ══════════════════════════════════════════════════════════════
//  LUXURY BLACK & GOLD CONTACT PAGE — PKT CALL TAXI
//  Logic & Callbacks: 100% untouched
//  UI: Full Black & Gold luxury redesign
// ══════════════════════════════════════════════════════════════

class Contectpage extends StatelessWidget {
  final Key? contectkey;
  final VoidCallback onHomeTap;
  final VoidCallback onAboutTap;
  final VoidCallback onTarifTap;
  final VoidCallback onContactTap;

  // ── Luxury Color Palette ──────────────────────────────────────
  static const Color kBg          = Color(0xFF0A0A0A);
  static const Color kPanel       = Color(0xFF111111);
  static const Color kCardBg      = Color(0xFF161616);
  static const Color kGold        = Color(0xFFC9A84C);
  static const Color kGoldDim     = Color(0xFF7A6030);
  static const Color kTextPrimary = Color(0xFFF0E6C8);
  static const Color kTextMuted   = Color(0xFF6A5C40);
  static const Color kBorder      = Color(0x22C9A84C);
  static const Color kBorderHov   = Color(0x55C9A84C);

  const Contectpage({
    super.key,
    this.contectkey,
    required this.onHomeTap,
    required this.onAboutTap,
    required this.onTarifTap,
    required this.onContactTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: contectkey,
      width: double.infinity,
      color: kBg,
      child: Column(
        children: [
          // ── Top gold divider line ───────────────────────────
          Container(height: 1, color: kBorder),

          // ── Main footer content ─────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 60),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── 1. Brand + Address ──────────────────
                    _buildBrandColumn(),

                    // ── 2. Quick Links ──────────────────────
                    _buildFooterColumn(
                      title: 'Quick Links',
                      children: [
                        _buildFooterLink('Home',         onHomeTap),
                        _buildFooterLink('About Us',     onAboutTap),
                        _buildFooterLink('Tariff Plan',  onTarifTap),
                        _buildFooterLink('Contact',      onContactTap),
                      ],
                    ),

                    // ── 3. Contact Info ─────────────────────
                    _buildContactColumn(),
                  ],
                ),
              ),
            ),
          ),

          // ── Bottom copyright bar ────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 60),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: kBorder)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Logo mark small
                Row(children: [
                  Container(
                    width: 24, height: 24,
                    decoration: BoxDecoration(
                      color: kGold,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(Icons.directions_car, color: kBg, size: 14),
                  ),
                  const SizedBox(width: 10),
                  const Text('PKT CALL TAXI', style: TextStyle(
                    color: kGold, fontSize: 11,
                    fontWeight: FontWeight.w800, letterSpacing: 2,
                  )),
                ]),
                const Text(
                  '© 2026 PKT Call Taxi · All Rights Reserved',
                  style: TextStyle(color: kTextMuted, fontSize: 11, letterSpacing: 0.5),
                ),
                Row(children: [
                  const Text('Made with ', style: TextStyle(color: kTextMuted, fontSize: 11)),
                  const Icon(Icons.favorite, color: kGold, size: 11),
                  const Text(' in Tamil Nadu', style: TextStyle(color: kTextMuted, fontSize: 11)),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Brand + Address Column ────────────────────────────────────
  Widget _buildBrandColumn() {
    return SizedBox(
      width: 320,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo
          Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: kGold,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.directions_car, color: kBg, size: 22),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('PKT', style: TextStyle(
                  color: kTextPrimary, fontSize: 18,
                  fontWeight: FontWeight.w900, letterSpacing: 3,
                )),
                Text('CALL TAXI', style: TextStyle(
                  color: kGoldDim, fontSize: 7,
                  fontWeight: FontWeight.w700, letterSpacing: 4,
                )),
              ],
            ),
          ]),

          const SizedBox(height: 28),

          // Address text
          const Text(
            'We, PKT Call Taxi, situated at Pattukkottai, Tamil Nadu, have a profound understanding of our consumers travel needs and preferences. We aim to offer individuals as well as corporate a wide range of cars on hire.',
            style: TextStyle(
              color: kTextMuted, fontSize: 13,
              height: 1.9, letterSpacing: 0.3,
            ),
          ),

          const SizedBox(height: 28),

          // Phone number
          

          const SizedBox(height: 28),

          // Social / badge row
          Row(children: [
            _buildBadge(Icons.verified, '4.9★ Rated'),
            const SizedBox(width: 10),
            _buildBadge(Icons.access_time, '24/7 Service'),
          ]),
        ],
      ),
    );
  }

  Widget _buildBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: kBorder),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: kGold, size: 12),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(
          color: kTextMuted, fontSize: 11, letterSpacing: 0.5,
        )),
      ]),
    );
  }

  // ── Quick Links Column ────────────────────────────────────────
  Widget _buildFooterColumn({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(title),
        const SizedBox(height: 28),
        ...children,
      ],
    );
  }

  // ── Contact Info Column ───────────────────────────────────────
  Widget _buildContactColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Contact Us'),
        const SizedBox(height: 28),
        Container(
          width: 320,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: kCardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Email
              _contactRow(Icons.email_rounded, 'info@pktcalltaxi.com'),
              _goldDivider(),

              // Phone numbers
              _contactRow(Icons.phone_android_rounded, '76677 33771'),
              const SizedBox(height: 14),
              _contactRow(Icons.phone_android_rounded, '98942 04941'),
              const SizedBox(height: 14),
              _contactRow(Icons.phone_in_talk_rounded,  '0437 3252785'),
              _goldDivider(),

              // Location
              _contactRow(Icons.location_on_rounded, 'Pattukkottai, Tamil Nadu'),
            ],
          ),
        ),
      ],
    );
  }

  // ── Reusable Widgets ──────────────────────────────────────────

  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: kTextPrimary, fontSize: 12,
            fontWeight: FontWeight.w800, letterSpacing: 2.5,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          height: 1.5, width: 36,
          decoration: BoxDecoration(
            color: kGold,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  Widget _buildFooterLink(String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        mouseCursor: SystemMouseCursors.click,
        hoverColor: Colors.transparent,
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 4, height: 4,
            decoration: const BoxDecoration(
              color: kGoldDim, shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: kTextMuted, fontSize: 11,
              fontWeight: FontWeight.w500, letterSpacing: 1.5,
            ),
          ),
        ]),
      ),
    );
  }

  Widget _contactRow(IconData icon, String text) {
    return Row(children: [
      Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          color: kGold.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: kBorder),
        ),
        child: Icon(icon, color: kGold, size: 15),
      ),
      const SizedBox(width: 14),
      Expanded(
        child: Text(
          text,
          style: const TextStyle(
            color: kTextPrimary, fontSize: 13,
            fontWeight: FontWeight.w500, letterSpacing: 0.3,
          ),
        ),
      ),
    ]);
  }

  Widget _goldDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Container(height: 0.5, color: kBorder),
    );
  }
}