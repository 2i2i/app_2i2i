import 'package:app_2i2i/infrastructure/commons/utils.dart';
import 'package:app_2i2i/infrastructure/providers/all_providers.dart';
import 'package:app_2i2i/infrastructure/routes/app_routes.dart';
import 'package:app_2i2i/ui/commons/custom_navigation.dart';
import 'package:app_2i2i/ui/screens/home/wait_page.dart';
import 'package:app_2i2i/ui/screens/user_bid/user_page.dart';
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

    return ListView.builder(

      itemCount: topMeetings.length,
      padding: EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (BuildContext context, int index) => Card(
        child: ListTile(
          contentPadding: EdgeInsets.all(8),
          onTap: () {
            CustomNavigation.push(context, UserPage(uid: topMeetings[index].B), Routes.USER);
          },
          title: Row(
            children: [
              SizedBox(width: 8),
              Expanded(
                child: Row(
                  children: [
                    SizedBox(width: 8),
                    Text(topMeetings[index].name,
                        style: Theme.of(context).textTheme.subtitle1!.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme().tabTextColor)),
                  ],
                ),
              ),
              Text(secondsToSensibleTimePeriod(topMeetings[index].duration),
                  style: Theme.of(context)
                      .textTheme
                      .subtitle2!
                      .copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
      // separatorBuilder: (BuildContext context, int index) => Divider(),
    );
  }
}
