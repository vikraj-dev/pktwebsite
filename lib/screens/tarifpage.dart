import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ══════════════════════════════════════════════════════════════
//  LUXURY BLACK & GOLD TARIFF PAGE — PKT CALL TAXI
//  Tabs: Oneway | Roundtrip | Local Drop
//  Logic: Firebase dynamic fetch — all 3 types
//  UI: 100% luxury black & gold — untouched
// ══════════════════════════════════════════════════════════════

class TarifPage extends StatefulWidget {
  final Key? tarifkey;
  const TarifPage({super.key, this.tarifkey});

  @override
  State<TarifPage> createState() => _TarifPageState();
}

class _TarifPageState extends State<TarifPage> with TickerProviderStateMixin {

  // ── Luxury Color Palette ──────────────────────────────────────
  static const Color kBg          = Color(0xFF0A0A0A);
  static const Color kPanel       = Color(0xFF111111);
  static const Color kCardBg      = Color(0xFF161616);
  static const Color kGold        = Color(0xFFC9A84C);
  static const Color kGoldDim     = Color(0xFF7A6030);
  static const Color kTextPrimary = Color(0xFFF0E6C8);
  static const Color kTextMuted   = Color(0xFF6A5C40);
  static const Color kBorder      = Color(0x22C9A84C);
  static const Color kBorderHov   = Color(0x66C9A84C);

  // ── State ─────────────────────────────────────────────────────
  String selectedTarif  = 'oneway';
  List<bool> isHovering = List.filled(4, false);

  // ── Firebase tariffs ──────────────────────────────────────────
  List<Map<String, dynamic>> onewayTariffs    = [];
  List<Map<String, dynamic>> roundtripTariffs = [];
  List<Map<String, dynamic>> dropTariffs      = [];
  bool isLoading = true;

  // ── Vehicle meta ──────────────────────────────────────────────
  final Map<String, String> vehicleImages = {
    'SEDAN':  'assets/sedanwhite.png',
    'ETIOS':  'assets/sedan.png',
    'SUV':    'assets/mini.png',
    'INNOVA': 'assets/innova.png',
  };

  final Map<String, IconData> vehicleIcons = {
    'SEDAN':  Icons.directions_car_outlined,
    'ETIOS':  Icons.directions_car,
    'SUV':    Icons.airport_shuttle_outlined,
    'INNOVA': Icons.directions_bus_outlined,
  };

  final Map<String, List<String>> vehicleFeatures = {
    'SEDAN':  ['Comfortable ride', 'On-time guarantee', 'Trained driver'],
    'ETIOS':  ['Clean & sanitized', 'On-time guarantee', 'Trained driver'],
    'SUV':    ['Extra luggage space', 'Group friendly', 'Premium comfort'],
    'INNOVA': ['7 seater spacious', 'Group friendly', 'Premium comfort'],
  };

  // ── Animation ─────────────────────────────────────────────────
  late AnimationController _fadeController;
  late Animation<double>   _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _fadeAnim = CurvedAnimation(
        parent: _fadeController, curve: Curves.easeOut);
    _fetchTariffs();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  // ══════════════════════════════════════════════════════════════
  //  FIREBASE FETCH — OneWay + RoundTrip + Drop (parallel)
  // ══════════════════════════════════════════════════════════════

  Future<void> _fetchTariffs() async {
    try {
      final results = await Future.wait([
        FirebaseFirestore.instance
            .collection('tariffs/OUTSTATION/OneWay')
            .get(),
        FirebaseFirestore.instance
            .collection('tariffs/OUTSTATION/RoundTrip')
            .get(),
        FirebaseFirestore.instance
            .collection('tariffs/LOCAL/Drop')
            .get(),
      ]);

      final maxLen = results
          .map((s) => s.docs.length)
          .reduce((a, b) => a > b ? a : b);

      setState(() {
        onewayTariffs    = _parseSnap(results[0]);
        roundtripTariffs = _parseSnap(results[1]);
        dropTariffs      = _parseSnap(results[2]);
        isLoading        = false;
        isHovering       = List.filled(maxLen, false);
      });
    } catch (e) {
      debugPrint('Tariff fetch error: $e');
      setState(() => isLoading = false);
    }
  }

  List<Map<String, dynamic>> _parseSnap(QuerySnapshot snap) {
    const order = ['SEDAN', 'ETIOS', 'SUV', 'INNOVA'];
    final list  = snap.docs.map((d) {
      final data = d.data() as Map<String, dynamic>;
      return {
        'category': (data['category'] ?? d.id).toString().toUpperCase(),
        'perKm':    (data['perKm']    ?? 0).toDouble(),
        'cost':     (data['cost']     ?? 0).toDouble(),
        'minKm':    (data['minKm']    ?? 0).toDouble(),
      };
    }).toList();

    list.sort((a, b) {
      int iA = order.indexOf(a['category']);
      int iB = order.indexOf(b['category']);
      if (iA == -1) iA = 99;
      if (iB == -1) iB = 99;
      return iA.compareTo(iB);
    });
    return list;
  }

  void _switchTarif(String type) {
    setState(() => selectedTarif = type);
    _fadeController.forward(from: 0);
  }

  List<Map<String, dynamic>> get _currentTariffs {
    switch (selectedTarif) {
      case 'roundtrip': return roundtripTariffs;
      case 'drop':      return dropTariffs;
      default:          return onewayTariffs;
    }
  }

  // ══════════════════════════════════════════════════════════════
  //  BUILD
  // ══════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Container(
      key: widget.tarifkey,
      width: double.infinity,
      color: kBg,
      child: Stack(
        children: [
          // Decorative bg circles
          Positioned(
            top: 60, right: -100,
            child: Container(
              width: 350, height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kGold.withOpacity(0.03),
              ),
            ),
          ),
          Positioned(
            bottom: 80, left: -80,
            child: Container(
              width: 280, height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kGold.withOpacity(0.03),
              ),
            ),
          ),

          Column(
            children: [
              const SizedBox(height: 80),

              // Section tag
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(width: 24, height: 1, color: kGold),
                const SizedBox(width: 10),
                const Text('OUR TARIFF', style: TextStyle(
                  color: kGold, fontSize: 10,
                  fontWeight: FontWeight.w700, letterSpacing: 3,
                )),
                const SizedBox(width: 10),
                Container(width: 24, height: 1, color: kGold),
              ]),

              const SizedBox(height: 28),

              // 3-tab toggle
              _buildTarifSelector(),

              const SizedBox(height: 50),

              // Heading — animated on switch
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                switchInCurve:  Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: Column(
                  key: ValueKey(selectedTarif),
                  children: [
                    Text(
                      _headingText(),
                      style: const TextStyle(
                        fontSize: 38, fontWeight: FontWeight.w900,
                        color: kTextPrimary, letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 700),
                        child: Text(
                          _subText(),
                          style: const TextStyle(
                            fontSize: 15, color: kTextMuted, height: 1.7,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 70),

              // Cards
              if (isLoading)
                _buildLoadingShimmer()
              else if (_currentTariffs.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.info_outline, color: kTextMuted, size: 16),
                      SizedBox(width: 10),
                      Text('Tariff data unavailable',
                          style: TextStyle(color: kTextMuted, fontSize: 13)),
                    ],
                  ),
                )
              else
                FadeTransition(
                  opacity: _fadeAnim,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth < 1100) {
                        return Column(
                          children: List.generate(
                            _currentTariffs.length,
                            (i) => _buildCarCard(i, true),
                          ),
                        );
                      }
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: List.generate(
                          _currentTariffs.length,
                          (i) => _buildCarCard(i, false),
                        ),
                      );
                    },
                  ),
                ),

              const SizedBox(height: 100),
            ],
          ),
        ],
      ),
    );
  }

  // ── Heading helpers ───────────────────────────────────────────
  String _headingText() {
    switch (selectedTarif) {
      case 'roundtrip': return 'Roundtrip Premium';
      case 'drop':      return 'Local Drop';
      default:          return 'Oneway Special';
    }
  }

  String _subText() {
    switch (selectedTarif) {
      case 'roundtrip':
        return 'The ultimate round-trip experience. Your driver waits for you while you finish your work. Perfect for outstation travel.';
      case 'drop':
        return 'Quick and comfortable local drop within the city. Pay only for the distance you travel. No hidden charges, no surprises.';
      default:
        return 'Experience premium one-way travel. Pay only for the drop-off distance. No return charges. Simple, transparent, and luxury.';
    }
  }

  // ── Loading shimmer ───────────────────────────────────────────
  Widget _buildLoadingShimmer() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        width: 280, height: 380,
        decoration: BoxDecoration(
          color: kCardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kBorder),
        ),
        child: const Center(
          child: CircularProgressIndicator(
              color: kGold, strokeWidth: 1.5),
        ),
      )),
    );
  }

  // ── 3-Tab Toggle ─────────────────────────────────────────────
  Widget _buildTarifSelector() {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: kPanel,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleButton(
              'oneway', 'Oneway', Icons.arrow_forward_outlined),
          _buildToggleButton(
              'roundtrip', 'Roundtrip', Icons.sync_outlined),
          _buildToggleButton(
              'drop', 'Local Drop', Icons.location_on_outlined),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String type, String label, IconData icon) {
    final bool isSelected = selectedTarif == type;
    return InkWell(
      onTap: () => _switchTarif(type),
      borderRadius: BorderRadius.circular(7),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
        decoration: BoxDecoration(
          color: isSelected ? kGold : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                color: isSelected ? kBg : kTextMuted, size: 13),
            const SizedBox(width: 7),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? kBg : kTextMuted,
                fontWeight: FontWeight.w700,
                fontSize: 13,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Car Card ──────────────────────────────────────────────────
  Widget _buildCarCard(int index, bool isMobile) {
    final tariff   = _currentTariffs[index];
    final category = tariff['category'] as String;
    final perKm    = tariff['perKm']    as double;
    final minKm    = tariff['minKm']    as double;
    final cost     = tariff['cost']     as double;

    final bool isFeatured = index == 1;
    final bool hovering =
        index < isHovering.length ? isHovering[index] : false;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, isFeatured ? 0 : 20, 16, 20),
      child: MouseRegion(
        onEnter: (_) {
          if (index < isHovering.length) {
            setState(() => isHovering[index] = true);
          }
        },
        onExit: (_) {
          if (index < isHovering.length) {
            setState(() => isHovering[index] = false);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          width: isMobile ? 340 : 290,
          transform: Matrix4.translationValues(0, hovering ? -8 : 0, 0),
          decoration: BoxDecoration(
            color: isFeatured ? kPanel : kCardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hovering
                  ? kBorderHov
                  : isFeatured
                      ? const Color(0x44C9A84C)
                      : kBorder,
              width: isFeatured ? 1.0 : 0.5,
            ),
          ),
          child: Column(
            children: [
              // Featured badge
              if (isFeatured)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: const BoxDecoration(
                    color: kGold,
                    borderRadius: BorderRadius.only(
                      topLeft:  Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                  ),
                  child: const Text(
                    'MOST POPULAR',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: kBg, fontSize: 10,
                      fontWeight: FontWeight.w900, letterSpacing: 2.5,
                    ),
                  ),
                ),

              Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  children: [
                    // Car image
                    SizedBox(
                      height: 130,
                      child: Image.asset(
                        vehicleImages[category] ?? 'assets/sedan.png',
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Icon(
                          vehicleIcons[category] ?? Icons.directions_car,
                          color: kGold, size: 80,
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    // Gold divider
                    Row(children: [
                      Expanded(
                          child: Container(height: 0.5, color: kBorder)),
                      Container(
                        margin:
                            const EdgeInsets.symmetric(horizontal: 10),
                        width: 5, height: 5,
                        decoration: const BoxDecoration(
                            color: kGold, shape: BoxShape.circle),
                      ),
                      Expanded(
                          child: Container(height: 0.5, color: kBorder)),
                    ]),

                    const SizedBox(height: 18),

                    // Friendly name
                    Text(
                      _friendlyName(category),
                      style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w800,
                        color: kTextPrimary, letterSpacing: 0.3,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Category badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: kGold.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: kBorder),
                      ),
                      child: Text(
                        category,
                        style: const TextStyle(
                          color: kGoldDim, fontSize: 9,
                          fontWeight: FontWeight.w700, letterSpacing: 1.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    // ── Price block — Firebase dynamic ──────────
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        key: ValueKey('$selectedTarif-$category'),
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 16),
                        decoration: BoxDecoration(
                          color: kGold.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: kBorder),
                        ),
                        child: Column(
                          children: [
                            // Per km — big number
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              crossAxisAlignment:
                                  CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                const Text('₹ ', style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600,
                                  color: kGoldDim,
                                )),
                                Text(
                                  perKm.toStringAsFixed(0),
                                  style: const TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.w900,
                                    color: kGold, letterSpacing: -1,
                                  ),
                                ),
                                const Text(' / km', style: TextStyle(
                                  fontSize: 12, color: kTextMuted,
                                  letterSpacing: 0.5,
                                )),
                              ],
                            ),

                            // Base fare row
                            if (cost > 0) ...[
                              const SizedBox(height: 8),
                              Container(
                                height: 0.5, color: kBorder,
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 8),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(children: const [
                                    Icon(Icons.flag_outlined,
                                        color: kTextMuted, size: 11),
                                    SizedBox(width: 5),
                                    Text('Base fare',
                                        style: TextStyle(
                                          color: kTextMuted,
                                          fontSize: 10,
                                          letterSpacing: 0.3,
                                        )),
                                  ]),
                                  Text(
                                    '₹ ${cost.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      color: kGoldDim, fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ],

                            // Min km row
                            if (minKm > 0) ...[
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(children: const [
                                    Icon(Icons.straighten,
                                        color: kTextMuted, size: 11),
                                    SizedBox(width: 5),
                                    Text('Min km',
                                        style: TextStyle(
                                          color: kTextMuted,
                                          fontSize: 10,
                                          letterSpacing: 0.3,
                                        )),
                                  ]),
                                  Text(
                                    '${minKm.toStringAsFixed(0)} km',
                                    style: const TextStyle(
                                      color: kGoldDim, fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Features
                    ..._buildFeatures(category),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Friendly name ─────────────────────────────────────────────
  String _friendlyName(String category) {
    switch (category) {
      case 'SEDAN':  return 'Premium Sedan';
      case 'ETIOS':  return 'Etios Comfort';
      case 'SUV':    return 'Luxury SUV';
      case 'INNOVA': return 'Innova Grand';
      default:       return category;
    }
  }

  // ── Feature bullets ───────────────────────────────────────────
  List<Widget> _buildFeatures(String category) {
    final features = vehicleFeatures[category] ??
        ['On-time guarantee', 'Clean & sanitized', 'Trained driver'];

    return features
        .map((f) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(children: [
                Container(
                  width: 16, height: 16,
                  decoration: BoxDecoration(
                    color: kGold.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: kGold, size: 10),
                ),
                const SizedBox(width: 10),
                Text(f,
                    style: const TextStyle(
                      color: kTextMuted, fontSize: 12, letterSpacing: 0.3,
                    )),
              ]),
            ))
        .toList();
  }
}