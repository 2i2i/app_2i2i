import 'package:app_2i2i/infrastructure/providers/all_providers.dart';
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
    // if (topMeetingsAsyncValue is AsyncLoading || topMeetingsAsyncValue is AsyncError) return WaitPage();
    // final topMeetings = topMeetingsAsyncValue.value!;

    return ListView.separated(
      itemCount: 5, //topMeetings.length,
      padding: EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (BuildContext context, int index) => ListTile(
        title: Text(
          'Chandresh', //topMeetings[index].name,
        ),
        trailing: Text(
          '100 μALGO/s', //'${topMeetings[index].speed.num} μALGO/s',
          style: Theme.of(context).textTheme.headline3,
        ),
      ),
      separatorBuilder: (BuildContext context, int index) => Divider(),
    );
  }
}
