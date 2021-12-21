import 'package:flutter/foundation.dart';

class CallScreenModel extends ChangeNotifier {
  bool _swapped = false;
  bool _isMute = false;
  bool _isDisableVideo = false;

  bool get swapped => _swapped;

  bool get isMute => _isMute;

  bool get isDisableVideo => _isDisableVideo;

  set isMute(bool value) {
    _isMute = value;
    notifyListeners();
  }

  set swapped(bool value) {
    _swapped = value;
    notifyListeners();
  }

  set isDisableVideo(bool value) {
    _isDisableVideo = value;
    notifyListeners();
  }

  hangCall() {
   /* try {

      if (budgetTimer?.isActive ?? false) {
        budgetTimer?.cancel();
      }


      await signaling?.hangUp(_localRenderer);

    widget.onHangPhone(widget.meeting.A == widget.user.id? widget.meeting.B: widget.meeting.A,widget.meeting.id);

    } catch (e) {
    log(e.toString());
    }*/
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
