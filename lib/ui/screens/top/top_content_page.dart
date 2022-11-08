import 'package:app_2i2i/infrastructure/commons/utils.dart';
import 'package:app_2i2i/infrastructure/models/fx_model.dart';
import 'package:app_2i2i/infrastructure/models/meeting_model.dart';
import 'package:app_2i2i/infrastructure/providers/all_providers.dart';
import 'package:app_2i2i/infrastructure/routes/app_routes.dart';
import 'package:app_2i2i/ui/screens/app/wait_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class TopContentPage extends ConsumerStatefulWidget {
  const TopContentPage({Key? key, required this.topProvider, required this.statFn}) : super(key: key);

  final StreamProvider<List<TopMeeting>> topProvider;
  final String Function(TopMeeting, FXModel) statFn;

  @override
  _TopContentPageState createState() => _TopContentPageState();
}

class _TopContentPageState extends ConsumerState<TopContentPage> {
  @override
  Widget build(BuildContext context) {
    // log(I + '_TopContentPageState, build');

    final topMeetingsAsyncValue = ref.watch(widget.topProvider);
    if (haveToWait(topMeetingsAsyncValue)) {
      return WaitPage();
    }
    if (topMeetingsAsyncValue.value == null) return WaitPage();
    final topMeetings = topMeetingsAsyncValue.value!;

    return ListView.builder(
      itemCount: topMeetings.length,
      padding: EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (BuildContext context, int index) {
        final meeting = topMeetings[index];
        // log(I + '_TopContentPageState, index=$index meeting=$meeting meeting.nameB=${meeting.nameB} meeting.speed.assetId=${meeting.speed.assetId} meeting.speed.num=${meeting.speed.num} meeting.duration=${meeting.duration} meeting.FX=${meeting.FX}');

        FXModel FXValue = FXModel.ALGO();
        if (meeting.speed.assetId != 0) {
          final FXValueTmp = ref.watch(FXProvider(meeting.speed.assetId)).value;
          if (haveToWait(FXValueTmp)) {
            return Container();
          }
          FXValue = FXValueTmp!;
        }

        return Card(
          child: ListTile(
            contentPadding: EdgeInsets.all(8),
            onTap: () {
              context.pushNamed(Routes.user.nameFromPath(), params: {'uid': meeting.B});
            },
            title: Row(
              children: [
                SizedBox(width: 8),
                Expanded(
                  child: Row(
                    children: [
                      SizedBox(width: 8),
                      Text(
                        meeting.nameB,
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                    ],
                  ),
                ),
                Text('${widget.statFn(meeting, FXValue)}', style: Theme.of(context).textTheme.subtitle2),
              ],
            ),
          ),
        );
      },
    );
  }
}
