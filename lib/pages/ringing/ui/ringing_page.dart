import 'dart:async';

import 'package:app_2i2i/models/meeting.dart';
import 'package:app_2i2i/pages/home/wait_page.dart';
import 'package:app_2i2i/pages/ringing/ui/ripples_animation.dart';
import 'package:app_2i2i/services/all_providers.dart';
import 'package:app_2i2i/services/logging.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animator/widgets/attention_seekers/bounce.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class RingingPage extends ConsumerStatefulWidget {
  const RingingPage({Key? key, required this.meeting}) : super(key: key);
  final Meeting meeting;

  @override
  RingingPageState createState() => RingingPageState(meeting: meeting);
}

class RingingPageState extends ConsumerState<RingingPage> {
  bool isClicked = false;

  RingingPageState({Key? key, required this.meeting});

  final Meeting meeting;
  Timer? timer;
  final player = AudioPlayer();

  @override
  void initState() {
    start();
    super.initState();
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    finish();
  }

  Future<void> start() async {
    timer =
        Timer(Duration(seconds: 30), () => cancelMeeting(reason: 'NO_PICKUP'));
    await player.setAsset('assets/video_call.mp3');
    await player.setLoopMode(LoopMode.one);
    if (!player.playing) {
      await player.play();
    }
  }

  Future<void> finish() async {
    if (timer?.isActive ?? false) {
      timer!.cancel();
    }
    if (player.playing) {
      await player.stop();
    }
    await player.dispose();
    timer = null;
  }

  final FirebaseFunctions functions = FirebaseFunctions.instance;

  Future cancelMeeting({String? reason}) async {
    final finishFuture = finish();
    final HttpsCallable endMeeting = functions.httpsCallable('endMeeting');
    final args = {'meetingId': meeting.id};
    if (reason != null) args['reason'] = reason;
    final endMeetingFuture = endMeeting(args);
    await Future.wait([finishFuture, endMeetingFuture]);
  }

  @override
  Widget build(BuildContext context) {
    log(F + 'RingingPage - build');
    final ringingPageViewModel = ref.watch(ringingPageViewModelProvider);
    if (ringingPageViewModel == null) return WaitPage();
    log(F + 'RingingPage - scaffold');
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SizedBox(
        width: double.infinity,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 2,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Ripples(
                      size: MediaQuery.of(context).size.height * 0.17,
                      color: Colors.green,
                      child: CircleAvatar(
                          radius: MediaQuery.of(context).size.height * 0.11,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset(
                              'assets/logo.png',
                              height: MediaQuery.of(context).size.height * 0.11,
                              width: MediaQuery.of(context).size.height * 0.11,
                            ),
                          )),
                    ),
                    CircularPercentIndicator(
                      radius: MediaQuery.of(context).size.height * 0.22,
                      lineWidth: 4.0,
                      animation: true,
                      animationDuration: 30000,
                      circularStrokeCap: CircularStrokeCap.round,
                      percent: 1,
                      progressColor: Colors.white,
                      backgroundColor: Colors.blueAccent,
                      animateFromLastPercent: true,
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Connecting with',
                      style: Theme.of(context).textTheme.caption,
                    ),
                    SizedBox(height: 10),
                    Text(
                       ringingPageViewModel.otherUser.name,
                      style: Theme.of(context)
                          .textTheme
                          .headline6!
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  width: MediaQuery.of(context).size.height * 0.6,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: FloatingActionButton(
                          child: Icon(Icons.call_end, color: Colors.white),
                          backgroundColor: Color.fromARGB(255, 239, 102, 84),
                          onPressed: () async {
                            final finishFuture = finish();
                            final cancelMeetingFuture = ringingPageViewModel.cancelMeeting();
                            await Future.wait([finishFuture, cancelMeetingFuture]);
                          },
                        ),
                      ),
                      Visibility(
                        visible: !isClicked &&
                            ringingPageViewModel.amA() &&
                            ringingPageViewModel.meeting.isInit(),
                        child: Expanded(
                          child: Bounce(
                            child: FloatingActionButton(
                              child: Icon(Icons.call, color: Colors.white),
                              backgroundColor: Colors.green,
                              onPressed: () async {
                                isClicked = true;
                                if (mounted) {
                                  setState(() {});
                                }
                                final finishFuture = finish();
                                final acceptMeetingFuture = ringingPageViewModel.acceptMeeting();
                                await Future.wait([finishFuture, acceptMeetingFuture]);
                              },
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
