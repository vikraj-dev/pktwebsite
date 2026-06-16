import 'package:flutter/material.dart';

// ─── Color Constants ───────────────────────────────────────────────────────────
class AppColors {
  static const Color kBg          = Color(0xFF0A0A0A);
  static const Color kPanel       = Color(0xFF111111);
  static const Color kCardBg      = Color(0xFF161616);
  static const Color kGold        = Color(0xFFC9A84C);
  static const Color kGoldDim     = Color(0xFF7A6030);
  static const Color kTextPrimary = Color(0xFFF0E6C8);
  static const Color kTextMuted   = Color(0xFF6A5C40);
  static const Color kBorder      = Color(0x22C9A84C);
  static const Color kBorderHov   = Color(0x66C9A84C);
}

// ─── Feature Model ─────────────────────────────────────────────────────────────
class FeatureItem {
  final IconData icon;
  final String title;
  final String description;
  final String badge;

  const FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.badge,
  });
}

// ─── Features Data ─────────────────────────────────────────────────────────────
const List<FeatureItem> features = [
  FeatureItem(
    icon: Icons.currency_rupee_rounded,
    title: 'Transparent Pricing',
    description: 'Pay only for the distance. No hidden charges, no return fare. Simple and honest billing.',
    badge: 'No hidden fees',
  ),
  FeatureItem(
    icon: Icons.access_time_filled_rounded,
    title: '24/7 Service',
    description: 'Available any hour, any day. Early morning airport runs or late-night returns — always ready.',
    badge: 'Always available',
  ),
  FeatureItem(
    icon: Icons.flight_takeoff_rounded,
    title: 'Airport Transfers',
    description: 'Punctual pickups, flight-tracking, and professional service for every travel trip.',
    badge: 'On-time guarantee',
  ),
  FeatureItem(
    icon: Icons.directions_car_filled_rounded,
    title: 'Premium Fleet',
    description: 'Choose from Sedan, Etios, Luxury SUV, or Innova Grand — 50+ pristine vehicles.',
    badge: '50+ vehicles',
  ),
  FeatureItem(
    icon: Icons.verified_user_rounded,
    title: 'Safety & Comfort',
    description: 'Trained, verified drivers. Clean and sanitized vehicles before every single ride.',
    badge: 'Verified drivers',
  ),
  FeatureItem(
    icon: Icons.chat_rounded,
    title: 'WhatsApp Booking',
    description: 'Book instantly via WhatsApp or call. No app needed — fast and hassle-free.',
    badge: 'Instant booking',
  ),
  FeatureItem(
    icon: Icons.map_rounded,
    title: 'Multiple Stops',
    description: 'Add multiple pickup and drop points. Flexible routing for outstation or local drops.',
    badge: 'Flexible routing',
  ),
  FeatureItem(
    icon: Icons.payment_rounded,
    title: 'Multiple Payments',
    description: 'Pay via UPI, cash, card, or online transfer. Convenient payment for every customer.',
    badge: 'UPI / Cash / Card',
  ),
];

// ─── Stat Model ────────────────────────────────────────────────────────────────
class StatItem {
  final String value;
  final String label;
  const StatItem(this.value, this.label);
}

const List<StatItem> stats = [
  StatItem('4.9★', 'Rating'),
  StatItem('12K+', 'Rides'),
  StatItem('50+', 'Vehicles'),
  StatItem('24/7', 'Service'),
];

// ─── Features Page ─────────────────────────────────────────────────────────────
class FeaturesPage extends StatelessWidget {
  const FeaturesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildHeader(),
              const SizedBox(height: 40),
              _buildGrid(),
              const SizedBox(height: 48),
              _buildDivider(),
              const SizedBox(height: 32),
              _buildStats(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Column(
      children: [
        // Eyebrow
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 32, height: 1, color: AppColors.kGold),
            const SizedBox(width: 10),
            const Text(
              'WHY CHOOSE US',
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 3,
                color: AppColors.kGold,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 10),
            Container(width: 32, height: 1, color: AppColors.kGold),
          ],
        ),
        const SizedBox(height: 16),

        // Title
        RichText(
          textAlign: TextAlign.center,
          text: const TextSpan(
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: AppColors.kTextPrimary,
              height: 1.2,
            ),
            children: [
              TextSpan(text: 'Features of\n'),
              TextSpan(
                text: 'PKT Call Taxi',
                style: TextStyle(color: AppColors.kGold),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Subtitle
        const Text(
          'Premium travel from Pattukkottai.\nThe finest choice for your every journey.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: AppColors.kTextMuted,
            height: 1.7,
          ),
        ),
      ],
    );
  }

  // ── Feature Grid ────────────────────────────────────────────────────────────
  Widget _buildGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: features.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.82,
      ),
      itemBuilder: (context, index) => _FeatureCard(item: features[index]),
    );
  }

  // ── Divider ─────────────────────────────────────────────────────────────────
  Widget _buildDivider() {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            AppColors.kGold.withOpacity(0.3),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  // ── Stats Row ───────────────────────────────────────────────────────────────
  Widget _buildStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: stats.map((s) => _StatWidget(stat: s)).toList(),
    );
  }
}

// ─── Feature Card Widget ───────────────────────────────────────────────────────
class _FeatureCard extends StatefulWidget {
  final FeatureItem item;
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
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _hovered ? -3 : 0, 0),
        decoration: BoxDecoration(
          color: AppColors.kPanel,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _hovered ? AppColors.kBorderHov : AppColors.kBorder,
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            // Gold top accent line on hover
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: _hovered ? 1.0 : 0.0,
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      AppColors.kGold,
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Card Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.kGold.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.kGold.withOpacity(0.2),
                      ),
                    ),
                    child: Icon(
                      widget.item.icon,
                      color: AppColors.kGold,
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    widget.item.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.kTextPrimary,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Description
                  Expanded(
                    child: Text(
                      widget.item.description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.kTextMuted,
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.kGold.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.kGold.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_rounded,
                          size: 11,
                          color: AppColors.kGold,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          widget.item.badge,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.kGold,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Stat Widget ───────────────────────────────────────────────────────────────
class _StatWidget extends StatelessWidget {
  final StatItem stat;
  const _StatWidget({required this.stat});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          stat.value,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: AppColors.kGold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          stat.label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.kTextMuted,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}

// ─── Main (for standalone testing) ────────────────────────────────────────────
void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: FeaturesPage(),
  ));
}