import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pktwebsite/widgets/search_box_widget.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pktwebsite/widgets/send_driver_push_notification.dart';

// ══════════════════════════════════════════════════════════════
//  LUXURY BLACK & GOLD THEME — PKT CALL TAXI
//  UI: Full redesign with Black & Gold luxury aesthetic
//  Logic: Firebase, Maps, Tariff — 100% untouched
// ══════════════════════════════════════════════════════════════

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> with TickerProviderStateMixin {
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
  static const Color kBorderHov   = Color(0x55C9A84C);

  // ── Controllers & Firebase Logic (UNCHANGED) ─────────────────
  final nameController     = TextEditingController();
  final phoneController    = TextEditingController();
  final pickupController   = TextEditingController();
  final dropController     = TextEditingController();

  String _mainMode        = 'LOCAL';
  String _tripType        = 'Drop';
  double distanceKm       = 0.0;
  double displayedKm      = 0.0;
  double? fareAmount;
  int?   selectedCarIndex;
  String? carName;
  int? _selectedHours;
  TimeOfDay? selectedTime;
  DateTime? returnDate;
  DateTime? selectedDate;
  List<Map<String, dynamic>> tariffs      = [];
  StreamSubscription<QuerySnapshot>? _tariffSub;
  List<dynamic> pickupSuggestions         = [];
  List<dynamic> dropSuggestions           = [];

  // ── Map Variables (UNCHANGED) ────────────────────────────────
  GoogleMapController? mapController;
  LatLng _chennaiCenter = const LatLng(13.0827, 80.2707);
  Set<Marker>   _markers   = {};
  Set<Polyline> _polylines = {};
  LatLng? _pickupLatLng;
  LatLng? _dropLatLng;

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _startTariffListener();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _tariffSub?.cancel();
    nameController.dispose();
    phoneController.dispose();
    pickupController.dispose();
    dropController.dispose();
    super.dispose();
  }

  // ══════════════════════════════════════════════════════════════
  //  FIREBASE & MAP LOGIC — 100% ORIGINAL, UNTOUCHED
  // ══════════════════════════════════════════════════════════════

  void _startTariffListener() {
    if (_mainMode.isEmpty || _tripType.isEmpty) return;
    _tariffSub?.cancel();

    bool isLocalPackage = _mainMode.toUpperCase() == 'LOCAL' &&
        (_tripType.toLowerCase() == 'package' || _tripType == 'PackageMatrix');

    String path = isLocalPackage
        ? 'tariffs/LOCAL/PackageMatrix'
        : 'tariffs/$_mainMode/${_tripType.replaceAll(" ", "")}';

    final ref = FirebaseFirestore.instance.collection(path);

    _tariffSub = ref.snapshots().listen((snap) {
      if (!mounted) return;

      List<Map<String, dynamic>> fetchedTariffs = snap.docs.map((d) {
        final data = d.data();
        return {
          'id': d.id,
          'category': data['category'] ?? d.id,
          'iconUrl': data['iconUrl'] ?? '',
          'fullData': data,
          'cost': (data['cost'] ?? 0).toDouble(),
          'perKm': (data['perKm'] ?? 0).toDouble(),
          'hrCost': (data['hrCost'] ?? 0).toDouble(),
          'minKm': (data['minKm'] ?? 0).toDouble(),
        };
      }).toList();

      fetchedTariffs.sort((a, b) =>
          a['category'].toString().compareTo(b['category'].toString()));

      setState(() {
        tariffs = fetchedTariffs;
        _calculateFare();
      });
    });
  }

  Future<void> _fetchSuggestions(String input, bool isPickup) async {
    if (input.isEmpty) {
      setState(() => isPickup ? pickupSuggestions = [] : dropSuggestions = []);
      return;
    }

    if (_debounce?.isActive ?? false) _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 300), () async {
      try {
        final url = Uri.parse('https://us-central1-pktcalltaxiapp.cloudfunctions.net/mapsapi?input=${Uri.encodeComponent(input)}');

        final res = await http.get(url);
        
        if (res.statusCode == 200) {
          final data = json.decode(res.body);
          if (mounted && data['predictions'] != null) {
            setState(() {
              if (isPickup) {
                pickupSuggestions = data['predictions'];
              } else {
                dropSuggestions = data['predictions'];
              }
            });
          }
        }
      } catch (e) {
        print("Maps API Fetch Error: $e");
      }
    });
  }

  Future<void> _selectPlace(String placeId, String description, bool isPickup) async {
    

    try {
      final url = Uri.parse('https://us-central1-pktcalltaxiapp.cloudfunctions.net/placeDetailsapi?place_id=$placeId');

      final res = await http.get(url);

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        
        if (data['status'] == 'OK') {
          final loc = data['result']['geometry']['location'];
          final latLng = LatLng(loc['lat'], loc['lng']);

          setState(() {
            if (isPickup) {
              pickupController.text = description;
              _pickupLatLng = latLng;
              pickupSuggestions = [];
            } else {
              dropController.text = description;
              _dropLatLng = latLng;
              dropSuggestions = [];
            }
          });
          FocusScope.of(context).unfocus();

          if (_pickupLatLng != null && _dropLatLng != null) {
            _getDistance();
          }
        } else {
          _showLuxurySnackBar("API Status Error: ${data['status']}", isError: true);
        }
      } else {
        _showLuxurySnackBar("Server error: ${res.statusCode}", isError: true);
      }
    } catch (e) {
      _showLuxurySnackBar("Location error: $e", isError: true);
    }
    _updateMapElements();
  }

  Future<void> _getDistance() async {
    if (_pickupLatLng == null || _dropLatLng == null) return;

    try {
      final url = Uri.parse(
        'https://us-central1-pktcalltaxiapp.cloudfunctions.net/distanceapi?origins=${_pickupLatLng!.latitude},${_pickupLatLng!.longitude}&destinations=${_dropLatLng!.latitude},${_dropLatLng!.longitude}');  

      final res = await http.get(url);

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        
        if (data['status'] == 'OK' && 
            data['rows'] != null && 
            data['rows'][0]['elements'][0]['status'] == 'OK') {
          
          setState(() {
            distanceKm = data['rows'][0]['elements'][0]['distance']['value'] / 1000.0;
          });
          
          _calculateFare();
        } else {
          print("Distance API Status Error: ${data['status']}");
        }
      }
    } catch (e) {
      print("Distance error macha: $e");
    }
  }

  void _calculateFare() {
    if (tariffs.isEmpty || selectedCarIndex == null) {
      setState(() => fareAmount = null);
      return;
    }

    final t = tariffs[selectedCarIndex!];
    double distanceToCharge = 0.0;
    double cost = (t['cost'] ?? 0).toDouble();
    double perKm = (t['perKm'] ?? 0).toDouble();

    // Local Package Logic
    if (_mainMode.toUpperCase() == 'LOCAL' &&
        _tripType.toLowerCase().contains('package')) {
      if (_selectedHours == null) {
        setState(() {
          fareAmount = null;
          displayedKm = 0.0;
        });
        return;
      }
      var hourKey = _selectedHours.toString();
      var packageMap = t['fullData'] as Map<String, dynamic>;
      if (packageMap.containsKey(hourKey)) {
        var selectedPackage = packageMap[hourKey];
        double amount = (selectedPackage['amount'] ?? 0).toDouble();
        fareAmount = (amount / 5).ceil() * 5.0;
        displayedKm = (selectedPackage['uptoKm'] ?? 0).toDouble();
      }
      setState(() {});
      return;
    }

    if (distanceKm == 0.0) {
      setState(() => displayedKm = 0.0);
      return;
    }

    // Outstation Logic
    if (_mainMode.toUpperCase() == 'OUTSTATION') {
      if (_tripType.toLowerCase().contains('one')) {
        distanceToCharge = distanceKm < 130.0 ? 130.0 : distanceKm;
        displayedKm = distanceKm;
        double fare = cost + (distanceToCharge * perKm);
        fareAmount = (fare / 5).ceil() * 5.0;
      } else if (_tripType.toLowerCase().contains('round')) {
        if (selectedDate != null && selectedTime != null && returnDate != null) {
          DateTime pickupDateTime = DateTime(selectedDate!.year,
              selectedDate!.month, selectedDate!.day, selectedTime!.hour, selectedTime!.minute);
          DateTime returnDateTime = DateTime(returnDate!.year,
              returnDate!.month, returnDate!.day, selectedTime!.hour, selectedTime!.minute);
          int hourDiff = returnDateTime.difference(pickupDateTime).inHours;
          int days = (hourDiff / 24).ceil();
          if (days < 1) days = 1;
          double minKmPerDay = 250.0;
          double totalMinKm = days * minKmPerDay;
          double actualKm = distanceKm * 2;
          distanceToCharge = actualKm > totalMinKm ? actualKm : totalMinKm;
          displayedKm = distanceKm;
          double fare = (cost * days) + (distanceToCharge * perKm);
          fareAmount = (fare / 5).ceil() * 5.0;
        }
      }
    } else {
      // Local Drop
      double minKm = (t['minKm'] ?? 0).toDouble();
      distanceToCharge = distanceKm < minKm ? minKm : distanceKm;
      displayedKm = distanceKm;
      double fare = cost + (distanceToCharge * perKm);
      fareAmount = (fare / 5).ceil() * 5.0;
    }
    setState(() {});
  }

  void _updateMapElements() {
    if (!mounted) return;
    setState(() {
      _markers.clear();
      _polylines.clear();
      if (_pickupLatLng != null) {
        _markers.add(Marker(
          markerId: const MarkerId('pickup'),
          position: _pickupLatLng!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
        ));
      }
      if (_dropLatLng != null) {
        _markers.add(Marker(
          markerId: const MarkerId('drop'),
          position: _dropLatLng!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        ));
      }
      if (_pickupLatLng != null && _dropLatLng != null) {
        _polylines.add(Polyline(
          polylineId: const PolylineId('route'),
          points: [_pickupLatLng!, _dropLatLng!],
          color: kGold,
          width: 4,
        ));
        _fitMapToMarkers();
      } else if (_pickupLatLng != null) {
        mapController?.animateCamera(CameraUpdate.newLatLngZoom(_pickupLatLng!, 14));
      }
    });
  }

  void _fitMapToMarkers() {
  if (_pickupLatLng == null || _dropLatLng == null || mapController == null) return;

  final double minLat = _pickupLatLng!.latitude < _dropLatLng!.latitude
      ? _pickupLatLng!.latitude : _dropLatLng!.latitude;
  final double maxLat = _pickupLatLng!.latitude > _dropLatLng!.latitude
      ? _pickupLatLng!.latitude : _dropLatLng!.latitude;
  final double minLng = _pickupLatLng!.longitude < _dropLatLng!.longitude
      ? _pickupLatLng!.longitude : _dropLatLng!.longitude;
  final double maxLng = _pickupLatLng!.longitude > _dropLatLng!.longitude
      ? _pickupLatLng!.longitude : _dropLatLng!.longitude;

  final bounds = LatLngBounds(
    southwest: LatLng(minLat, minLng),
    northeast: LatLng(maxLat, maxLng),
  );

  mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
}

 void _resetFields() {
  setState(() {
    nameController.clear();
    phoneController.clear();
    pickupController.clear();
    dropController.clear();
    selectedDate = null;
    selectedTime = null;
    returnDate = null;
    _selectedHours = null;
    distanceKm = 0.0;
    displayedKm = 0.0;
    fareAmount = null;
    selectedCarIndex = null;
    carName = null; // ✅ itha add pannu — vehicle selection clear aagum
    _pickupLatLng = null;
    _dropLatLng = null;
    pickupSuggestions = [];
    dropSuggestions = [];
    _markers.clear();   // ✅ markers clear
    _polylines.clear(); // ✅ polylines clear
  });

  // ✅ Map-ah Chennai default position ku reset pannu
  mapController?.animateCamera(
    CameraUpdate.newLatLngZoom(_chennaiCenter, 12),
  );
}

  // ══════════════════════════════════════════════════════════════
  //  LUXURY SNACKBAR — replaces _showProfessionalSnackBar
  // ══════════════════════════════════════════════════════════════

  void _showLuxurySnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 28),
        duration: const Duration(seconds: 3),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: kPanel,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isError
                  ? const Color(0x88E53935)
                  : const Color(0x88C9A84C),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isError
                    ? const Color(0x33E53935)
                    : const Color(0x33C9A84C),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon badge
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isError
                      ? const Color(0x22E53935)
                      : kGold.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isError
                        ? const Color(0x55E53935)
                        : kBorder,
                  ),
                ),
                child: Icon(
                  isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
                  color: isError ? const Color(0xFFE53935) : kGold,
                  size: 16,
                ),
              ),
              const SizedBox(width: 14),
              // Message
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isError ? 'ATTENTION' : 'SUCCESS',
                      style: TextStyle(
                        color: isError ? const Color(0xFFE53935) : kGold,
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      message,
                      style: const TextStyle(
                        color: kTextPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
              // Thin right accent bar
              Container(
                width: 2,
                height: 32,
                decoration: BoxDecoration(
                  color: isError ? const Color(0xFFE53935) : kGold,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmBooking() async {
    if (nameController.text.isEmpty ||
        phoneController.text.isEmpty ||
        pickupController.text.isEmpty) {
      _showLuxurySnackBar("Fill all mandatory fields.", isError: true);
      return;
    }
    if (selectedDate == null || selectedTime == null) {
      _showLuxurySnackBar("Select pickup date & time.", isError: true);
      return;
    }
    if (fareAmount == null || selectedCarIndex == null) {
      _showLuxurySnackBar("Select vehicle to calculate fare.", isError: true);
      return;
    }

    try {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => Center(
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: kPanel,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kBorder),
                  ),
                  child: const CircularProgressIndicator(color: kGold, strokeWidth: 2),
                ),
              ));

      final bookingId = FirebaseFirestore.instance.collection('bookings').doc().id;

      final driverSnapshot = await FirebaseFirestore.instance
          .collection('approved_drivers')
          .where('isOnline', isEqualTo: true)
          .get();

      if (driverSnapshot.docs.isEmpty) {
        Navigator.pop(context);
        _showLuxurySnackBar("No online drivers available", isError: true);
        return;
      }

      final notifiedDrivers = driverSnapshot.docs.map((d) => d.id).toList();

      final bookingData = {
        'booking_id': bookingId,
        'passenger_name': nameController.text.trim(),
        'passenger_phone': phoneController.text.trim(),
        'pickup_name': pickupController.text.trim(),
        'drop_name': dropController.text.trim(),
        'pickup_latlng': GeoPoint(_pickupLatLng!.latitude, _pickupLatLng!.longitude),
        'drop_latlng': _dropLatLng != null ? GeoPoint(_dropLatLng!.latitude, _dropLatLng!.longitude) : null,
        'final_fare': fareAmount,
        'distance': displayedKm,
        'trip_mode': _mainMode,
        'trip_type': _tripType,
        'car_name': tariffs[selectedCarIndex!]['category'],
        'booking_date': DateFormat('dd-MM-yyyy').format(selectedDate!),
        'booking_time': selectedTime!.format(context),
        'return_date': returnDate != null ? DateFormat('dd-MM-yyyy').format(returnDate!) : null,
        'status': 'PENDING',
        'timestamp': FieldValue.serverTimestamp(),
        'notified_drivers': notifiedDrivers,
      };

      WriteBatch batch = FirebaseFirestore.instance.batch();
      batch.set(FirebaseFirestore.instance.collection('bookings').doc(bookingId), bookingData);

      for (var d in driverSnapshot.docs) {
        final dRef = FirebaseFirestore.instance
            .collection('approved_drivers')
            .doc(d.id)
            .collection('incoming_requests')
            .doc(bookingId);
        batch.set(dRef, bookingData);

        final token = d.data()['fcmToken'];
        if (token != null) {
          sendDriverPushNotification(token, bookingId, pickupController.text, dropController.text);
        }
      }

      await batch.commit();
      Navigator.pop(context);
      _showLuxurySnackBar("Booking shared with drivers! 🚀");
      _resetFields();
    } catch (e) {
      if (Navigator.canPop(context)) Navigator.pop(context);
      _showLuxurySnackBar("Error: $e", isError: true);
    }
  }

  // ══════════════════════════════════════════════════════════════
  //  LUXURY UI — BLACK & GOLD
  // ══════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final screenWidth  = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Material(
      color: kBg,
      child: SizedBox(
        width: screenWidth,
        height: screenHeight,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── LEFT PANEL: Booking Form ────────────────────────
            Expanded(
              flex: 4,
              child: Container(
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: kPanel,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: kBorder),
                ),
                child: Column(
                  children: [
                    _buildPanelHeader(),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        physics: const BouncingScrollPhysics(),
                        children: [
                          _buildTripSettings(),
                          const SizedBox(height: 16),
                          _buildCustomerInfo(),
                          const SizedBox(height: 16),
                          _buildRouteSection(),
                          const SizedBox(height: 16),
                          _buildVehicleSection(),
                          _buildGoldDivider(),
                          _buildFarePanel(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── RIGHT PANEL: Map ────────────────────────────────
            Expanded(
              flex: 6,
              child: Container(
                margin: const EdgeInsets.fromLTRB(0, 12, 12, 12),
                decoration: BoxDecoration(
                  color: kPanel,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: kBorder),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      GoogleMap(
                        initialCameraPosition: CameraPosition(target: _chennaiCenter, zoom: 12),
                        onMapCreated: (c) => mapController = c,
                        markers:   _markers,
                        polylines: _polylines,
                        myLocationButtonEnabled: false,
                        zoomControlsEnabled: true,
                        mapType: MapType.normal,
                      ),
                      // Map overlay badge
                      Positioned(
                        top: 16, left: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: kPanel.withOpacity(0.92),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: kBorder),
                          ),
                          child: Row(children: const [
                            Icon(Icons.map_outlined, color: kGold, size: 13),
                            SizedBox(width: 8),
                            Text('LIVE ROUTE', style: TextStyle(
                              color: kGold, fontSize: 10,
                              fontWeight: FontWeight.w700, letterSpacing: 2,
                            )),
                          ]),
                        ),
                      ),
                      // Distance badge — shown only when route is set
                      if (distanceKm > 0)
                        Positioned(
                          bottom: 20, left: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: kPanel.withOpacity(0.95),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: kBorder),
                            ),
                            child: Row(children: [
                              const Icon(Icons.straighten, color: kGold, size: 13),
                              const SizedBox(width: 8),
                              Text(
                                '${distanceKm.toStringAsFixed(1)} km',
                                style: const TextStyle(
                                  color: kGold, fontSize: 13,
                                  fontWeight: FontWeight.w700, letterSpacing: 1,
                                ),
                              ),
                            ]),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  LUXURY DATE / TIME / PACKAGE PICKERS
  // ══════════════════════════════════════════════════════════════

  /// Gold-themed date picker tile
  Widget _buildLuxuryDatePicker({required bool isReturn}) {
    final hasValue = isReturn ? returnDate != null : selectedDate != null;
    final label    = isReturn ? 'RETURN DATE' : 'PICKUP DATE';
    final display  = hasValue
        ? DateFormat('dd MMM yyyy').format(isReturn ? returnDate! : selectedDate!)
        : (isReturn ? 'Select Return' : 'Select Date');

    return GestureDetector(
      onTap: () async {
        final d = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 90)),
          builder: (context, child) => Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: const ColorScheme.dark(
                primary: kGold,
                onPrimary: kBg,
                surface: kPanel,
                onSurface: kTextPrimary,
              ),
              dialogBackgroundColor: kPanel,
            ),
            child: child!,
          ),
        );
        if (d != null) {
          setState(() => isReturn ? returnDate = d : selectedDate = d);
          _calculateFare();
        }
      },
      child: _luxuryPickerTile(
        label: label,
        display: display,
        icon: Icons.calendar_today_outlined,
        hasValue: hasValue,
      ),
    );
  }

  /// Gold-themed time picker tile
  Widget _buildLuxuryTimePicker() {
    final hasValue = selectedTime != null;
    final display  = hasValue ? selectedTime!.format(context) : 'Select Time';

    return GestureDetector(
      onTap: () async {
        final t = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
          builder: (context, child) => Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: const ColorScheme.dark(
                primary: kGold,
                onPrimary: kBg,
                surface: kPanel,
                onSurface: kTextPrimary,
              ),
              dialogBackgroundColor: kPanel,
            ),
            child: child!,
          ),
        );
        if (t != null) {
          setState(() => selectedTime = t);
          _calculateFare();
        }
      },
      child: _luxuryPickerTile(
        label: 'PICKUP TIME',
        display: display,
        icon: Icons.access_time_outlined,
        hasValue: hasValue,
      ),
    );
  }

  /// Gold-themed package hour dropdown
  Widget _buildLuxuryPackageHours() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('DURATION'),
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: kCardBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _selectedHours != null ? kGold.withOpacity(0.5) : kBorder,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton2<int>(
              isExpanded: true,
              hint: Row(children: [
                const Icon(Icons.timer_outlined, color: kGoldDim, size: 14),
                const SizedBox(width: 10),
                Text(
                  _selectedHours != null
                      ? '$_selectedHours ${_selectedHours == 1 ? 'Hour' : 'Hours'}'
                      : 'Select Duration',
                  style: TextStyle(
                    color: _selectedHours != null ? kTextPrimary : kTextMuted,
                    fontSize: 12,
                    letterSpacing: 0.4,
                  ),
                ),
              ]),
              items: List.generate(10, (i) => i + 1).map((hour) {
                final bool isSelected = _selectedHours == hour;
                return DropdownMenuItem<int>(
                  value: hour,
                  child: Row(children: [
                    Icon(
                      Icons.timer_outlined,
                      color: isSelected ? kGold : kGoldDim,
                      size: 13,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '$hour ${hour == 1 ? 'Hour' : 'Hours'}',
                      style: TextStyle(
                        color: isSelected ? kGold : kTextPrimary,
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ]),
                );
              }).toList(),
              value: _selectedHours,
              onChanged: (value) {
                setState(() => _selectedHours = value);
                _calculateFare();
              },
              buttonStyleData: const ButtonStyleData(
                height: 50,
                padding: EdgeInsets.symmetric(horizontal: 14),
              ),
              dropdownStyleData: DropdownStyleData(
                maxHeight: 260,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: kPanel,
                  border: Border.all(color: kBorder),
                ),
                scrollbarTheme: ScrollbarThemeData(
                  radius: const Radius.circular(40),
                  thickness: WidgetStateProperty.all(2),
                  thumbVisibility: WidgetStateProperty.all(true),
                  thumbColor: WidgetStateProperty.all(kGoldDim),
                ),
              ),
              menuItemStyleData: const MenuItemStyleData(
                height: 40,
                padding: EdgeInsets.symmetric(horizontal: 14),
              ),
              iconStyleData: const IconStyleData(
                icon: Icon(Icons.keyboard_arrow_down_rounded, color: kGoldDim, size: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Shared picker tile shape (date/time)
  Widget _luxuryPickerTile({
    required String label,
    required String display,
    required IconData icon,
    required bool hasValue,
  }) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: hasValue ? kGold.withOpacity(0.5) : kBorder,
        ),
      ),
      child: Row(children: [
        Icon(icon, color: hasValue ? kGold : kGoldDim, size: 14),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label, style: const TextStyle(
                color: kTextMuted, fontSize: 7,
                fontWeight: FontWeight.w700, letterSpacing: 1.8,
              )),
              const SizedBox(height: 2),
              Text(display, style: TextStyle(
                color: hasValue ? kTextPrimary : kTextMuted,
                fontSize: 12,
                fontWeight: hasValue ? FontWeight.w500 : FontWeight.w400,
                letterSpacing: 0.3,
              )),
            ],
          ),
        ),
        Icon(
          Icons.keyboard_arrow_down_rounded,
          color: kGoldDim,
          size: 16,
        ),
      ]),
    );
  }

  // ── Panel Header ──────────────────────────────────────────────
  Widget _buildPanelHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: kBorder)),
      ),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: kGold,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.directions_car, color: kBg, size: 18),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('PKT CALL TAXI', style: TextStyle(
                color: kGold, fontSize: 13,
                fontWeight: FontWeight.w900, letterSpacing: 2.5,
              )),
              Text('Premium Chauffeur Service', style: TextStyle(
                color: kTextMuted, fontSize: 9, letterSpacing: 1.5,
              )),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: kGold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: kBorder),
            ),
            child: const Text('24/7', style: TextStyle(
              color: kGold, fontSize: 10,
              fontWeight: FontWeight.w700, letterSpacing: 1.5,
            )),
          ),
        ],
      ),
    );
  }

  // ── Trip Settings ─────────────────────────────────────────────
  Widget _buildTripSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        _sectionLabel('TRIP SETTINGS'),
        Row(children: [
          Expanded(child: _luxuryDropdown(
            _mainMode, ['LOCAL', 'OUTSTATION'],
            Icons.route_outlined, (v) {
              setState(() {
                _mainMode = v!;
                _tripType = _mainMode == 'LOCAL' ? 'Drop' : 'OneWay';
                selectedCarIndex = null;
              });
              _startTariffListener();
            },
          )),
          const SizedBox(width: 10),
          Expanded(child: _luxuryDropdown(
            _tripType,
            _mainMode == 'LOCAL' ? ['Drop', 'Package'] : ['OneWay', 'RoundTrip'],
            Icons.swap_horiz_outlined, (v) {
              setState(() { _tripType = v!; selectedCarIndex = null; });
              _startTariffListener();
            },
          )),
        ]),
      ],
    );
  }

  // ── Customer Info ─────────────────────────────────────────────
  Widget _buildCustomerInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('PASSENGER DETAILS'),
        _luxuryInput('Passenger Name', nameController, Icons.person_outline),
        const SizedBox(height: 8),
        _luxuryInput('Phone Number', phoneController, Icons.phone_android_outlined),
      ],
    );
  }

  // ── Route Section ─────────────────────────────────────────────
  Widget _buildRouteSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('ROUTE DETAILS'),

        // PICKUP
        SearchBoxWidget(
          controller: pickupController,
          suggestions: pickupSuggestions,
          onTextChanged: (val, _) => _fetchSuggestions(val, true),
          onPlaceSelected: (id, desc, _) => _selectPlace(id, desc, true),
          hint: 'Pickup Location',
          isPickup: true,
        ),

        // DROP (hide for Package)
        if (!(_mainMode == 'LOCAL' && _tripType == 'Package')) ...[
          const SizedBox(height: 8),
          SearchBoxWidget(
            controller: dropController,
            suggestions: dropSuggestions,
            onTextChanged: (val, _) => _fetchSuggestions(val, false),
            onPlaceSelected: (id, desc, _) => _selectPlace(id, desc, false),
            hint: 'Drop Location',
            isPickup: false,
          ),
        ],

        const SizedBox(height: 10),

        // DATE & TIME — side by side
        Row(children: [
          Expanded(child: _buildLuxuryDatePicker(isReturn: false)),
          const SizedBox(width: 8),
          Expanded(child: _buildLuxuryTimePicker()),
        ]),

        // RETURN DATE (only RoundTrip)
        if (_mainMode == 'OUTSTATION' && _tripType == 'RoundTrip') ...[
          const SizedBox(height: 8),
          _buildLuxuryDatePicker(isReturn: true),
        ],

        // PACKAGE HOURS (only Local Package)
        if (_mainMode == 'LOCAL' && _tripType == 'Package') ...[
          const SizedBox(height: 12),
          _buildLuxuryPackageHours(),
        ],
      ],
    );
  }

  // ── Vehicle Section ───────────────────────────────────────────
  Widget _buildVehicleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('VEHICLE CLASS'),
        _buildLuxuryVehicleList(),
      ],
    );
  }

  Widget _buildLuxuryVehicleList() {
    if (tariffs.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(children: const [
          Icon(Icons.info_outline, color: kTextMuted, size: 12),
          SizedBox(width: 8),
          Text('Select route to view vehicles',
              style: TextStyle(color: kTextMuted, fontSize: 10, letterSpacing: 0.5)),
        ]),
      );
    }

    // 🔥 Original strict order — UNTOUCHED
    final List<String> order = ['SEDAN', 'ETIOS', 'SUV', 'INNOVA'];
    final List<Map<String, dynamic>> sortedTariffs = List.from(tariffs);
    sortedTariffs.sort((a, b) {
      int iA = order.indexOf(a['category'].toString().toUpperCase());
      int iB = order.indexOf(b['category'].toString().toUpperCase());
      if (iA == -1) iA = 99;
      if (iB == -1) iB = 99;
      return iA.compareTo(iB);
    });

    Map<String, IconData> vehicleIcons = {
      'SEDAN':  Icons.directions_car_outlined,
      'ETIOS':  Icons.directions_car,
      'SUV':    Icons.airport_shuttle_outlined,
      'INNOVA': Icons.directions_bus_outlined,
    };

    return Container(
      margin: const EdgeInsets.only(top: 6, bottom: 4),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: sortedTariffs.map((tariff) {
          final String category  = tariff['category'].toString().toUpperCase();
          final bool   isSelected = (carName == category);
          final IconData icon    = vehicleIcons[category] ?? Icons.directions_car_outlined;

          return GestureDetector(
            onTap: () {
              setState(() {
                carName          = category;
                selectedCarIndex = tariffs.indexOf(tariff);
              });
              _calculateFare();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? kGold.withOpacity(0.12) : kCardBg,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isSelected ? kGold : kBorder,
                  width: isSelected ? 1.0 : 0.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon,
                    color: isSelected ? kGold : kTextMuted,
                    size: 13,
                  ),
                  const SizedBox(width: 7),
                  Text(
                    category,
                    style: TextStyle(
                      color:      isSelected ? kGold : kTextMuted,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                      fontSize:   11,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Gold Divider ──────────────────────────────────────────────
  Widget _buildGoldDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(children: [
        Expanded(child: Container(height: 0.5, color: kBorder)),
        Container(
          width: 6, height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 10),
          decoration: const BoxDecoration(color: kGold, shape: BoxShape.circle),
        ),
        Expanded(child: Container(height: 0.5, color: kBorder)),
      ]),
    );
  }

  // ── Fare Panel ────────────────────────────────────────────────
  Widget _buildFarePanel() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: kCardBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: kBorder),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('ESTIMATED FARE', style: TextStyle(
                    color: kTextMuted, fontSize: 9,
                    fontWeight: FontWeight.w700, letterSpacing: 1.5,
                  )),
                  const SizedBox(height: 4),
                  if (distanceKm > 0)
                    Text('${distanceKm.toStringAsFixed(1)} km',
                      style: const TextStyle(color: kTextMuted, fontSize: 10, letterSpacing: 0.5)),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  const Text('₹ ', style: TextStyle(color: kGoldDim, fontSize: 14, fontWeight: FontWeight.w500)),
                  Text(
                    fareAmount?.toStringAsFixed(0) ?? '—',
                    style: const TextStyle(
                      color: kGold, fontSize: 32,
                      fontWeight: FontWeight.w900, letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _confirmBooking,
            style: ElevatedButton.styleFrom(
              backgroundColor: kGold,
              foregroundColor: kBg,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.directions_car, size: 15, color: kBg),
                SizedBox(width: 10),
                Text('CONFIRM RIDE', style: TextStyle(
                  color: kBg, fontSize: 12,
                  fontWeight: FontWeight.w900, letterSpacing: 2.5,
                )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  REUSABLE LUXURY COMPONENTS
  // ══════════════════════════════════════════════════════════════

  Widget _sectionLabel(String label) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(children: [
      Container(width: 2, height: 10, color: kGold, margin: const EdgeInsets.only(right: 8)),
      Text(label, style: const TextStyle(
        color: kGold, fontSize: 9,
        fontWeight: FontWeight.w900, letterSpacing: 2,
      )),
    ]),
  );

  Widget _luxuryInput(String hint, TextEditingController ctrl, IconData icon) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: kBorder),
      ),
      child: TextField(
        controller: ctrl,
        style: const TextStyle(color: kTextPrimary, fontSize: 13, letterSpacing: 0.3),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: kGoldDim, size: 15),
          hintText: hint,
          hintStyle: const TextStyle(color: kTextMuted, fontSize: 12),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 13),
        ),
      ),
    );
  }

  Widget _luxuryDropdown(
    String val,
    List<String> items,
    IconData prefixIcon,
    Function(String?) onCh,
  ) {
    return DropdownButtonHideUnderline(
      child: DropdownButton2<String>(
        isExpanded: true,
        hint: Row(children: [
          Icon(prefixIcon, color: kGoldDim, size: 13),
          const SizedBox(width: 8),
          Text('Select', style: TextStyle(fontSize: 11, color: kTextMuted)),
        ]),
        items: items.map((item) => DropdownMenuItem<String>(
          value: item,
          child: Row(children: [
            Icon(prefixIcon, color: kGoldDim, size: 13),
            const SizedBox(width: 8),
            Text(item, style: const TextStyle(
              fontSize: 11, fontWeight: FontWeight.w700,
              color: kTextPrimary, letterSpacing: 0.8,
            )),
          ]),
        )).toList(),
        value: val,
        onChanged: onCh,
        buttonStyleData: ButtonStyleData(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: kCardBg,
            border: Border.all(color: kBorder),
          ),
        ),
        dropdownStyleData: DropdownStyleData(
          maxHeight: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: kPanel,
            border: Border.all(color: kBorder),
          ),
          scrollbarTheme: ScrollbarThemeData(
            radius: const Radius.circular(40),
            thickness: WidgetStateProperty.all(3),
            thumbVisibility: WidgetStateProperty.all(true),
          ),
        ),
        menuItemStyleData: const MenuItemStyleData(
          height: 38,
          padding: EdgeInsets.symmetric(horizontal: 14),
        ),
        iconStyleData: const IconStyleData(
          icon: Icon(Icons.keyboard_arrow_down, color: kGoldDim, size: 16),
        ),
      ),
    );
  }
}