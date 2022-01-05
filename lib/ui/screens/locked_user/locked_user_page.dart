import 'package:app_2i2i/infrastructure/models/meeting_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../infrastructure/providers/all_providers.dart';
import '../home/wait_page.dart';
import '../ringing/ringing_page.dart';
import '../web_rtc/call_page.dart';

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
    if (lockedUserViewModel == null) {
      return WaitPage();
    }

    final meetingStatus = lockedUserViewModel.meeting.status;

    bool isActive = meetingStatus == MeetingStatus.ROOM_CREATED ||
        meetingStatus == MeetingStatus.A_RECEIVED_REMOTE ||
        meetingStatus == MeetingStatus.B_RECEIVED_REMOTE ||
        meetingStatus == MeetingStatus.CALL_STARTED;
    bool showCallPage = (meetingStatus == MeetingStatus.TXN_CONFIRMED &&
            lockedUserViewModel.amA()) ||
        isActive;
    bool showRingingPage = meetingStatus == MeetingStatus.INIT ||
        meetingStatus == MeetingStatus.ACCEPTED ||
        meetingStatus == MeetingStatus.TXN_CREATED ||
        meetingStatus == MeetingStatus.TXN_SIGNED ||
        meetingStatus == MeetingStatus.TXN_SENT ||
        (meetingStatus == MeetingStatus.TXN_CONFIRMED &&
            lockedUserViewModel.amB());
    bool showWaitPage = !(showCallPage || showRingingPage);

    return Stack(
      fit: StackFit.expand,
      children: [
        Visibility(
          visible: showCallPage,
          child: CallPage(
              onHangPhone: (uid, meetingId) {
                widget.onHangPhone!(uid, meetingId);
              },
              meeting: lockedUserViewModel.meeting,
              user: lockedUserViewModel.user),
        ),
        Visibility(
            visible: showRingingPage,
            child: RingingPage(meeting: lockedUserViewModel.meeting)),
        Visibility(
          visible: showWaitPage,
          child: WaitPage(),
        ),
      ],
    );
  }
}
