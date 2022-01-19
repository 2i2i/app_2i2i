import 'package:app_2i2i/infrastructure/commons/theme.dart';
import 'package:app_2i2i/infrastructure/models/meeting_model.dart';
import 'package:app_2i2i/infrastructure/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../infrastructure/providers/all_providers.dart';
import '../home/wait_page.dart';
import 'widgets/meeting_history_tile.dart';

class MeetingHistoryList extends ConsumerStatefulWidget {
  @override
  _MeetingHistoryListState createState() => _MeetingHistoryListState();
}

class _MeetingHistoryListState extends ConsumerState<MeetingHistoryList> {
  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(myUIDProvider)!;

    final meetingList = ref.read(meetingHistoryProvider(uid));
    if (meetingList == null) {
      return WaitPage();
    }
    List<Meeting?> meetingItemList = meetingList.meetingList;
    return ListView.builder(
      itemCount: meetingItemList.length,
      padding: const EdgeInsets.symmetric(vertical: 10),
      itemBuilder: (BuildContext context, int index) {
        Meeting? meetingModel = meetingItemList[index];
        if (meetingModel == null) {
          return Container();
        }
        return MeetingHistoryTile(
          currentUid: uid,
          meetingModel: meetingModel,
        );
      },
    );
  }

  Widget getCallTypeIcon(UserModel userModel, String currentUid) {
    if (userModel.id == currentUid) {
      return Icon(Icons.call_received_rounded, color: AppTheme().red);
    }
    return Icon(Icons.call_made_rounded, color: AppTheme().green);
  }
}
