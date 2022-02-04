import 'dart:async';

import 'package:animate_countdown_text/animate_countdown_text.dart';
import 'package:app_2i2i/infrastructure/commons/theme.dart';
import 'package:app_2i2i/infrastructure/commons/utils.dart';
import 'package:app_2i2i/infrastructure/data_access_layer/services/logging.dart';
import 'package:app_2i2i/infrastructure/models/hangout_model.dart';
import 'package:app_2i2i/infrastructure/models/meeting_model.dart';
import 'package:app_2i2i/infrastructure/providers/all_providers.dart';
import 'package:app_2i2i/infrastructure/providers/web_rtc_provider/call_screen_provider.dart';
import 'package:app_2i2i/ui/commons/custom_animated_progress_bar.dart';
import 'package:app_2i2i/ui/screens/web_rtc/signaling_websockets.dart';
import 'package:app_2i2i/ui/screens/web_rtc/widgets/circle_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:core';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class CallPageWebsockets extends ConsumerStatefulWidget {
  final Meeting meeting;
  final Hangout hangout;
  final Function onHangPhone;
  final MeetingChanger meetingChanger;
  final HangoutChanger hangoutChanger;

  static String tag = 'call_sample';
  final String host = 'demo.cloudwebrtc.com';
  CallPageWebsockets({
    // required this.host,
    required this.meeting,
    required this.meetingChanger,
    required this.hangoutChanger,
    required this.onHangPhone,
    required this.hangout,
  });

  @override
  _CallPageWebsocketsState createState() => _CallPageWebsocketsState();
}

class _CallPageWebsocketsState extends ConsumerState<CallPageWebsockets> {
  SignalingWebSockets? _signaling;
  List<dynamic> _peers = [];
  String? _selfId;
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  bool _inCalling = false;
  Session? _session;

  // ignore: unused_element
  _CallPageWebsocketsState();

  @override
  initState() {
    super.initState();
    initRenderers();

    amA = widget.meeting.A == widget.hangout.id;
    localId = amA ? widget.meeting.A : widget.meeting.B;
    remoteId = amA ? widget.meeting.B : widget.meeting.A;

    _connect();
  }

  initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  @override
  deactivate() {
    super.deactivate();
    _signaling?.close();
    _localRenderer.dispose();
    _remoteRenderer.dispose();

    budgetTimer?.cancel();
    progressTimer?.cancel();
    widget.onHangPhone(remoteId, widget.meeting.id);
  }

  void _connect() {
    _signaling ??= SignalingWebSockets(widget.host, localId)..connect();
    _signaling?.onSignalingStateChange = (SignalingState state) {
      log(K + '_signaling?.onSignalingStateChange - state=$state');
      switch (state) {
        case SignalingState.ConnectionClosed:
        case SignalingState.ConnectionError:
        case SignalingState.ConnectionOpen:
          break;
      }
    };

    _signaling?.onCallStateChange = (Session session, CallState state) {
      log(K + '_signaling?.onCallStateChange - state=$state');
      switch (state) {
        case CallState.CallStateNew:
          setState(() {
            _session = session;
            _inCalling = true;
          });

          log(K +
              '_signaling?.onCallStateChange - widget.meeting.status=${widget.meeting.status}');
          if (amA && widget.meeting.status == MeetingStatus.ACCEPTED_A)
            return widget.meetingChanger.roomCreatedMeeting(
                widget.meeting.id, _session!.sid + '-' + _session!.pid);

          break;
        case CallState.CallStateBye:
          setState(() {
            _localRenderer.srcObject = null;
            _remoteRenderer.srcObject = null;
            _inCalling = false;
            _session = null;
          });
          break;
        case CallState.CallStateInvite:
        case CallState.CallStateConnected:
        case CallState.CallStateRinging:
      }
    };

    _signaling?.onPeersUpdate = ((event) {
      log(K + '_signaling?.onPeersUpdate - event[self]=${event['self']}');
      log(K + '_signaling?.onPeersUpdate - event[peers]=${event['peers']}');
      setState(() {
        _selfId = event['self'];
        _peers = event['peers'];
      });

      if (amA) _invitePeer(remoteId, false);
    });

    _signaling?.onLocalStream = ((stream) {
      log(K + '_signaling?.onLocalStream - stream=$stream');
      _localRenderer.srcObject = stream;
    });

    _signaling?.onAddRemoteStream = ((_, stream) {
      log(K +
          '_signaling?.onAddRemoteStream - stream=$stream - amA=$amA - widget.meeting.status=${widget.meeting.status}');
      _remoteRenderer.srcObject = stream;

      if (amA && widget.meeting.status != MeetingStatus.RECEIVED_REMOTE_A)
        return widget.meetingChanger
            .remoteReceivedByAMeeting(widget.meeting.id);
      else if (!amA && widget.meeting.status != MeetingStatus.RECEIVED_REMOTE_B)
        return widget.meetingChanger
            .remoteReceivedByBMeeting(widget.meeting.id);
    });

    _signaling?.onRemoveRemoteStream = ((_, stream) {
      log(K + '_signaling?.onRemoveRemoteStream - stream=$stream');
      _remoteRenderer.srcObject = null;
    });
  }

  // _invitePeer(BuildContext context, String peerId, bool useScreen) async {
  _invitePeer(String peerId, bool useScreen) {
    if (_signaling != null && peerId != _selfId) {
      _signaling?.invite(peerId, 'video', useScreen);
    }
  }

  _hangUp(MeetingStatus reason) {
    if (_session != null) {
      _signaling?.bye(_session!.sid);
      return widget.meetingChanger.endMeeting(widget.meeting, reason);
    }
  }

  _switchCamera() {
    _signaling?.switchCamera();
  }

  _muteAudio() {
    _signaling?.muteAudio();
  }

  _muteVideo() {
    _signaling?.muteVideo();
  }

  // _buildRow(context, peer) {
  //   var self = (peer['id'] == _selfId);
  //   return ListBody(children: <Widget>[
  //     ListTile(
  //       title: Text(self
  //           ? peer['name'] + ', ID: ${peer['id']} ' + ' [Your self]'
  //           : peer['name'] + ', ID: ${peer['id']} '),
  //       onTap: null,
  //       trailing: SizedBox(
  //           width: 100.0,
  //           child: Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: <Widget>[
  //                 IconButton(
  //                   icon: Icon(self ? Icons.close : Icons.videocam,
  //                       color: self ? Colors.grey : Colors.black),
  //                   onPressed: () => _invitePeer(context, peer['id'], false),
  //                   tooltip: 'Video calling',
  //                 ),
  //                 IconButton(
  //                   icon: Icon(self ? Icons.close : Icons.screen_share,
  //                       color: self ? Colors.grey : Colors.black),
  //                   onPressed: () => _invitePeer(context, peer['id'], true),
  //                   tooltip: 'Screen sharing',
  //                 )
  //               ])),
  //       subtitle: Text('[' + peer['user_agent'] + ']'),
  //     ),
  //     Divider()
  //   ]);
  // }

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
      _hangUp(MeetingStatus.END_TIMER);
      // signaling?.hangUp(reason: MeetingStatus.END_TIMER);
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
    if (duration <= 100) {
      countDownTimerDate =
          DateTime.now().toUtc().add(Duration(seconds: duration));
      if (mounted) {
        setState(() {});
      }
    }
  }

  late bool amA;
  late String localId;
  late String remoteId;

  Timer? budgetTimer;
  Timer? progressTimer;
  CallScreenModel? callScreenModel;

  ValueNotifier<double> progress = ValueNotifier(100);
  DateTime? countDownTimerDate;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    _initTimers();

    callScreenModel = ref.watch(callScreenProvider);
    final hangout = ref.watch(hangoutProvider(localId));
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
                  ? videoView(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      renderer: _localRenderer,
                    )
                  : videoView(
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
                          ? videoView(
                              height: MediaQuery.of(context).size.height * 0.3,
                              width: MediaQuery.of(context).size.height * 0.3,
                              renderer: _localRenderer,
                            )
                          : videoView(
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
                          onTap: () {
                            if (budgetTimer?.isActive ?? false) {
                              budgetTimer?.cancel();
                            }
                            final reason =
                                amA ? MeetingStatus.END_A : MeetingStatus.END_B;
                            // await signaling?.hangUp(reason: reason);

                            // await disposeInit();

                            _hangUp(reason);
                          }),
                      CircleButton(
                        icon: callScreenModel?.isAudioEnabled ?? false
                            ? Icons.mic_rounded
                            : Icons.mic_off_rounded,
                        onTap: _muteAudio,
                      // () => callScreenModel!.muteAudio(
                      //     signaling: signaling!,
                      //     localRenderer: _localRenderer)),
                      ),
                      CircleButton(
                          icon: callScreenModel?.isVideoEnabled ?? false
                              ? Icons.videocam_rounded
                              : Icons.videocam_off_rounded,
                          onTap: _muteVideo,
                      // () => callScreenModel!
                      //     .muteVideo(signaling: signaling!)),
                      ),
                      CircleButton(
                          icon: Icons.cameraswitch_rounded,
                          onTap: _switchCamera,
                          // () => callScreenModel!.cameraSwitch(
                          //     context: context, signaling: signaling!)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );

    // return Scaffold(
    //   appBar: AppBar(
    //     title: Text('P2P Call Sample' +
    //         (_selfId != null ? ' [Your ID ($_selfId)] ' : '')),
    //     actions: <Widget>[
    //       IconButton(
    //         icon: const Icon(Icons.settings),
    //         onPressed: null,
    //         tooltip: 'setup',
    //       ),
    //     ],
    //   ),
    //   floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    //   floatingActionButton: _inCalling
    //       ? SizedBox(
    //           width: 200.0,
    //           child: Row(
    //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //               children: <Widget>[
    //                 FloatingActionButton(
    //                   child: const Icon(Icons.switch_camera),
    //                   onPressed: _switchCamera,
    //                 ),
    //                 FloatingActionButton(
    //                   onPressed: _hangUp,
    //                   tooltip: 'Hangup',
    //                   child: Icon(Icons.call_end),
    //                   backgroundColor: Colors.pink,
    //                 ),
    //                 FloatingActionButton(
    //                   child: const Icon(Icons.mic_off),
    //                   onPressed: _muteMic,
    //                 )
    //               ]))
    //       : null,
    //   body: _inCalling
    //       ? OrientationBuilder(builder: (context, orientation) {
    //           return Container(
    //             child: Stack(children: <Widget>[
    //               Positioned(
    //                   left: 0.0,
    //                   right: 0.0,
    //                   top: 0.0,
    //                   bottom: 0.0,
    //                   child: Container(
    //                     margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
    //                     width: MediaQuery.of(context).size.width,
    //                     height: MediaQuery.of(context).size.height,
    //                     child: RTCVideoView(_remoteRenderer),
    //                     decoration: BoxDecoration(color: Colors.black54),
    //                   )),
    //               Positioned(
    //                 left: 20.0,
    //                 top: 20.0,
    //                 child: Container(
    //                   width: orientation == Orientation.portrait ? 90.0 : 120.0,
    //                   height:
    //                       orientation == Orientation.portrait ? 120.0 : 90.0,
    //                   child: RTCVideoView(_localRenderer, mirror: true),
    //                   decoration: BoxDecoration(color: Colors.black54),
    //                 ),
    //               ),
    //             ]),
    //           );
    //         })
    //       : ListView.builder(
    //           shrinkWrap: true,
    //           padding: const EdgeInsets.all(0.0),
    //           itemCount: (_peers != null ? _peers.length : 0),
    //           itemBuilder: (context, i) {
    //             return _buildRow(context, _peers[i]);
    //           }),
    // );
  }

  Widget videoView(
      {required double height,
      required double width,
      required RTCVideoRenderer renderer,
      bool mirror = false}) {
    return Container(
      width: width,
      height: height,
      child: RTCVideoView(renderer,
          mirror: mirror,
          objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover),
      decoration: BoxDecoration(color: Colors.black54),
    );
  }

  DurationFormat _formatHMS(Duration duration) => DurationFormat(
        second: "${duration.inSeconds}",
      );
}
