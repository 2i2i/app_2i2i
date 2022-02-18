import 'dart:convert';

import 'package:awesome_notifications/android_foreground_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class FirebaseNotifications {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  FirebaseNotifications() {
    awesomeNotificationSetup();
    firebaseCloudMessagingListeners();
  }

  void firebaseCloudMessagingListeners() {
    getNotificationToken().then((value) => print(value));

    FirebaseMessaging.instance.requestPermission(sound: true, badge: true, alert: true);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Handling a onMessage message: ${message.messageId}");
      String title = message.notification?.title??'';
      String body = message.notification?.body??'';
      String? imageUrl;
      Map data = message.data;
      String type = data['type']??'';
      if(data['imageUrl'] != null){
        imageUrl = data['imageUrl'];
      }
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
            autoDismissible: false,
            backgroundColor: Colors.white,
            payload: data.cast<String,String>(),
          ),
          actionButtons: [
            NotificationActionButton(
                key: 'ACCEPT',
                label: 'Answer',
                color: Colors.green,
                autoDismissible: true
            ),
            NotificationActionButton(
                key: 'REJECT',
                label: 'Decline',
                color: Colors.green,
                isDangerousOption: true,
                autoDismissible: true
            ),
          ]
      );
    });

  }

  Future<String?> getNotificationToken() async {
    var token = await messaging.getToken();
    print('Firebase token: \n $token');
    return token;
  }

  Future<void> awesomeNotificationSetup() async {
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
      print('AwesomeNotifications().actionStream ${receivedAction.payload}');
      if(receivedAction.channelKey == 'call_channel'){
        switch (receivedAction.buttonKeyPressed) {

          case 'REJECT':
            AndroidForegroundService.stopForeground();
            break;

          case 'ACCEPT':
            AndroidForegroundService.stopForeground();
          // loadSingletonPage(targetPage: PAGE_PHONE_CALL, receivedAction: receivedAction);
            break;

          default:
            AndroidForegroundService.stopForeground();
          // loadSingletonPage(targetPage: PAGE_PHONE_CALL, receivedAction: receivedAction);
            break;
        }
        return;
      }
    });
  }

  Future sendNotification(String token, String title, String message, Map data) async {
    Map map = {
      "to": token,
      "notification": {"title": title, "body": message},
      "data": data,
    };
    if (token.isNotEmpty) {
      print('Unable to send FCM message, no token exists.');
      return;
    }
    try {
      await post(
        Uri.parse('https://api.rnfirebase.io/messaging/send'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'key=AAAAaa2e9ys:APA91bHjXVbNkKrkNC6_HxcFYuVal_IMNFxK7738gFxTu87_ACZ8HUeGQd3dkvRwiTmqtfjDd30fMV-d5XiHr_BBTGKOLJdH0OgKs1B9Q6eAXgWadZeiv2hV2E4ydmyb7Ar6Ykl86UlD',
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
  String title = message.notification?.title??'';
  String body = message.notification?.body??'';
  String? imageUrl;
  Map data = message.data;
  String type = data['type']??'';
  if(data['imageUrl'] != null){
    imageUrl = data['imageUrl'];
  }
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
          autoDismissible: false,
          backgroundColor: Colors.white,
          payload: data.cast<String,String>(),
      ),
      actionButtons: [
        NotificationActionButton(
            key: 'ACCEPT',
            label: 'Answer',
            color: Colors.green,
            autoDismissible: true
        ),
        NotificationActionButton(
            key: 'REJECT',
            label: 'Decline',
            color: Colors.green,
            isDangerousOption: true,
            autoDismissible: true
        ),
      ]
  );
}
