import 'dart:convert';
import 'package:http/http.dart' as http;

/// Sends a push notification to the driver using FCM
Future<void> sendDriverPushNotification(
    String token, String bookingId, String pickup, String drop) async {
  const String serverKey = 'AIzaSyCzaHfgeGygyPRc_wgX72qEarAeijC21Fc'; // 🔥 Replace with your FCM server key

  try {
    final response = await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverKey',
      },
      body: jsonEncode({
        'notification': {
          'title': '🚗 PKT Call Taxi',
          'body': 'New Request from $pickup',
          'sound': 'default',
        },
        'priority': 'high',
        'data': {
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'booking_id': bookingId,
          'type': 'new_request',
        },
        'to': token,
      }),
    );

    if (response.statusCode == 200) {
      print('✅ Push notification sent successfully');
    } else {
      print('❌ Failed to send notification: ${response.body}');
    }
  } catch (e) {
    print('❌ Error sending notification: $e');
  }
}
