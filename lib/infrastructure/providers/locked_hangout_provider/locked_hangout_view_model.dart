import 'package:app_2i2i/infrastructure/models/meeting_model.dart';
import 'package:app_2i2i/infrastructure/models/hangout_model.dart';
import 'package:flutter/foundation.dart';

import '../../data_access_layer/services/logging.dart';

class LockedHangoutViewModel with ChangeNotifier {
  LockedHangoutViewModel({required this.hangout, required this.meeting});
  final Hangout hangout;
  final Meeting meeting;

  bool amA() {
    final x = meeting.A == hangout.id;
    log('LockedUserViewModel - amA - x=$x');
    return x;
  }

  bool amB() {
    final x = meeting.B == hangout.id;
    log('LockedUserViewModel - amA - x=$x');
    return x;
  }
}
