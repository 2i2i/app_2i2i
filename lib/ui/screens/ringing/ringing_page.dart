import 'dart:async';

import 'package:app_2i2i/infrastructure/commons/app_config.dart';
import 'package:app_2i2i/ui/screens/ringing/ripples_animation.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../../../infrastructure/commons/utils.dart';
import '../../../infrastructure/data_access_layer/services/logging.dart';
import '../../../infrastructure/models/meeting_model.dart';
import '../../../infrastructure/providers/all_providers.dart';
import '../../../infrastructure/providers/ringing_provider/ringing_page_view_model.dart';
import '../../commons/custom_profile_image_view.dart';
import '../home/wait_page.dart';
import 'ripples_animation.dart';

class RingingPage extends ConsumerStatefulWidget {
  const RingingPage({Key? key}) : super(key: key);

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

  void setTimer(RingingPageViewModel model) {
    if (timer != null) return;
    if (model.meeting.status != MeetingStatus.ACCEPTED_B) return;
    timer = Timer(Duration(seconds: AppConfig().RINGPAGEDURATION), () async {
      log(J + 'RingingPage - Timer');
      final finishFuture = finish();
      final endMeetingFuture = model.endMeeting(MeetingStatus.END_TIMER);
      await Future.wait([finishFuture, endMeetingFuture]);
    });
  }

  Future<void> start() async {
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

  String comment(RingingPageViewModel ringingPageViewModel) => ringingPageViewModel
          .amA()
      ? 'Please pick up for ${shortString(ringingPageViewModel.otherUser.name)}'
      : 'Waiting for ${shortString(ringingPageViewModel.otherUser.name)} to pick up';

  @override
  Widget build(BuildContext context) {
    log(F + 'RingingPage - build');
    final _ringingPageViewModel = ref.watch(ringingPageViewModelProvider);
    if (haveToWait(_ringingPageViewModel)) {
      return WaitPage();
    }

    ringingPageViewModel = _ringingPageViewModel;
    if (ringingPageViewModel is RingingPageViewModel) {
      setTimer(ringingPageViewModel!);
    }
    String callerName = '';
    String callerBio = '';
    String bidComment = '';
    int maxDuration = 0;
    double callerRating = 1.0;

    bool amA = ringingPageViewModel!.amA();

    final meetingId = ringingPageViewModel?.meeting.id;
    if (amA && meetingId != null) {
      final bidOutAsyncValue = ref.watch(bidOutProvider(meetingId));
      if (!haveToWait(bidOutAsyncValue)) {
        final bidOut = bidOutAsyncValue.value!;
        bidComment = bidOut.comment ?? '';
      }
    } else if (meetingId != null) {
      final bidInPrivateAsyncValue = ref.watch(bidInPrivateProvider(meetingId));
      if (!haveToWait(bidInPrivateAsyncValue)) {
        final bidInPrivate = bidInPrivateAsyncValue.value!;
        bidComment = bidInPrivate.comment ?? '';
      }
    }

    String otherUserId =
        amA ? ringingPageViewModel!.meeting.B : ringingPageViewModel!.meeting.A;
    final otherHangoutAsyncValue = ref.read(hangoutProvider(otherUserId));
    if (!haveToWait(otherHangoutAsyncValue)) {
      callerName = otherHangoutAsyncValue.asData!.value.name;
      callerBio = otherHangoutAsyncValue.asData!.value.bio;
      callerRating = otherHangoutAsyncValue.asData!.value.rating;
    }

    if (ringingPageViewModel?.meeting is Meeting) {
      maxDuration = ringingPageViewModel!.meeting.maxDuration();
    }

    log(F + 'RingingPage - scaffold');
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
              child: Container(
                width: MediaQuery.of(context).size.width / 1.5,
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
                      style: Theme.of(context).textTheme.headline6?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).primaryColorDark),
                    ),
                    SizedBox(height: 14),
                    Text(
                      callerBio,
                      maxLines: 2,
                      softWrap: true,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .bodyText2
                          ?.copyWith(color: Theme.of(context).primaryColorDark),
                    ),
                    SizedBox(height: 14),
                    Visibility(
                      visible: !amA && bidComment.isNotEmpty,
                      child: Text(
                        'Note: $bidComment',
                        maxLines: 2,
                        softWrap: true,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyText2?.copyWith(
                            color: Theme.of(context).primaryColorDark),
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
                            '${callerRating * 5.0}',
                            style: Theme.of(context)
                                .textTheme
                                .caption
                                ?.copyWith(color: Colors.amber),
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
                      decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(61)),
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
                        '${secondsToSensibleTimePeriod(maxDuration.toInt())} (${ringingPageViewModel!.meeting.speed.num} μAlgo/s)',
                        maxLines: 2,
                        softWrap: true,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyText2?.copyWith(
                            color: Theme.of(context).primaryColorDark),
                      ),
                  ],
                ),
              ),
            ),
            Expanded(
                flex: 1,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    (!isClicked &&
                            ringingPageViewModel!.amA() &&
                            ringingPageViewModel!.meeting.status ==
                                MeetingStatus.ACCEPTED_B)
                        ? Ripples(
                            color: Colors.white.withOpacity(0.3),
                            child: InkWell(
                              onTap: () async {
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
                              child: CircleAvatar(
                                  radius: kToolbarHeight,
                                  child: Text(
                                    'Start',
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle1
                                        ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary),
                                  )),
                            ),
                          )
                        : Container(
                            alignment: Alignment.center,
                            margin: EdgeInsets.symmetric(horizontal: 22),
                            padding: EdgeInsets.symmetric(
                                vertical: 14, horizontal: 22),
                            decoration: BoxDecoration(
                                color: Color.fromRGBO(255, 255, 255, 0.2),
                                borderRadius: BorderRadius.circular(20)),
                            child: Text(
                                amA
                                    ? 'We are connecting the Host....'
                                    : 'We are connecting the Guest....',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText2
                                    ?.copyWith(
                                        color: Theme.of(context)
                                            .primaryColorDark)),
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
