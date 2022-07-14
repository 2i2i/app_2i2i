import 'dart:async';
import 'dart:io';

import 'package:app_2i2i/infrastructure/commons/app_config.dart';
import 'package:app_2i2i/infrastructure/commons/theme.dart';
import 'package:app_2i2i/ui/screens/ringing/ripples_animation.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:perfect_volume_control/perfect_volume_control.dart';

import '../../../common_main.dart';
import '../../../infrastructure/commons/keys.dart';
import '../../../infrastructure/commons/utils.dart';
import '../../../infrastructure/models/meeting_model.dart';
import '../../../infrastructure/providers/all_providers.dart';
import '../../../infrastructure/providers/ringing_provider/ringing_page_view_model.dart';
import '../../commons/custom_profile_image_view.dart';
import '../app/wait_page.dart';
import 'ripples_animation.dart';

class RingingPage extends ConsumerStatefulWidget {
  const RingingPage({Key? key}) : super(key: key);

  @override
  RingingPageState createState() => RingingPageState();
}

class RingingPageState extends ConsumerState<RingingPage> {
  bool isClicked = false;

  RingingPageState({Key? key});

  Timer? timer;
  final player = AudioPlayer();
  StreamSubscription<double>? _subscription;

  ValueNotifier<bool> volumeState = ValueNotifier(true);

  @override
  void initState() {
    _subscription = PerfectVolumeControl.stream.listen((value) {
      volumeState.value = false;
      stopRingAudio();
    });
    startRingAudio();
    platform.invokeMethod('ANSWER', "ANSWER");
    super.initState();
  }

  @override
  Future<void> dispose() async {
    Future.delayed(Duration.zero, () async {
      _subscription?.cancel();
      await finishTimer();
    });
    super.dispose();
  }

  void setTimer(RingingPageViewModel model) {
    if (timer != null) return;
    if (model.meeting.status != MeetingStatus.ACCEPTED_B) return;
    timer = Timer(Duration(seconds: AppConfig().RINGPAGEDURATION), () async {
      if (mounted && model.meeting.status != MeetingStatus.RECEIVED_REMOTE_A) {
        final finishFuture = finishTimer();
        final endMeetingFuture = model.endMeeting(MeetingStatus.END_TIMER_RINGING_PAGE);
        await Future.wait([finishFuture, endMeetingFuture]);
      }
    });
  }

  Future<void> startRingAudio() async {
    await player.setAsset('assets/video_call.mp3');
    await player.setLoopMode(LoopMode.one);
    if (!player.playing) {
      volumeState.value = true;
      await player.play();
    }
  }

  Future<void> stopRingAudio() async {
    if (player.playing) {
      await player.stop();
    }
  }

  Future<void> finishTimer() async {
    if (timer?.isActive ?? false) {
      timer?.cancel();
    }
    timer = null;

    await stopRingAudio();

    if (Platform.isIOS) {
      await platform.invokeMethod('CUT_CALL');
    }
  }

  final FirebaseFunctions functions = FirebaseFunctions.instance;

  String comment(RingingPageViewModel ringingPageViewModel) => ringingPageViewModel.amA()
      ? '${Keys.pickUpMsg.tr(context)} ${shortString(ringingPageViewModel.otherUser.name)}'
      : '${Keys.waitingFor.tr(context)} ${shortString(ringingPageViewModel.otherUser.name)} ${Keys.toPickUp.tr(context)}';

  @override
  Widget build(BuildContext context) {
    final ringingPageViewModel = ref.watch(ringingPageViewModelProvider);
    if (haveToWait(ringingPageViewModel)) {
      return WaitPage();
    }

    if (ringingPageViewModel is RingingPageViewModel) {
      setTimer(ringingPageViewModel);
    }

    String callerName = '';
    String callerBio = '';
    String bidComment = '';
    int maxDuration = 0;
    double callerRating = 1.0;

    bool amA = ringingPageViewModel!.amA();

    final meetingId = ringingPageViewModel.meeting.id;
    if (amA) {
      final bidOutAsyncValue = ref.watch(bidOutProvider(meetingId));
      if (!haveToWait(bidOutAsyncValue)) {
        final bidOut = bidOutAsyncValue.value!;
        bidComment = bidOut.comment ?? '';
      }
    } else {
      final bidInPrivateAsyncValue = ref.watch(bidInPrivateProvider(meetingId));
      if (!haveToWait(bidInPrivateAsyncValue)) {
        final bidInPrivate = bidInPrivateAsyncValue.value!;
        bidComment = bidInPrivate.comment ?? '';
      }
    }

    String otherUserId = amA ? ringingPageViewModel.meeting.B : ringingPageViewModel.meeting.A;
    final otherUserAsyncValue = ref.read(userProvider(otherUserId));
    if (!haveToWait(otherUserAsyncValue)) {
      callerName = otherUserAsyncValue.value!.name;
      callerBio = otherUserAsyncValue.value!.bio;
      callerRating = otherUserAsyncValue.value!.rating;
    }

    maxDuration = ringingPageViewModel.meeting.maxDuration();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(237, 239, 241, 1),
              Color.fromRGBO(35, 214, 125, 1),
            ],
          ),
        ),
        width: double.infinity,
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Stack(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ProfileWidget(
                          stringPath: callerName,
                          radius: 84,
                          showBorder: false,
                          hideShadow: true,
                        ),
                        SizedBox(height: 12),
                        Text(
                          callerName,
                          style: Theme.of(context).textTheme.headline6?.copyWith(fontWeight: FontWeight.w800, color: Theme.of(context).primaryColorDark),
                        ),
                        SizedBox(height: 14),
                        Text(
                          callerBio,
                          maxLines: 2,
                          softWrap: true,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyText2?.copyWith(color: Theme.of(context).primaryColorDark),
                        ),
                        SizedBox(height: 14),
                        Visibility(
                          visible: !amA && bidComment.isNotEmpty,
                          child: Text(
                            '${Keys.Note.tr(context)}: $bidComment',
                            maxLines: 2,
                            softWrap: true,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyText2?.copyWith(color: Theme.of(context).primaryColorDark),
                          ),
                        ),
                        SizedBox(height: 14),
                        Container(
                          padding: EdgeInsets.all(10),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${(callerRating * 5.0).toStringAsFixed(1)}',
                                style: Theme.of(context).textTheme.caption?.copyWith(color: Colors.amber),
                              ),
                              SizedBox(width: 4),
                              IgnorePointer(
                                ignoring: true,
                                child: RatingBar.builder(
                                  initialRating: callerRating * 5.0,
                                  minRating: 1,
                                  direction: Axis.horizontal,
                                  tapOnlyMode: true,
                                  updateOnDrag: false,
                                  itemCount: 5,
                                  itemSize: 16,
                                  allowHalfRating: true,
                                  glowColor: Colors.white,
                                  ignoreGestures: false,
                                  unratedColor: Colors.grey.shade300,
                                  itemBuilder: (context, _) => Icon(
                                    Icons.star_rounded,
                                    color: Colors.amber,
                                  ),
                                  onRatingUpdate: (double value) {},
                                ),
                              )
                            ],
                          ),
                          decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.circular(61)),
                        ),
                        Container(
                          width: kTextTabBarHeight,
                          margin: EdgeInsets.only(top: 2),
                          child: Divider(
                            thickness: 2,
                          ),
                        ),
                        SizedBox(height: 4),
                        if (maxDuration != double.infinity)
                          Text(
                            '${secondsToSensibleTimePeriod(maxDuration.toInt())} (${ringingPageViewModel.meeting.speed.num} μAlgo/s)',
                            maxLines: 2,
                            softWrap: true,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyText2?.copyWith(color: Theme.of(context).primaryColorDark),
                          ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 1,
                    top: 10,
                    child: ValueListenableBuilder(
                      valueListenable: volumeState,
                      builder: (BuildContext context, bool value, Widget? child) {
                        return MaterialButton(
                          elevation: 5,
                          color: Colors.white,
                          shape: CircleBorder(side: BorderSide(color: Colors.white)),
                          onPressed: () async {
                            volumeState.value = !volumeState.value;
                            if (volumeState.value) {
                              await startRingAudio();
                            } else {
                              await stopRingAudio();
                            }
                          },
                          child: Icon(
                            value ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                            size: 18,
                            color: AppTheme().black,
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
            Expanded(
                flex: 1,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    (!isClicked && ringingPageViewModel.amA() && ringingPageViewModel.meeting.status == MeetingStatus.ACCEPTED_B)
                        ? Ripples(
                            color: Colors.white.withOpacity(0.3),
                            child: InkWell(
                              onTap: () async {
                                isClicked = true;
                                if (mounted) {
                                  setState(() {});
                                }
                                final finishFuture = finishTimer();
                                final acceptMeetingFuture = ringingPageViewModel.acceptMeeting();
                                await Future.wait([finishFuture, acceptMeetingFuture]);
                              },
                              child: CircleAvatar(
                                  radius: kToolbarHeight,
                                  child: Text(
                                    '${Keys.Start.tr(context)}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle1
                                        ?.copyWith(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.secondary),
                                  )),
                            ),
                          )
                        : Container(
                      alignment: Alignment.center,
                            margin: EdgeInsets.symmetric(horizontal: 22),
                            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 22),
                            decoration: BoxDecoration(color: Color.fromRGBO(255, 255, 255, 0.2), borderRadius: BorderRadius.circular(20)),
                            child: Text(amA ? '${Keys.connectingHost.tr(context)}' : '${Keys.connectingGuest.tr(context)}',
                                style: Theme.of(context).textTheme.bodyText2?.copyWith(color: Theme.of(context).primaryColorDark)),
                          ),
                  ],
                )),
            SizedBox(
              height: 10,
            )
          ],
        ),
      ),
    );
  }
}
