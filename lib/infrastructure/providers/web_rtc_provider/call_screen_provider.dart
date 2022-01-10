import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../../../ui/screens/web_rtc/signaling.dart';

class CallScreenModel extends ChangeNotifier {
  bool _swapped = false;
  bool _isAudioEnabled = true;
  bool _isVideoEnabled = true;
  bool _switchCamera = false;

  bool get swapped => _swapped;

  bool get isAudioEnabled => _isAudioEnabled;

  bool get isVideoEnabled => _isVideoEnabled;

  bool get switchCamera => _switchCamera;

  getInitialValue(MediaStream localStream) {
    _isAudioEnabled = localStream.getAudioTracks().first.enabled;
    _isVideoEnabled = localStream.getVideoTracks().first.enabled;
    notifyListeners();
  }

  set isAudioEnabled(bool value) {
    _isAudioEnabled = value;
    notifyListeners();
  }

  set swapped(bool value) {
    _swapped = value;
    notifyListeners();
  }

  set isVideoEnabled(bool value) {
    _isVideoEnabled = value;
    notifyListeners();
  }

  muteAudio(
      {required Signaling signaling, required RTCVideoRenderer localRenderer}) {
    _isAudioEnabled = !isAudioEnabled;
    localRenderer.muted = _isAudioEnabled;
    signaling.localStream?.getAudioTracks().first.enabled = _isAudioEnabled;
    notifyListeners();
  }

  muteVideo({required Signaling signaling}) {
    _isVideoEnabled = !isVideoEnabled;
    signaling.localStream?.getVideoTracks().first.enabled = _isVideoEnabled;
    notifyListeners();
  }

  Future<void> cameraSwitch({required Signaling signaling, required BuildContext context}) async {
    if(signaling.localStream == null){
      return;
    }
    _switchCamera = !switchCamera;
    int selectedIndex;
    List<MediaDeviceInfo> cameras = await Helper.cameras;
    if (cameras.isNotEmpty && cameras.length > 1) {
      selectedIndex = switchCamera ? 0 : 1;
      await Helper.switchCamera(
          signaling.localStream!.getVideoTracks()[selectedIndex],
          cameras[selectedIndex].deviceId,
          signaling.localStream,
      );
    } else {
      showToast('No secondary camera found',
          context: context,
          animation: StyledToastAnimation.slideFromTop,
          reverseAnimation: StyledToastAnimation.slideToTop,
          position: StyledToastPosition.top,
          startOffset: Offset(0.0, -3.0),
          reverseEndOffset: Offset(0.0, -3.0),
          duration: Duration(seconds: 4),
          animDuration: Duration(seconds: 1),
          curve: Curves.elasticOut,
          reverseCurve: Curves.fastOutSlowIn);
    }
  }
}
