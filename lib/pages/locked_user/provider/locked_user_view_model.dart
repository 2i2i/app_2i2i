import 'package:app_2i2i/models/meeting.dart';
import 'package:app_2i2i/models/user.dart';
import 'package:app_2i2i/services/logging.dart';
import 'package:flutter/foundation.dart';

class LockedUserViewModel with ChangeNotifier {
  LockedUserViewModel({required this.user, required this.meeting});
  final UserModel user;
  final Meeting meeting;

  bool amA() {
    final x = meeting.A == user.id;
    log('LockedUserViewModel - amA - x=$x');
    return x;
  }

  bool amB() {
    final x = meeting.B == user.id;
    log('LockedUserViewModel - amA - x=$x');
    return x;
  }
}
