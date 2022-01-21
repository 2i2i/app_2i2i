import 'dart:async';

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
  const RingingPage({Key? key, this.meeting}) : super(key: key);
  final Meeting? meeting;

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
    if (widget.meeting!.status != MeetingStatus.ACCEPTED_B) return;
    int duration = 30;

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

  String comment(RingingPageViewModel ringingPageViewModel) => ringingPageViewModel
          .amA()
      ? 'Please pick up for ${shortString(ringingPageViewModel.otherUser.name)}'
      : 'Waiting for ${shortString(ringingPageViewModel.otherUser.name)} to pick up';

  @override
  Widget build(BuildContext context) {
    log(F + 'RingingPage - build');
    final _ringingPageViewModel = ref.watch(ringingPageViewModelProvider);
    if (_ringingPageViewModel == null ||
        _ringingPageViewModel is AsyncLoading ||
        _ringingPageViewModel is AsyncError) return WaitPage();
    ringingPageViewModel = _ringingPageViewModel;
    String callerName = '';
    String callerBio = '';
    double callerRating = 0.0;

    bool amA = ringingPageViewModel!.amA();
    String userId =
        amA ? ringingPageViewModel!.meeting.B : ringingPageViewModel!.meeting.A;

    final hangoutAsyncValue = ref.read(hangoutProvider(userId));
    if (!(haveToWait(hangoutAsyncValue))) {
      callerName = hangoutAsyncValue.asData!.value.name;
      callerBio = hangoutAsyncValue.asData!.value.bio;
      callerRating = hangoutAsyncValue.asData!.value.rating;
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
                      stringPath:
                          "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8Mnx8dXNlcnxlbnwwfHwwfHw%3D&w=1000&q=80",
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
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('$callerRating',
                              style: Theme.of(context)
                                  .textTheme
                                  .caption
                                  ?.copyWith(color: Colors.amber)),
                          SizedBox(width: 4),
                          IgnorePointer(
                            ignoring: true,
                            child: RatingBar.builder(
                              initialRating: callerRating * 5,
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
                    Text(
                      '5min Call',
                      maxLines: 2,
                      softWrap: true,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .bodyText2
                          ?.copyWith(color: Theme.of(context).primaryColorDark),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: (!isClicked &&
                      ringingPageViewModel!.amA() &&
                      ringingPageViewModel!.meeting.status ==
                          MeetingStatus.ACCEPTED_B)
                  ? Ripples(
                      color: Colors.white.withOpacity(0.3),
                      child: MaterialButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(60),
                        ),
                        elevation: 2,
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
                        child: CircleAvatar(
                            radius: kToolbarHeight,
                            child: Text(
                              'Start',
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle1
                                  ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color:
                                          Theme.of(context).primaryColorDark),
                            )),
                      ),
                    )
                  : Container(
                      alignment: Alignment.center,
                      padding:
                          EdgeInsets.symmetric(vertical: 14, horizontal: 22),
                      decoration: BoxDecoration(
                          color: Color.fromRGBO(255, 255, 255, 0.2),
                          borderRadius: BorderRadius.circular(20)),
                      child: Text('We are connecting to guest....',
                          style: Theme.of(context)
                              .textTheme
                              .bodyText2
                              ?.copyWith(
                                  color: Theme.of(context).primaryColorDark)),
                    ),
            ),
            SizedBox(
              height: 10,
            )
          ],
        ),
      ),
    );
  }
}
