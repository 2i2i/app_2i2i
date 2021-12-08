import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:animate_countdown_text/animate_countdown_text.dart';
import 'package:app_2i2i/common/animated_progress_bar.dart';
import 'package:app_2i2i/common/utils.dart';
import 'package:app_2i2i/models/meeting.dart';
import 'package:app_2i2i/models/user.dart';
import 'package:app_2i2i/pages/web_rtc/signaling.dart';
import 'package:app_2i2i/services/logging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class CallPage extends StatefulWidget {

  final Meeting meeting;
  final UserModel user;

  CallPage({Key? key, required this.meeting, required this.user}) : super(key: key);

  @override
  _CallPageState createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> with TickerProviderStateMixin {
  bool swapped = false;
  Signaling? signaling;
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  TextEditingController textEditingController = TextEditingController(text: '');

  Timer? budgetTimer;
  Timer? progressTimer;

  ValueNotifier<double> progress = ValueNotifier(100);
  DateTime? countDownTimerDate;

  void _initBudgetTimer() {
    // no timer for free call
    if (widget.meeting.speed.num == 0) return;

    var maxDuration = ((widget.meeting.budget) / (widget.meeting.speed.num)).floor();
    int duration = getDuration(maxDuration);

    budgetTimer = Timer(Duration(seconds: duration), () {
      progressTimer?.cancel();
      signaling?.hangUp(_localRenderer, reason: 'BUDGET');
    });

    progressTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      double percentage = (timer.tick * 100) / maxDuration;
      progress.value = 100 - percentage;
      if (timer.tick >= maxDuration) progressTimer?.cancel();
      showCountDown(duration);
    });
  }

  int getDuration(int maxDuration) {
    int duration= maxDuration;
    final activeTime = widget.meeting.activeTime();
    if (activeTime != null) {
      final maxEndTime = activeTime + maxDuration;
      duration = max(maxEndTime - epochSecsNow(), 0);
    }
    return duration;
  }

  void showCountDown(int duration) {
    if(countDownTimerDate != null){
      return;
    }
    var maxDuration = ((widget.meeting.budget) / (widget.meeting.speed.num)).floor();
    int duration = getDuration(maxDuration);
    log(F+ ' ====== $duration');
    if(duration <= 60) {
      countDownTimerDate = DateTime.now().add(Duration(seconds: duration));
      if (mounted) {
        Future.delayed(Duration.zero).then((value) {
          if (mounted) {
            setState(() {});
          }
        });
      }
    }
  }

  @override
  void initState() {

    _localRenderer.initialize();
    _remoteRenderer.initialize();

    _initBudgetTimer();

    signaling = Signaling(
        meeting: widget.meeting,
        amA: widget.meeting.A == widget.user.id,
        localVideo: _localRenderer,
        remoteVideo: _remoteRenderer);
    signaling!.onAddRemoteStream = ((stream) {
      _remoteRenderer.srcObject = stream;
      setState(() {});
    });

    super.initState();
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    budgetTimer?.cancel();
    progressTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: OrientationBuilder(builder: (context, orientation) {
          return Container(
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              swapped
                  ? firstVideoView(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      renderer: _localRenderer,
                    )
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
                      child: !swapped
                          ? firstVideoView(
                              height: MediaQuery.of(context).size.height * 0.3,
                              width: MediaQuery.of(context).size.height * 0.3,
                                renderer: _localRenderer,
                        )
                            : secondVideoView(
                                height: MediaQuery.of(context).size.height*0.3,
                                width: MediaQuery.of(context).size.height*0.3,
                                renderer: _remoteRenderer,
                        ),
                    ),
                    InkResponse(
                        onTap: (){
                            swapped = !swapped;
                          setState(() {});
                        },
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
              Align(
                alignment: Alignment.centerRight,
                child: ValueListenableBuilder(
                  valueListenable: progress,
                  builder: (BuildContext context, double value, Widget? child) {
                    double width = MediaQuery.of(context).size.height / 3;
                    double height = value * width / 100;
                    return Padding(
                      padding: const EdgeInsets.only(right: 30),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white24,
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(20)
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(8),
                            child: Material(
                              shadowColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)
                              ),
                              type: MaterialType.card,
                              child: ProgressBar(
                                height: height,
                              ),
                            ),
                          ),
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
                          dateTime: countDownTimerDate??DateTime.now(),
                          format: _formatHMS,
                          animationType: AnimationType.scaleIn,
                          characterTextStyle: Theme.of(context).textTheme.headline3!.copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: GestureDetector(
                  onTap: () {
                    try {
                      if (budgetTimer?.isActive ?? false) {
                        budgetTimer?.cancel();
                      }
                      signaling?.hangUp(_localRenderer);
                    } catch (e) {
                      print(e);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom:8.0),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white38,
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(20)
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Material(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Icon(
                                Icons.call_end,
                                color: Colors.white,
                              ),
                            ),
                            color: Color.fromARGB(255, 239, 102, 84),
                            shadowColor: Colors.white,
                            type: MaterialType.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            ],
          ),
        );
      }),
    );
  }

  Widget firstVideoView({double? height, double? width, RTCVideoRenderer? renderer}) {
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

  Widget secondVideoView({double? height, double? width, RTCVideoRenderer? renderer}) {
    return Container(
      width: width,
      height: height,
      child: RTCVideoView(renderer!,
          mirror: true,
          objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover),
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
