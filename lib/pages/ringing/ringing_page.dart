import 'dart:async';

import 'package:app_2i2i/models/meeting.dart';
import 'package:app_2i2i/app/home/wait_page.dart';
import 'package:app_2i2i/pages/ringing/ringing_page_view_model.dart';
import 'package:app_2i2i/services/logging.dart';
import 'package:app_2i2i/services/all_providers.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RingingPage extends ConsumerStatefulWidget {
  const RingingPage({Key? key, required this.meeting}) : super(key: key);

  final Meeting meeting;

  @override
  RingingPageState createState() => RingingPageState(meeting: meeting);
}

class RingingPageState extends ConsumerState<RingingPage> {
  RingingPageState({Key? key, required this.meeting});

  final Meeting meeting;
  Timer? T;
  @override
  void initState() {
    T?.cancel();
    T = null;
    T = Timer(
        Duration(seconds: 30), () => cancelMeeting(reason: 'NO_PICKUP'));
    super.initState();
  }

  @override
  void dispose() {
    T?.cancel();
    T = null;
    super.dispose();
  }

  final FirebaseFunctions functions = FirebaseFunctions.instance;
  Future cancelMeeting({String? reason}) async {
    T?.cancel();
    T = null;
    final HttpsCallable endMeeting = functions.httpsCallable('endMeeting');
    final args = {'meetingId': meeting.id};
    if (reason != null) args['reason'] = reason;
    await endMeeting(args);
  }

  List<FloatingActionButton> actionWidgetsList(
      RingingPageViewModel ringingPageViewModel) {
    List<FloatingActionButton> actions = [];

    if (ringingPageViewModel.meeting.isInit() && ringingPageViewModel.amA())
      actions.add(FloatingActionButton(
        onPressed: () => ringingPageViewModel.acceptMeeting(),
        tooltip: 'Accept',
        child: Icon(Icons.done),
        backgroundColor: Colors.green,
      ));

    actions.add(FloatingActionButton(
      onPressed: () => ringingPageViewModel.cancelMeeting(),
      tooltip: 'Cancel',
      child: Icon(Icons.call_end),
      backgroundColor: Colors.pink,
    ));

    return actions;
  }

  List<Widget> bodyWidgetsList(RingingPageViewModel ringingPageViewModel) {
    List<Widget> bodyList = [
      Image.asset(
        'assets/logo.png',
        scale: 1,
      ),
      Text(ringingPageViewModel.amA()
          ? 'Please pick up'
          : 'Waiting for user to pick up')
    ];
    if (!ringingPageViewModel.amA())
      bodyList.add(const CircularProgressIndicator());
    return bodyList;
  }

  @override
  Widget build(BuildContext context) {
    log('RingingPage - build');
    final ringingPageViewModel = ref.watch(ringingPageViewModelProvider);
    if (ringingPageViewModel == null) return WaitPage();
    log('RingingPage - scaffold');
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: actionWidgetsList(ringingPageViewModel)),
      body: Center(
        child: Column(children: bodyWidgetsList(ringingPageViewModel)),
      ),
    );
  }
}
