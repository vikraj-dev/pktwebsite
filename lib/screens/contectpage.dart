import 'package:flutter/material.dart';
import 'package:get/get.dart'; // ← ADD THIS IMPORT

// ══════════════════════════════════════════════════════════════
//  LUXURY BLACK & GOLD CONTACT PAGE — PKT CALL TAXI
//  Logic & Callbacks: 100% untouched
//  ADDED: Privacy Policy link in Quick Links + Copyright bar
// ══════════════════════════════════════════════════════════════

class Contectpage extends StatelessWidget {
  final Key? contectkey;
  final VoidCallback onHomeTap;
  final VoidCallback onAboutTap;
  final VoidCallback onTarifTap;
  final VoidCallback onContactTap;

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

  bool _isMobile(BuildContext ctx)  => MediaQuery.of(ctx).size.width < 600;
  bool _isTablet(BuildContext ctx)  => MediaQuery.of(ctx).size.width >= 600 && MediaQuery.of(ctx).size.width < 1024;
  bool _isDesktop(BuildContext ctx) => MediaQuery.of(ctx).size.width >= 1024;

  // ── Privacy Policy navigate ───────────────────────────────────
  void _openPrivacyPolicy() => Get.toNamed('/privacy-policy');

  @override
  Widget build(BuildContext context) {
    final mobile = _isMobile(context);
    final tablet = _isTablet(context);
    final double hPad = mobile ? 20 : (tablet ? 36 : 60);
    final double vPad = mobile ? 48 : (tablet ? 60 : 80);

    return Container(
      key: contectkey,
      width: double.infinity,
      color: kBg,
      child: Column(
        children: [
          Container(height: 1, color: kBorder),
          Padding(
            padding: EdgeInsets.symmetric(vertical: vPad, horizontal: hPad),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: mobile
                    ? _buildMobileLayout(context)
                    : tablet
                        ? _buildTabletLayout(context)
                        : _buildDesktopLayout(context),
              ),
            ),
          ),
          _buildCopyrightBar(context),
        ],
      ),
    );
  }

  // ── Desktop ───────────────────────────────────────────────────
  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBrandColumn(context),
        _buildFooterColumn(
          title: 'Quick Links',
          children: [
            _buildFooterLink('Home',        onHomeTap),
            _buildFooterLink('About Us',    onAboutTap),
            _buildFooterLink('Tariff Plan', onTarifTap),
            _buildFooterLink('Contact',     onContactTap),
            _buildPrivacyLink(),  // ← ADDED
          ],
        ),
        _buildContactColumn(context),
      ],
    );
  }

  // ── Tablet ────────────────────────────────────────────────────
  Widget _buildTabletLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBrandColumn(context, fullWidth: true),
        const SizedBox(height: 40),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: _buildFooterColumn(
                title: 'Quick Links',
                children: [
                  _buildFooterLink('Home',        onHomeTap),
                  _buildFooterLink('About Us',    onAboutTap),
                  _buildFooterLink('Tariff Plan', onTarifTap),
                  _buildFooterLink('Contact',     onContactTap),
                  _buildPrivacyLink(),  // ← ADDED
                ],
              ),
            ),
            const SizedBox(width: 30),
            Expanded(
              flex: 3,
              child: _buildContactColumn(context, fullWidth: true),
            ),
          ],
        ),
      ],
    );
  }

  // ── Mobile ────────────────────────────────────────────────────
  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBrandColumn(context, fullWidth: true),
        const SizedBox(height: 36),
        _buildFooterColumn(
          title: 'Quick Links',
          children: [
            _buildFooterLink('Home',        onHomeTap),
            _buildFooterLink('About Us',    onAboutTap),
            _buildFooterLink('Tariff Plan', onTarifTap),
            _buildFooterLink('Contact',     onContactTap),
            _buildPrivacyLink(),  // ← ADDED
          ],
        ),
        const SizedBox(height: 36),
        _buildContactColumn(context, fullWidth: true),
      ],
    );
  }

  // ── Brand Column ──────────────────────────────────────────────
  Widget _buildBrandColumn(BuildContext context, {bool fullWidth = false}) {
    return SizedBox(
      width: fullWidth ? double.infinity : 320,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: kGold, borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.directions_car, color: kBg, size: 22),
            ),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
              Text('PKT', style: TextStyle(color: kTextPrimary, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 3)),
              Text('CALL TAXI', style: TextStyle(color: kGoldDim, fontSize: 7, fontWeight: FontWeight.w700, letterSpacing: 4)),
            ]),
          ]),
          const SizedBox(height: 24),
          const Text(
            'We, PKT Call Taxi, situated at Pattukkottai, Tamil Nadu, have a profound understanding of our consumers travel needs and preferences. We aim to offer individuals as well as corporate a wide range of cars on hire.',
            style: TextStyle(color: kTextMuted, fontSize: 13, height: 1.9, letterSpacing: 0.3),
          ),
          const SizedBox(height: 24),
          Wrap(spacing: 10, runSpacing: 10, children: [
            _buildBadge(Icons.verified, '4.9★ Rated'),
            _buildBadge(Icons.access_time, '24/7 Service'),
          ]),
        ],
      ),
    );
  }

  Widget _buildBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(color: kCardBg, borderRadius: BorderRadius.circular(6), border: Border.all(color: kBorder)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: kGold, size: 12),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: kTextMuted, fontSize: 11, letterSpacing: 0.5)),
      ]),
    );
  }

  // ── Footer column ─────────────────────────────────────────────
  Widget _buildFooterColumn({required String title, required List<Widget> children}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _buildSectionTitle(title),
      const SizedBox(height: 28),
      ...children,
    ]);
  }

  // ── Contact Column ────────────────────────────────────────────
  Widget _buildContactColumn(BuildContext context, {bool fullWidth = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Contact Us'),
        const SizedBox(height: 24),
        Container(
          width: fullWidth ? double.infinity : 320,
          decoration: BoxDecoration(
            color: kCardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: kBorder, width: 0.5),
          ),
          child: Column(children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              decoration: const BoxDecoration(
                color: kPanel,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(13), topRight: Radius.circular(13)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: kPanel, borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: kBorderHov, width: 0.5)),
                  child: const Text('CALL US NOW', style: TextStyle(color: kTextMuted, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 2.5)),
                ),
                const SizedBox(height: 16),
                _highlightPhoneRow(Icons.phone_android_rounded, '+91 76677 33771', isPrimary: false),
                const SizedBox(height: 12),
                const SizedBox(height: 12),
                _highlightPhoneRow(Icons.phone_in_talk_rounded, '0437 3252785', isPrimary: false),
              ]),
            ),
            Container(height: 1, color: kBorder),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(children: [
                _contactRow(Icons.email_rounded, 'info@pktcalltaxi.com'),
                _goldDivider(),
                _contactRow(Icons.location_on_rounded, 'Pattukkottai, Tamil Nadu'),
              ]),
            ),
          ]),
        ),
      ],
    );
  }

  Widget _highlightPhoneRow(IconData icon, String number, {required bool isPrimary}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isPrimary ? 14 : 10, vertical: isPrimary ? 12 : 9),
      decoration: BoxDecoration(
        color: isPrimary ? kCardBg : kBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isPrimary ? kBorderHov : kBorder,
          width: isPrimary ? 1.0 : 0.5,
        ),
      ),
      child: Row(children: [
        Container(
          width: isPrimary ? 36 : 30, height: isPrimary ? 36 : 30,
          decoration: BoxDecoration(
            color: kPanel,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: kTextMuted, size: isPrimary ? 17 : 14),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(number, style: TextStyle(
          color: kTextPrimary,
          fontSize: isPrimary ? 18 : 14,
          fontWeight: isPrimary ? FontWeight.w900 : FontWeight.w600,
          letterSpacing: isPrimary ? 1.5 : 0.5,
        ))),
        if (isPrimary)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: kPanel,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: kBorderHov, width: 0.5),
            ),
            child: const Text('PRIMARY', style: TextStyle(
              color: kTextMuted, fontSize: 8,
              fontWeight: FontWeight.w900, letterSpacing: 1.5,
            )),
          ),
      ]),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  COPYRIGHT BAR — Privacy Policy chip added
  // ══════════════════════════════════════════════════════════════

  Widget _buildCopyrightBar(BuildContext context) {
    final mobile  = _isMobile(context);
    final double hPad = mobile ? 20 : 60;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: mobile ? 16 : 20, horizontal: hPad),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: kBorder))),
      child: mobile
          ? Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(width: 22, height: 22,
                  decoration: BoxDecoration(color: kGold, borderRadius: BorderRadius.circular(4)),
                  child: const Icon(Icons.directions_car, color: kBg, size: 13)),
                const SizedBox(width: 8),
                const Text('PKT CALL TAXI', style: TextStyle(color: kGold, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 2)),
              ]),
              const SizedBox(height: 10),
              const Text('© 2026 PKT Call Taxi · All Rights Reserved',
                  style: TextStyle(color: kTextMuted, fontSize: 10, letterSpacing: 0.3), textAlign: TextAlign.center),
              const SizedBox(height: 6),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
                Text('Made with ', style: TextStyle(color: kTextMuted, fontSize: 10)),
                Icon(Icons.favorite, color: kGold, size: 10),
                Text(' in Tamil Nadu', style: TextStyle(color: kTextMuted, fontSize: 10)),
              ]),
              const SizedBox(height: 12),
              // ── Privacy Policy chip — mobile ─────────────────
              _buildPrivacyPolicyChip(small: true),
            ])
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left: logo
                Row(children: [
                  Container(width: 24, height: 24,
                    decoration: BoxDecoration(color: kGold, borderRadius: BorderRadius.circular(4)),
                    child: const Icon(Icons.directions_car, color: kBg, size: 14)),
                  const SizedBox(width: 10),
                  const Text('PKT CALL TAXI', style: TextStyle(color: kGold, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 2)),
                ]),
                // Center: copyright
                const Text('© 2026 PKT Call Taxi · All Rights Reserved',
                    style: TextStyle(color: kTextMuted, fontSize: 11, letterSpacing: 0.5)),
                // Right: Made with + Privacy Policy chip ← ADDED
                Row(children: [
                  const Text('Made with ', style: TextStyle(color: kTextMuted, fontSize: 11)),
                  const Icon(Icons.favorite, color: kGold, size: 11),
                  const Text(' in Tamil Nadu', style: TextStyle(color: kTextMuted, fontSize: 11)),
                  const SizedBox(width: 16),
                  _buildPrivacyPolicyChip(),  // ← ADDED
                ]),
              ],
            ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  PRIVACY POLICY WIDGETS — 2 variants
  // ══════════════════════════════════════════════════════════════

  // Quick Links la — text link style (other links la match)
  Widget _buildPrivacyLink() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: _openPrivacyPolicy,
        mouseCursor: SystemMouseCursors.click,
        hoverColor: Colors.transparent,
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 4, height: 4,
              decoration: const BoxDecoration(color: kGold, shape: BoxShape.circle)),
          const SizedBox(width: 10),
          const Text('PRIVACY POLICY', style: TextStyle(
            color: kGold,                    // Gold — highlight panrom
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          )),
          const SizedBox(width: 6),
          const Icon(Icons.open_in_new_rounded, color: kGoldDim, size: 10),
        ]),
      ),
    );
  }

  // Copyright bar la — chip style
  Widget _buildPrivacyPolicyChip({bool small = false}) {
    return InkWell(
      onTap: _openPrivacyPolicy,
      mouseCursor: SystemMouseCursors.click,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: small ? 10 : 12, vertical: small ? 5 : 6),
        decoration: BoxDecoration(
          color: kGold.withOpacity(0.08),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: kBorder),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.shield_outlined, color: kGoldDim, size: small ? 10 : 11),
          const SizedBox(width: 5),
          Text('Privacy Policy', style: TextStyle(
            color: kGold, fontSize: small ? 9 : 10,
            fontWeight: FontWeight.w700, letterSpacing: 0.5,
          )),
        ]),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  REUSABLE WIDGETS (untouched)
  // ══════════════════════════════════════════════════════════════

  Widget _buildSectionTitle(String title) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title.toUpperCase(), style: const TextStyle(color: kTextPrimary, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 2.5)),
      const SizedBox(height: 10),
      Container(height: 1.5, width: 36, decoration: BoxDecoration(color: kGold, borderRadius: BorderRadius.circular(2))),
    ]);
  }

  Widget _buildFooterLink(String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        mouseCursor: SystemMouseCursors.click,
        hoverColor: Colors.transparent,
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 4, height: 4, decoration: const BoxDecoration(color: kGoldDim, shape: BoxShape.circle)),
          const SizedBox(width: 10),
          Text(label.toUpperCase(), style: const TextStyle(color: kTextMuted, fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 1.5)),
        ]),
      ),
    );
  }

  Widget _contactRow(IconData icon, String text) {
    return Row(children: [
      Container(width: 32, height: 32,
        decoration: BoxDecoration(color: kPanel, borderRadius: BorderRadius.circular(6), border: Border.all(color: kBorder, width: 0.5)),
        child: Icon(icon, color: kTextMuted, size: 15)),
      const SizedBox(width: 14),
      Expanded(child: Text(text, style: const TextStyle(color: kTextPrimary, fontSize: 13, fontWeight: FontWeight.w500, letterSpacing: 0.3))),
    ]);
  }

  Widget _goldDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Container(height: 0.5, color: kBorder),
    );
  }
}