// https://github.com/fireship-io/webrtc-firebase-demo

import 'dart:async';
import 'dart:math';

import 'package:app_2i2i/models/meeting.dart';
import 'package:app_2i2i/models/user.dart';
import 'package:app_2i2i/pages/web_rtc/signaling.dart';
import 'package:app_2i2i/services/logging.dart';
import 'package:app_2i2i/common/utils.dart';
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
    final maxDuration = (meeting.budget / meeting.speed.num).floor();
    log(F +
        '_CallPageState - _initTimer - meeting.id=${meeting.id} - maxDuration=$maxDuration');
    int duration = maxDuration;
    final activeTime = meeting.activeTime();
    if (activeTime != null) {
      final maxEndTime = activeTime + maxDuration;
      log(F +
          '_CallPageState - _initTimer - meeting.id=${meeting.id} - maxEndTime=$maxEndTime');
      duration = max(maxEndTime - epochSecsNow(), 0);
    }
    log(F +
        '_CallPageState - _initTimer - meeting.id=${meeting.id} - duration=$duration');
    budgetTimer = Timer(Duration(seconds: duration),
        () => signaling.hangUp(_localRenderer, reason: 'BUDGET'));
  }

  bool amA() {
    return meeting.A == user.id;
  }

  @override
  void initState() {
    log(F + '_CallPageState - initState');
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
    log(F + '_CallPageState - dispose');
    _localRenderer.dispose();
    log('_CallPageState - dispose - _localRenderer.dispose');
    _remoteRenderer.dispose();
    log('_CallPageState - dispose - _remoteRenderer.dispose');
    budgetTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    log(F + '_CallPageState - build');

    return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          onPressed: () => signaling.hangUp(_localRenderer),
          tooltip: 'Hangup',
          child: Icon(Icons.call_end),
          backgroundColor: Colors.pink,
        ),
        // floatingActionButton: SizedBox(
        //     width: 200.0,
        //     child: Row(
        //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //         children: <Widget>[
        //           // FloatingActionButton(
        //           //   child: const Icon(Icons.switch_camera),
        //           //   onPressed: _switchCamera,
        //           // ),
        //           // FloatingActionButton(
        //           //   onPressed: () => signaling.openUserMedia(_localRenderer, _remoteRenderer),
        //           //   tooltip: 'openUserMedia',
        //           //   child: Icon(Icons.call_end),
        //           //   backgroundColor: Colors.pink,
        //           // ),
        //           // FloatingActionButton(
        //           //   onPressed: () => signaling.createRoom(),
        //           //   tooltip: 'createRoom',
        //           //   child: Icon(Icons.call_end),
        //           //   backgroundColor: Colors.pink,
        //           // ),
        //           // FloatingActionButton(
        //           //   onPressed: () => signaling.joinRoom(),
        //           //   tooltip: 'joinRoom',
        //           //   child: Icon(Icons.call_end),
        //           //   backgroundColor: Colors.pink,
        //           // ),
        //           FloatingActionButton(
        //             onPressed: () => signaling.hangUp(_localRenderer),
        //             tooltip: 'Hangup',
        //             child: Icon(Icons.call_end),
        //             backgroundColor: Colors.pink,
        //           ),
        //           // FloatingActionButton(
        //           //   child: const Icon(Icons.mic_off),
        //           //   onPressed: _muteMic,
        //           // )
        //         ])),
        body: OrientationBuilder(builder: (context, orientation) {
          return Container(
            child: Stack(children: <Widget>[
              Positioned(
                  left: 0.0,
                  right: 0.0,
                  top: 0.0,
                  bottom: 0.0,
                  child: Container(
                    margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: RTCVideoView(_remoteRenderer),
                    decoration: BoxDecoration(color: Colors.black54),
                  )),
              Positioned(
                left: 20.0,
                top: 20.0,
                child: Container(
                  width: orientation == Orientation.portrait ? 90.0 : 120.0,
                  height: orientation == Orientation.portrait ? 120.0 : 90.0,
                  child: RTCVideoView(_localRenderer, mirror: true),
                  decoration: BoxDecoration(color: Colors.black54),
                ),
              ),
            ]),
          );
        })

        // Column(
        //   children: [
        //     SizedBox(height: 8),
        //     Row(
        //       mainAxisAlignment: MainAxisAlignment.center,
        //       children: [
        //         ElevatedButton(
        //           onPressed: () {
        //             signaling.openUserMedia(_localRenderer, _remoteRenderer);
        //           },
        //           child: Text("Open camera & microphone"),
        //         ),
        //         SizedBox(
        //           width: 8,
        //         ),
        //         ElevatedButton(
        //           onPressed: () async {
        //             roomId = await signaling.createRoom(_remoteRenderer);
        //             textEditingController.text = roomId!;
        //             setState(() {});
        //           },
        //           child: Text("Create room"),
        //         ),
        //         SizedBox(
        //           width: 8,
        //         ),
        //         ElevatedButton(
        //           onPressed: () {
        //             // Add roomId
        //             signaling.joinRoom(
        //               textEditingController.text,
        //               _remoteRenderer,
        //             );
        //           },
        //           child: Text("Join room"),
        //         ),
        //         SizedBox(
        //           width: 8,
        //         ),
        //         ElevatedButton(
        //           onPressed: () {
        //             signaling.hangUp(_localRenderer);
        //           },
        //           child: Text("Hangup"),
        //         )
        //       ],
        //     ),
        //     SizedBox(height: 8),
        //     Expanded(
        //       child: Padding(
        //         padding: const EdgeInsets.all(8.0),
        //         child: Row(
        //           mainAxisAlignment: MainAxisAlignment.center,
        //           children: [
        //             Expanded(child: RTCVideoView(_localRenderer, mirror: true)),
        //             Expanded(child: RTCVideoView(_remoteRenderer)),
        //           ],
        //         ),
        //       ),
        //     ),
        //     Padding(
        //       padding: const EdgeInsets.all(8.0),
        //       child: Row(
        //         mainAxisAlignment: MainAxisAlignment.center,
        //         children: [
        //           Text("Join the following Room: "),
        //           Flexible(
        //             child: TextFormField(
        //               controller: textEditingController,
        //             ),
        //           )
        //         ],
        //       ),
        //     ),
        //     SizedBox(height: 8)
        //   ],
        // ),
        );
  }
}
