import 'dart:async';

import 'package:animate_countdown_text/animate_countdown_text.dart';
import 'package:app_2i2i/infrastructure/commons/theme.dart';
import 'package:app_2i2i/infrastructure/commons/utils.dart';
import 'package:app_2i2i/ui/commons/custom_animated_progress_bar.dart';
import 'package:app_2i2i/ui/screens/web_rtc/signaling.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../../../infrastructure/data_access_layer/services/logging.dart';
import '../../../infrastructure/models/meeting_model.dart';
import '../../../infrastructure/models/hangout_model.dart';
import '../../../infrastructure/providers/all_providers.dart';
import '../../../infrastructure/providers/web_rtc_provider/call_screen_provider.dart';
import 'widgets/circle_button.dart';

class CallPage extends ConsumerStatefulWidget {
  final Meeting meeting;
  final Hangout hangout;
  final Function onHangPhone;
  final MeetingChanger meetingChanger;
  final HangoutChanger hangoutChanger;

  CallPage({
    Key? key,
    required this.meeting,
    required this.meetingChanger,
    required this.hangoutChanger,
    required this.onHangPhone,
    required this.hangout,
  }) : super(key: key);

  @override
  _CallPageState createState() => _CallPageState();
}

class _CallPageState extends ConsumerState<CallPage>
    with TickerProviderStateMixin {
  late bool amA;

  Signaling? signaling;
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  TextEditingController textEditingController = TextEditingController(text: '');

  Timer? budgetTimer;
  Timer? progressTimer;
  CallScreenModel? callScreenModel;

  ValueNotifier<double> progress = ValueNotifier(100);
  DateTime? countDownTimerDate;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> _init() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();

    signaling = Signaling(
      meeting: widget.meeting,
      meetingChanger: widget.meetingChanger,
      hangoutChanger: widget.hangoutChanger,
      amA: amA,
      localVideo: _localRenderer,
      remoteVideo: _remoteRenderer,
    );
    signaling!.onAddRemoteStream = ((stream) {
      _remoteRenderer.srcObject = stream;
      if (signaling?.localStream != null) {
        ref.read(callScreenProvider).getInitialValue(signaling!.localStream!);
      }
      // if(mounted) {
      //   setState(() {});
      // }
    });
  }

  Future<void> _initTimers() async {
    // no timer for free call
    if (widget.meeting.start == null) return;
    if (budgetTimer?.isActive ?? false) return;

    final maxDuration = widget.meeting.maxDuration();
    // log(X + 'maxDuration=$maxDuration');
    final duration = getDurationLeft(maxDuration);
    // log(X + 'duration=$duration');
    budgetTimer = Timer(Duration(seconds: duration), () {
      // log(X + 'budgetTimer');
      progressTimer?.cancel();
      signaling?.hangUp(reason: MeetingStatus.END_TIMER);
    });

    progressTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      double percentage = (timer.tick * 100) / maxDuration;
      progress.value = 100 - percentage;
      if (timer.tick >= maxDuration) progressTimer?.cancel();
      showCountDown(duration);
    });
  }

  int getDurationLeft(int maxDuration) {
    final DateTime maxEndTime =
        widget.meeting.start!.add(Duration(seconds: maxDuration));
    final durationObj = maxEndTime.difference(DateTime.now().toUtc());
    return durationObj.inSeconds;
  }

  void showCountDown(int duration) {
    if (countDownTimerDate != null) {
      return;
    }
    final maxDuration = widget.meeting.maxDuration();
    final duration = getDurationLeft(maxDuration);
    log(' ====== $duration');
    if (duration <= 60) {
      countDownTimerDate =
          DateTime.now().toUtc().add(Duration(seconds: duration));
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  void initState() {
    _init();
    amA = widget.meeting.A == widget.hangout.id;
    super.initState();
  }

  @override
  void dispose() async {
    super.dispose();
    await disposeInit();

    // final otherUid = amA ? widget.meeting.B : widget.meeting.A;
    // await widget.onHangPhone(otherUid, widget.meeting.id);
  }

  Future<void> disposeInit() async {
    if (_localRenderer.srcObject != null) {
      _localRenderer.srcObject!
          .getTracks()
          .forEach((element) async => await element.stop());
      await _localRenderer.srcObject!.dispose();
      _localRenderer.srcObject = null;
    }

    if (_remoteRenderer.srcObject != null) {
      _remoteRenderer.srcObject!
          .getTracks()
          .forEach((element) async => await element.stop());
      await _remoteRenderer.srcObject!.dispose();
      _remoteRenderer.srcObject = null;
    }

    budgetTimer?.cancel();
    progressTimer?.cancel();

    final otherUid = amA ? widget.meeting.B : widget.meeting.A;
    widget.onHangPhone(otherUid, widget.meeting.id);
  }

  @override
  Widget build(BuildContext context) {
    _initTimers();

    callScreenModel = ref.watch(callScreenProvider);
    final myUid = amA ? widget.meeting.A : widget.meeting.B;
    final hangout = ref.watch(hangoutProvider(myUid));
    if (haveToWait(hangout)) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      key: _scaffoldKey,
      body: OrientationBuilder(builder: (context, orientation) {
        return Container(
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              callScreenModel?.swapped ?? false
                  ? firstVideoView(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      renderer: _localRenderer,
                      hangout: hangout.asData!.value)
                  : secondVideoView(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      renderer: _remoteRenderer,
                    ),
              Positioned(
                top: 40,
                left: 40,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16.0),
                      child: !(callScreenModel?.swapped ?? false)
                          ? firstVideoView(
                              height: MediaQuery.of(context).size.height * 0.3,
                              width: MediaQuery.of(context).size.height * 0.3,
                              renderer: _localRenderer,
                              hangout: hangout.asData!.value)
                          : secondVideoView(
                              height: MediaQuery.of(context).size.height * 0.3,
                              width: MediaQuery.of(context).size.height * 0.3,
                              renderer: _remoteRenderer,
                            ),
                    ),
                    InkResponse(
                      onTap: () => callScreenModel!.swapped = !(callScreenModel?.swapped ?? false),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16.0),
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.3,
                          width: MediaQuery.of(context).size.height * 0.3,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              if ((widget.meeting.speed.num) == 0)
                Container()
              else
                Align(
                  alignment: Alignment.centerRight,
                  child: ValueListenableBuilder(
                    valueListenable: progress,
                    builder:
                        (BuildContext context, double value, Widget? child) {
                      var val = value;
                      if (amA && value > 0) {
                        val = 100 - value;
                      }

                      double width = MediaQuery.of(context).size.height / 3;
                      double height = (val * width) / 100;
                      return Container(
                        height: width,
                        width: 28,
                        margin: const EdgeInsets.only(right: 30, left: 30),
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(8),
                                child: Material(
                                  color: Colors.transparent,
                                  shadowColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  type: MaterialType.card,
                                  child: SizedBox(
                                    height: width,
                                    width: 20,
                                  ),
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Padding(
                                padding: EdgeInsets.all(8),
                                child: Material(
                                  borderRadius: BorderRadius.circular(20),
                                  shadowColor: Colors.black12,
                                  type: MaterialType.card,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: ProgressBar(
                                      height: width,
                                      radius: 0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.topCenter,
                              child: Padding(
                                padding: EdgeInsets.all(8),
                                child: Material(
                                  color: Colors.grey,
                                  shadowColor: Colors.black,
                                  type: MaterialType.card,
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(20),
                                    topLeft: Radius.circular(20),
                                  ),
                                  child: Container(
                                    height: height,
                                    width: 20,
                                    decoration: BoxDecoration(
                                        color: Colors.white24,
                                        border: Border(bottom: BorderSide())),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Visibility(
                  visible: countDownTimerDate is DateTime,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 100.0),
                    child: SizedBox(
                      height: 100,
                      width: 100,
                      child: Center(
                        child: AnimateCountdownText(
                          dateTime:
                              countDownTimerDate ?? DateTime.now().toUtc(),
                          format: _formatHMS,
                          animationType: AnimationType.scaleIn,
                          characterTextStyle: Theme.of(context)
                              .textTheme
                              .headline3!
                              .copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  margin: EdgeInsets.all(8),
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                      color: Colors.white38,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleButton(
                          icon: Icons.call_end,
                          iconColor: Colors.white,
                          backgroundColor: AppTheme().red,
                          onTap: () async {
                            if (budgetTimer?.isActive ?? false) {
                              budgetTimer?.cancel();
                            }
                            final reason =
                                amA ? MeetingStatus.END_A : MeetingStatus.END_B;
                            await signaling?.hangUp(reason: reason);

                            await disposeInit();
                          }),
                      CircleButton(
                          icon: callScreenModel?.isAudioEnabled ?? false
                              ? Icons.mic_rounded
                              : Icons.mic_off_rounded,
                          onTap: () => callScreenModel!.muteAudio(
                              signaling: signaling!,
                              localRenderer: _localRenderer)),
                      CircleButton(
                          icon: callScreenModel?.isVideoEnabled ?? false
                              ? Icons.videocam_rounded
                              : Icons.videocam_off_rounded,
                          onTap: () => callScreenModel!
                              .muteVideo(signaling: signaling!)),
                      // CircleButton(
                      //     icon: Icons.cameraswitch_rounded,
                      //     onTap: () => callScreenModel!.cameraSwitch(
                      //         context: context, signaling: signaling!)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget secondVideoView(
      {double? height, double? width, RTCVideoRenderer? renderer}) {
    return Container(
      width: width,
      height: height,
      child: RTCVideoView(renderer!,
          mirror: true,
          objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover),
      decoration: BoxDecoration(color: Colors.black54),
    );
  }

  Widget firstVideoView(
      {double? height,
      double? width,
      RTCVideoRenderer? renderer,
      Hangout? hangout}) {
    return Container(
      width: width,
      height: height,
      child: RTCVideoView(
        renderer!,
        objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
      ),
      decoration: BoxDecoration(color: Colors.black54),
    );
  }

  DurationFormat _formatHMS(Duration duration) => DurationFormat(
        second: "${duration.inSeconds}",
      );
}
