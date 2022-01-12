import 'dart:async';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animator/widgets/attention_seekers/bounce.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../../infrastructure/commons/utils.dart';
import '../../../infrastructure/data_access_layer/services/logging.dart';
import '../../../infrastructure/models/meeting_model.dart';
import '../../../infrastructure/providers/all_providers.dart';
import '../../../infrastructure/providers/ringing_provider/ringing_page_view_model.dart';
import '../home/wait_page.dart';
import 'ripples_animation.dart';

class RingingPage extends ConsumerStatefulWidget {
  const RingingPage({Key? key, required this.meeting}) : super(key: key);
  final Meeting meeting;

  @override
  RingingPageState createState() => RingingPageState();
}

class RingingPageState extends ConsumerState<RingingPage> {
  bool isClicked = false;

  RingingPageState({Key? key});

  RingingPageViewModel? ringingPageViewModel;

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

  // TODO does this work? does the timer stay when changing to MeetingStatus.TXN_SENT? that would be wrong
  void setTimer() {
    log('setTimer - widget.meeting.status=${widget.meeting.status}');

    int? duration;
    if (widget.meeting.status == MeetingStatus.INIT)
      duration = 30;
    else if (widget.meeting.status == MeetingStatus.ACCEPTED) duration = 60;
    if (duration == null) return;

    timer = Timer(Duration(seconds: duration), () async {
      final finishFuture = finish();
      final endMeetingFuture =
          ringingPageViewModel!.endMeeting(MeetingStatus.END_TIMER);
      await Future.wait([finishFuture, endMeetingFuture]);
    });
  }

  Future<void> start() async {
    setTimer();
    await player.setAsset('assets/video_call.mp3');
    await player.setLoopMode(LoopMode.one);
    if (!player.playing) {
      await player.play();
    }
  }

  Future<void> finish() async {
    if (timer?.isActive ?? false) {
      timer?.cancel();
    }
    timer = null;

    if (player.playing) {
      await player.stop();
    }
    await player.dispose();
  }

  final FirebaseFunctions functions = FirebaseFunctions.instance;

  String comment(RingingPageViewModel ringingPageViewModel) =>
      ringingPageViewModel.amA()
          ? commentAsA(ringingPageViewModel)
          : commentAsB(ringingPageViewModel);
  String commentAsA(RingingPageViewModel ringingPageViewModel) {
    switch (widget.meeting.status) {
      case MeetingStatus.INIT:
        return '1/5 - Pick up for ${shortString(ringingPageViewModel.otherUser.name)}';
      case MeetingStatus.ACCEPTED:
        return '2/5 - Creating blockchain transaction';
      case MeetingStatus.TXN_CREATED:
        return '3/5 - Please confirm the blockchain transaction on your wallet';
      case MeetingStatus.TXN_SIGNED:
        return '3/5 - Transaction signed. Sending to the blockchain';
      case MeetingStatus.TXN_SENT:
        return '4/5 - Sent the transaction to the blockchain';
      case MeetingStatus.TXN_CONFIRMED:
        return '5/5 - Your coins are locked in the smart contract';
      default:
        throw Exception(
            'commentAsA - should never be here - meeting.status=${widget.meeting.status}');
    }
  }

  String commentAsB(RingingPageViewModel ringingPageViewModel) {
    switch (widget.meeting.status) {
      case MeetingStatus.INIT:
        return '1/5 - Waiting for ${shortString(ringingPageViewModel.otherUser.name)} to pick up';
      case MeetingStatus.ACCEPTED:
        return '2/5 - Creating blockchain transaction';
      case MeetingStatus.TXN_CREATED:
        return '3/5 - Waiting for ${shortString(ringingPageViewModel.otherUser.name)} to confirm the blockchain transaction';
      case MeetingStatus.TXN_SIGNED:
        return '3/5 - ${shortString(ringingPageViewModel.otherUser.name)} has signed the transaction. Sending to the network';
      case MeetingStatus.TXN_SENT:
        return '4/5 - Sent the transaction to the blockchain';
      case MeetingStatus.TXN_CONFIRMED:
        return '5/5 - ${shortString(ringingPageViewModel.otherUser.name)}'
            's coins are locked in the smart contract';
      default:
        throw Exception(
            'commentAsB - should never be here - meeting.status=${widget.meeting.status}');
    }
  }

  @override
  Widget build(BuildContext context) {
    log(F + 'RingingPage - build');
    final _ringingPageViewModel = ref.watch(ringingPageViewModelProvider);
    if (_ringingPageViewModel == null) return WaitPage();
    ringingPageViewModel = _ringingPageViewModel;
    String name = '';

    bool amA = ringingPageViewModel!.amA();
    String userId = amA ? ringingPageViewModel!.meeting.B : ringingPageViewModel!.meeting.A;
    final userAsyncValue = ref.read(userProvider(userId));
    if (!(userAsyncValue is AsyncLoading || userAsyncValue is AsyncError)) {
      name = userAsyncValue.asData!.value.name;
    }

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
                      size: 140,
                      color: Colors.green,
                      child: CircleAvatar(
                          radius: 100,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset(
                              'assets/logo.png',
                              scale: 1,
                            ),
                          )),
                    ),
                    CircularPercentIndicator(
                      radius: 230.0,
                      lineWidth: 4.0,
                      animation: true,
                      animationDuration: 30000,
                      circularStrokeCap: CircularStrokeCap.round,
                      percent: 1,
                      progressColor: Colors.white,
                      backgroundColor: Colors.blueAccent,
                      animateFromLastPercent: true,
                    ),
                    DottedBorder(
                      borderType: BorderType.RRect,
                      radius: Radius.circular(220),
                      strokeWidth: 3,
                      dashPattern: [8],
                      strokeCap: StrokeCap.butt,
                      color: Colors.blueAccent,
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        child: Container(
                          height: 222,
                          width: 222,
                        ),
                      ),
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
                      comment(ringingPageViewModel!),
                      style: Theme.of(context).textTheme.caption,
                    ),
                    SizedBox(height: 10),
                    Text(
                      name,
                      style: Theme.of(context).textTheme.headline6,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (!isClicked &&
                        ringingPageViewModel!.meeting.status ==
                            MeetingStatus.INIT)
                      Column(
                        children: [
                          FloatingActionButton(
                            child: Icon(Icons.call_end, color: Colors.white),
                            backgroundColor: Color.fromARGB(255, 239, 102, 84),
                            onPressed: () async {
                              final finishFuture = finish();
                              final cancelMeetingFuture = ringingPageViewModel!
                                  .endMeeting(ringingPageViewModel!.amA()
                                      ? MeetingStatus.END_A
                                      : MeetingStatus.END_B);
                              await Future.wait(
                                  [finishFuture, cancelMeetingFuture]);
                            },
                          ),
                        ],
                      ),
                    if (!isClicked &&
                        ringingPageViewModel!.amA() &&
                        ringingPageViewModel!.meeting.status ==
                            MeetingStatus.INIT)
                      Column(
                        children: [
                          Bounce(
                            child: FloatingActionButton(
                              child: Icon(Icons.call, color: Colors.white),
                              backgroundColor: Colors.green,
                              onPressed: () async {
                                isClicked = true;
                                if (mounted) {
                                  setState(() {});
                                }
                                final finishFuture = finish();
                                final acceptMeetingFuture =
                                    ringingPageViewModel!.acceptMeeting();
                                await Future.wait(
                                    [finishFuture, acceptMeetingFuture]);
                              },
                            ),
                          ),
                        ],
                      )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
