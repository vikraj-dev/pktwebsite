import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:get/get.dart';

class DashboardPage extends StatelessWidget {
  final String? bookingDataJson;

  const DashboardPage({super.key, this.bookingDataJson});

  Map<String, dynamic>? _getBookingData() {
    if (bookingDataJson == null) return null;
    try {
      return jsonDecode(bookingDataJson!);
    } catch (e) {
      debugPrint("❌ Failed to decode booking data JSON: $e");
      return null;
    }
  }

  Future<void> _storeBookingDataForAdmin() async {
    if (bookingDataJson == null) return;
    try {
      final Map<String, dynamic> bookingData = jsonDecode(bookingDataJson!);
      debugPrint("✅ Booking saved for admin: $bookingData");
    } catch (e) {
      debugPrint("❌ Failed to store booking data: $e");
    }
  }

  void _showConfirmationSnackbar() {
    if (bookingDataJson == null) return;

    Get.snackbar(
      "Success!",
      "Your premium ride is scheduled.",
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF1E293B).withOpacity(0.9),
      colorText: Colors.white,
      margin: const EdgeInsets.all(15),
      borderRadius: 10,
      duration: const Duration(seconds: 4),
      icon: const Icon(Icons.stars, color: Colors.amber, size: 30),
      shouldIconPulse: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _showConfirmationSnackbar();
      await _storeBookingDataForAdmin();
    });

    final Map<String, dynamic>? bookingDetails = _getBookingData();

    if (bookingDetails == null) {
      return const Scaffold(
        body: Center(child: Text("Error: No booking data found.", style: TextStyle(color: Colors.red))),
      );
    }

    // Data Extraction
    final String name = bookingDetails['passenger_name'] ?? 'N/A';
    final String number = bookingDetails['passenger_phone'] ?? 'N/A';
    final String pickup = bookingDetails['pickup_location'] ?? 'N/A';
    final String drop = bookingDetails['drop_location'] ?? 'N/A';
    final String carType = bookingDetails['car_type'] ?? 'Premium Sedan';
    final String fare = bookingDetails['total_fare_in_inr'] ?? '0';
    final String date = bookingDetails['date'] ?? 'N/A';
    final String time = bookingDetails['time'] ?? 'N/A';
    final String tripType = bookingDetails['trip_type'] ?? 'One-Way';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Booking Summary", style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1.1)),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF1E293B)]),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(30),
              decoration: const BoxDecoration(
                color: Color(0xFF1E293B),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                children: [
                  const Icon(Icons.check_circle, color: Colors.greenAccent, size: 60),
                  const SizedBox(height: 15),
                  const Text(
                    "Booking Confirmed!",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Ride ID: #PKT${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}",
                    style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              child: Column(
                children: [
                  // Main Booking Card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))
                      ],
                    ),
                    child: Column(
                      children: [
                        // Fare Section
                        Padding(
                          padding: const EdgeInsets.all(25.0),
                          child: Column(
                            children: [
                              Text("$tripType Trip Fare".toUpperCase(), 
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.blueGrey, letterSpacing: 1.5)),
                              const SizedBox(height: 8),
                              Text("₹$fare", 
                                style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                            ],
                          ),
                        ),

                        // Dash Divider
                        Row(
                          children: List.generate(30, (i) => Expanded(
                            child: Container(color: i % 2 == 0 ? Colors.transparent : Colors.grey.withOpacity(0.3), height: 1.5),
                          )),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(25.0),
                          child: Column(
                            children: [
                              // Date & Time
                              Row(
                                children: [
                                  Expanded(child: _buildInfoItem("DATE", date, Icons.calendar_today_outlined)),
                                  Expanded(child: _buildInfoItem("TIME", time, Icons.access_time_rounded)),
                                ],
                              ),
                              const SizedBox(height: 25),
                              
                              // Locations
                              _buildLocationStep(pickup, drop, tripType),
                              
                              const SizedBox(height: 25),
                              const Divider(),
                              const SizedBox(height: 15),

                              // Passenger & Car Details
                              _buildHorizontalDetail(Icons.directions_car_filled_rounded, "Car Selected", carType),
                              _buildHorizontalDetail(Icons.person_outline_rounded, "Passenger", name),
                              _buildHorizontalDetail(Icons.phone_iphone_rounded, "Contact", number),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 30),

                  // Action Buttons
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () => Get.offAllNamed('/home'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F172A),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 5,
                      ),
                      child: const Text("RETURN TO HOME", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextButton.icon(
                    onPressed: () {}, // Optional: Add share functionality
                    icon: const Icon(Icons.ios_share_rounded),
                    label: const Text("Share Receipt"),
                    style: TextButton.styleFrom(foregroundColor: Colors.blueGrey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.blueAccent),
            const SizedBox(width: 5),
            Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
          ],
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black87)),
      ],
    );
  }

  Widget _buildHorizontalDetail(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blueGrey.shade400),
          const SizedBox(width: 12),
          Text("$label: ", style: const TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.w500)),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87), textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  Widget _buildLocationStep(String pickup, String drop, String tripType) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.radio_button_checked, color: Colors.blue, size: 20),
            const SizedBox(width: 15),
            Expanded(child: Text(pickup, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
          ],
        ),
        if (tripType == 'One-Way') ...[
          Container(
            height: 25,
            margin: const EdgeInsets.only(left: 9),
            decoration: BoxDecoration(border: Border(left: BorderSide(color: Colors.grey.shade300, width: 2))),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on, color: Colors.redAccent, size: 20),
              const SizedBox(width: 15),
              Expanded(child: Text(drop, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
            ],
          ),
        ]
      ],
    );
  }
}