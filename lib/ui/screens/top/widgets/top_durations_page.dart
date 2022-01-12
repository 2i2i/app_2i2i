import 'package:app_2i2i/infrastructure/commons/utils.dart';
import 'package:app_2i2i/infrastructure/providers/all_providers.dart';
import 'package:app_2i2i/ui/screens/home/wait_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../infrastructure/commons/theme.dart';

class TopDurationsPage extends ConsumerStatefulWidget {
  const TopDurationsPage({Key? key}) : super(key: key);

  @override
  _TopDurationsPageState createState() => _TopDurationsPageState();
}

class _TopDurationsPageState extends ConsumerState<TopDurationsPage> {
  @override
  Widget build(BuildContext context) {
    final topMeetingsAsyncValue = ref.watch(topDurationsProvider);
    if (topMeetingsAsyncValue is AsyncLoading ||
        topMeetingsAsyncValue is AsyncError) return WaitPage();
    final topMeetings = topMeetingsAsyncValue.value!;

    return ListView.separated(
      itemCount: topMeetings.length,
      padding: EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (BuildContext context, int index) => ListTile(
        title: Row(
          children: [
            SizedBox(width: 8),
            Expanded(
              child: Row(
                children: [
                  SizedBox(width: 8),
                  Text(topMeetings[index].name,
                      style: Theme.of(context).textTheme.headline6!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme().tabTextColor)),
                ],
              ),
            ),
            Text(secondsToSensibleTimePeriod(topMeetings[index].duration),
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
