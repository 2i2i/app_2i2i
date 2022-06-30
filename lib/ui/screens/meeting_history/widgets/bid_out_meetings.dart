import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../infrastructure/commons/keys.dart';
import '../../../../infrastructure/commons/utils.dart';
import '../../../../infrastructure/models/meeting_history_model.dart';
import '../../../../infrastructure/models/meeting_model.dart';
import '../../../../infrastructure/providers/all_providers.dart';
import '../../../../infrastructure/routes/app_routes.dart';
import '../../home/wait_page.dart';
import '../../my_user/widgets/meeting_history_tile.dart';

class BidOutMeetings extends ConsumerStatefulWidget {
  final String uid;

  const BidOutMeetings({required this.uid, Key? key}) : super(key: key);

  @override
  ConsumerState<BidOutMeetings> createState() => _BidOutMeetingsState();
}

class _BidOutMeetingsState extends ConsumerState<BidOutMeetings> {
  ScrollController controller = ScrollController();

  MeetingHistoryModel? meetingHistoryModel;

  @override
  void initState() {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      ref.read(meetingHistory).getMeetingHistoryList(
          MeetingDataModel(uId: widget.uid, page: 10, userAorB: 'B'));
    });
    controller.addListener(_scrollListener);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    meetingHistoryModel = ref.watch(meetingHistory);
    if (haveToWait(meetingHistoryModel)) {
      return Center(child: WaitPage());
    }
    List<Meeting?> meetingListB = meetingHistoryModel?.meetingHistoryList ?? [];

    if (meetingListB.isEmpty && !(meetingHistoryModel?.isRequesting ?? false)) {
      return Center(
          child: Text(
        Keys.noMeetingsFound.tr(context),
        style: Theme.of(context).textTheme.subtitle1,
      ));
    }

    return ListView(
      controller: controller,
      shrinkWrap: true,
      primary: false,
      children: [
        ListView.builder(
          itemCount: meetingListB.length,
          shrinkWrap: true,
          primary: false,
          padding: const EdgeInsets.symmetric(vertical: 10),
          itemBuilder: (BuildContext context, int index) {
            Meeting? meetingModel = meetingListB[index];
            if (meetingModel == null) {
              return Container();
            }
            bool amA = meetingModel.A == widget.uid;

            return MeetingHistoryTile(
              currentUid: widget.uid,
              meetingModel: meetingModel,
              onTap: () =>
                  context.pushNamed(Routes.user.nameFromPath(), params: {
                    'uid': amA ? meetingModel.B : meetingModel.A,
                  }),
            );
          },
        ),
        meetingHistoryModel?.isRequesting ?? false
            ? Container(
                width: MediaQuery.of(context).size.width,
                height: kToolbarHeight,
                padding: EdgeInsets.all(5),
                color: Colors.transparent,
                alignment: Alignment.center,
                child: Text(
                  Keys.loading.tr(context),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : Container()
      ],
    );
  }

  void _scrollListener() {
    double maxScroll = controller.position.maxScrollExtent;
    double currentScroll = controller.position.pixels;
    double delta = MediaQuery.of(context).size.height * 0.20;
    if (maxScroll - currentScroll <= delta && !(meetingHistoryModel?.isRequesting ?? false)) {
      ref.read(meetingHistory).getMeetingHistoryList(MeetingDataModel(
          uId: widget.uid,
          page: 10,
          userAorB: 'B',
          lastDocument: meetingHistoryModel?.lastDocument));
    }
  }
}
