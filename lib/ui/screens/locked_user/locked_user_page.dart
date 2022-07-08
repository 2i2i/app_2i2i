import 'package:app_2i2i/infrastructure/models/meeting_model.dart';
import 'package:app_2i2i/ui/screens/web_rtc/call_page_websockets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../infrastructure/providers/all_providers.dart';
import '../app/wait_page.dart';
import '../ringing/ringing_page.dart';

class LockedUserPage extends ConsumerStatefulWidget {
  final Function? onHangPhone;

  const LockedUserPage({
    this.onHangPhone,
    Key? key,
  }) : super(key: key);

  @override
  _LockedUserPageState createState() => _LockedUserPageState();
}

class _LockedUserPageState extends ConsumerState<LockedUserPage> {
  @override
  Widget build(BuildContext context) {
    final lockedUserViewModel = ref.watch(lockedUserViewModelProvider);
    if (lockedUserViewModel == null) return WaitPage();

    final userModelChanger = ref.watch(userChangerProvider);
    if (userModelChanger == null) return WaitPage();

    final meetingChanger = ref.watch(meetingChangerProvider);

    final meetingStatus = lockedUserViewModel.meeting.status;

    bool isActive = meetingStatus == MeetingStatus.ROOM_CREATED ||
        meetingStatus == MeetingStatus.RECEIVED_REMOTE_A ||
        meetingStatus == MeetingStatus.RECEIVED_REMOTE_B ||
        meetingStatus == MeetingStatus.CALL_STARTED;
    bool showCallPage = (meetingStatus == MeetingStatus.ACCEPTED_A && lockedUserViewModel.amA()) || isActive;
    bool showRingingPage = meetingStatus == MeetingStatus.ACCEPTED_B || meetingStatus == MeetingStatus.ACCEPTED_A;
    bool showWaitPage = !(showCallPage || showRingingPage);

    return Stack(
      fit: StackFit.expand,
      children: [
        Visibility(
          visible: showCallPage,
          child: CallPageWebsockets(
            meeting: lockedUserViewModel.meeting,
            meetingChanger: meetingChanger,
            userChanger: userModelChanger,
            user: lockedUserViewModel.user,
            onHangPhone: (uid, meetingId) => widget.onHangPhone?.call(uid, meetingId),
          ),
        ),
        Visibility(
          visible: showRingingPage,
          child: RingingPage(),
        ),
        Visibility(
          visible: showWaitPage,
          child: WaitPage(),
        ),
      ],
    );
  }
}
