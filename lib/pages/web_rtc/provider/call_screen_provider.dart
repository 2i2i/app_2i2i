import 'dart:async';

import 'package:app_2i2i/pages/web_rtc/signaling.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class CallScreenModel extends ChangeNotifier {
  bool _swapped = false;
  bool _isMuteEnable = true;
  bool _isVideoEnable = true;
  bool _switchCamera = false;

  bool get swapped => _swapped;

  bool get isMuteEnable => _isMuteEnable;

  bool get isVideoEnable => _isVideoEnable;

  bool get switchCamera => _switchCamera;

  getInitialValue(MediaStream localStream) {
    _isMuteEnable = localStream.getAudioTracks().first.enabled;
    _isVideoEnable = localStream.getVideoTracks().first.enabled;
    notifyListeners();
  }

  set isMuteEnable(bool value) {
    _isMuteEnable = value;
    notifyListeners();
  }

  set swapped(bool value) {
    _swapped = value;
    notifyListeners();
  }

  set isVideoEnable(bool value) {
    _isVideoEnable = value;
    notifyListeners();
  }

  muteCall(
      {required Signaling signaling, required RTCVideoRenderer localRenderer}) {
    localRenderer.muted = !isMuteEnable;
    signaling.localStream.getAudioTracks().first.enabled = !isMuteEnable;
    _isMuteEnable = !_isMuteEnable;
  }

  disableVideo({required Signaling signaling}) {
    signaling.localStream.getVideoTracks().first.enabled = !isVideoEnable;
    _isVideoEnable = !isVideoEnable;
  }

  Future<void> cameraSwitch(
      {required Signaling signaling, required BuildContext context}) async {
    _switchCamera = !switchCamera;
    int selectedIndex;
    List<MediaDeviceInfo> cameras = await Helper.cameras;
    if (cameras.isNotEmpty && cameras.length > 1) {
      selectedIndex = switchCamera ? 0 : 1;
      await Helper.switchCamera(
          signaling.localStream.getVideoTracks()[selectedIndex],
          cameras[selectedIndex].deviceId,
          signaling.localStream);
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
