import 'package:app_2i2i/infrastructure/providers/all_providers.dart';
import 'package:app_2i2i/ui/screens/home/wait_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../infrastructure/commons/theme.dart';
import '../../../commons/custom_profile_image_view.dart';

class HighestSpeedPage extends ConsumerStatefulWidget {
  const HighestSpeedPage({Key? key}) : super(key: key);

  @override
  _HighestSpeedPageState createState() => _HighestSpeedPageState();
}

class _HighestSpeedPageState extends ConsumerState<HighestSpeedPage> {
  @override
  Widget build(BuildContext context) {
    final meeting = ref.watch(topMeetingProvider(""));
    if (meeting is AsyncLoading || meeting is AsyncError) return WaitPage();
    return ListView.separated(
      itemCount: 10,
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
                      text: "name",
                      statusColor: Colors.green,
                      hideShadow: true,
                      radius: kToolbarHeight + 6,
                      style: Theme.of(context).textTheme.headline5!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme().tabTextColor)),
                  SizedBox(width: 8),
                  Text('Guy Hawkins'.toUpperCase(),
                      style: Theme.of(context).textTheme.headline6!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme().tabTextColor)),
                ],
              ),
            ),
            Text('${index * 100}'.toUpperCase(),
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
