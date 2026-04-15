import 'package:get/get.dart';
// import 'dart:convert'; // இந்த import-ஐ நீக்கிவிட்டேன், தேவைப்படாது

// 1. Booking Model Class
class Booking {
  final String passengerName;
  final String pickupLocation;
  final String dropLocation;
  final String totalFare;
  final String carType;
  final String dateAndTime;

  Booking({
    required this.passengerName,
    required this.pickupLocation,
    required this.dropLocation,
    required this.totalFare,
    required this.carType,
    required this.dateAndTime,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      passengerName: json['passenger_name'] ?? 'N/A',
      pickupLocation: json['pickup_location'] ?? 'N/A',
      // Round Trip-க்கு Drop Location pickup-ஆக இருக்கும்
      dropLocation: json['drop_location'] ?? (json['trip_type'] == 'Round-Trip' ? json['pickup_location'] : 'N/A'),
      totalFare: json['total_fare_in_inr'] ?? '0.00',
      carType: json['car_type'] ?? 'Unknown',
      dateAndTime: '${json['date']} @ ${json['time']}',
    );
  }
}

// 2. Booking Controller Class
class BookingController extends GetxController {
  RxList<Booking> bookings = <Booking>[].obs;

  void addBooking(Map<String, dynamic> bookingJsonData) {
    final newBooking = Booking.fromJson(bookingJsonData);
    bookings.add(newBooking);
    print("✅ Booking added to Controller: ${newBooking.passengerName}");
    print("Total Bookings: ${bookings.length}");
  }
}