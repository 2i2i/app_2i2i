
import 'dart:async';
import 'dart:math';

import 'package:app_2i2i/common/utils.dart';
import 'package:app_2i2i/models/meeting.dart';
import 'package:app_2i2i/models/user.dart';
import 'package:app_2i2i/pages/web_rtc/signaling.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class CallPage extends StatefulWidget {
  CallPage({Key? key, required this.meeting, required this.user})
      : super(key: key);

  final Meeting meeting;
  final UserModel user;

  @override
  _CallPageState createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> with TickerProviderStateMixin {
  Meeting? meeting;
  UserModel? user;
  AnimationController? controller;

  Timer? timer;
  bool swapped = false;
  Signaling? signaling;
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  String? roomId;
  TextEditingController textEditingController = TextEditingController(text: '');

  Timer? budgetTimer;

  void _initBudgetTimer() {
    // no timer for free call
    if (meeting!.speed.num == 0) return;

    final maxDuration = (meeting!.budget / meeting!.speed.num).floor();
    int duration = maxDuration;
    final activeTime = meeting!.activeTime();
    if (activeTime != null) {
      final maxEndTime = activeTime + maxDuration;
      duration = max(maxEndTime - epochSecsNow(), 0);
    }
    budgetTimer = Timer(Duration(seconds: duration),
        () => signaling!.hangUp(_localRenderer, reason: 'BUDGET'));
    controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: duration),
    )..addListener(() {});
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
    controller!.forward();
  }

  bool amA() {
    return meeting!.A == user!.id;
  }

  @override
  void initState() {
    meeting = widget.meeting;
    user = widget.user;
    _localRenderer.initialize();
    _remoteRenderer.initialize();

    _initBudgetTimer();

    signaling = Signaling(
        meeting: meeting!,
        amA: amA(),
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
    budgetTimer!.cancel();
    controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          onPressed: () => signaling!.hangUp(_localRenderer),
          child: Icon(
            Icons.call_end,
            color: Colors.white,
          ),
          backgroundColor: Colors.pink,
        ),
        body: OrientationBuilder(builder: (context, orientation) {
          return Container(
            child: Stack(children: <Widget>[
              swapped
                  ? firstVideoView(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      renderer: _localRenderer)
                  : secondVideoView(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      renderer: _remoteRenderer),
              Positioned(
                top: 40,
                left: 40,
                child: Stack(
                  children: [
                    ClipRRect(
                        borderRadius: BorderRadius.circular(16.0),
                        child: !swapped
                            ? firstVideoView(
                                height:
                                    MediaQuery.of(context).size.height * 0.3,
                                width: MediaQuery.of(context).size.height * 0.3,
                                renderer: _localRenderer)
                            : secondVideoView(
                                height: MediaQuery.of(context).size.height*0.3,
                                width: MediaQuery.of(context).size.height*0.3,
                                renderer: _remoteRenderer)),
                    InkResponse(
                        onTap: (){
                          setState(() {
                            swapped = !swapped;
                          });
                        },
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(16.0),
                            child: Container(
                              height: MediaQuery.of(context).size.height * 0.3,
                              width: MediaQuery.of(context).size.height * 0.3,
                            )))
                  ],
                ),
              ),
              Positioned(
                top: 40,
                right: 40,
                child: AnimatedContainer(
                  height: timer?.tick.isEven ?? false ? 90 : 80,
                  width: timer?.tick.isEven ?? false ? 90 : 80,
                  duration: Duration(seconds: 1),
                  child: Stack(
                    children: [
                      Image.asset('assets/stopwatch.png',
                          height: 100, width: 100),
                      Positioned(
                          bottom: 10,
                          right: 10,
                          left: 10,
                          child: Center(
                              child: AnimatedContainer(
                                  duration: Duration(seconds: 1),
                                  child: CircularProgressIndicator(
                                      strokeWidth: 4,
                                      value: controller!.value,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white)),
                                  height: timer?.tick.isEven ?? false ? 61 : 52,
                                  width:
                                      timer?.tick.isEven ?? false ? 61 : 52)))
                    ],
                  ),
                ),
              ),
            ]),
          );
        }));
  }

  Widget firstVideoView(
      {double? height, double? width, RTCVideoRenderer? renderer}) {
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
}