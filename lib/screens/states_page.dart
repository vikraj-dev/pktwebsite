import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ══════════════════════════════════════════════════════════════
//  PKT CALL TAXI — STATS PAGE
//  Fix: _StatsSection → StatsSection (public, usable in webpage.dart)
// ══════════════════════════════════════════════════════════════

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

// ══════════════════════════════════════════════════════════════
//  MODEL
// ══════════════════════════════════════════════════════════════
class _StatsData {
  final int    states;
  final String statesList;
  final double kmTravelled;
  final int    tripsDone;
  final int    vehicles;
  final String tripCompletion;
  final int    routes;
  final String ratingGoogle;
  final String ratingWhatsapp;
  final String Growth;
  final String avgRating;
  final int    airportsServed;

  const _StatsData({
    required this.states,
    required this.statesList,
    required this.kmTravelled,
    required this.tripsDone,
    required this.vehicles,
    required this.tripCompletion,
    required this.routes,
    required this.ratingGoogle,
    required this.ratingWhatsapp,
    required this.Growth,
    required this.avgRating,
    required this.airportsServed,
  });

  factory _StatsData.fromFirestore(Map<String, dynamic> d) {
    int toInt(dynamic v) =>
        v == null ? 0 : (v is int ? v : (v as num).toInt());
    return _StatsData(
      states:         toInt(d['states']),
      statesList:     (d['statesList']     ?? '').toString(),
      kmTravelled:    ((d['kmTravelled']   ?? 0) as num).toDouble(),
      tripsDone:      toInt(d['tripsDone']),
      vehicles:       toInt(d['vehicles']),
      tripCompletion: (d['tripCompletion'] ?? '—').toString(),
      routes:         toInt(d['routes']),
      ratingGoogle:   (d['ratingGoogle']   ?? '—').toString(),
      ratingWhatsapp: (d['ratingWhatsapp'] ?? '—').toString(),
      Growth:      (d['yoyGrowth']      ?? '—').toString(),
      avgRating:      (d['avgRating']      ?? '—').toString(),
      airportsServed: toInt(d['airportsServed']),
    );
  }

  static const _StatsData empty = _StatsData(
    states: 0, statesList: '', kmTravelled: 0, tripsDone: 0,
    vehicles: 0, tripCompletion: '—', routes: 0,
    ratingGoogle: '—', ratingWhatsapp: '—',
    Growth: '—', avgRating: '—', airportsServed: 0,
  );
}

// ══════════════════════════════════════════════════════════════
//  PUBLIC WIDGET — StatsSection (no underscore, webpage.dart use pannalaam)
// ══════════════════════════════════════════════════════════════
class StatsSection extends StatefulWidget {
  final GlobalKey sectionKey;
  const StatsSection({required this.sectionKey, super.key});

  @override
  State<StatsSection> createState() => _StatsSectionState();
}

class _StatsSectionState extends State<StatsSection>
    with SingleTickerProviderStateMixin {

  late AnimationController _pulseCtrl;
  late Animation<double>   _pulseAnim;

  double _kmDisplay    = 0;
  int    _tripsDisplay = 0;

  _StatsData _data    = _StatsData.empty;
  bool       _loading = true;
  String?    _error;

  StreamSubscription<DocumentSnapshot>? _sub;
  Timer? _countTimer;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.4, end: 1.0).animate(_pulseCtrl);
    _signInAndListen();
  }

  // ── Step 1: Anonymous auth ────────────────────────────────────
  Future<void> _signInAndListen() async {
    try {
      if (FirebaseAuth.instance.currentUser == null) {
        await FirebaseAuth.instance.signInAnonymously();
      }
      _listenFirestore();
    } catch (e) {
      debugPrint('Anonymous auth failed: $e');
      _listenFirestore(); // rules allow read: if true — still try
    }
  }

  // ── Step 2: Firestore realtime listener ──────────────────────
  void _listenFirestore() {
    _sub?.cancel();
    _sub = FirebaseFirestore.instance
        .collection('admin')
        .doc('stats')
        .snapshots()
        .listen(
      (snap) {
        if (!snap.exists || snap.data() == null) {
          setState(() { _loading = false; _error = 'No data in admin/stats'; });
          return;
        }
        final newData = _StatsData.fromFirestore(
            snap.data() as Map<String, dynamic>);
        setState(() { _data = newData; _loading = false; _error = null; });
        _animateCounters(newData);
      },
      onError: (e) {
        debugPrint('Firestore error: $e');
        setState(() { _loading = false; _error = e.toString(); });
      },
    );
  }

  // ── Count-up animation ────────────────────────────────────────
  void _animateCounters(_StatsData target) {
    _countTimer?.cancel();
    const steps   = 60;
    final startKm = _kmDisplay;
    final startT  = _tripsDisplay.toDouble();
    int step = 0;
    _countTimer = Timer.periodic(const Duration(milliseconds: 20), (t) {
      step++;
      final ease = 1 - (1 - step / steps) * (1 - step / steps);
      setState(() {
        _kmDisplay    = startKm + (target.kmTravelled - startKm) * ease;
        _tripsDisplay =
            (startT + (target.tripsDone - startT) * ease).toInt();
      });
      if (step >= steps) t.cancel();
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _countTimer?.cancel();
    _pulseCtrl.dispose();
    super.dispose();
  }

  Widget _vDivider() =>
      Container(width: 1, height: 80, color: AppColors.kBorder);

  // ══════════════════════════════════════════════════════════════
  //  BUILD
  // ══════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final mobile  = screenW < 600;

    return Container(
      key: widget.sectionKey,
      color: Colors.transparent,
      padding: EdgeInsets.symmetric(
        horizontal: mobile ? 16 : 40,
        vertical: 40,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: _loading
              ? _buildLoader()
              : _error != null
                  ? _buildError()
                  : _buildContent(mobile),
        ),
      ),
    );
  }

  // ── Loader ────────────────────────────────────────────────────
  Widget _buildLoader() => const SizedBox(
    height: 300,
    child: Center(
      child: CircularProgressIndicator(color: AppColors.kGold),
    ),
  );

  // ── Error + Retry ─────────────────────────────────────────────
  Widget _buildError() => SizedBox(
    height: 300,
    child: Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.wifi_off_rounded,
            color: AppColors.kGoldDim, size: 40),
        const SizedBox(height: 12),
        const Text('Failed to load stats',
            style: TextStyle(
                color: AppColors.kTextPrimary, fontSize: 16)),
        const SizedBox(height: 6),
        Text(_error ?? '',
            style: const TextStyle(
                color: AppColors.kTextMuted, fontSize: 11)),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () {
            setState(() { _loading = true; _error = null; });
            _signInAndListen();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.kGold.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: AppColors.kGold.withOpacity(0.3)),
            ),
            child: const Text('Retry',
                style: TextStyle(
                    color: AppColors.kGold,
                    fontWeight: FontWeight.w600)),
          ),
        ),
      ]),
    ),
  );

  // ── Main content ──────────────────────────────────────────────
  Widget _buildContent(bool mobile) {
    final kmStr    = '${(_kmDisplay / 1000).toStringAsFixed(0)}K km';
    final tripsStr = '$_tripsDisplay+';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [

        // ── Live badge ──────────────────────────────────────────
        AnimatedBuilder(
          animation: _pulseAnim,
          builder: (_, __) => Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.kGold.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: AppColors.kGold.withOpacity(0.3)),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 7, height: 7,
                decoration: BoxDecoration(
                  color: AppColors.kGold
                      .withOpacity(_pulseAnim.value),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 7),
              const Text('Live',
                  style: TextStyle(
                      color: AppColors.kGold,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5)),
            ]),
          ),
        ),
        const SizedBox(height: 16),

        // ── Title ───────────────────────────────────────────────
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(
              fontSize: mobile ? 24 : 28,
              fontWeight: FontWeight.w700,
              color: AppColors.kTextPrimary,
              height: 1.2,
            ),
            children: const [
              TextSpan(text: 'PKT Call Taxi — '),
              TextSpan(
                  text: 'Trusted\nTaxi Service',
                  style: TextStyle(color: AppColors.kGold)),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Real-time performance across our cab network',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 13,
              color: AppColors.kTextMuted,
              height: 1.6),
        ),
        const SizedBox(height: 32),

        // ── Main big card ───────────────────────────────────────
        _GoldCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              mobile
                  ? Column(children: [
                      Row(children: [
                        Expanded(child: _StatBlock(
                            icon: Icons.location_on_rounded,
                            value: '${_data.states}',
                            label: 'STATES',
                            sub: _data.statesList)),
                        _vDivider(),
                        Expanded(child: _StatBlock(
                            icon: Icons.directions_car_filled_rounded,
                            value: kmStr,
                            label: 'KM TRAVELLED')),
                      ]),
                      const SizedBox(height: 16),
                      Container(height: 1, color: AppColors.kBorder),
                      const SizedBox(height: 16),
                      Row(children: [
                        Expanded(child: _StatBlock(
                            icon: Icons.check_circle_rounded,
                            value: tripsStr,
                            label: 'TRIPS DONE')),
                        _vDivider(),
                        Expanded(child: _StatBlock(
                            icon: Icons.people_alt_rounded,
                            value: '${_data.vehicles}+',
                            label: 'VEHICLES')),
                      ]),
                    ])
                  : Row(children: [
                      Expanded(child: _StatBlock(
                          icon: Icons.location_on_rounded,
                          value: '${_data.states}',
                          label: 'STATES',
                          sub: _data.statesList)),
                      _vDivider(),
                      Expanded(child: _StatBlock(
                          icon: Icons.directions_car_filled_rounded,
                          value: kmStr,
                          label: 'KM TRAVELLED')),
                      _vDivider(),
                      Expanded(child: _StatBlock(
                          icon: Icons.check_circle_rounded,
                          value: tripsStr,
                          label: 'TRIPS DONE')),
                      _vDivider(),
                      Expanded(child: _StatBlock(
                          icon: Icons.people_alt_rounded,
                          value: '${_data.vehicles}+',
                          label: 'VEHICLES')),
                    ]),
              const SizedBox(height: 20),
              Container(height: 1, color: AppColors.kBorder),
              const SizedBox(height: 16),
              Wrap(spacing: 20, runSpacing: 10, children: [
                _GrowthBadge(
                    percent: _data.Growth,
                    label: 'Ride Growth'),
                _GrowthBadge(
                    percent: _data.avgRating,
                    label: 'Avg Rating'),
              ]),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // ── Bottom 4 cards ──────────────────────────────────────
        mobile
            ? Column(children: [
                Row(children: [
                  Expanded(child: _SmallStatCard(
                      icon: Icons.flight_rounded,
                      value: '${_data.airportsServed}+',
                      label: 'AIRPORTS SERVED')),
                  const SizedBox(width: 12),
                  Expanded(child: _SmallStatCard(
                      icon: Icons.task_alt_rounded,
                      value: _data.tripCompletion,
                      label: 'TRIP COMPLETION')),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: _SmallStatCard(
                      icon: Icons.route_rounded,
                      value: '${_data.routes}+',
                      label: 'ROUTES')),
                  const SizedBox(width: 12),
                  Expanded(child: _RatingsCard(
                      google: _data.ratingGoogle,
                      whatsapp: _data.ratingWhatsapp)),
                ]),
              ])
            : Row(children: [
                Expanded(child: _SmallStatCard(
                    icon: Icons.flight_rounded,
                    value: '${_data.airportsServed}+',
                    label: 'AIRPORTS SERVED')),
                const SizedBox(width: 12),
                Expanded(child: _SmallStatCard(
                    icon: Icons.task_alt_rounded,
                    value: _data.tripCompletion,
                    label: 'TRIP COMPLETION')),
                const SizedBox(width: 12),
                Expanded(child: _SmallStatCard(
                    icon: Icons.route_rounded,
                    value: '${_data.routes}+',
                    label: 'ROUTES')),
                const SizedBox(width: 12),
                Expanded(child: _RatingsCard(
                    google: _data.ratingGoogle,
                    whatsapp: _data.ratingWhatsapp)),
              ]),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  SHARED WIDGETS
// ══════════════════════════════════════════════════════════════

class _GoldCard extends StatelessWidget {
  final Widget child;
  const _GoldCard({required this.child});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppColors.kPanel,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.kBorder),
    ),
    child: child,
  );
}

class _StatBlock extends StatelessWidget {
  final IconData icon;
  final String   value;
  final String   label;
  final String?  sub;
  const _StatBlock({
    required this.icon,
    required this.value,
    required this.label,
    this.sub,
  });
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.kGold.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.kGold, size: 16),
      ),
      const SizedBox(height: 10),
      Text(value,
          style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.kTextPrimary)),
      const SizedBox(height: 3),
      Text(label,
          style: const TextStyle(
              fontSize: 10,
              color: AppColors.kTextMuted,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w500)),
      if (sub != null && sub!.isNotEmpty) ...[
        const SizedBox(height: 6),
        Text(sub!,
            style: const TextStyle(
                fontSize: 10,
                color: AppColors.kTextMuted,
                height: 1.5)),
      ],
    ]),
  );
}

class _GrowthBadge extends StatelessWidget {
  final String percent;
  final String label;
  const _GrowthBadge({required this.percent, required this.label});
  @override
  Widget build(BuildContext context) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Text(percent,
            style: const TextStyle(
                color: AppColors.kGold,
                fontWeight: FontWeight.w700,
                fontSize: 15)),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(
                color: AppColors.kTextMuted, fontSize: 13)),
      ]);
}

class _SmallStatCard extends StatelessWidget {
  final IconData icon;
  final String   value;
  final String   label;
  const _SmallStatCard({
    required this.icon,
    required this.value,
    required this.label,
  });
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
    decoration: BoxDecoration(
      color: AppColors.kPanel,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.kBorder),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.kTextPrimary)),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.kTextMuted,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w500)),
        ]),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.kGold.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: AppColors.kGold.withOpacity(0.2)),
          ),
          child: Icon(icon, color: AppColors.kGold, size: 18),
        ),
      ],
    ),
  );
}

class _RatingsCard extends StatelessWidget {
  final String google;
  final String whatsapp;
  const _RatingsCard({required this.google, required this.whatsapp});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
    decoration: BoxDecoration(
      color: AppColors.kPanel,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.kBorder),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('RATINGS',
              style: TextStyle(
                  fontSize: 10,
                  color: AppColors.kTextMuted,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 10),
          Row(children: [
            _RatingItem(value: google,   source: 'Google'),
            const SizedBox(width: 16),
            _RatingItem(value: whatsapp, source: 'WhatsApp'),
          ]),
        ]),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.kGold.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: AppColors.kGold.withOpacity(0.2)),
          ),
          child: const Icon(Icons.star_rounded,
              color: AppColors.kGold, size: 18),
        ),
      ],
    ),
  );
}

class _RatingItem extends StatelessWidget {
  final String value;
  final String source;
  const _RatingItem({required this.value, required this.source});
  @override
  Widget build(BuildContext context) => Column(children: [
    Text(value,
        style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.kGold)),
    Text(source,
        style: const TextStyle(
            fontSize: 10, color: AppColors.kTextMuted)),
  ]);
}