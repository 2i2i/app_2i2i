import 'package:app_2i2i/infrastructure/commons/strings.dart';
import 'package:app_2i2i/infrastructure/commons/theme.dart';
import 'package:app_2i2i/infrastructure/models/meeting_model.dart';
import 'package:app_2i2i/infrastructure/models/hangout_model.dart';
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

    return Scaffold(
      appBar: AppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 10),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: Text(
              Strings().meetingsHistory,
              style: Theme.of(context).textTheme.headline5,
            ),
          ),
          SizedBox(height: 15),
          Expanded(
            child: Builder(
              builder: (context) {
                if (meetingList == null) {
                  return WaitPage(isCupertino: true);
                }
                List<Meeting?> meetingItemList = meetingList.meetingList;
                return ListView.builder(
                  itemCount: meetingItemList.length,
                  padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 15),
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
            ),
          ),
        ],
      ),
    );
  }

  Widget getCallTypeIcon(Hangout hangout, String currentUid) {
    if (hangout.id == currentUid) {
      return Icon(Icons.call_received_rounded, color: AppTheme().red);
    }
    return Icon(Icons.call_made_rounded, color: AppTheme().green);
  }
}
