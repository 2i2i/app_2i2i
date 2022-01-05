import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseConfig {
  static FirebaseOptions get platformOptions {
    if (kIsWeb) {
      return const FirebaseOptions(
        apiKey: 'AIzaSyCOTTyRjSkGaao_86k4JyNla0JX-iSSlTs',
        appId: '1:453884442411:web:dad8591e5125eb8998776e',
        messagingSenderId: '453884442411',
        projectId: 'i2i-test',
        authDomain: 'i2i-test.firebaseapp.com',
      );
    } else if (Platform.isIOS || Platform.isMacOS) {
      return const FirebaseOptions(
        apiKey: 'AIzaSyCOTTyRjSkGaao_86k4JyNla0JX-iSSlTs',
        appId: '1:453884442411:web:dad8591e5125eb8998776e',
        messagingSenderId: '453884442411',
        projectId: 'i2i-test',
        authDomain: 'i2i-test.firebaseapp.com',
        // iosBundleId: 'io.flutter.plugins.firebase.auth',
        // databaseURL: 'https://react-native-firebase-testing.firebaseio.com',
        // iosClientId: '448618578101-m53gtqfnqipj12pts10590l37npccd2r.apps.googleusercontent.com',
        // androidClientId: '448618578101-26jgjs0rtl4ts2i667vjb28kldvs2kp6.apps.googleusercontent.com',
        storageBucket: 'i2i-test.appspot.com',
      );
    } else {
      return const FirebaseOptions(
        apiKey: 'AIzaSyCOTTyRjSkGaao_86k4JyNla0JX-iSSlTs',
        appId: '1:453884442411:web:dad8591e5125eb8998776e',
        messagingSenderId: '453884442411',
        projectId: 'i2i-test',
        authDomain: 'i2i-test.firebaseapp.com',
        // databaseURL: 'https://react-native-firebase-testing.firebaseio.com',
        // androidClientId: '448618578101-qd7qb4i251kmq2ju79bl7sif96si0ve3.apps.googleusercontent.com',
      );
    }
  }
}
