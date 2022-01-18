import 'dart:async';
import 'package:animate_countdown_text/animate_countdown_text.dart';
import 'package:app_2i2i/ui/commons/custom_animated_progress_bar.dart';
import 'package:app_2i2i/infrastructure/commons/theme.dart';
import 'package:app_2i2i/ui/screens/web_rtc/signaling.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../../infrastructure/data_access_layer/services/logging.dart';
import '../../../infrastructure/models/meeting_model.dart';
import '../../../infrastructure/models/user_model.dart';
import '../../../infrastructure/providers/all_providers.dart';
import '../../../infrastructure/providers/web_rtc_provider/call_screen_provider.dart';
import 'widgets/circle_button.dart';

class CallPage extends ConsumerStatefulWidget {
  final Meeting meeting;
  final UserModel user;
  final Function onHangPhone;
  final MeetingChanger meetingChanger;
  final UserModelChanger userModelChanger;

  CallPage({
    Key? key,
    required this.meeting,
    required this.meetingChanger,
    required this.userModelChanger,
    required this.onHangPhone,
    required this.user,
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

  Future<void> _initBudgetTimer() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();

    signaling = Signaling(
      meeting: widget.meeting,
      meetingChanger: widget.meetingChanger,
      userModelChanger: widget.userModelChanger,
      amA: amA,
      localVideo: _localRenderer,
      remoteVideo: _remoteRenderer,
    );
    signaling!.onAddRemoteStream = ((stream) {
      _remoteRenderer.srcObject = stream;
      if (signaling?.localStream != null) {
        ref.read(callScreenProvider).getInitialValue(signaling!.localStream!);
      }
      setState(() {});
    });

    // no timer for free call
    if (widget.meeting.speed.num == 0) return;

    final maxDuration = widget.meeting.maxDuration()!;
    final duration = getDuration(maxDuration);
    budgetTimer = Timer(Duration(seconds: duration), () {
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

  int getDuration(int maxDuration) {
    int duration = maxDuration;
    final activeTime = widget.meeting.start;
    if (activeTime != null) {
      final DateTime maxEndTime =
          activeTime.add(Duration(seconds: maxDuration));
      final durationObj = maxEndTime.difference(DateTime.now().toUtc());
      duration = durationObj.inSeconds;
    }
    return duration;
  }

  void showCountDown(int duration) {
    if (countDownTimerDate != null) {
      return;
    }
    final maxDuration = widget.meeting.maxDuration()!;
    final duration = getDuration(maxDuration);
    log(' ====== $duration');
    if (duration <= 100) {
      countDownTimerDate = DateTime.now().add(Duration(seconds: duration));
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  void initState() {
    _initBudgetTimer();

    amA = widget.meeting.A == widget.user.id;

    super.initState();
  }

  @override
  void dispose() async {
    _localRenderer.srcObject?.getTracks().forEach((element) async {
      await element.stop();
    });
    await _localRenderer.srcObject?.dispose();
    _localRenderer.srcObject = null;
    await _localRenderer.dispose();

    _remoteRenderer.srcObject?.getTracks().forEach((element) async {
      await element.stop();
    });
    await _remoteRenderer.srcObject?.dispose();
    _remoteRenderer.srcObject = null;
    await _remoteRenderer.dispose();

    budgetTimer?.cancel();
    progressTimer?.cancel();

    // final otherUid = amA ? widget.meeting.B : widget.meeting.A;
    // await widget.onHangPhone(otherUid, widget.meeting.id);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    callScreenModel = ref.watch(callScreenProvider);
    final myUid = amA ? widget.meeting.A : widget.meeting.B;
    final userModel = ref.watch(userProvider(myUid));
    if (userModel is AsyncLoading || userModel is AsyncError) {
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
                      userModel: userModel.asData!.value)
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
                              userModel: userModel.asData!.value)
                          : secondVideoView(
                              height: MediaQuery.of(context).size.height * 0.3,
                              width: MediaQuery.of(context).size.height * 0.3,
                              renderer: _remoteRenderer,
                            ),
                    ),
                    InkResponse(
                      onTap: () => callScreenModel!.swapped =
                          !(callScreenModel?.swapped ?? false),
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
                      if (!amA) {
                        val = 100 - value;
                      }
                      double width = MediaQuery.of(context).size.height / 3;
                      double height = val * width / 100;
                      return RotationTransition(
                        turns: new AlwaysStoppedAnimation(amA ? 0 : 0),
                        child: Container(
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
                                        borderRadius:
                                            BorderRadius.circular(20)),
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
                                    shadowColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    type: MaterialType.card,
                                    child: ProgressBar(
                                      height: height,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
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
                          dateTime: countDownTimerDate ?? DateTime.now(),
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

                            dispose();
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
                      CircleButton(
                          icon: Icons.cameraswitch_rounded,
                          onTap: () => callScreenModel!.cameraSwitch(
                              context: context, signaling: signaling!)),
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
      UserModel? userModel}) {
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

  DurationFormat _formatHMS(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes - hours * 60;
    final seconds = duration.inSeconds - hours * 60 * 60 - minutes * 60;
    return DurationFormat(
      second: "$seconds",
    );
  }
}
