import 'dart:async';
import 'dart:math';

import 'package:app_2i2i/common/utils.dart';
import 'package:app_2i2i/models/meeting.dart';
import 'package:app_2i2i/models/user.dart';
import 'package:app_2i2i/pages/web_rtc/signaling.dart';
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

  void _initBudgetTimer() {

    // no timer for free call
    if (widget.meeting.speed.num == 0) return;

    var maxDuration = ((widget.meeting.budget) / (widget.meeting.speed.num)).floor();
    int duration = maxDuration;
    final activeTime = widget.meeting.activeTime();
    if (activeTime != null) {
      final maxEndTime = activeTime + maxDuration;
      duration = max(maxEndTime - epochSecsNow(), 0);
    }
    budgetTimer = Timer(Duration(seconds: duration), () {
      progressTimer!.cancel();
      signaling!.hangUp(_localRenderer, reason: 'BUDGET');
    });
    progressTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      double percentage = (timer.tick * 100) / maxDuration;
      progress.value = 100 - percentage;
      if (timer.tick >= maxDuration) timer.cancel();
    });
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
    budgetTimer!.cancel();
    progressTimer!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                alignment: Alignment.bottomCenter,
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  margin: EdgeInsets.symmetric(horizontal: 100,vertical: 10),
                  color: Colors.black38,
                  child: Container(
                    height: 100,
                    alignment: Alignment.center,
                    child: Stack(
                      alignment: Alignment.center,
                      // mainAxisAlignment: MainAxisAlignment.center,
                      // crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        FloatingActionButton(
                          onPressed: () {
                          try {
                            if (budgetTimer?.isActive ?? false) {
                              budgetTimer?.cancel();
                            }
                            signaling?.hangUp(_localRenderer);
                          } catch (e) {
                            print(e);
                          }
                        },
                          child: Icon(
                            Icons.call_end,
                            color: Colors.white,
                          ),
                          backgroundColor: Color.fromARGB(255, 239, 102, 84),
                        ),
                        RotatedBox(
                          quarterTurns: 90,
                          child: Padding(
                            padding: EdgeInsets.only(left: MediaQuery.of(context).size.width/1.5),
                            child: ValueListenableBuilder(
                              valueListenable: progress,
                              builder: (BuildContext context, double value, Widget? child) {
                                var percentage = value.toDouble();
                                if(value > 1){
                                  percentage = (value/100);
                                }
                                bool isAnimate = value <= 20 && (budgetTimer?.tick.isEven ?? false);
                                print('==== $value $isAnimate ${budgetTimer?.tick}');
                                return SizedBox(
                                  width: MediaQuery.of(context).size.width/8,
                                  child: LinearProgressIndicator(
                                    value: value,
                                    minHeight: 4,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      isAnimate?Colors.red:Colors.white,
                                    ),
                                  ),
                                );
                              },

                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // painter: CurvePainter(),
              ),
            ),
            /*Positioned(
                bottom: 5,
                right: 450,
                left: 0,
                child: ValueListenableBuilder(
                  valueListenable: progress,
                  builder: (BuildContext context, double value, Widget? child) {
                    var percentage = value.toDouble();
                    if(value > 1){
                      percentage = (value/100);
                    }
                    bool isAnimate = value <= 20 && (budgetTimer?.tick.isEven ?? false);
                    print('==== $value $isAnimate ${budgetTimer?.tick}');
                    return AnimatedContainer(
                      height: isAnimate ? 90 : 80,
                      width: isAnimate ? 90 : 80,
                      duration: Duration(seconds: 1),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset('assets/stopwatch.png', height: 100, width: 100),
                          Positioned(
                            bottom: 10,
                            right: 10,
                            left: 10,
                            child: Center(
                              child: AnimatedContainer(
                                duration: Duration(seconds: 1),
                                child: CircularProgressIndicator(
                                  strokeWidth: 4,
                                  value: percentage,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    isAnimate?Colors.red:Colors.white,
                                  ),
                                ),
                                height: isAnimate ? 61 : 52,
                                width: isAnimate ? 61 : 52,
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),*/
          ]),
        );
      }),
    );
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
