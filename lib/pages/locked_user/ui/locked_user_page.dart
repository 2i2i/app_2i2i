import 'package:app_2i2i/models/meeting.dart';
import 'package:app_2i2i/pages/home/wait_page.dart';
import 'package:app_2i2i/pages/ringing/ui/ringing_page.dart';
import 'package:app_2i2i/pages/web_rtc/call_page.dart';
import 'package:app_2i2i/services/all_providers.dart';
import 'package:app_2i2i/services/logging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LockedUserPage extends ConsumerStatefulWidget {

  const LockedUserPage({
    Key? key,
  }) : super(key: key);

  @override
  _LockedUserPageState createState() => _LockedUserPageState();
}

class _LockedUserPageState extends ConsumerState<LockedUserPage> {

  @override
  Widget build(BuildContext context) {
    final lockedUserViewModel = ref.watch(lockedUserViewModelProvider);
    if (lockedUserViewModel == null) {
      return WaitPage();
    }

    final meetingStatus = lockedUserViewModel.meeting.currentStatus();
    bool isInit = meetingStatus == MeetingValue.INIT;
    bool isStarted = meetingStatus == MeetingValue.LOCK_COINS_STARTED;

    // bool isConfirmed = meetingStatus == MeetingValue.LOCK_COINS_CONFIRMED && !lockedUserViewModel.amA();
    //A-Caller
    bool isConfirmedAndA = meetingStatus == MeetingValue.LOCK_COINS_CONFIRMED && lockedUserViewModel.amA();
    //B-Receiver
    bool isConfirmedAndB = meetingStatus == MeetingValue.LOCK_COINS_CONFIRMED && lockedUserViewModel.amB();

    bool isActive =  meetingStatus == MeetingValue.ACTIVE;
    log(F+' isInit : $isInit -- isStarted : $isStarted -- isConfirmedAndA : $isConfirmedAndA -- isActive : $isActive --');
    log(F+' meeting: ${lockedUserViewModel.meeting}, user: ${lockedUserViewModel.user},');

    return Stack(
      fit: StackFit.expand,
      children: [
        Visibility(
          visible: (isConfirmedAndA || isActive),
          child: CallPage(
              meeting: lockedUserViewModel.meeting,
              user: lockedUserViewModel.user),
        ),
        Visibility(
            visible: (isInit || isStarted || isConfirmedAndB),
            child: RingingPage(meeting: lockedUserViewModel.meeting)
        ),
        Visibility(
          visible: !(isInit || isStarted || isConfirmedAndA || isConfirmedAndB || isActive),
          child: WaitPage(),
        ),
      ],
    );
  }
}
