import 'package:app_2i2i/infrastructure/providers/all_providers.dart';
import 'package:app_2i2i/ui/screens/home/wait_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../infrastructure/commons/theme.dart';
import '../../../commons/custom_profile_image_view.dart';

class TopSpeedsPage extends ConsumerStatefulWidget {
  const TopSpeedsPage({Key? key}) : super(key: key);

  @override
  _TopSpeedsPageState createState() => _TopSpeedsPageState();
}

class _TopSpeedsPageState extends ConsumerState<TopSpeedsPage> {
  @override
  Widget build(BuildContext context) {
    final topMeetingsAsyncValue = ref.watch(topSpeedsProvider);
    if (topMeetingsAsyncValue is AsyncLoading ||
        topMeetingsAsyncValue is AsyncError) return WaitPage();
    final topMeetings = topMeetingsAsyncValue.value!;

    return ListView.separated(
      itemCount: topMeetings.length,
      padding: EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (BuildContext context, int index) => ListTile(
        title: Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: AppTheme().tabColor,
              child: Text(
                '$index',
                style: Theme.of(context).textTheme.bodyText2!.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).disabledColor),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: Row(
                children: [
                  TextProfileView(
                      text: topMeetings[index].name,
                      statusColor: Colors.green,
                      hideShadow: true,
                      radius: kToolbarHeight + 6,
                      style: Theme.of(context).textTheme.headline5!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme().tabTextColor)),
                  SizedBox(width: 8),
                  Text(topMeetings[index].name,
                      style: Theme.of(context).textTheme.headline6!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme().tabTextColor)),
                ],
              ),
            ),
            Text('${topMeetings[index].speed.num} μALGO/sec',
                style: Theme.of(context)
                    .textTheme
                    .headline5!
                    .copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      separatorBuilder: (BuildContext context, int index) => Divider(),
    );
  }
}
