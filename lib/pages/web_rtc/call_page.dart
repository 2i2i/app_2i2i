
import 'dart:async';
import 'dart:math';

import 'package:app_2i2i/common/utils.dart';
import 'package:app_2i2i/models/meeting.dart';
import 'package:app_2i2i/models/user.dart';
import 'package:app_2i2i/pages/web_rtc/signaling.dart';
import 'package:app_2i2i/services/logging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class CallPage extends StatefulWidget {
  CallPage({Key? key, required this.meeting, required this.user})
      : super(key: key);

  final Meeting meeting;
  final UserModel user;

  @override
  _CallPageState createState() => _CallPageState(meeting: meeting, user: user);
}

class _CallPageState extends State<CallPage> {
  _CallPageState({required this.meeting, required this.user});
  final Meeting meeting;
  final UserModel user;

  late Signaling signaling;
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  String? roomId;
  TextEditingController textEditingController = TextEditingController(text: '');

  late Timer budgetTimer;
  void _initBudgetTimer() {

    // no timer for free call
    if (meeting.speed.num == 0) return;

    final maxDuration = (meeting.budget / meeting.speed.num).floor();
    log('_CallPageState - _initTimer - meeting.id=${meeting.id} - maxDuration=$maxDuration');
    int duration = maxDuration;
    final activeTime = meeting.activeTime();
    if (activeTime != null) {
      final maxEndTime = activeTime + maxDuration;
      log('_CallPageState - _initTimer - meeting.id=${meeting.id} - maxEndTime=$maxEndTime');
      duration = max(maxEndTime - epochSecsNow(), 0);
    }
    log('_CallPageState - _initTimer - meeting.id=${meeting.id} - duration=$duration');
    budgetTimer = Timer(Duration(seconds: duration),
            () => signaling.hangUp(_localRenderer, reason: 'BUDGET'));
  }

  bool swapped = false;

  bool amA() {
    return meeting.A == user.id;
  }

  @override
  void initState() {
    log('_CallPageState - initState');
    _initBudgetTimer();

    _localRenderer.initialize();
    _remoteRenderer.initialize();

    log('_CallPageState - initState - renderers initialized - amA()=${amA()}');
    signaling = Signaling(
        meeting: meeting,
        amA: amA(),
        localVideo: _localRenderer,
        remoteVideo: _remoteRenderer);
    log('_CallPageState - initState - signaling constructed');
    // signaling.openUserMedia(_localRenderer, _remoteRenderer);
    signaling.onAddRemoteStream = ((stream) {
      _remoteRenderer.srcObject = stream;
      setState(() {});
    });
    log('_CallPageState - initState - signaling onAddRemoteStream');

    super.initState();
  }

  @override
  void dispose() {
    log('_CallPageState - dispose');
    _localRenderer.dispose();
    log('_CallPageState - dispose - _localRenderer.dispose');
    _remoteRenderer.dispose();
    log('_CallPageState - dispose - _remoteRenderer.dispose');
    budgetTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    log('_CallPageState - build');

    return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          onPressed: () => signaling.hangUp(_localRenderer),
          tooltip: 'Hangup',
          child: Icon(Icons.call_end,color: Colors.white,),
          backgroundColor: Colors.pink,
        ),
        body: OrientationBuilder(builder: (context, orientation) {
          return Container(
            child: Stack(children: <Widget>[
              swapped
                  ? firstVideoView(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  renderer: _localRenderer,
                  orientation: orientation)
                  : secondVideoView(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  renderer: _remoteRenderer,
                  orientation: orientation),
              Positioned(
                top: 40,
                left: 40,
                child: InkResponse(
                    onTap: () {
                      setState(() {
                        swapped = !swapped;
                      });
                    },
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(16.0),
                        child: !swapped
                            ? firstVideoView(
                            height: 220,
                            width: 220,
                            orientation: orientation,
                            renderer: _localRenderer)
                            : secondVideoView(
                            height: 220,
                            width: 220,
                            orientation: orientation,
                            renderer: _remoteRenderer))),
              ),
              ElevatedButton(onPressed: (){setState(() {
                swapped = !swapped;
              });}, child: Text('Swap'))
            ]),
          );
        }));
  }

  Widget firstVideoView(
      {double? height,
        double? width,
        RTCVideoRenderer? renderer,
        Orientation? orientation}) {
    return Container(
      margin: EdgeInsets.fromLTRB(6.0, 6.0, 6.0, 6.0),
      width: width,
      height: height,
      child: RTCVideoView(renderer!,objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,),
      decoration: BoxDecoration(color: Colors.black54),
    );
  }

  Widget secondVideoView(
      {double? height,
        double? width,
        RTCVideoRenderer? renderer,
        Orientation? orientation}) {
    return Container(
      width: width,
      margin: EdgeInsets.fromLTRB(6.0, 6.0, 6.0, 6.0),
      height: height,
      child: RTCVideoView(renderer!, mirror: true,objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover),
      decoration: BoxDecoration(color: Colors.black54),
    );
  }
}