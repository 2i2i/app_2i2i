import 'package:awesome_notifications/android_foreground_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

class FirebaseNotifications {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  void requestPermissionForNotification() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    print('User granted permission: ${settings.authorizationStatus}');
  }

  FirebaseNotifications() {
    awesomeNotificationSetup();
    firebaseCloudMessagingListeners();
  }

  void awesomeNotificationSetup() {
    AwesomeNotifications().initialize(
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
            // loadSingletonPage(targetPage: PAGE_PHONE_CALL, receivedAction: receivedAction);
            AndroidForegroundService.stopForeground();
            break;

          default:
            // loadSingletonPage(targetPage: PAGE_PHONE_CALL, receivedAction: receivedAction);
            break;
        }
        return;
      }
    });
  }

  void firebaseCloudMessagingListeners() {
    getNotificationToken().then((value) => print(value));

    FirebaseMessaging.instance
        .requestPermission(sound: true, badge: true, alert: true);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidForegroundService.startForeground(
      // AwesomeNotifications().createNotification(
          content: NotificationContent(
              id: 10,
              channelKey: 'call_channel',
              title: 'Incoming Call',
              body: 'from Little Mary',
              category: NotificationCategory.Call,
              largeIcon: 'asset://assets/logo_dark.png',
              wakeUpScreen: true,
              fullScreenIntent: true,
              autoDismissible: false,
              backgroundColor: Colors.white,
              customSound: 'resource://raw/video_call',
              payload: {
                'username': 'Little Mary'
              }
          ),
          actionButtons: [
            NotificationActionButton(
                key: 'ACCEPT',
                label: 'Accept Call',
                color: Colors.green,
                autoDismissible: true
            ),
            NotificationActionButton(
                key: 'REJECT',
                label: 'Reject',
                isDangerousOption: true,
                autoDismissible: true
            ),
          ]
      );
    });

    /*FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) async {
      RemoteNotification? notification = message?.notification;
      print('FirebaseMessaging.getInitialMessage() ${notification?.toString()}');
    });*/
  }

  Future<String?> getNotificationToken() async {
    var token = await messaging.getToken();
    print('Firebase token: \n $token');
    return token;
  }
}

Future<void> firebaseMessagingBackgroundHandler(message) async {
  print("Handling a background message: ${message?.messageId}");
  // if (!kIsWeb) {
  //   await Firebase.initializeApp();
  // }
  // AndroidForegroundService.startForeground(
  AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: 10,
          channelKey: 'call_channel',
          title: 'Incoming Call',
          body: 'from Little Mary',
          category: NotificationCategory.Call,
          // largeIcon: 'asset://assets/images/girl-phonecall.jpg',
          wakeUpScreen: true,
          fullScreenIntent: true,
          autoDismissible: false,
          backgroundColor: Colors.white,
          payload: {
            'username': 'Little Mary'
          }
      ),
      actionButtons: [
        NotificationActionButton(
            key: 'ACCEPT',
            label: 'Accept Call',
            color: Colors.green,
            autoDismissible: true
        ),
        NotificationActionButton(
            key: 'REJECT',
            label: 'Reject',
            isDangerousOption: true,
            autoDismissible: true
        ),
      ]
  );
}
