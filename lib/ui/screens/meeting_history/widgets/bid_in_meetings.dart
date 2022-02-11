import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../infrastructure/commons/keys.dart';
import '../../../../infrastructure/models/meeting_model.dart';
import '../../my_hangout/widgets/meeting_history_tile.dart';

class BidInMeetings extends ConsumerWidget {
  final List<Meeting?> meetingListA;
  final String uid;

  const BidInMeetings({required this.meetingListA, required this.uid, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if(meetingListA.isEmpty){
      return Center(child: Text(Keys.noBidFound.tr(context),style: Theme.of(context).textTheme.subtitle1,));
    }
    return ListView.builder(
      itemCount: meetingListA.length,
      padding: const EdgeInsets.symmetric(vertical: 10),
      itemBuilder: (BuildContext context, int index) {
        Meeting? meetingModel = meetingListA[index];
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
}
