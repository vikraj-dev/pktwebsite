import 'package:flutter/material.dart';

// ══════════════════════════════════════════════════════════════
//  LUXURY BLACK & GOLD ABOUT PAGE — PKT CALL TAXI
//  Logic & Keys: 100% untouched
//  UI: Full Black & Gold luxury redesign
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

  @override
  Widget build(BuildContext context) {
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
            padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 50),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // ── LEFT: Car Image Panel ─────────────────
                    Expanded(
                      flex: 1,
                      child: _buildImagePanel(),
                    ),

                    const SizedBox(width: 80),

                    // ── RIGHT: Content ────────────────────────
                    Expanded(
                      flex: 1,
                      child: _buildContent(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Left Image Panel ──────────────────────────────────────────
  Widget _buildImagePanel() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer gold ring
        Container(
          height: 420, width: 420,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: kBorder, width: 1),
          ),
        ),
        // Inner dark circle
        Container(
          height: 360, width: 360,
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
            height: 320,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.directions_car,
              color: kGold,
              size: 120,
            ),
          ),
        ),
        // Bottom label badge
        Positioned(
          bottom: 30,
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
    decoration: const BoxDecoration(
      color: kGold, shape: BoxShape.circle,
    ),
  );

  // ── Right Content ─────────────────────────────────────────────
  Widget _buildContent() {
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
        const Text(
          'Experience the\nPinnacle of\nProfessional Travel',
          style: TextStyle(
            fontSize: 46,
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
            color: kGold,
            borderRadius: BorderRadius.circular(2),
          ),
        ),

        // Description texts
        _buildDescription(
          "At PKT Call Taxi, we don't just provide rides; we deliver excellence. "
          "Specializing in reliable, convenient, and premium one-way taxi services "
          "tailored for your journey.",
        ),

        const SizedBox(height: 20),

        _buildDescription(
          "Whether it's an airport transfer or a corporate meeting, our fleet of "
          "pristine vehicles and elite drivers ensure you arrive not just on time, "
          "but in comfort and style.",
        ),

        const SizedBox(height: 48),

        // Stats row
        Row(children: [
          _buildStat('4.9★', 'Rating'),
          _buildStatDivider(),
          _buildStat('12K+', 'Rides'),
          _buildStatDivider(),
          _buildStat('50+', 'Vehicles'),
        ]),

        const SizedBox(height: 40),

        // Feature badges
        Row(children: [
          _buildFeatureBadge(Icons.verified_user_outlined, 'Safety First'),
          const SizedBox(width: 14),
          _buildFeatureBadge(Icons.timer_outlined, '24/7 Service'),
          const SizedBox(width: 14),
          _buildFeatureBadge(Icons.workspace_premium_outlined, 'Premium'),
        ]),
      ],
    );
  }

  Widget _buildDescription(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        height: 1.9,
        color: kTextMuted,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.3,
      ),
    );
  }

  // ── Stat block ────────────────────────────────────────────────
  Widget _buildStat(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: const TextStyle(
          color: kGold, fontSize: 28,
          fontWeight: FontWeight.w900, letterSpacing: -0.5,
        )),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(
          color: kTextMuted, fontSize: 10,
          letterSpacing: 2, fontWeight: FontWeight.w500,
        )),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 28),
      width: 1, height: 36,
      color: kBorder,
    );
  }

  // ── Feature Badge ─────────────────────────────────────────────
  Widget _buildFeatureBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: kCardBg,
        border: Border.all(color: kBorder),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: kGold),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(
            color: kTextPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 11,
            letterSpacing: 0.5,
          )),
        ],
      ),
    );
  }
}