import 'dart:async';
import 'dart:convert';
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

class _HomepageState extends State<Homepage> with TickerProviderStateMixin {
  // --- Firebase & State Logic (STRICTLY UNTOUCHED) ---
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final pickupController = TextEditingController();
  final dropController = TextEditingController();

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

  // --- Animation Controllers ---
  late AnimationController _carMoveController;

  @override
  void initState() {
    super.initState();
    _startTariffListener();
    _carMoveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _carMoveController.dispose();
    _debounce?.cancel();
    _tariffSub?.cancel();
    super.dispose();
  }

  // ====================== FIREBASE LOGIC (NO CHANGES) ======================

  void _startTariffListener() {
    if (_mainMode.isEmpty || _tripType.isEmpty) return;
    _tariffSub?.cancel();
    bool isLocalPackage = _mainMode.toUpperCase() == 'LOCAL' && (_tripType.toLowerCase() == 'package' || _tripType == 'PackageMatrix');
    String path = isLocalPackage ? 'tariffs/LOCAL/PackageMatrix' : 'tariffs/$_mainMode/${_tripType.replaceAll(" ", "")}';
    FirebaseFirestore.instance.collection(path).snapshots().listen((snap) {
      if (!mounted) return;
      List<Map<String, dynamic>> fetched = snap.docs.map((d) {
        final data = d.data();
        return {'id': d.id, 'category': data['category'] ?? d.id, 'fullData': data, 'cost': (data['cost'] ?? 0).toDouble(), 'perKm': (data['perKm'] ?? 0).toDouble(), 'minKm': (data['minKm'] ?? 0).toDouble()};
      }).toList();
      fetched.sort((a, b) => a['category'].toString().compareTo(b['category'].toString()));
      setState(() { tariffs = fetched; _calculateFare(); });
    });
  }

  Future<void> _fetchSuggestions(String input, bool isPickup) async {
    if (input.isEmpty) { setState(() => isPickup ? pickupSuggestions = [] : dropSuggestions = []); return; }
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final url = Uri.parse('https://us-central1-pktcalltaxiapp.cloudfunctions.net/mapsapi?input=${Uri.encodeComponent(input)}');
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (mounted && data['predictions'] != null) {
          setState(() { if (isPickup) pickupSuggestions = data['predictions']; else dropSuggestions = data['predictions']; });
        }
      }
    });
  }

  Future<void> _selectPlace(String placeId, String description, bool isPickup) async {
    final url = Uri.parse('https://us-central1-pktcalltaxiapp.cloudfunctions.net/placeDetailsapi?place_id=$placeId');
    final res = await http.get(url);
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      final loc = data['result']['geometry']['location'];
      setState(() {
        if (isPickup) { pickupController.text = description; _pickupLatLng = LatLng(loc['lat'], loc['lng']); pickupSuggestions = []; }
        else { dropController.text = description; _dropLatLng = LatLng(loc['lat'], loc['lng']); dropSuggestions = []; }
      });
      if (_pickupLatLng != null && _dropLatLng != null) _getDistance();
    }
  }

  Future<void> _getDistance() async {
    if (_pickupLatLng == null || _dropLatLng == null) return;
    final url = Uri.parse('https://us-central1-pktcalltaxiapp.cloudfunctions.net/distanceapi?origins=${_pickupLatLng!.latitude},${_pickupLatLng!.longitude}&destinations=${_dropLatLng!.latitude},${_dropLatLng!.longitude}');
    final res = await http.get(url);
    final data = json.decode(res.body);
    if (data['status'] == 'OK') { setState(() { distanceKm = data['rows'][0]['elements'][0]['distance']['value'] / 1000.0; }); _calculateFare(); }
  }

  void _calculateFare() {
    if (tariffs.isEmpty || selectedCarIndex == null) { setState(() => fareAmount = null); return; }
    final t = tariffs[selectedCarIndex!];
    double cost = t['cost'], perKm = t['perKm'];
    if (_mainMode == 'LOCAL' && _tripType == 'Package') {
      if (_selectedHours == null) return;
      var pkg = t['fullData'][_selectedHours.toString()];
      if (pkg != null) { fareAmount = (pkg['amount'].toDouble() / 5).ceil() * 5.0; displayedKm = pkg['uptoKm'].toDouble(); }
      setState(() {}); return;
    }
    if (distanceKm == 0) return;
    if (_mainMode == 'OUTSTATION') {
      if (_tripType == 'OneWay') { double dist = distanceKm < 130 ? 130 : distanceKm; fareAmount = ((cost + (dist * perKm)) / 5).ceil() * 5.0; }
      else { if (selectedDate != null && returnDate != null) { int days = returnDate!.difference(selectedDate!).inDays; if (days < 1) days = 1; double dist = (distanceKm * 2) < (days * 250) ? (days * 250) : (distanceKm * 2); fareAmount = (((cost * days) + (dist * perKm)) / 5).ceil() * 5.0; } }
    } else { double dist = distanceKm < t['minKm'] ? t['minKm'] : distanceKm; fareAmount = ((cost + (dist * perKm)) / 5).ceil() * 5.0; }
    displayedKm = distanceKm;
    setState(() {});
  }

  // ====================== UBER STYLE SPLIT UI (NO SCAFFOLD) ======================

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            _buildAnimatedTopBar(),
            Expanded(
              child: Row(
                children: [
                  // LEFT SIDE: Input Form
                  Expanded(
                    flex: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 30),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: _buildBookingForm(),
                      ),
                    ),
                  ),
                  // RIGHT SIDE: Fixed Summary
                  Expanded(
                    flex: 4,
                    child: _buildSummaryPanel(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedTopBar() {
    return Container(
      height: 100,
      decoration: BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Colors.grey.shade100))),
      child: Column(
        children: [
          Expanded(
            child: AnimatedBuilder(
              animation: _carMoveController,
              builder: (context, child) {
                return Stack(
                  children: [
                    Positioned(
                      left: (MediaQuery.of(context).size.width + 200) * _carMoveController.value - 200,
                      bottom: 0,
                      child: Row(
                        children: [
                          const Icon(Icons.local_taxi, color: Color(0xFF276EF1), size: 30),
                          const SizedBox(width: 5),
                          Container(width: 100, height: 1, color: Colors.black12),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          
        ],
      ),
    );
  }

  Widget _buildBookingForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Book Your Journey", style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900)),
        const SizedBox(height: 40),
        
        _sectionLabel("PERSONAL INFO"),
        Row(
          children: [
            Expanded(child: _modernInput("Name", nameController, Icons.person_outline)),
            const SizedBox(width: 20),
            Expanded(child: _modernInput("Mobile", phoneController, Icons.phone_android)),
          ],
        ),
        
        const SizedBox(height: 30),
        _sectionLabel("TRIP DETAILS"),
        Row(
          children: [
            Expanded(child: _modernDropdown("Mode", _mainMode, ['LOCAL', 'OUTSTATION'], (v) {
              setState(() { _mainMode = v!; _tripType = _mainMode == 'LOCAL' ? 'Drop' : 'OneWay'; selectedCarIndex = null; });
              _startTariffListener();
            })),
            const SizedBox(width: 20),
            Expanded(child: _modernDropdown("Type", _tripType, _mainMode == 'LOCAL' ? ['Drop', 'Package'] : ['OneWay', 'RoundTrip'], (v) {
              setState(() { _tripType = v!; selectedCarIndex = null; });
              _startTariffListener();
            })),
          ],
        ),
        
        const SizedBox(height: 30),
        _sectionLabel("LOCATIONS"),
        SearchBoxWidget(
          controller: pickupController,
          suggestions: pickupSuggestions,
          onTextChanged: (val, _) => _fetchSuggestions(val, true),
          onPlaceSelected: (id, desc, _) => _selectPlace(id, desc, true),
          hint: "Pick up location",
        ),
        if (_tripType != 'Package') ...[
          const SizedBox(height: 15),
          SearchBoxWidget(
            controller: dropController,
            suggestions: dropSuggestions,
            onTextChanged: (val, _) => _fetchSuggestions(val, false),
            onPlaceSelected: (id, desc, _) => _selectPlace(id, desc, false),
            hint: "Drop off location",
          ),
        ],
        
        const SizedBox(height: 30),
        _sectionLabel("SELECT VEHICLE (Uber Style Selection)"),
        _buildVehicleRadioCards(),
        
        const SizedBox(height: 30),
        _sectionLabel("DATE & TIME"),
        _buildSchedulePicker(),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildVehicleRadioCards() {
    if (tariffs.isEmpty) return const Padding(padding: EdgeInsets.all(20), child: Text("Enter locations to view cars...", style: TextStyle(color: Colors.grey)));
    
    return Column(
      children: List.generate(tariffs.length, (index) {
        bool isSelected = selectedCarIndex == index;
        return GestureDetector(
          onTap: () { setState(() { selectedCarIndex = index; carName = tariffs[index]['category']; }); _calculateFare(); },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFF1F6FF) : Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: isSelected ? const Color(0xFF276EF1) : Colors.grey.shade200, width: 2),
            ),
            child: Row(
              children: [
                Radio(
                  value: index,
                  groupValue: selectedCarIndex,
                  activeColor: const Color(0xFF276EF1),
                  onChanged: (val) { setState(() { selectedCarIndex = val as int; carName = tariffs[val!]['category']; }); _calculateFare(); },
                ),
                const SizedBox(width: 15),
                Icon(Icons.directions_car, color: isSelected ? const Color(0xFF276EF1) : Colors.black54),
                const SizedBox(width: 20),
                Text(tariffs[index]['category'].toString().toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                const Spacer(),
                if (isSelected && fareAmount != null)
                  Text("₹ ${fareAmount?.toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF276EF1), fontSize: 18)),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSummaryPanel() {
  return Container(
    margin: const EdgeInsets.all(25), // Margin konjam korachuruken
    padding: const EdgeInsets.all(25), // Padding optimized for space
    decoration: BoxDecoration(
      color: const Color(0xFFF9F9F9),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: Colors.white, width: 2),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Ride Summary", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
        const Divider(height: 30),
        
        // Wrap items in Expanded + Scroll to prevent pushing the fare box
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _summaryItem("From", pickupController.text.isEmpty ? "Not set" : pickupController.text),
                _summaryItem("To", dropController.text.isEmpty ? "Not set" : dropController.text),
                _summaryItem("Vehicle", carName ?? "Not selected"),
                _summaryItem("Distance", "${displayedKm.toStringAsFixed(1)} KM"),
              ],
            ),
          ),
        ),

        const SizedBox(height: 15), // Small gap before fare box

        // Fixed Fare Container at Bottom
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "ESTIMATED FARE",
                    style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)
                  ),
                  Text(
                    "₹ ${fareAmount?.toStringAsFixed(0) ?? '0'}",
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50, // Standard height to avoid overflow
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF276EF1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  onPressed: _confirmBooking,
                  child: const Text(
                    "CONFIRM RIDE",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    ),
  );
}

  // --- Helpers ---
  Widget _sectionLabel(String t) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(t, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.5)));

  Widget _modernInput(String hint, TextEditingController ctrl, IconData icon) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFFF1F1F1), borderRadius: BorderRadius.circular(12)),
      child: TextField(
        controller: ctrl,
        decoration: InputDecoration(prefixIcon: Icon(icon, color: Colors.black, size: 20), hintText: hint, border: InputBorder.none, contentPadding: const EdgeInsets.all(20)),
      ),
    );
  }

  Widget _modernDropdown(String label, String val, List<String> items, Function(String?) onCh) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(color: const Color(0xFFF1F1F1), borderRadius: BorderRadius.circular(12)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
          isExpanded: true,
          value: val,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontWeight: FontWeight.w700)))).toList(),
          onChanged: onCh,
        ),
      ),
    );
  }

  Widget _buildSchedulePicker() {
    return Row(
      children: [
        _miniPicker(selectedDate == null ? "Date" : DateFormat('dd MMM').format(selectedDate!), Icons.event, () async {
          final d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 60)));
          if (d != null) setState(() => selectedDate = d); _calculateFare();
        }),
        const SizedBox(width: 15),
        _miniPicker(selectedTime == null ? "Time" : selectedTime!.format(context), Icons.schedule, () async {
          final t = await showTimePicker(context: context, initialTime: TimeOfDay.now());
          if (t != null) setState(() => selectedTime = t); _calculateFare();
        }),
      ],
    );
  }

  Widget _miniPicker(String t, IconData i, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(12)),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(i, size: 18), const SizedBox(width: 10), Text(t, style: const TextStyle(fontWeight: FontWeight.bold))]),
        ),
      ),
    );
  }

  Widget _summaryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  // ====================== FIREBASE SUBMIT (UNTOUCHED) ======================

  void _resetFields() {
  setState(() {
    // Text Controllers clear panrathu
    nameController.clear();
    phoneController.clear();
    pickupController.clear();
    dropController.clear();

    // Data variables reset panrathu
    _pickupLatLng = null;
    _dropLatLng = null;
    distanceKm = 0.0;
    displayedKm = 0.0;
    fareAmount = null;
    selectedCarIndex = null;
    carName = null;
    
    // Suggestions clear panrathu
    pickupSuggestions = [];
    dropSuggestions = [];
    
    // Date & Time reset (Optional - current time-ku set aagum)
    selectedDate = null;
    selectedTime = null;
  });
}

  Future<void> _confirmBooking() async {
    // Basic Validation Check
    if (nameController.text.isEmpty || 
        phoneController.text.isEmpty || 
        pickupController.text.isEmpty || 
        fareAmount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Macha, please fill all details and select a vehicle!"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    try {
      // 1. Show Loading Dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
          child: CircularProgressIndicator(color: Color(0xFF276EF1)),
        ),
      );

      // 2. Generate Booking ID & Get Online Drivers
      final bookingId = FirebaseFirestore.instance.collection('bookings').doc().id;
      final driverSnap = await FirebaseFirestore.instance
          .collection('approved_drivers')
          .where('isOnline', isEqualTo: true)
          .get();

      // 3. Prepare Data Map
      final bookingData = {
        'booking_id': bookingId,
        'passenger_name': nameController.text.trim(),
        'passenger_phone': phoneController.text.trim(),
        'pickup_name': pickupController.text.trim(),
        'drop_name': dropController.text.trim(),
        'pickup_latlng': GeoPoint(_pickupLatLng!.latitude, _pickupLatLng!.longitude),
        'drop_latlng': _dropLatLng != null 
            ? GeoPoint(_dropLatLng!.latitude, _dropLatLng!.longitude) 
            : null,
        'final_fare': fareAmount,
        'distance': displayedKm,
        'trip_mode': _mainMode,
        'trip_type': _tripType,
        'car_name': carName,
        'booking_date': DateFormat('dd-MM-yyyy').format(selectedDate ?? DateTime.now()),
        'booking_time': selectedTime?.format(context) ?? "Immediate",
        'status': 'PENDING',
        'timestamp': FieldValue.serverTimestamp(),
      };

      // 4. Batch Operation (Write to Global Bookings & Driver Sub-collections)
      WriteBatch batch = FirebaseFirestore.instance.batch();

      // Global Booking Record
      batch.set(
        FirebaseFirestore.instance.collection('bookings').doc(bookingId), 
        bookingData
      );

      // Distribute to Each Online Driver
      for (var d in driverSnap.docs) {
        batch.set(
          FirebaseFirestore.instance
              .collection('approved_drivers')
              .doc(d.id)
              .collection('incoming_requests')
              .doc(bookingId), 
          bookingData
        );

        // 5. Send Notification via FCM
        final token = d.data()['fcmToken'];
        if (token != null) {
          sendDriverPushNotification(
            token, 
            bookingId, 
            pickupController.text, 
            dropController.text
          );
        }
      }

      // 6. Execute Batch
      await batch.commit();

      // 7. Success - Close Loader & Notify User
      if (Navigator.canPop(context)) Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Success! Request sent to all online drivers. 🚀"),
          backgroundColor: Color(0xFF276EF1),
          behavior: SnackBarBehavior.floating,
        ),
      );

      // 🔥 8. ITHU THAAN MUKKIYAM: Reset all fields after success
      _resetFields();

    } catch (e) {
      // Handle Errors
      if (Navigator.canPop(context)) Navigator.pop(context);
      debugPrint("Booking Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Macha, something went wrong: $e")),
      );
    }
  }
}