import 'dart:convert';
import 'dart:io';

import 'package:app_2i2i/infrastructure/data_access_layer/services/logging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';

import '../../../common_main.dart';
import '../repository/firestore_database.dart';

class FirebaseNotifications {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  FirebaseNotifications() {
    awesomeNotificationSetup();
    firebaseCloudMessagingListeners();
  }

  Future<void> firebaseCloudMessagingListeners() async {
    if (!kIsWeb) {
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      switch (settings.authorizationStatus) {
        case AuthorizationStatus.authorized:
          print('User granted permission');
          break;
        case AuthorizationStatus.denied:
          // TODO: Handle this case.
          print('User granted permission denied');
          break;
        case AuthorizationStatus.notDetermined:
          print('User granted permission notDetermined');
          break;
        case AuthorizationStatus.provisional:
          print('User granted permission provisional');
          break;
      }
    }

    FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      log("Handling a onMessage message: ${message.messageId}");
    });
  }

  Future<void> awesomeNotificationSetup() async {
    await Firebase.initializeApp();

    await FirebaseMessaging.instance.getToken().then((value) => log("Token $value"));

    // Note: This callback is fired at each app startup and whenever a new
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
      if (uid.isNotEmpty) {
        FirestoreDatabase().updateToken(uid, fcmToken);
      }
    }).onError((err) {
      log(err);
    });
  }

  Future sendNotification(String token, Map data, bool isIOS) async {
    var notification = {};
    Map notificationMap = {};

    if (isIOS || data['type'].toString().toLowerCase() != 'Call'.toLowerCase()) {
      notification['title'] = data['title'];
      notification['body'] = data['body'];
      notificationMap['notification'] = notification;
    }

    notificationMap.addAll({
      "registration_ids": [token],
      "mutable_content": true,
      "content_available": true,
      "priority": "high",
      "data": data,
    });
    if (token.isEmpty) {
      log('Unable to send FCM message, no token exists.');
      return;
    }
    try {
      await post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'key=${dotenv.env['FIREBASE_SERVER_KEY'].toString()}',
        },
        body: jsonEncode(notificationMap),
      );
    } catch (e) {
      log("$e");
    }
  }
}

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log("Handling a background message: ${message.messageId}");

  // String? imageUrl;
  Map data = message.data;
  // String title = data['title'] ?? (message.notification?.title ?? '');
  // String body = data['body'] ?? (message.notification?.body ?? '');
  String type = data['type'] ?? '';
  // if (data['imageUrl'] != null) {
  //   imageUrl = data['imageUrl'];
  // }
  if (type.toLowerCase() == 'Call'.toLowerCase()) {
    if (Platform.isIOS) {
      await platform.invokeMethod('INCOMING_CALL', data);
    }
  }
}
