import 'package:app_2i2i/infrastructure/commons/utils.dart';
import 'package:app_2i2i/infrastructure/models/meeting_model.dart';
import 'package:app_2i2i/infrastructure/providers/all_providers.dart';
import 'package:app_2i2i/infrastructure/routes/app_routes.dart';
import 'package:app_2i2i/ui/commons/custom_navigation.dart';
import 'package:app_2i2i/ui/screens/home/wait_page.dart';
import 'package:app_2i2i/ui/screens/user_info/user_info_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';


class TopDurationsPage extends ConsumerStatefulWidget {
  const TopDurationsPage({Key? key}) : super(key: key);

  @override
  _TopDurationsPageState createState() => _TopDurationsPageState();
}

class _TopDurationsPageState extends ConsumerState<TopDurationsPage> {
  @override
  Widget build(BuildContext context) {
    final topMeetingsAsyncValue = ref.watch(topDurationsProvider);
    if (haveToWait(topMeetingsAsyncValue)) {
      return WaitPage();
    }
    if(topMeetingsAsyncValue.value is List) {
      final topMeetings = topMeetingsAsyncValue.value!;
      return ListView.builder(
        itemCount: topMeetings.length,
        padding: EdgeInsets.symmetric(vertical: 8),
        itemBuilder: (BuildContext context, int index) {
          TopMeeting meeting = topMeetings[index];
          return Card(
            child: ListTile(
              contentPadding: EdgeInsets.all(8),
              onTap: () {
                context.pushNamed(Routes.user.nameFromPath(),params: {'uid':meeting.B});
              },
              title: Row(
                children: [
                  SizedBox(width: 8),
                  Expanded(
                    child: Row(
                      children: [
                        SizedBox(width: 8),
                        Text(
                          meeting.name,
                          style: Theme
                              .of(context)
                              .textTheme
                              .subtitle1,
                        ),
                      ],
                    ),
                  ),
                  Text(secondsToSensibleTimePeriod(meeting.duration),
                      style: Theme
                          .of(context)
                          .textTheme
                          .subtitle2,
                  ),
                ],
              ),
            ),
          );
        },
        // separatorBuilder: (BuildContext context, int index) => Divider(),
      );
    }
    return WaitPage();
  }
}
