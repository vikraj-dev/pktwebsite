import 'package:flutter/material.dart';
import 'package:pktwebsite/screens/header.dart';

// ══════════════════════════════════════════════════════════════
//  PKT CALL TAXI — PRIVACY POLICY PAGE (FLUTTER)
//  - Black & Gold luxury theme — matches website exactly
//  - Responsive: Mobile / Tablet / Desktop
//  - Play Store URL submit ku ready
//  - Header integrated
// ══════════════════════════════════════════════════════════════

class PrivacyPolicyPage extends StatefulWidget {
  const PrivacyPolicyPage({super.key});

  @override
  State<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  // ── Luxury Color Palette ──────────────────────────────────────
  static const Color kBg          = Color(0xFF0A0A0A);
  static const Color kPanel       = Color(0xFF111111);
  static const Color kCard        = Color(0xFF161616);
  static const Color kGold        = Color(0xFFC9A84C);
  static const Color kGoldDim     = Color(0xFF7A6030);
  static const Color kTextPrimary = Color(0xFFF0E6C8);
  static const Color kTextMuted   = Color(0xFF6A5C40);
  static const Color kTextSub     = Color(0xFF9A8A6A);
  static const Color kBorder      = Color(0x22C9A84C);
  static const Color kBorderHov   = Color(0x44C9A84C);

  final ScrollController _scrollController = ScrollController();
  final String _lastUpdated = 'January 1, 2025';

  // ── Responsive helpers ────────────────────────────────────────
  bool _isMobile(BuildContext ctx)  => MediaQuery.of(ctx).size.width < 600;
  bool _isTablet(BuildContext ctx)  => MediaQuery.of(ctx).size.width >= 600 && MediaQuery.of(ctx).size.width < 1024;
  bool _isDesktop(BuildContext ctx) => MediaQuery.of(ctx).size.width >= 1024;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mobile  = _isMobile(context);
    final tablet  = _isTablet(context);
    final double hPad = mobile ? 20 : (tablet ? 40 : 80);
    final double maxWidth = 900;

    return Scaffold(
      backgroundColor: kBg,
      body: Stack(
        children: [

          // ── LAYER 0: Background subtle circles ───────────────
          Positioned(
            top: -80, right: -80,
            child: Container(
              width: 400, height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kGold.withOpacity(0.03),
              ),
            ),
          ),
          Positioned(
            bottom: 100, left: -60,
            child: Container(
              width: 300, height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kGold.withOpacity(0.03),
              ),
            ),
          ),

          // ── LAYER 1: Main scrollable content ─────────────────
          Positioned.fill(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const SizedBox(height: 72), // header height offset

                  // ── HERO SECTION ──────────────────────────────
                  _buildHero(hPad, mobile),

                  // ── CONTENT ───────────────────────────────────
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: hPad,
                      vertical: mobile ? 40 : 60,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxWidth),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            // Intro
                            _buildIntroCard(mobile),
                            const SizedBox(height: 32),

                            // All sections
                            _buildSection(
                              number: '01',
                              title: 'Information We Collect',
                              icon: Icons.folder_outlined,
                              items: [
                                _sectionItem('Personal Information', 'When you register or book a ride, we collect your full name, email address, phone number, and city or region of residence.'),
                                _sectionItem('Location Data', 'We collect real-time GPS location data when you use our app to find drivers near you, set pickup points, and track your ride in progress.'),
                                _sectionItem('Booking History', 'We store records of your past bookings including pickup/drop locations, trip date, time, vehicle category, fare amount, and driver details.'),
                                _sectionItem('Device Information', 'We automatically collect your device type, operating system version, app version, and unique device identifiers for analytics and crash reporting.'),
                                _sectionItem('Payment Information', 'We do not store credit/debit card details. Payment processing is handled through secure third-party payment gateways.'),
                              ],
                              mobile: mobile,
                            ),

                            _buildSection(
                              number: '02',
                              title: 'How We Use Your Information',
                              icon: Icons.settings_outlined,
                              items: [
                                _sectionItem('Ride Booking', 'To process your taxi bookings, assign drivers, send real-time notifications, and complete your journey successfully.'),
                                _sectionItem('Driver Matching', 'To find and notify nearby online drivers about your booking request using your GPS location.'),
                                _sectionItem('Communication', 'To send booking confirmations, driver details, ride updates, and important service notifications via SMS and push notifications.'),
                                _sectionItem('Service Improvement', 'To analyze usage patterns, fix bugs, improve app performance, and develop new features based on user feedback.'),
                                _sectionItem('Safety & Security', 'To verify user identity, prevent fraud, investigate disputes, and ensure the safety of both passengers and drivers.'),
                                _sectionItem('Legal Compliance', 'To comply with applicable laws, regulations, and respond to lawful requests from government authorities when required.'),
                              ],
                              mobile: mobile,
                            ),

                            _buildSection(
                              number: '03',
                              title: 'Location Data Usage',
                              icon: Icons.location_on_outlined,
                              items: [
                                _sectionItem('Real-Time Tracking', 'Your location is accessed only when the app is active and in use. We use this to show available drivers nearby and provide accurate pickup.'),
                                _sectionItem('Background Location', 'We may request background location permission to track your ongoing ride. This stops automatically when your trip is completed.'),
                                _sectionItem('Driver Proximity', 'Driver locations are shared with passengers only during an active booking to enable live tracking and ETA calculation.'),
                                _sectionItem('No Continuous Tracking', 'We do not track your location when the app is closed or when you are not on an active booking session.'),
                              ],
                              mobile: mobile,
                            ),

                            _buildSection(
                              number: '04',
                              title: 'Third-Party Services',
                              icon: Icons.share_outlined,
                              items: [
                                _sectionItem('Google Maps & Places API', 'We use Google Maps SDK for route display, location search, autocomplete suggestions, and distance calculation. Google\'s privacy policy applies to data processed by their services.'),
                                _sectionItem('Firebase (Google)', 'We use Firebase Firestore for data storage, Firebase Auth for user authentication, and Firebase Cloud Messaging (FCM) for push notifications.'),
                                _sectionItem('Firebase Realtime Database', 'Used to track driver locations in real time during active bookings for live tracking functionality.'),
                                _sectionItem('No Advertising Networks', 'We do not share your personal data with advertising companies or use your data for targeted advertising.'),
                              ],
                              mobile: mobile,
                            ),

                            _buildSection(
                              number: '05',
                              title: 'Data Sharing & Disclosure',
                              icon: Icons.people_outline,
                              items: [
                                _sectionItem('With Drivers', 'Your name, phone number, pickup and drop location are shared with your assigned driver to facilitate your ride.'),
                                _sectionItem('No Sale of Data', 'We do not sell, rent, or trade your personal information to any third parties under any circumstances.'),
                                _sectionItem('Legal Requirements', 'We may disclose information when required by law, court order, or governmental authority for legitimate legal purposes.'),
                                _sectionItem('Business Transfer', 'In case of a merger or acquisition, user data may be transferred as part of the business assets with prior notice given to users.'),
                              ],
                              mobile: mobile,
                            ),

                            _buildSection(
                              number: '06',
                              title: 'Data Retention',
                              icon: Icons.storage_outlined,
                              items: [
                                _sectionItem('Account Data', 'Your account information is retained as long as your account remains active. You may request deletion at any time.'),
                                _sectionItem('Booking History', 'Trip records are stored for up to 3 years for dispute resolution, billing purposes, and legal compliance.'),
                                _sectionItem('Location Logs', 'Location data from completed trips is anonymized and retained for service improvement analytics only.'),
                                _sectionItem('Deleted Accounts', 'Upon account deletion request, your personal data is permanently removed within 30 days, except where retention is required by law.'),
                              ],
                              mobile: mobile,
                            ),

                            _buildSection(
                              number: '07',
                              title: 'Your Rights',
                              icon: Icons.verified_user_outlined,
                              items: [
                                _sectionItem('Access', 'You have the right to request a copy of all personal data we hold about you at any time.'),
                                _sectionItem('Correction', 'You may update or correct your personal information directly through the app profile settings or by contacting us.'),
                                _sectionItem('Deletion', 'You can request permanent deletion of your account and associated data by contacting our support team.'),
                                _sectionItem('Opt-Out', 'You may opt out of promotional communications at any time through the app notification settings.'),
                                _sectionItem('Data Portability', 'You may request your data in a portable format for transfer to another service provider.'),
                              ],
                              mobile: mobile,
                            ),

                            _buildSection(
                              number: '08',
                              title: 'Security',
                              icon: Icons.lock_outline,
                              items: [
                                _sectionItem('Encryption', 'All data transmitted between the app and our servers is encrypted using industry-standard TLS/SSL encryption protocols.'),
                                _sectionItem('Firebase Security Rules', 'Access to your data is restricted using Firebase Security Rules, ensuring only you and authorized drivers can access your booking data.'),
                                _sectionItem('Authentication', 'User accounts are protected by Firebase Authentication. We never store raw passwords.'),
                                _sectionItem('Breach Notification', 'In the unlikely event of a data breach affecting your personal information, we will notify you within 72 hours of becoming aware.'),
                              ],
                              mobile: mobile,
                            ),

                            _buildSection(
                              number: '09',
                              title: 'Children\'s Privacy',
                              icon: Icons.child_care_outlined,
                              items: [
                                _sectionItem('Age Requirement', 'PKT Call Taxi is intended for users aged 18 and above. We do not knowingly collect personal information from children under 18.'),
                                _sectionItem('Parental Action', 'If you believe a child has provided us with personal information, please contact us immediately and we will delete it promptly.'),
                              ],
                              mobile: mobile,
                            ),

                            _buildSection(
                              number: '10',
                              title: 'Changes to This Policy',
                              icon: Icons.update_outlined,
                              items: [
                                _sectionItem('Updates', 'We may update this Privacy Policy from time to time. The "Last Updated" date at the top will reflect the most recent revision.'),
                                _sectionItem('Notification', 'For significant changes, we will notify you via in-app notification or email before the changes take effect.'),
                                _sectionItem('Continued Use', 'Your continued use of PKT Call Taxi after changes are posted constitutes acceptance of the updated Privacy Policy.'),
                              ],
                              mobile: mobile,
                            ),

                            const SizedBox(height: 40),

                            // Contact card
                            _buildContactCard(mobile),

                            const SizedBox(height: 60),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ── FOOTER STRIP ──────────────────────────────
                  _buildFooter(mobile),
                ],
              ),
            ),
          ),

          // ── LAYER 2: Fixed header ─────────────────────────────
          
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  HERO SECTION
  // ══════════════════════════════════════════════════════════════

  Widget _buildHero(double hPad, bool mobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        hPad,
        mobile ? 48 : 64,
        hPad,
        mobile ? 48 : 64,
      ),
      decoration: BoxDecoration(
        color: kPanel,
        border: Border(
          bottom: BorderSide(color: kBorder),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Tag
              Row(children: [
                Container(width: 24, height: 1, color: kGold),
                const SizedBox(width: 10),
                const Text(
                  'LEGAL',
                  style: TextStyle(
                    color: kGold, fontSize: 10,
                    fontWeight: FontWeight.w700, letterSpacing: 3,
                  ),
                ),
              ]),

              SizedBox(height: mobile ? 20 : 28),

              // Title
              Text(
                'Privacy Policy',
                style: TextStyle(
                  color: kTextPrimary,
                  fontSize: mobile ? 36 : 52,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                  letterSpacing: -1,
                ),
              ),

              const SizedBox(height: 16),

              // Gold underline
              Container(
                height: 2, width: 60,
                decoration: BoxDecoration(
                  color: kGold,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              SizedBox(height: mobile ? 20 : 28),

              // Description
              Text(
                'PKT Call Taxi is committed to protecting your privacy. '
                'This policy explains how we collect, use, and safeguard your personal information '
                'when you use our taxi booking services.',
                style: TextStyle(
                  color: kTextSub,
                  fontSize: mobile ? 14 : 16,
                  height: 1.8,
                  letterSpacing: 0.3,
                ),
              ),

              const SizedBox(height: 24),

              // Last updated chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: kCard,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: kBorder),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.calendar_today_outlined,
                      color: kGoldDim, size: 12),
                  const SizedBox(width: 8),
                  Text(
                    'Last Updated: $_lastUpdated',
                    style: const TextStyle(
                      color: kTextMuted, fontSize: 11,
                      fontWeight: FontWeight.w500, letterSpacing: 0.5,
                    ),
                  ),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  INTRO CARD
  // ══════════════════════════════════════════════════════════════

  Widget _buildIntroCard(bool mobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(mobile ? 20 : 28),
      decoration: BoxDecoration(
        color: kGold.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: kGold.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.info_outline_rounded,
                color: kGold, size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'YOUR PRIVACY MATTERS',
                  style: TextStyle(
                    color: kGold, fontSize: 10,
                    fontWeight: FontWeight.w900, letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'By using PKT Call Taxi (available on Android), '
                  'you agree to the collection and use of information '
                  'as described in this policy. Please read it carefully '
                  'before using our services.',
                  style: TextStyle(
                    color: kTextSub,
                    fontSize: mobile ? 13 : 14,
                    height: 1.7,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  SECTION BUILDER
  // ══════════════════════════════════════════════════════════════

  Widget _buildSection({
    required String number,
    required String title,
    required IconData icon,
    required List<Widget> items,
    required bool mobile,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Section header
          Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            // Number badge
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: kGold,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  number,
                  style: const TextStyle(
                    color: kBg, fontSize: 11,
                    fontWeight: FontWeight.w900, letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Icon(icon, color: kGoldDim, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: kTextPrimary,
                  fontSize: mobile ? 16 : 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ]),

          const SizedBox(height: 4),

          // Gold accent line under header
          Padding(
            padding: const EdgeInsets.only(left: 50),
            child: Container(
              height: 1, color: kBorder,
            ),
          ),

          const SizedBox(height: 16),

          // Items
          Container(
            decoration: BoxDecoration(
              color: kPanel,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kBorder),
            ),
            child: Column(
              children: List.generate(items.length, (i) {
                return Column(children: [
                  items[i],
                  if (i < items.length - 1)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(height: 0.5, color: kBorder),
                    ),
                ]);
              }),
            ),
          ),
        ],
      ),
    );
  }

  // ── Section item ─────────────────────────────────────────────
  Widget _sectionItem(String title, String body) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gold dot
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Container(
              width: 6, height: 6,
              decoration: const BoxDecoration(
                color: kGold, shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: kTextPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: const TextStyle(
                    color: kTextSub,
                    fontSize: 13,
                    height: 1.7,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  CONTACT CARD
  // ══════════════════════════════════════════════════════════════

  Widget _buildContactCard(bool mobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(mobile ? 24 : 32),
      decoration: BoxDecoration(
        color: kPanel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kGold.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: kGold.withOpacity(0.06),
            blurRadius: 24, spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Header
          Row(children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: kGold.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.mail_outline_rounded,
                  color: kGold, size: 18),
            ),
            const SizedBox(width: 14),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
              Text(
                'CONTACT US',
                style: TextStyle(
                  color: kGold, fontSize: 10,
                  fontWeight: FontWeight.w900, letterSpacing: 2.5,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Questions about this policy?',
                style: TextStyle(
                  color: kTextMuted, fontSize: 12, letterSpacing: 0.3,
                ),
              ),
            ]),
          ]),

          const SizedBox(height: 24),

          // Divider
          Container(height: 0.5, color: kBorder),
          const SizedBox(height: 20),

          // Contact rows
          _contactRow(Icons.email_rounded,        'info@pktcalltaxi.com'),
          const SizedBox(height: 12),
          _contactRow(Icons.phone_android_rounded, '76677 33771'),
          const SizedBox(height: 12),
          _contactRow(Icons.phone_android_rounded, '98942 04941'),
          const SizedBox(height: 12),
          _contactRow(Icons.phone_in_talk_rounded,  '0437 3252785'),
          const SizedBox(height: 12),
          _contactRow(Icons.location_on_rounded,   'Pattukkottai, Tamil Nadu, India'),

          const SizedBox(height: 20),
          Container(height: 0.5, color: kBorder),
          const SizedBox(height: 16),

          Text(
            'We will respond to all privacy-related inquiries within 3–5 business days.',
            style: const TextStyle(
              color: kTextMuted, fontSize: 12,
              height: 1.6, letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _contactRow(IconData icon, String text) {
    return Row(children: [
      Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          color: kGold.withOpacity(0.08),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: kBorder),
        ),
        child: Icon(icon, color: kGold, size: 14),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Text(
          text,
          style: const TextStyle(
            color: kTextPrimary, fontSize: 13,
            fontWeight: FontWeight.w500, letterSpacing: 0.2,
          ),
        ),
      ),
    ]);
  }

  // ══════════════════════════════════════════════════════════════
  //  FOOTER STRIP
  // ══════════════════════════════════════════════════════════════

  Widget _buildFooter(bool mobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: 20,
        horizontal: mobile ? 20 : 60,
      ),
      decoration: BoxDecoration(
        color: kPanel,
        border: Border(top: BorderSide(color: kBorder)),
      ),
      child: mobile
          ? Column(
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(
                    width: 22, height: 22,
                    decoration: BoxDecoration(
                      color: kGold, borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(Icons.directions_car,
                        color: kBg, size: 13),
                  ),
                  const SizedBox(width: 8),
                  const Text('PKT CALL TAXI',
                      style: TextStyle(
                        color: kGold, fontSize: 10,
                        fontWeight: FontWeight.w800, letterSpacing: 2,
                      )),
                ]),
                const SizedBox(height: 8),
                const Text(
                  '© 2025 PKT Call Taxi · All Rights Reserved',
                  style: TextStyle(
                      color: kTextMuted, fontSize: 10, letterSpacing: 0.3),
                  textAlign: TextAlign.center,
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  Container(
                    width: 24, height: 24,
                    decoration: BoxDecoration(
                      color: kGold, borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(Icons.directions_car,
                        color: kBg, size: 14),
                  ),
                  const SizedBox(width: 10),
                  const Text('PKT CALL TAXI',
                      style: TextStyle(
                        color: kGold, fontSize: 11,
                        fontWeight: FontWeight.w800, letterSpacing: 2,
                      )),
                ]),
                const Text(
                  '© 2025 PKT Call Taxi · All Rights Reserved',
                  style: TextStyle(
                      color: kTextMuted, fontSize: 11, letterSpacing: 0.5),
                ),
                Row(children: const [
                  Text('Privacy Policy',
                      style: TextStyle(
                        color: kGold, fontSize: 11,
                        fontWeight: FontWeight.w600,
                      )),
                ]),
              ],
            ),
    );
  }
}