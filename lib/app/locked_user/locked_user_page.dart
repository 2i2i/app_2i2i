import 'package:app_2i2i/models/meeting.dart';
import 'package:app_2i2i/app/home/wait_page.dart';
import 'package:app_2i2i/app/web_rtc/call_page.dart';
import 'package:app_2i2i/pages/ringing/ringing_page.dart';
import 'package:app_2i2i/services/logging.dart';
import 'package:app_2i2i/services/all_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LockedUserPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    log(F + 'LockedUserPage - build');

    final lockedUserViewModel = ref.watch(lockedUserViewModelProvider);
    log(F +
        'LockedUserPage - build - lockedUserViewModel=$lockedUserViewModel');
    if (lockedUserViewModel == null) return WaitPage();

    final meetingStatus = lockedUserViewModel.meeting.currentStatus();
    log(F + 'LockedUserPage - build - meetingStatus=$meetingStatus');
    if (meetingStatus == MeetingValue.INIT ||
        meetingStatus == MeetingValue.LOCK_COINS_STARTED)
      return RingingPage(
        meeting: lockedUserViewModel.meeting,
      );

    if (meetingStatus == MeetingValue.LOCK_COINS_CONFIRMED &&
        !lockedUserViewModel.amA())
      return RingingPage(
        meeting: lockedUserViewModel.meeting,
      );

    if (meetingStatus == MeetingValue.LOCK_COINS_CONFIRMED ||
        meetingStatus == MeetingValue.ACTIVE)
      return CallPage(
          meeting: lockedUserViewModel.meeting, user: lockedUserViewModel.user);

    throw new Exception('unknown meetingStatus=$meetingStatus');
  }
}
