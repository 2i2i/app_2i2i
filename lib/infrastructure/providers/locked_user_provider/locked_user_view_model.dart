import 'package:app_2i2i/infrastructure/models/meeting_model.dart';
import 'package:app_2i2i/infrastructure/models/user_model.dart';
import 'package:flutter/foundation.dart';

import '../../data_access_layer/services/logging.dart';
import '../../models/call_status_model.dart';

class LockedUserViewModel with ChangeNotifier {
  LockedUserViewModel(
      {required this.user,
      required this.meeting});

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
