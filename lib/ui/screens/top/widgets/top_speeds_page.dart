import 'package:app_2i2i/infrastructure/models/bid_model.dart';
import 'package:app_2i2i/infrastructure/models/meeting_model.dart';
import 'package:app_2i2i/infrastructure/providers/all_providers.dart';
import 'package:app_2i2i/infrastructure/routes/app_routes.dart';
import 'package:app_2i2i/ui/commons/custom_navigation.dart';
import 'package:app_2i2i/ui/screens/home/wait_page.dart';
import 'package:app_2i2i/ui/screens/user_bid/user_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../infrastructure/commons/theme.dart';

class TopSpeedsPage extends ConsumerStatefulWidget {
  const TopSpeedsPage({Key? key}) : super(key: key);

  @override
  _TopSpeedsPageState createState() => _TopSpeedsPageState();
}

class _TopSpeedsPageState extends ConsumerState<TopSpeedsPage> {
  @override
  Widget build(BuildContext context) {
    final topMeetingsAsyncValue = ref.watch(topSpeedsProvider);
    if (topMeetingsAsyncValue is AsyncLoading || topMeetingsAsyncValue is AsyncError) return WaitPage();
    final topMeetings = topMeetingsAsyncValue.value!;

    return ListView.builder(
      itemCount: topMeetings.length,
      padding: EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (BuildContext context, int index) 
      {
        TopMeeting meeting=topMeetings[index];
        return Card(
          child: ListTile(
            contentPadding: EdgeInsets.all(8),
            onTap: () {
              CustomNavigation.push(
                  context, UserPage(uid: meeting.B), Routes.USER);
            },
            title: Row(
              children: [
                SizedBox(width: 8),
                Expanded(
                  child: Row(
                    children: [
                      SizedBox(width: 8),
                      Text(meeting.name,
                          style: Theme.of(context)
                              .textTheme
                              .subtitle1,
                      ),
                    ],
                  ),
                ),
                Text('${meeting.speed.num} μALGO/s',
                    style: Theme.of(context)
                        .textTheme
                        .subtitle2),
              ],
            ),
          ),
        );
      },
    );
  }
}
