import 'package:app_2i2i/models/meeting.dart';
import 'package:app_2i2i/models/user.dart';
import 'package:app_2i2i/pages/home/wait_page.dart';
import 'package:app_2i2i/pages/ringing/ui/ringing_page.dart';
import 'package:app_2i2i/pages/web_rtc/call_page.dart';
import 'package:app_2i2i/repository/firestore_database.dart';
import 'package:app_2i2i/services/all_providers.dart';
import 'package:app_2i2i/services/logging.dart';
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
    final uid = ref.watch(myUIDProvider)!;
    final user = ref.watch(userProvider(uid));
    /*final lockedUserViewModel = ref.watch(lockedUserViewModelProvider);
    if (lockedUserViewModel == null) {
      return WaitPage();
    }*/

    if(user is AsyncLoading){
      return WaitPage();
    }
    UserModel userModel = user.data!.value;
    return StreamBuilder(
      stream: FirestoreDatabase().meetingStream(id: userModel.currentMeeting!),
      builder: (BuildContext context, AsyncSnapshot<Meeting> snapshot) {
        if(snapshot.data?.status.isNotEmpty??false) {
          log(F + '\n\n${snapshot.data?.status.last.value.toString()}\n\n');
        }
        if(snapshot.hasData && snapshot.data is Meeting) {
          Meeting meeting = snapshot.data!;
          final meetingStatus = meeting.currentStatus();
          bool isInit = meetingStatus == MeetingValue.INIT;
          bool isStarted = meetingStatus == MeetingValue.LOCK_COINS_STARTED;
          bool isConfirmed = meetingStatus == MeetingValue.LOCK_COINS_CONFIRMED;
          bool isActive = meetingStatus == MeetingValue.ACTIVE;
          log(F + ' isInit : $isInit -- isStarted : $isStarted -- isConfirmed : $isConfirmed -- isActive : $isActive --');

          if (isConfirmed || isActive) {
            return CallPage(meeting: meeting, user: userModel);
          }
          return RingingPage(meeting: meeting);
        }
        return WaitPage();
      },
    );
  }
}
