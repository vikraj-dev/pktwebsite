import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pktwebsite/widgets/search_box_widget.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:pktwebsite/widgets/send_driver_push_notification.dart';


class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  // --- Controllers ---
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final pickupController = TextEditingController();
  final dropController = TextEditingController();

  // --- State Variables ---
  String _mainMode = 'LOCAL';
  String _tripType = 'Drop';
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  DateTime? returnDate;
  int? _selectedHours;

  double distanceKm = 0.0;
  double displayedKm = 0.0;
  double? fareAmount;
  int? selectedCarIndex;
  String? carName;

  List<Map<String, dynamic>> tariffs = [];
  StreamSubscription<QuerySnapshot>? _tariffSub;
  List<dynamic> pickupSuggestions = [];
  List<dynamic> dropSuggestions = [];
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

  // ====================== LOGIC METHODS ======================

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
          'fullData': data,
          'cost': (data['cost'] ?? 0).toDouble(),
          'perKm': (data['perKm'] ?? 0).toDouble(),
          'minKm': (data['minKm'] ?? 0).toDouble(),
        };
      }).toList();

      fetchedTariffs.sort((a, b) => a['category'].toString().compareTo(b['category'].toString()));

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
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        final url = Uri.parse('https://us-central1-pktcalltaxiapp.cloudfunctions.net/mapsapi?input=${Uri.encodeComponent(input)}');
        final res = await http.get(url);
        if (res.statusCode == 200) {
          final data = json.decode(res.body);
          if (mounted && data['predictions'] != null) {
            setState(() {
              if (isPickup) pickupSuggestions = data['predictions'];
              else dropSuggestions = data['predictions'];
            });
          }
        }
      } catch (e) { debugPrint("Maps Error: $e"); }
    });
  }

  Future<void> _selectPlace(String placeId, String description, bool isPickup) async {
    try {
      final url = Uri.parse('https://us-central1-pktcalltaxiapp.cloudfunctions.net/placeDetailsapi?place_id=$placeId');
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
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
        if (_pickupLatLng != null && _dropLatLng != null) _getDistance();
      }
    } catch (e) { _showSnackBar("Location error", true); }
  }

  Future<void> _getDistance() async {
    if (_pickupLatLng == null || _dropLatLng == null) return;
    try {
      final url = Uri.parse('https://us-central1-pktcalltaxiapp.cloudfunctions.net/distanceapi?origins=${_pickupLatLng!.latitude},${_pickupLatLng!.longitude}&destinations=${_dropLatLng!.latitude},${_dropLatLng!.longitude}');
      final res = await http.get(url);
      final data = json.decode(res.body);
      if (data['status'] == 'OK') {
        setState(() {
          distanceKm = data['rows'][0]['elements'][0]['distance']['value'] / 1000.0;
        });
        _calculateFare();
      }
    } catch (e) { debugPrint("Distance Error: $e"); }
  }

  void _calculateFare() {
    if (tariffs.isEmpty || selectedCarIndex == null) {
      setState(() => fareAmount = null);
      return;
    }
    final t = tariffs[selectedCarIndex!];
    double cost = t['cost'];
    double perKm = t['perKm'];

    if (_mainMode == 'LOCAL' && _tripType == 'Package') {
      if (_selectedHours == null) return;
      var pkg = t['fullData'][_selectedHours.toString()];
      if (pkg != null) {
        fareAmount = (pkg['amount'].toDouble() / 5).ceil() * 5.0;
        displayedKm = pkg['uptoKm'].toDouble();
      }
      setState(() {});
      return;
    }

    if (distanceKm == 0) return;

    if (_mainMode == 'OUTSTATION') {
      if (_tripType == 'OneWay') {
        double dist = distanceKm < 130 ? 130 : distanceKm;
        fareAmount = ((cost + (dist * perKm)) / 5).ceil() * 5.0;
      } else {
        if (selectedDate != null && returnDate != null) {
          int days = returnDate!.difference(selectedDate!).inDays;
          if (days < 1) days = 1;
          double dist = (distanceKm * 2) < (days * 250) ? (days * 250) : (distanceKm * 2);
          fareAmount = (((cost * days) + (dist * perKm)) / 5).ceil() * 5.0;
        }
      }
    } else {
      double dist = distanceKm < t['minKm'] ? t['minKm'] : distanceKm;
      fareAmount = ((cost + (dist * perKm)) / 5).ceil() * 5.0;
    }
    displayedKm = distanceKm;
    setState(() {});
  }

  // ====================== UI DESIGN (CONTAINER BASED) ======================

  @override
Widget build(BuildContext context) {
  // Material wrapper is MANDATORY when not using Scaffold
  return Material(
    type: MaterialType.transparency, // Background image theriyanum la, so transparency
    child: Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Stack(
        children: [
          // Background Image
          PositionImageBackground(),
          
          // Main UI
          SelectionArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
              child: Center(
                child: ConstrainedBox(
                  // Center-la fix panna intha constraint romba mukkiyam
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: RepaintBoundary(
                    child: GlassCard(
                      child: Column(
                        mainAxisSize: MainAxisSize.min, // Content-ku thaguve maathiri scroll aagum
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 30),
                          _buildCustomerInfo(),
                          const SizedBox(height: 25),
                          _buildTripConfigs(),
                          const SizedBox(height: 25),
                          _buildLocationPickers(),
                          const SizedBox(height: 25),
                          _buildDatePickers(),
                          const SizedBox(height: 30),
                          _buildVehicleSelection(),
                          const SizedBox(height: 40),
                          _buildFarePanel(),
                          const SizedBox(height: 40),
                          _buildActionButtons(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  // --- UI Components ---

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: const Color(0xFF134E4A), borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.local_taxi, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 15),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("PKT Call Taxi", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
            Text("Premium Portal • Ride Safe", style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    );
  }

  Widget _buildCustomerInfo() {
    return Row(
      children: [
        Expanded(child: _buildTextField("Full Name", nameController, Icons.person_outline)),
        const SizedBox(width: 15),
        Expanded(child: _buildTextField("Mobile Number", phoneController, Icons.phone_android_outlined)),
      ],
    );
  }

  Widget _buildTripConfigs() {
    return Row(
      children: [
        Expanded(child: _buildDropdown("Mode", _mainMode, ['LOCAL', 'OUTSTATION'], (v) {
          setState(() { 
            _mainMode = v!; 
            _tripType = _mainMode == 'LOCAL' ? 'Drop' : 'OneWay'; 
            selectedCarIndex = null;
            fareAmount = null;
          });
          _startTariffListener();
        })),
        const SizedBox(width: 15),
        Expanded(child: _buildDropdown("Type", _tripType, _mainMode == 'LOCAL' ? ['Drop', 'Package'] : ['OneWay', 'RoundTrip'], (v) {
          setState(() {
            _tripType = v!;
            selectedCarIndex = null;
            fareAmount = null;
          });
          _startTariffListener();
        })),
      ],
    );
  }

  Widget _buildLocationPickers() {
    return Column(
      children: [
        SearchBoxWidget(
          controller: pickupController,
          suggestions: pickupSuggestions,
          onTextChanged: (val, _) => _fetchSuggestions(val, true),
          onPlaceSelected: (id, desc, _) => _selectPlace(id, desc, true),
          hint: "Pickup Address",
        ),
        if (_tripType != 'Package') ...[
          const SizedBox(height: 20),
          SearchBoxWidget(
            controller: dropController,
            suggestions: dropSuggestions,
            onTextChanged: (val, _) => _fetchSuggestions(val, false),
            onPlaceSelected: (id, desc, _) => _selectPlace(id, desc, false),
            hint: "Drop Address",
          ),
        ],
      ],
    );
  }

  Widget _buildDatePickers() {
    return Row(
      children: [
        Expanded(child: _buildPickerTile(selectedDate == null ? "Date" : DateFormat('dd MMM yyyy').format(selectedDate!), Icons.calendar_month, () async {
          final d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 60)));
          if (d != null) { setState(() => selectedDate = d); _calculateFare(); }
        })),
        const SizedBox(width: 10),
        Expanded(child: _buildPickerTile(selectedTime == null ? "Time" : selectedTime!.format(context), Icons.access_time_rounded, () async {
          final t = await showTimePicker(context: context, initialTime: TimeOfDay.now());
          if (t != null) { setState(() => selectedTime = t); _calculateFare(); }
        })),
        if (_tripType == 'RoundTrip') ...[
          const SizedBox(width: 10),
          Expanded(child: _buildPickerTile(returnDate == null ? "Return" : DateFormat('dd MMM').format(returnDate!), Icons.event_repeat, () async {
            final d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 60)));
            if (d != null) { setState(() => returnDate = d); _calculateFare(); }
          })),
        ]
      ],
    );
  }

  Widget _buildVehicleSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("VEHICLE TYPE", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF134E4A), letterSpacing: 1)),
        const SizedBox(height: 15),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: tariffs.length,
            itemBuilder: (context, i) {
              bool isSelected = selectedCarIndex == i;
              return GestureDetector(
                onTap: () { setState(() { selectedCarIndex = i; carName = tariffs[i]['category']; }); _calculateFare(); },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 130,
                  margin: const EdgeInsets.only(right: 15),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF134E4A) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: isSelected ? [BoxShadow(color: const Color(0xFF134E4A).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))] : [],
                    border: Border.all(color: isSelected ? Colors.transparent : Colors.grey.shade200),
                  ),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.directions_car_filled_rounded, color: isSelected ? Colors.white : Colors.grey, size: 28),
                    const SizedBox(height: 8),
                    Text(tariffs[i]['category'], style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.bold, fontSize: 13)),
                  ]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFarePanel() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF134E4A), Color(0xFF1E293B)]),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: const Color(0xFF134E4A).withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))]
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _fareCol("DISTANCE", "${displayedKm.toStringAsFixed(1)} KM"),
          _fareCol("NET FARE", "₹ ${fareAmount?.toStringAsFixed(0) ?? '0'}", isPrice: true),
        ],
      ),
    );
  }

  Widget _fareCol(String label, String val, {bool isPrice = false}) {
    return Column(crossAxisAlignment: isPrice ? CrossAxisAlignment.end : CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
      const SizedBox(height: 5),
      Text(val, style: TextStyle(color: Colors.white, fontSize: isPrice ? 28 : 22, fontWeight: FontWeight.w900)),
    ]);
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        TextButton(onPressed: () { setState(() { _resetFields(); }); }, child: const Text("Reset", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold))),
        const Spacer(),
        SizedBox(
          height: 55,
          width: 250,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF134E4A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 4
            ),
            onPressed: _confirmBooking,
            child: const Text("BOOK NOW", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: 1)),
          ),
        ),
      ],
    );
  }

  // --- Helpers ---

  Widget _buildTextField(String hint, TextEditingController controller, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(hint, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 18, color: Colors.grey),
            hintText: "Enter $hint",
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade100)),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String val, List<String> items, Function(String?)? onChange) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54)),
        const SizedBox(height: 8),
        DropdownButton2<String>(
          
          underline: SizedBox(),
          isExpanded: true,
          value: val,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)))).toList(),
          onChanged: onChange,
          buttonStyleData: ButtonStyleData(height: 50, padding: const EdgeInsets.symmetric(horizontal: 10), decoration: BoxDecoration(
            color: Colors.white, 
            borderRadius: BorderRadius.circular(12),
             border: Border.all(color: Colors.grey.shade200),
              
             )
             ),
        ),
      ],
    );
  }

  Widget _buildPickerTile(String text, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade100)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 16, color: const Color(0xFF134E4A)),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
        ]),
      ),
    );
  }

  void _showSnackBar(String msg, bool isErr) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: isErr ? Colors.redAccent : Colors.teal, behavior: SnackBarBehavior.floating, width: 300));
  }

  void _resetFields() {
    nameController.clear(); phoneController.clear(); pickupController.clear(); dropController.clear();
    _pickupLatLng = null; _dropLatLng = null; fareAmount = null; distanceKm = 0; selectedCarIndex = null;
  }
  

  Future<void> _confirmBooking() async {
      if (nameController.text.isEmpty ||
          phoneController.text.isEmpty ||
          pickupController.text.isEmpty) {
        _showProfessionalSnackBar("Fill all mandatory fields.", true,context);
        return;
      }
      if (selectedDate == null || selectedTime == null) {
        _showProfessionalSnackBar("Select pickup date/time.", true,context);
        return;
      }
      if (fareAmount == null || selectedCarIndex == null) {
        _showProfessionalSnackBar("Select vehicle to calculate fare.", true,context);
        return;
      }

      try {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(child: CircularProgressIndicator()));

        final bookingId = FirebaseFirestore.instance.collection('bookings').doc().id;

        final driverSnapshot = await FirebaseFirestore.instance
            .collection('approved_drivers')
            .where('isOnline', isEqualTo: true)
            .get();

        if (driverSnapshot.docs.isEmpty) {
          Navigator.pop(context);
          _showProfessionalSnackBar("No online drivers available", true,context);
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
        _showProfessionalSnackBar("Booking shared with drivers! 🚀", false,context);
        _resetFields();
      } catch (e) {
        if (Navigator.canPop(context)) Navigator.pop(context);
        _showProfessionalSnackBar("Error: $e", true,context);
      }
    }
}

void _showProfessionalSnackBar(String message, bool isError, BuildContext context) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(isError ? Icons.error_outline : Icons.check_circle_outline,
                  color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                  child: Text(message,
                      style: const TextStyle(fontWeight: FontWeight.w500))),
            ],
          ),
          backgroundColor: isError ? Colors.redAccent : const Color(0xFF134E4A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(15),
          duration: const Duration(seconds: 3),
        ),
      );
    }

// ====================== HELPER WIDGETS ======================

class PositionImageBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: NetworkImage('https://images.unsplash.com/photo-1449965408869-eaa3f722e40d?auto=format&fit=crop&q=80&w=2070'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(color: Colors.black.withOpacity(0.55)),
    );
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  const GlassCard({required this.child});
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.all(35),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.4)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 30, offset: const Offset(0, 15))]
          ),
          child: child,
        ),
      ),
    );
  }
}