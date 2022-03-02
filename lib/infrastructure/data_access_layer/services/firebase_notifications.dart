import 'dart:convert';
import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

import '../../../main.dart';

class FirebaseNotifications {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  FirebaseNotifications() {
    awesomeNotificationSetup();
    firebaseCloudMessagingListeners();
  }

  void firebaseCloudMessagingListeners() {
    FirebaseMessaging.instance.requestPermission(sound: true, badge: true, alert: true);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print("Handling a onMessage message: ${message.messageId}");
    });
  }

  Future<void> awesomeNotificationSetup() async {
    FirebaseMessaging.instance
        .getToken()
        .then((value) => print("\n\nMobile Token ======= $value \n\n"));
    await Firebase.initializeApp();
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelGroupKey: 'incoming_call',
          channelKey: 'call_channel',
          channelName: 'Calls',
          channelDescription: 'Incoming call notifications',
          defaultColor: Color(0xFF9D50DD),
          importance: NotificationImportance.Max,
          ledColor: Colors.white,
          channelShowBadge: true,
          locked: true,
          playSound: true,
          soundSource: 'resource://raw/video_call',
          vibrationPattern: highVibrationPattern,
        ),
      ],
      channelGroups: [
        NotificationChannelGroup(
          channelGroupkey: 'incoming_call',
          channelGroupName: 'Calls',
        )
      ],
      debug: true,
    );

    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });


    AwesomeNotifications().actionStream.listen((receivedAction) {
      print('AwesomeNotifications().actionStream ${receivedAction.payload.toString()}');
      if (receivedAction.channelKey == 'call_channel') {
        switch (receivedAction.buttonKeyPressed) {
          case 'view':

            break;
        }
        return;
      }
    });
  }

  Future sendNotification(String token,Map data,bool isIos) async {
    var notification = {};
    if(isIos){
      notification['title'] = data['title'];
      notification['body'] = data['body'];
    }
    Map map = {
      "to": token,
      "notification": notification,
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
          'Authorization':
              'key=AAAAaa2e9ys:APA91bHjXVbNkKrkNC6_HxcFYuVal_IMNFxK7738gFxTu87_ACZ8HUeGQd3dkvRwiTmqtfjDd30fMV-d5XiHr_BBTGKOLJdH0OgKs1B9Q6eAXgWadZeiv2hV2E4ydmyb7Ar6Ykl86UlD',
        },
        body: jsonEncode(map),
      );
      print('FCM request for device sent!');
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
  if (type == 'Call') {
    if (Platform.isIOS) {
      await platform.invokeMethod('INCOMING_CALL', {'name': data['title']});
    } else {
      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 10,
          channelKey: 'call_channel',
          title: title,
          body: body,
          category: NotificationCategory.Call,
          largeIcon: imageUrl,
          wakeUpScreen: true,
          fullScreenIntent: true,
          autoDismissible: true,
          backgroundColor: Colors.white,
          customSound: 'resource://raw/video_call',
          payload: data.cast<String, String>(),
        ),
        actionButtons: [
          NotificationActionButton(
            key: 'view',
            label: 'View',
            color: Colors.green,
            autoDismissible: true,
          ),
        ],
      );
    }
  }
}