import 'package:flutter/material.dart';
import 'dart:async';

// ══════════════════════════════════════════════════════════════
//  PKT CALL TAXI — CUSTOMER REVIEWS PAGE
//  Theme: Dark #0A0A0A + Gold #C9A84C  (matches Webpage exactly)
// ══════════════════════════════════════════════════════════════

class ReviewsPage extends StatefulWidget {
  final GlobalKey reviewsKey;
  const ReviewsPage({required this.reviewsKey, super.key});

  @override
  State<ReviewsPage> createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _autoScrollAnim;
  int _currentPage = 0;
  Timer? _autoTimer;

  static const _gold   = Color(0xFFC9A84C);
  static const _card   = Color(0xFF111111);
  static const _border = Color(0x22C9A84C);
  static const _dim    = Color(0xFF6A5C40);
  static const _light  = Color(0xFFF0E6C8);

  // ── Avatar helper: ui-avatars.com — name based, always works ──
  static String _av(String name, {bool female = false}) {
    final encoded = Uri.encodeComponent(name);
    return 'https://ui-avatars.com/api/?name=$encoded'
        '&background=C9A84C&color=0A0A0A&size=128&bold=true&rounded=true';
  }

  // ── Review data ──────────────────────────────────────────────
  static final List<_ReviewData> _reviews = [
    _ReviewData(
      name:     'Rajesh Kumar',
      location: 'Chennai',
      avatar:   _av('Rajesh Kumar'),
      review:   'PKT Call Taxi is simply the best! Reached Chennai airport on time even during heavy traffic. Driver was professional and the car was spotless. Highly recommended!',
      rating:   5,
      tripType: 'Airport Transfer',
      date:     'Dec 2024',
      verified: true,
    ),
    _ReviewData(
      name:     'Priya Lakshmi',
      location: 'Madurai',
      avatar:   _av('Priya Lakshmi', female: true),
      review:   'Travelled from Pattukkottai to Madurai for a family function. Super comfortable Innova, very courteous driver. Price was transparent — no hidden charges at all.',
      rating:   5,
      tripType: 'Outstation',
      date:     'Nov 2024',
      verified: true,
    ),
    _ReviewData(
      name:     'Suresh Babu',
      location: 'Trichy',
      avatar:   _av('Suresh Babu'),
      review:   'Booked via WhatsApp at 4 AM for an urgent hospital trip. They responded within minutes and arrived in 15 minutes. Lifesavers! Will always use PKT.',
      rating:   5,
      tripType: 'Emergency',
      date:     'Oct 2024',
      verified: true,
    ),
    _ReviewData(
      name:     'Kavitha Devi',
      location: 'Erode',
      avatar:   _av('Kavitha Devi', female: true),
      review:   'Excellent service from Erode to Coimbatore. Clean sedan, AC was perfect, driver knew all the shortcuts. Will definitely book again for my next trip!',
      rating:   5,
      tripType: 'City Drop',
      date:     'Jan 2025',
      verified: true,
    ),
    _ReviewData(
      name:     'Murugan S',
      location: 'Salem',
      avatar:   _av('Murugan S'),
      review:   'Used PKT for a wedding in Salem. They arranged a luxury SUV that impressed all my relatives. On-time, well-dressed driver, perfect experience.',
      rating:   5,
      tripType: 'Special Occasion',
      date:     'Feb 2025',
      verified: true,
    ),
    _ReviewData(
      name:     'Anitha R',
      location: 'Pattukkottai',
      avatar:   _av('Anitha R', female: true),
      review:   'Local trips within Pattukkottai are so easy now. I call PKT every week for shopping and hospital visits. Very affordable and always on time.',
      rating:   5,
      tripType: 'Local Trip',
      date:     'Mar 2025',
      verified: true,
    ),
    _ReviewData(
      name:     'Vijay Anand',
      location: 'Chennai',
      avatar:   _av('Vijay Anand'),
      review:   'Booked round trip Chennai–Pattukkottai. Amazing comfort, driver was polite and played good music. Arrived 20 minutes early both ways. 5 stars!',
      rating:   5,
      tripType: 'Round Trip',
      date:     'Apr 2025',
      verified: true,
    ),
    _ReviewData(
      name:     'Meena Kumari',
      location: 'Thanjavur',
      avatar:   _av('Meena Kumari', female: true),
      review:   'Came across PKT through a friend. First ride was from Thanjavur to Chennai — absolutely loved it. The Etios was brand new and driver was super helpful.',
      rating:   4,
      tripType: 'Outstation',
      date:     'May 2025',
      verified: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
    _autoScrollAnim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoTimer?.cancel();
    _autoTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      final next = (_currentPage + 1) % _reviews.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _pageController.dispose();
    _autoScrollAnim.dispose();
    super.dispose();
  }

  bool _isMobile(BuildContext ctx) => MediaQuery.of(ctx).size.width < 600;

  @override
  Widget build(BuildContext context) {
    final mobile = _isMobile(context);

    return Container(
      key: widget.reviewsKey,
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
              // ── Section Label ──
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(width: 32, height: 1, color: _gold),
                const SizedBox(width: 10),
                const Text('CUSTOMER REVIEWS',
                    style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 3,
                        color: _gold,
                        fontWeight: FontWeight.w600)),
                const SizedBox(width: 10),
                Container(width: 32, height: 1, color: _gold),
              ]),
              const SizedBox(height: 16),

              // ── Heading ──
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                      fontSize: mobile ? 24 : 30,
                      fontWeight: FontWeight.w700,
                      color: _light,
                      height: 1.25),
                  children: const [
                    TextSpan(text: 'What Our\n'),
                    TextSpan(
                        text: 'Passengers Say',
                        style: TextStyle(color: _gold)),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Real experiences from real travellers across Tamil Nadu.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: _dim, height: 1.7),
              ),
              const SizedBox(height: 32),

              // ── Overall Rating Bar ──
              _OverallRatingBar(mobile: mobile),
              const SizedBox(height: 36),

              // ── Carousel ──
              SizedBox(
                height: mobile ? 290 : 260,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemCount: _reviews.length,
                  itemBuilder: (_, i) => AnimatedScale(
                    scale: _currentPage == i ? 1.0 : 0.93,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: _ReviewCard(data: _reviews[i], mobile: mobile),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Dot Indicators ──
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_reviews.length, (i) {
                  final active = i == _currentPage;
                  return GestureDetector(
                    onTap: () {
                      _autoTimer?.cancel();
                      _pageController.animateToPage(i,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOutCubic);
                      setState(() => _currentPage = i);
                      _startAutoScroll();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: active ? 24 : 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: active ? _gold : _gold.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 36),

              // ── Featured 2 Cards ──
              mobile
                  ? Column(children: [
                      _FeaturedReviewCard(data: _reviews[2]),
                      const SizedBox(height: 12),
                      _FeaturedReviewCard(data: _reviews[5]),
                    ])
                  : Row(children: [
                      Expanded(child: _FeaturedReviewCard(data: _reviews[2])),
                      const SizedBox(width: 14),
                      Expanded(child: _FeaturedReviewCard(data: _reviews[5])),
                    ]),
              const SizedBox(height: 36),

              // ── Bottom Stats Strip ──
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _border),
                ),
                child: mobile
                    ? Column(children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: const [
                            _ReviewStat(value: '4.9★', label: 'GOOGLE'),
                            _ReviewStat(value: '4.9★', label: 'WHATSAPP'),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(height: 1, color: _border),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: const [
                            _ReviewStat(value: '12K+', label: 'HAPPY RIDES'),
                            _ReviewStat(value: '98%', label: 'RECOMMEND US'),
                          ],
                        ),
                      ])
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: const [
                          _ReviewStat(value: '4.9★', label: 'GOOGLE RATING'),
                          _VertDivider(),
                          _ReviewStat(value: '4.9★', label: 'WHATSAPP RATING'),
                          _VertDivider(),
                          _ReviewStat(value: '12K+', label: 'HAPPY RIDES'),
                          _VertDivider(),
                          _ReviewStat(value: '98%', label: 'RECOMMEND US'),
                        ],
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
//  DATA MODEL
// ══════════════════════════════════════════════════════════════
class _ReviewData {
  final String name, location, avatar, review, tripType, date;
  final int    rating;
  final bool   verified;
  const _ReviewData({
    required this.name, required this.location, required this.avatar,
    required this.review, required this.rating, required this.tripType,
    required this.date, required this.verified,
  });
}

// ══════════════════════════════════════════════════════════════
//  AVATAR WIDGET — Gold initials, graceful fallback
// ══════════════════════════════════════════════════════════════
class _Avatar extends StatelessWidget {
  final String url;
  final double size;
  const _Avatar({required this.url, required this.size});

  static const _gold = Color(0xFFC9A84C);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size / 2),
      child: Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        // Loading: gold shimmer circle
        loadingBuilder: (ctx, child, progress) => progress == null
            ? child
            : Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: _gold.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(size / 2),
                  border: Border.all(color: _gold.withOpacity(0.3)),
                ),
                child: Center(
                  child: SizedBox(
                    width: size * 0.4,
                    height: size * 0.4,
                    child: const CircularProgressIndicator(
                      strokeWidth: 1.5,
                      color: _gold,
                    ),
                  ),
                ),
              ),
        // Error: gold person icon
        errorBuilder: (_, __, ___) => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: _gold.withOpacity(0.15),
            borderRadius: BorderRadius.circular(size / 2),
            border: Border.all(color: _gold.withOpacity(0.3)),
          ),
          child: Icon(Icons.person_rounded, color: _gold, size: size * 0.55),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  OVERALL RATING BAR
// ══════════════════════════════════════════════════════════════
class _OverallRatingBar extends StatelessWidget {
  final bool mobile;
  const _OverallRatingBar({required this.mobile});

  static const _gold   = Color(0xFFC9A84C);
  static const _card   = Color(0xFF111111);
  static const _border = Color(0x22C9A84C);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: mobile
          ? Column(children: [
              _BigRating(),
              const SizedBox(height: 16),
              Container(height: 1, color: _border),
              const SizedBox(height: 16),
              _RatingBars(),
            ])
          : Row(children: [
              _BigRating(),
              Container(
                  width: 1,
                  height: 100,
                  color: _border,
                  margin: const EdgeInsets.symmetric(horizontal: 24)),
              Expanded(child: _RatingBars()),
            ]),
    );
  }
}

class _BigRating extends StatelessWidget {
  static const _gold  = Color(0xFFC9A84C);
  static const _light = Color(0xFFF0E6C8);
  static const _dim   = Color(0xFF6A5C40);

  @override
  Widget build(BuildContext context) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Row(mainAxisSize: MainAxisSize.min, children: const [
        Icon(Icons.star_rounded, color: _gold, size: 28),
        SizedBox(width: 6),
        Text('4.9',
            style: TextStyle(
                fontSize: 40, fontWeight: FontWeight.w800, color: _light)),
      ]),
      const SizedBox(height: 6),
      const Text('Out of 5.0',
          style: TextStyle(fontSize: 12, color: _dim)),
      const SizedBox(height: 6),
      _StarRow(rating: 5, size: 18),
      const SizedBox(height: 4),
      const Text('Based on 12,000+ rides',
          style: TextStyle(fontSize: 11, color: _dim)),
    ],
  );
}

class _RatingBars extends StatelessWidget {
  static const _gold = Color(0xFFC9A84C);
  static const _dim  = Color(0xFF6A5C40);
  static const _bars = [(5, 0.87), (4, 0.09), (3, 0.03), (2, 0.01), (1, 0.00)];

  @override
  Widget build(BuildContext context) => Column(
    children: _bars.map((b) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Text('${b.$1}★',
            style: const TextStyle(
                fontSize: 12, color: _gold, fontWeight: FontWeight.w600)),
        const SizedBox(width: 10),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: b.$2,
              backgroundColor: const Color(0xFF1A1A1A),
              valueColor: const AlwaysStoppedAnimation<Color>(_gold),
              minHeight: 7,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text('${(b.$2 * 100).toStringAsFixed(0)}%',
            style: const TextStyle(fontSize: 11, color: _dim)),
      ]),
    )).toList(),
  );
}

// ══════════════════════════════════════════════════════════════
//  REVIEW CARD (Carousel)
// ══════════════════════════════════════════════════════════════
class _ReviewCard extends StatelessWidget {
  final _ReviewData data;
  final bool        mobile;
  const _ReviewCard({required this.data, required this.mobile});

  static const _gold   = Color(0xFFC9A84C);
  static const _card   = Color(0xFF111111);
  static const _border = Color(0x22C9A84C);
  static const _light  = Color(0xFFF0E6C8);
  static const _dim    = Color(0xFF6A5C40);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
              color: _gold.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── Top row ──
        Row(children: [
          _Avatar(url: data.avatar, size: 48),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Flexible(
                  child: Text(data.name,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _light)),
                ),
                if (data.verified) ...[
                  const SizedBox(width: 6),
                  const Icon(Icons.verified_rounded, color: _gold, size: 14),
                ],
              ]),
              const SizedBox(height: 2),
              Row(children: [
                const Icon(Icons.location_on_rounded, color: _dim, size: 12),
                const SizedBox(width: 3),
                Text(data.location,
                    style: const TextStyle(fontSize: 11, color: _dim)),
              ]),
            ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            _StarRow(rating: data.rating, size: 14),
            const SizedBox(height: 4),
            Text(data.date,
                style: const TextStyle(fontSize: 10, color: _dim)),
          ]),
        ]),
        const SizedBox(height: 14),

        // ── Review text ──
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('"',
              style: TextStyle(
                  fontSize: 36,
                  color: _gold,
                  height: 0.8,
                  fontWeight: FontWeight.w700)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(data.review,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFFB0A080),
                    height: 1.65)),
          ),
        ]),
        const Spacer(),

        // ── Trip badge ──
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: _gold.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _gold.withOpacity(0.22)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.directions_car_rounded, size: 11, color: _gold),
            const SizedBox(width: 5),
            Text(data.tripType,
                style: const TextStyle(
                    fontSize: 11, color: _gold, letterSpacing: 0.3)),
          ]),
        ),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  FEATURED REVIEW CARD (Bottom 2)
// ══════════════════════════════════════════════════════════════
class _FeaturedReviewCard extends StatelessWidget {
  final _ReviewData data;
  const _FeaturedReviewCard({required this.data});

  static const _gold   = Color(0xFFC9A84C);
  static const _card   = Color(0xFF111111);
  static const _border = Color(0x22C9A84C);
  static const _light  = Color(0xFFF0E6C8);
  static const _dim    = Color(0xFF6A5C40);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_gold.withOpacity(0.04), Colors.transparent],
        ),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _Avatar(url: data.avatar, size: 56),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(
                child: Text(data.name,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _light)),
              ),
              if (data.verified)
                const Icon(Icons.verified_rounded, color: _gold, size: 15),
            ]),
            const SizedBox(height: 3),
            Row(children: [
              _StarRow(rating: data.rating, size: 13),
              const SizedBox(width: 8),
              Text(data.tripType,
                  style: const TextStyle(
                      fontSize: 10, color: _dim, letterSpacing: 0.5)),
            ]),
            const SizedBox(height: 10),
            Text('"${data.review}"',
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFB0A080),
                    height: 1.6,
                    fontStyle: FontStyle.italic)),
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.location_on_rounded, color: _dim, size: 11),
              const SizedBox(width: 3),
              Text(data.location,
                  style: const TextStyle(fontSize: 10, color: _dim)),
              const Spacer(),
              Text(data.date,
                  style: const TextStyle(fontSize: 10, color: _dim)),
            ]),
          ]),
        ),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  SHARED HELPERS
// ══════════════════════════════════════════════════════════════
class _StarRow extends StatelessWidget {
  final int    rating;
  final double size;
  const _StarRow({required this.rating, required this.size});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: List.generate(5, (i) => Icon(
      i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
      color: const Color(0xFFC9A84C),
      size: size,
    )),
  );
}

class _ReviewStat extends StatelessWidget {
  final String value, label;
  const _ReviewStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) => Column(children: [
    Text(value,
        style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Color(0xFFC9A84C))),
    const SizedBox(height: 4),
    Text(label,
        style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF6A5C40),
            letterSpacing: 1.2,
            fontWeight: FontWeight.w500)),
  ]);
}

class _VertDivider extends StatelessWidget {
  const _VertDivider();
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 50, color: const Color(0x22C9A84C));
}