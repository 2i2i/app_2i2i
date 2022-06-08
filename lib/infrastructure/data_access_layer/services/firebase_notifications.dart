import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../common_main.dart';
import 'package:http/http.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FirebaseNotifications {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  FirebaseNotifications() {
    awesomeNotificationSetup();
    firebaseCloudMessagingListeners();
  }

  void firebaseCloudMessagingListeners() {
    FirebaseMessaging.instance.requestPermission(sound: true, badge: false, alert: true);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print("Handling a onMessage message: ${message.messageId}");
    });
  }

  Future<void> awesomeNotificationSetup() async {
    FirebaseMessaging.instance.getToken().then((value) => print("\n\nMobile Token ======= $value \n\n"));
    await Firebase.initializeApp();

    // await AwesomeNotifications().initialize(
    //     null,
    //     [
    //       NotificationChannel(
    //           channelKey: 'alerts',
    //           channelName: 'Alerts',
    //           channelDescription: 'Notification alerts',
    //           importance: NotificationImportance.High,
    //           defaultColor: Color(0xFF9D50DD),
    //           ledColor: Colors.white,
    //           groupKey: 'alerts',
    //           channelShowBadge: true)
    //     ],
    //     debug: true);
    //
    // await Firebase.initializeApp();
    // await AwesomeNotificationsFcm().initialize(
    //     debug: true,
    //     onSilentDataHandle: (SilentData silentData) async {
    //       debugPrint('"SilentData": ${silentData.toString()}');
    //     });
    //
    // AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
    //   if (!isAllowed) {
    //     AwesomeNotifications().requestPermissionToSendNotifications();
    //   }
    // });
    //
    // AwesomeNotifications().actionStream.listen((receivedAction) {
    //   if (receivedAction.channelKey == 'call_channel') {
    //     switch (receivedAction.buttonKeyPressed) {
    //       case 'view':
    //         break;
    //     }
    //     return;
    //   }
    // });
  }

  Future sendNotification(String token, Map data, bool isIos) async {
    var notification = {};
    Map notificationMap = {};

    if (isIos || data['type'] != 'Call') {
      notification['title'] = data['title'];
      notification['body'] = data['body'];
      notificationMap['notification'] = notification;
    }

    notificationMap = {
      "registration_ids": [token],
      "mutable_content": true,
      "content_available": true,
      "priority": "high",
      "data": data,
    };
    if (token.isEmpty) {
      print('Unable to send FCM message, no token exists.');
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
      print(e);
    }
  }
}

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");

  String? imageUrl;
  Map data = message.data;
  String title = data['title'] ?? (message.notification?.title ?? '');
  String body = data['body'] ?? (message.notification?.body ?? '');
  String type = data['type'] ?? '';
  if (data['imageUrl'] != null) {
    imageUrl = data['imageUrl'];
  }
  if (type.toLowerCase() == 'Call'.toLowerCase()) {
    if (Platform.isIOS) {
      await platform.invokeMethod('INCOMING_CALL', data);
    }
  }
}
