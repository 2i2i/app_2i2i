import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../infrastructure/commons/keys.dart';
import '../../../../infrastructure/commons/utils.dart';
import '../../../../infrastructure/models/meeting_model.dart';
import '../../../../infrastructure/providers/all_providers.dart';
import '../../../../infrastructure/routes/app_routes.dart';
import '../../home/wait_page.dart';
import '../../my_user/widgets/meeting_history_tile.dart';

class BidOutMeetings extends ConsumerWidget {
  final String uid;

  const BidOutMeetings({required this.uid, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    var meetingList = ref.watch(meetingHistoryB(uid));
    if (haveToWait(meetingList)) {
      return Center(child: WaitPage());
    }
    List<Meeting?> meetingListB = meetingList.asData?.value ?? [];

    if (meetingListB.isEmpty) {
      return Center(
          child: Text(
            Keys.noMeetingsFound.tr(context),
            style: Theme.of(context).textTheme.subtitle1,
          ));
    }

    if(meetingListB.isEmpty){
      return Center(child: Text(Keys.noMeetingsFound.tr(context),style: Theme.of(context).textTheme.subtitle1,));
    }
    return ListView.builder(
      itemCount: meetingListB.length,
      padding: const EdgeInsets.symmetric(vertical: 10),
      itemBuilder: (BuildContext context, int index) {
        Meeting? meetingModel = meetingListB[index];
        if (meetingModel == null) {
          return Container();
        }
        return MeetingHistoryTile(
          currentUid: uid,
          meetingModel: meetingModel,
          onTap: () => context.pushNamed(Routes.user.nameFromPath(), params: {
            'uid': meetingModel.B,
          }),
        );
      },
    );
  }
}
