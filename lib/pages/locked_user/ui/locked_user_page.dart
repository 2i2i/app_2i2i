import 'package:app_2i2i/models/meeting.dart';
import 'package:app_2i2i/pages/home/wait_page.dart';
import 'package:app_2i2i/pages/ringing/ui/ringing_page.dart';
import 'package:app_2i2i/pages/web_rtc/call_page.dart';
import 'package:app_2i2i/services/all_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

class LockedUserPage extends ConsumerStatefulWidget {
  const LockedUserPage({Key? key}) : super(key: key);

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

    if (meetingStatus == MeetingValue.INIT ||
        meetingStatus == MeetingValue.LOCK_COINS_STARTED ||
        (meetingStatus == MeetingValue.LOCK_COINS_CONFIRMED &&
            !lockedUserViewModel.amA())) {
      return RingingPage(meeting: lockedUserViewModel.meeting);
    } else if (meetingStatus == MeetingValue.LOCK_COINS_CONFIRMED && !lockedUserViewModel.amA()) {
      return RingingPage(meeting: lockedUserViewModel.meeting);
    } else if (meetingStatus == MeetingValue.LOCK_COINS_CONFIRMED ||
        meetingStatus == MeetingValue.ACTIVE) {
      return CallPage(meeting: lockedUserViewModel.meeting, user: lockedUserViewModel.user,);
    } else {
      throw new Exception('unknown meetingStatus=$meetingStatus');
    }
  }
}
