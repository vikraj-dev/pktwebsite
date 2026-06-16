import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AppDownloadPage extends StatefulWidget {
  final GlobalKey appDownloadKey;
  const AppDownloadPage({required this.appDownloadKey});

  @override
  State<AppDownloadPage> createState() => _AppDownloadPageState();
}

class _AppDownloadPageState extends State<AppDownloadPage> {
  Future<void> _launchUserApp() async {
    final url = Uri.parse(
        'https://play.google.com/store/apps/details?id=com.pktcalltaxi.app');
    if (await canLaunchUrl(url))
      await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  Future<void> _launchDriverApp() async {
    final url = Uri.parse(
        'https://play.google.com/store/apps/details?id=com.pktcalltaxi.captain');
    if (await canLaunchUrl(url))
      await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  bool _isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  @override
  Widget build(BuildContext context) {
    final mobile = _isMobile(context);

    return Container(
      key: widget.appDownloadKey,
      color: Colors.transparent,
      padding: EdgeInsets.symmetric(
        horizontal: mobile ? 16 : 40,
        vertical: 40,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              // ── Eyebrow ──────────────────────────────────
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(width: 32, height: 1, color: const Color(0xFFC9A84C)),
                const SizedBox(width: 10),
                const Text('DOWNLOAD NOW',
                    style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 3,
                        color: Color(0xFFC9A84C),
                        fontWeight: FontWeight.w600)),
                const SizedBox(width: 10),
                Container(width: 32, height: 1, color: const Color(0xFFC9A84C)),
              ]),
              const SizedBox(height: 16),

              // ── Title ────────────────────────────────────
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                      fontSize: mobile ? 22 : 30,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFF0E6C8),
                      height: 1.25),
                  children: const [
                    TextSpan(text: 'PKT Call Taxi\n'),
                    TextSpan(
                        text: 'Apps for Everyone',
                        style: TextStyle(color: Color(0xFFC9A84C))),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'One platform — for riders and drivers both.\nAndroid app. Free to download.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13, color: Color(0xFF6A5C40), height: 1.7),
              ),
              const SizedBox(height: 40),

              // ── Two Cards ────────────────────────────────
              mobile
                  ? Column(children: [
                      _AppCard(type: _AppType.user,   onTap: _launchUserApp),
                      const SizedBox(height: 14),
                      _AppCard(type: _AppType.driver, onTap: _launchDriverApp),
                    ])
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _AppCard(type: _AppType.user,   onTap: _launchUserApp)),
                        const SizedBox(width: 16),
                        Expanded(child: _AppCard(type: _AppType.driver, onTap: _launchDriverApp)),
                      ],
                    ),

              const SizedBox(height: 40),

              // ── Divider ──────────────────────────────────
              Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    Colors.transparent,
                    const Color(0xFFC9A84C).withOpacity(0.35),
                    Colors.transparent,
                  ]),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  APP TYPE
// ══════════════════════════════════════════════════════════════
enum _AppType { user, driver }

// ══════════════════════════════════════════════════════════════
//  ICON BOX — network image with icon fallback
// ══════════════════════════════════════════════════════════════
class _AppIconBox extends StatelessWidget {
  final _AppType type;
  final Animation<double> shimmer;
  const _AppIconBox({required this.type, required this.shimmer});

  static const _gold = Color(0xFFC9A84C);

  // Rider  → smiling passenger illustration (ui-avatars style placeholder)
  // Driver → steering wheel / taxi illustration
  String get _imageUrl => type == _AppType.user
      ? 'https://img.icons8.com/color/96/000000/person-male.png'
      : 'https://img.icons8.com/color/96/000000/taxi.png';

  IconData get _fallbackIcon => type == _AppType.user
      ? Icons.person_rounded
      : Icons.local_taxi_rounded;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: shimmer,
      builder: (_, __) => Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: _gold.withOpacity(0.10),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _gold.withOpacity(0.25)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // ── Network image ──
              Image.network(
                _imageUrl,
                width: 34,
                height: 34,
                fit: BoxFit.contain,
                // While loading → gold shimmer spinner
                loadingBuilder: (ctx, child, progress) => progress == null
                    ? child
                    : Center(
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            color: _gold.withOpacity(0.6),
                          ),
                        ),
                      ),
                // On error → material icon fallback
                errorBuilder: (_, __, ___) => Icon(
                  _fallbackIcon,
                  color: _gold,
                  size: 26,
                ),
              ),

              // ── Shimmer sweep overlay ──
              Positioned.fill(
                child: Opacity(
                  opacity: 0.18,
                  child: Transform.translate(
                    offset: Offset(shimmer.value * 56, 0),
                    child: Container(
                      width: 20,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          Colors.transparent,
                          _gold.withOpacity(0.9),
                          Colors.transparent,
                        ]),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  APP CARD — luxury animated
// ══════════════════════════════════════════════════════════════
class _AppCard extends StatefulWidget {
  final _AppType type;
  final VoidCallback onTap;
  const _AppCard({required this.type, required this.onTap});

  @override
  State<_AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<_AppCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerCtrl;
  late Animation<double>   _shimmer;
  bool _hovered = false;

  bool   get _isUser    => widget.type == _AppType.user;
  String get _title     => _isUser ? 'Rider App'      : 'Driver App';
  String get _subtitle  => _isUser ? 'FOR PASSENGERS' : 'FOR DRIVERS';
  String get _desc      => _isUser
      ? 'Book rides instantly, track your cab live, pay via UPI or cash. Simple and fast.'
      : 'Accept rides, manage earnings, navigate routes — everything in one place.';
  String get _badge1    => _isUser ? 'Live Tracking'   : 'Earnings Dashboard';
  String get _badge2    => _isUser ? 'UPI / Cash'      : 'Route Navigation';
  String get _badge3    => _isUser ? 'Instant Booking' : 'Trip Management';
  String get _btnLabel  => _isUser ? 'Download Rider App' : 'Download Driver App';

  @override
  void initState() {
    super.initState();
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
    _shimmer = Tween<double>(begin: -1.5, end: 2.5).animate(
      CurvedAnimation(
          parent: _shimmerCtrl,
          curve: const Interval(0.0, 0.65, curve: Curves.easeInOut)),
    );
  }

  @override
  void dispose() {
    _shimmerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _hovered ? -4 : 0, 0),
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _hovered
                ? const Color(0xFFC9A84C).withOpacity(0.55)
                : const Color(0xFFC9A84C).withOpacity(0.18),
            width: _hovered ? 1.2 : 1.0,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(children: [

            // top shimmer line on hover
            AnimatedOpacity(
              duration: const Duration(milliseconds: 220),
              opacity: _hovered ? 1.0 : 0.0,
              child: Container(
                height: 2,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [
                    Colors.transparent,
                    Color(0xFFC9A84C),
                    Colors.transparent,
                  ]),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── Header row ──────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ★ Network image icon box
                      _AppIconBox(type: widget.type, shimmer: _shimmer),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFC9A84C).withOpacity(0.08),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                    color: const Color(0xFFC9A84C).withOpacity(0.2)),
                              ),
                              child: Text(_subtitle,
                                  style: const TextStyle(
                                      fontSize: 9,
                                      letterSpacing: 2,
                                      color: Color(0xFFC9A84C),
                                      fontWeight: FontWeight.w700)),
                            ),
                            const SizedBox(height: 6),
                            Text(_title,
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFF0E6C8),
                                    height: 1.1)),
                          ],
                        ),
                      ),
                      // Android badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                              color: const Color(0xFFC9A84C).withOpacity(0.15)),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: const [
                          Icon(Icons.android_rounded,
                              color: Color(0xFFC9A84C), size: 13),
                          SizedBox(width: 4),
                          Text('Android',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF6A5C40),
                                  fontWeight: FontWeight.w600)),
                        ]),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),
                  Container(height: 1, color: const Color(0xFFC9A84C).withOpacity(0.08)),
                  const SizedBox(height: 18),

                  Text(_desc,
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF6A5C40), height: 1.7)),
                  const SizedBox(height: 18),

                  Wrap(spacing: 8, runSpacing: 8, children: [
                    _FeatureBadge(label: _badge1),
                    _FeatureBadge(label: _badge2),
                    _FeatureBadge(label: _badge3),
                  ]),
                  const SizedBox(height: 22),

                  _DownloadButton(
                    label: _btnLabel,
                    onTap: widget.onTap,
                    filled: _isUser,
                  ),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  FEATURE BADGE
// ══════════════════════════════════════════════════════════════
class _FeatureBadge extends StatelessWidget {
  final String label;
  const _FeatureBadge({required this.label});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFC9A84C).withOpacity(0.07),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFC9A84C).withOpacity(0.20)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.check_rounded, size: 10, color: Color(0xFFC9A84C)),
          const SizedBox(width: 5),
          Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFFC9A84C),
                  letterSpacing: 0.3,
                  fontWeight: FontWeight.w500)),
        ]),
      );
}

// ══════════════════════════════════════════════════════════════
//  DOWNLOAD BUTTON
// ══════════════════════════════════════════════════════════════
class _DownloadButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final bool filled;
  const _DownloadButton(
      {required this.label, required this.onTap, required this.filled});

  @override
  State<_DownloadButton> createState() => _DownloadButtonState();
}

class _DownloadButtonState extends State<_DownloadButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown:   (_) => setState(() => _pressed = true),
      onTapUp:     (_) => setState(() => _pressed = false),
      onTapCancel: ()  => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _pressed ? 2 : 0, 0),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: widget.filled ? const Color(0xFFC9A84C) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFFC9A84C)
                .withOpacity(widget.filled ? 0.0 : 0.45),
          ),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.android_rounded,
              color: widget.filled
                  ? const Color(0xFF0A0A0A)
                  : const Color(0xFFC9A84C),
              size: 16),
          const SizedBox(width: 8),
          Text(widget.label,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: widget.filled
                      ? const Color(0xFF0A0A0A)
                      : const Color(0xFFC9A84C))),
          const SizedBox(width: 8),
          Icon(Icons.arrow_forward_ios_rounded,
              color: widget.filled
                  ? const Color(0xFF0A0A0A)
                  : const Color(0xFFC9A84C),
              size: 11),
        ]),
      ),
    );
  }
}