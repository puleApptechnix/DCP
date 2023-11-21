import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
//firebase_core: ^2.13.0
final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

Future<void> requestNotificationPermissions() async {
  NotificationSettings settings = await _firebaseMessaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  if (kDebugMode) {
    print('Notification permission granted: ${settings.authorizationStatus}');
  }

  FirebaseMessaging.instance.getToken().then((token) {
// Send the token to your server or store it in your local database
    if (kDebugMode) {
      print('Device token: $token');
    }
  });

}

