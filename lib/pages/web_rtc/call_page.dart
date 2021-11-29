
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

  Timer? timer;
  bool swapped = false;
  Signaling? signaling;
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  String? roomId;
  TextEditingController textEditingController = TextEditingController(text: '');

  Timer? budgetTimer;
  ValueNotifier<double> progress = ValueNotifier(100);
  ValueNotifier<String> time = ValueNotifier('');

  void _initBudgetTimer() {
    // no timer for free call
    // if (meeting!.speed.num == 0) return;

    var maxDuration = 1500;//(meeting!.budget / meeting!.speed.num).floor();
    int duration = maxDuration;
    final activeTime = meeting!.activeTime();
    if (activeTime != null) {
      final maxEndTime = activeTime + maxDuration;
      duration = max(maxEndTime - epochSecsNow(), 0);
    }
    budgetTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      maxDuration = 120;
      double percentage = (timer.tick * 100)/maxDuration;
      progress.value = 100 - percentage;
      if(timer.tick >= maxDuration){
        timer.cancel();
        signaling!.hangUp(_localRenderer, reason: 'BUDGET');
      }

      int minutes = (timer.tick / 60).truncate();
      time.value =formatedTime(timer.tick);

    });
    // budgetTimer = Timer(Duration(seconds: duration), () => signaling!.hangUp(_localRenderer, reason: 'BUDGET'));
  }
  String formatedTime(int secTime) {
    String getParsedTime(String time) {
      if (time.length <= 1) return "0$time";
      return time;
    }

    int min = secTime ~/ 60;
    int sec = secTime % 60;

    String parsedTime = getParsedTime(min.toString()) + " : " + getParsedTime(sec.toString());
    return parsedTime;
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


              Align(
                alignment: Alignment.bottomCenter,
                child: RotatedBox(
                  quarterTurns: 90,
                  child: CustomPaint(
                    isComplex: false,
                    willChange: false,
                    foregroundPainter: CurvePainter(),
                    child: Container(
                      height: 150,
                      width: MediaQuery.of(context).size.width,
                      alignment: Alignment.bottomCenter,
                    ),
                    // painter: CurvePainter(),
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                right: 0,
                left: 0,
                child: FloatingActionButton(
                  onPressed: () {
                    if(budgetTimer?.isActive??false) {
                      budgetTimer?.cancel();
                    }
                    signaling!.hangUp(_localRenderer);
                  },
                  child: Icon(
                    Icons.call_end,
                    color: Colors.white,
                  ),
                  backgroundColor: Colors.pink,
                ),
              ),
              Positioned(
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
              ),
              Positioned(
                bottom: 30,
                right: 0,
                left: 450,
                child: ValueListenableBuilder(
                  valueListenable: time,
                  builder: (BuildContext context, String value, Widget? child) {
                    return Text(
                      value,
                      style: TextStyle(
                          color: Colors.white
                      )
                      ,textAlign: TextAlign.center,
                    );
                  },
                ),
              ),
            ]),
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
}

class CurvePainter extends CustomPainter {
  Color colorOne = Colors.blueAccent.shade200;
  Color colorTwo = Colors.blueAccent.shade100;
  Color colorThree = Colors.blueAccent.withAlpha(50);

  @override
  void paint(Canvas canvas, Size size) {

    Path path = Path();
    Paint paint = Paint();

    path.lineTo(0, size.height * 0.75);
    path.quadraticBezierTo(size.width * 0.10, size.height * 0.70, size.width * 0.17, size.height * 0.90);
    path.quadraticBezierTo(size.width * 0.20, size.height, size.width * 0.25, size.height * 0.90);
    path.quadraticBezierTo(size.width * 0.40, size.height * 0.40, size.width * 0.50, size.height * 0.70);
    path.quadraticBezierTo(size.width * 0.60, size.height * 0.85, size.width * 0.65, size.height * 0.65);
    path.quadraticBezierTo(size.width * 0.70, size.height * 0.90, size.width, 0);
    path.close();

    paint.color = colorThree.withOpacity(0.5);
    canvas.drawPath(path, paint);

    path = Path();
    path.lineTo(0, size.height * 0.50);
    path.quadraticBezierTo(size.width * 0.10, size.height * 0.80, size.width * 0.15, size.height * 0.60);
    path.quadraticBezierTo(size.width * 0.20, size.height * 0.45, size.width * 0.27, size.height * 0.60);
    path.quadraticBezierTo(size.width * 0.20, size.height * 0.45, size.width * 0.27, size.height * 0.60);
    path.quadraticBezierTo(size.width * 0.45, size.height, size.width * 0.50, size.height * 0.80);
    path.quadraticBezierTo(size.width * 0.55, size.height * 0.45, size.width * 0.75, size.height * 0.75);
    path.quadraticBezierTo(size.width * 0.85, size.height * 0.93, size.width, size.height * 0.60);
    path.lineTo(size.width, 0);
    path.close();

    paint.color = colorTwo.withOpacity(0.5);
    canvas.drawPath(path, paint);

    path = Path();
    path.lineTo(0, size.height * 0.75);
    path.quadraticBezierTo(size.width * 0.10, size.height * 0.55, size.width * 0.22, size.height * 0.70);
    path.quadraticBezierTo(size.width * 0.30, size.height * 0.90, size.width * 0.40, size.height * 0.75);
    path.quadraticBezierTo(size.width * 0.52, size.height * 0.50, size.width * 0.65, size.height * 0.70);
    path.quadraticBezierTo(size.width * 0.75, size.height * 0.85, size.width, size.height * 0.60);
    path.lineTo(size.width, 0);
    path.close();

    paint.color = colorOne.withOpacity(0.5);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}