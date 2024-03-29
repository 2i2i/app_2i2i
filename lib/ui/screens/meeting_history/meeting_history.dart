import 'package:app_2i2i/infrastructure/commons/keys.dart';
import 'package:app_2i2i/infrastructure/commons/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../infrastructure/providers/all_providers.dart';
import '../../commons/custom.dart';
import 'widgets/bid_in_meetings.dart';
import 'widgets/bid_out_meetings.dart';

class MeetingHistory extends ConsumerStatefulWidget {
  @override
  _MeetingHistoryState createState() => _MeetingHistoryState();
}

class _MeetingHistoryState extends ConsumerState<MeetingHistory> with TickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _tabController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(myUIDProvider)!;
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 10),
            Text(
              Keys.meetingsHistory.tr(context),
              style: Theme.of(context).textTheme.headline5,
            ),
            SizedBox(height: kRadialReactionRadius),
            Container(
              decoration: Custom.getBoxDecoration(context),
              child: TabBar(
                controller: _tabController,
                indicatorPadding: EdgeInsets.all(3),
                indicator: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.circular(8),
                ),
                onTap: (int index) => ref.read(meetingHistory).onDisposeList(),
                unselectedLabelColor: Theme.of(context).tabBarTheme.unselectedLabelColor,
                labelColor: Theme.of(context).tabBarTheme.unselectedLabelColor,
                tabs: [
                  Tab(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Text(Keys.asHost.tr(context).toUpperCase()), SizedBox(width: 8), Icon(Icons.call_received_rounded, color: AppTheme().green)],
                    ),
                  ),
                  Tab(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Text(Keys.asGuest.tr(context).toUpperCase()), SizedBox(width: 8), Icon(Icons.call_made_rounded, color: AppTheme().red)],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  BidOutMeetings(uid: uid),
                  BidInMeetings(uid: uid),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
