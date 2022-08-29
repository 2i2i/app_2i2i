import 'package:app_2i2i/infrastructure/commons/keys.dart';
import 'package:app_2i2i/infrastructure/commons/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../infrastructure/providers/all_providers.dart';
import '../../commons/custom.dart';
import '../../commons/custom_app_bar_web.dart';
import 'widgets/bid_in_meetings.dart';
import 'widgets/bid_out_meetings.dart';

class MeetingHistoryWeb extends ConsumerStatefulWidget {
  @override
  _MeetingHistoryState createState() => _MeetingHistoryState();
}

class _MeetingHistoryState extends ConsumerState<MeetingHistoryWeb> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(myUIDProvider)!;
    return Scaffold(
      appBar: CustomAppbarWeb(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: kRadialReactionRadius - 10),
          Text(
            Keys.meetingsHistory.tr(context),
            style: Theme.of(context).textTheme.headline5,
          ),
          SizedBox(height: MediaQuery.of(context).size.height / 25),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width / 35),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          height: kRadialReactionRadius * 2.2,
                          decoration: Custom.getBoxDecoration(context),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(Keys.asHost.tr(context).toUpperCase()),
                              SizedBox(width: 8),
                              Icon(Icons.call_received_rounded, color: AppTheme().green),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height / 3,
                        ),
                        BidOutMeetings(uid: uid),
                      ],
                    ),
                  ),
                  Container(
                    width: kToolbarHeight * 4,
                    height: MediaQuery.of(context).size.height,
                    child: VerticalDivider(),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          height: kRadialReactionRadius * 2.2,
                          decoration: Custom.getBoxDecoration(context),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(Keys.asGuest.tr(context).toUpperCase()),
                              SizedBox(width: 8),
                              Icon(Icons.call_made_rounded, color: AppTheme().red),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height / 3,
                        ),
                        BidInMeetings(uid: uid),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
