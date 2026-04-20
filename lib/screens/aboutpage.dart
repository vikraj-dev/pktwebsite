import 'package:flutter/material.dart';

// ══════════════════════════════════════════════════════════════
//  LUXURY BLACK & GOLD ABOUT PAGE — PKT CALL TAXI
//  Logic & Keys: 100% untouched
//  UI: Full Black & Gold luxury redesign
//  ADDED: Responsive for Mobile / Tablet / Desktop
// ══════════════════════════════════════════════════════════════

class AboutPage extends StatelessWidget {
  final Key? aboutKey;

  const AboutPage({super.key, this.aboutKey});

  // ── Luxury Color Palette ──────────────────────────────────────
  static const Color kBg          = Color(0xFF0A0A0A);
  static const Color kPanel       = Color(0xFF111111);
  static const Color kCardBg      = Color(0xFF161616);
  static const Color kGold        = Color(0xFFC9A84C);
  static const Color kGoldLight   = Color(0xFFE0BC66);
  static const Color kGoldDim     = Color(0xFF7A6030);
  static const Color kTextPrimary = Color(0xFFF0E6C8);
  static const Color kTextMuted   = Color(0xFF6A5C40);
  static const Color kBorder      = Color(0x22C9A84C);

  // ── Breakpoints ───────────────────────────────────────────────
  static bool _isMobile(BuildContext ctx)  => MediaQuery.of(ctx).size.width < 600;
  static bool _isTablet(BuildContext ctx)  => MediaQuery.of(ctx).size.width >= 600 && MediaQuery.of(ctx).size.width < 1024;
  static bool _isDesktop(BuildContext ctx) => MediaQuery.of(ctx).size.width >= 1024;

  @override
  Widget build(BuildContext context) {
    final mobile  = _isMobile(context);
    final tablet  = _isTablet(context);
    final double hPad = mobile ? 20 : (tablet ? 32 : 50);
    final double vPad = mobile ? 60 : (tablet ? 80 : 100);

    return Container(
      key: aboutKey,
      width: double.infinity,
      color: kBg,
      child: Stack(
        children: [
          // ── Background decorative elements ──────────────────
          Positioned(
            top: -80, left: -80,
            child: Container(
              width: 400, height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kGold.withOpacity(0.03),
              ),
            ),
          ),
          Positioned(
            bottom: -60, right: -60,
            child: Container(
              width: 300, height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kGold.withOpacity(0.04),
              ),
            ),
          ),

          // ── Main Content ────────────────────────────────────
          Padding(
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
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  DESKTOP LAYOUT — side by side, original proportions
  // ══════════════════════════════════════════════════════════════

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

  // ══════════════════════════════════════════════════════════════
  //  TABLET LAYOUT — side by side, compact
  // ══════════════════════════════════════════════════════════════

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

  // ══════════════════════════════════════════════════════════════
  //  MOBILE LAYOUT — stacked (image on top, content below)
  // ══════════════════════════════════════════════════════════════

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

  // ══════════════════════════════════════════════════════════════
  //  IMAGE PANEL — size-aware
  // ══════════════════════════════════════════════════════════════

  Widget _buildImagePanel({required double size}) {
    final double innerSize  = size * 0.857;  // 360/420
    final double imageSize  = size * 0.762;  // 320/420
    final double badgeBottom = size * 0.071; // 30/420

    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer gold ring
        Container(
          height: size, width: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: kBorder, width: 1),
          ),
        ),
        // Inner dark circle
        Container(
          height: innerSize, width: innerSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: kCardBg,
            border: Border.all(color: kGold.withOpacity(0.15), width: 1),
          ),
        ),
        // Gold dot accents on ring
        ..._buildRingDots(),
        // Car image
        Hero(
          tag: 'car_image',
          child: Image.asset(
            'assets/sedan.png',
            fit: BoxFit.contain,
            height: imageSize,
            errorBuilder: (context, error, stackTrace) => Icon(
              Icons.directions_car,
              color: kGold,
              size: imageSize * 0.375,
            ),
          ),
        ),
        // Bottom label badge
        Positioned(
          bottom: badgeBottom,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: kPanel,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: kBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.star, color: kGold, size: 12),
                SizedBox(width: 8),
                Text('PREMIUM FLEET', style: TextStyle(
                  color: kGold, fontSize: 10,
                  fontWeight: FontWeight.w800, letterSpacing: 2.5,
                )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Gold dots around the ring
  List<Widget> _buildRingDots() {
    return [
      Positioned(top: 10, child: _goldDot()),
      Positioned(bottom: 10, child: _goldDot()),
      Positioned(left: 10, child: _goldDot()),
      Positioned(right: 10, child: _goldDot()),
    ];
  }

  Widget _goldDot() => Container(
    width: 8, height: 8,
    decoration: const BoxDecoration(color: kGold, shape: BoxShape.circle),
  );

  // ══════════════════════════════════════════════════════════════
  //  CONTENT SECTION — size-aware
  // ══════════════════════════════════════════════════════════════

  Widget _buildContent(BuildContext context, {
    required double headingSize,
    required double descSize,
  }) {
    final mobile = _isMobile(context);
    final double statValueSize   = mobile ? 22 : 28;
    final double statLabelSize   = mobile ? 9  : 10;
    final double statDividerMx   = mobile ? 16 : 28;
    final double badgeIconSize   = mobile ? 12 : 14;
    final double badgeFontSize   = mobile ? 10 : 11;
    final double badgeHPad       = mobile ? 10 : 14;
    final double badgeVPad       = mobile ? 8  : 10;
    final double badgeGap        = mobile ? 8  : 14;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section tag
        Row(children: [
          Container(width: 28, height: 1, color: kGold),
          const SizedBox(width: 10),
          const Text('ABOUT US', style: TextStyle(
            color: kGold, fontSize: 10,
            fontWeight: FontWeight.w700, letterSpacing: 3,
          )),
        ]),

        const SizedBox(height: 24),

        // Main heading
        Text(
          'Experience the\nPinnacle of\nProfessional Travel',
          style: TextStyle(
            fontSize: headingSize,
            fontWeight: FontWeight.w900,
            color: kTextPrimary,
            height: 1.1,
            letterSpacing: -1,
          ),
        ),

        // Gold underline accent
        Container(
          margin: const EdgeInsets.only(top: 16, bottom: 32),
          height: 2, width: 60,
          decoration: BoxDecoration(
            color: kGold, borderRadius: BorderRadius.circular(2),
          ),
        ),

        // Description texts
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

        // Stats row
        Row(children: [
          _buildStat('4.9★', 'Rating', valueSize: statValueSize, labelSize: statLabelSize),
          _buildStatDivider(mx: statDividerMx),
          _buildStat('12K+', 'Rides',  valueSize: statValueSize, labelSize: statLabelSize),
          _buildStatDivider(mx: statDividerMx),
          _buildStat('50+',  'Vehicles', valueSize: statValueSize, labelSize: statLabelSize),
        ]),

        SizedBox(height: mobile ? 28 : 40),

        // Feature badges — wrap on mobile to avoid overflow
        mobile
            ? Wrap(
                spacing: badgeGap,
                runSpacing: badgeGap,
                children: [
                  _buildFeatureBadge(Icons.verified_user_outlined, 'Safety First',
                      iconSize: badgeIconSize, fontSize: badgeFontSize,
                      hPad: badgeHPad, vPad: badgeVPad),
                  _buildFeatureBadge(Icons.timer_outlined, '24/7 Service',
                      iconSize: badgeIconSize, fontSize: badgeFontSize,
                      hPad: badgeHPad, vPad: badgeVPad),
                  _buildFeatureBadge(Icons.workspace_premium_outlined, 'Premium',
                      iconSize: badgeIconSize, fontSize: badgeFontSize,
                      hPad: badgeHPad, vPad: badgeVPad),
                ],
              )
            : Row(children: [
                _buildFeatureBadge(Icons.verified_user_outlined, 'Safety First',
                    iconSize: badgeIconSize, fontSize: badgeFontSize,
                    hPad: badgeHPad, vPad: badgeVPad),
                SizedBox(width: badgeGap),
                _buildFeatureBadge(Icons.timer_outlined, '24/7 Service',
                    iconSize: badgeIconSize, fontSize: badgeFontSize,
                    hPad: badgeHPad, vPad: badgeVPad),
                SizedBox(width: badgeGap),
                _buildFeatureBadge(Icons.workspace_premium_outlined, 'Premium',
                    iconSize: badgeIconSize, fontSize: badgeFontSize,
                    hPad: badgeHPad, vPad: badgeVPad),
              ]),
      ],
    );
  }

  Widget _buildDescription(String text, {double fontSize = 16}) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        height: 1.9,
        color: kTextMuted,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.3,
      ),
    );
  }

  // ── Stat block ────────────────────────────────────────────────
  Widget _buildStat(String value, String label, {
    double valueSize = 28,
    double labelSize = 10,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: TextStyle(
          color: kGold, fontSize: valueSize,
          fontWeight: FontWeight.w900, letterSpacing: -0.5,
        )),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(
          color: kTextMuted, fontSize: labelSize,
          letterSpacing: 2, fontWeight: FontWeight.w500,
        )),
      ],
    );
  }

  Widget _buildStatDivider({double mx = 28}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: mx),
      width: 1, height: 36,
      color: kBorder,
    );
  }

  // ── Feature Badge ─────────────────────────────────────────────
  Widget _buildFeatureBadge(
    IconData icon,
    String label, {
    double iconSize  = 14,
    double fontSize  = 11,
    double hPad      = 14,
    double vPad      = 10,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      decoration: BoxDecoration(
        color: kCardBg,
        border: Border.all(color: kBorder),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: iconSize, color: kGold),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(
            color: kTextPrimary,
            fontWeight: FontWeight.w600,
            fontSize: fontSize,
            letterSpacing: 0.5,
          )),
        ],
      ),
    );
  }
}