// import 'dart:convert';
//
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:http/http.dart' as http;
//
// class FireBaseMessagingService {
//   Future<FireBaseMessagingService> init() async {
//     firebaseCloudMessagingListeners();
//     getDeviceToken();
//     return this;
//   }
//
//   void firebaseCloudMessagingListeners() {
//     FirebaseMessaging.instance.requestPermission(sound: true, badge: true, alert: true);
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       RemoteNotification? notification = message.notification;
//       print("hola me llamo jose raul${notification}");
//     });
//     FirebaseMessaging.onMessageOpenedApp.listen((event) async {
//       print(event.data);
//     });
//   }
//
//   Future<String?> getDeviceToken() async {
//     return await FirebaseMessaging.instance.getToken();
//   }
//
//   Future sendNotification(
//       String token, String title, String body, String routeName) async {
//     Map map = {
//       "to": token,
//       "notification": {"title": title, "body": body},
//       "data": {"route": routeName}
//     };
//     if (token.isNotEmpty) {
//       print('Unable to send FCM message, no token exists.');
//       return;
//     }
//     try {
//       await http.post(
//         Uri.parse('https://api.rnfirebase.io/messaging/send'),
//         headers: <String, String>{
//           'Content-Type': 'application/json; charset=UTF-8',
//         },
//         body: jsonEncode(map),
//       );
//       print('FCM request for device sent!');
//     } catch (e) {
//       print(e);
//     }
//   }
// }
