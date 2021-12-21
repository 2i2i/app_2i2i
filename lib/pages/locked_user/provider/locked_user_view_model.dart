import 'package:app_2i2i/models/meeting.dart';
import 'package:app_2i2i/models/user.dart';
import 'package:app_2i2i/services/logging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

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

  bool _isMute = false;
  bool _isDisableVideo = false;


  bool get isMute => _isMute;

  bool get isDisableVideo => _isDisableVideo;

  set isMute(bool value) {
    _isMute = value;
    notifyListeners();
  }


  set isDisableVideo(bool value) {
    _isDisableVideo = value;
    notifyListeners();
  }



  Future<void> muteCall() async {


    // if (mediaStream != null) {
    //   mediaStream.getAudioTracks()[0]?.enabled = false;
    //   mediaStream.getAudioTracks()[0]?.setMicrophoneMute(true);
    // } else {
    //   mediaStream.getAudioTracks()[0]?.enabled = true;
    //   mediaStream.getAudioTracks()[0]?.setMicrophoneMute(true);
    // }
  }
}
