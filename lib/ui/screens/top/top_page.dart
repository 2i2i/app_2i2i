import 'dart:math';
import 'package:app_2i2i/infrastructure/commons/theme.dart';
import 'package:app_2i2i/infrastructure/commons/utils.dart';
import 'package:app_2i2i/infrastructure/models/fx_model.dart';
import 'package:app_2i2i/infrastructure/models/meeting_model.dart';
import 'package:app_2i2i/infrastructure/providers/all_providers.dart';
import 'package:app_2i2i/ui/screens/top/top_content_page.dart';
import 'package:flutter/material.dart';
import '../../../infrastructure/commons/keys.dart';

class TopPage extends StatefulWidget {
  const TopPage({Key? key}) : super(key: key);

  @override
  _TopPageState createState() => _TopPageState();
}

class _TopPageState extends State<TopPage> with SingleTickerProviderStateMixin {
  TabController? controller;

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 2, vsync: this);
  }

  String valueStat(TopMeeting meeting, FXModel FXValue) => '${meeting.speed.num * meeting.duration / pow(10, FXValue.decimals)} ${FXValue.getName}';
  String speedStat(TopMeeting meeting, FXModel FXValue) => '${meeting.speed.num / pow(10, FXValue.decimals)} ${FXValue.getName}/sec';
  String durationStat(TopMeeting meeting, FXModel FXValue) => secondsToSensibleTimePeriod(meeting.duration, context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Image.asset(
                  'assets/icons/hip_logo_p.png',
                  height: MediaQuery.of(context).size.height * 0.18,
                  width: MediaQuery.of(context).size.height * 0.18,
                ),
                Text(
                  Keys.whoTop.tr(context).toUpperCase(),
                  style: Theme.of(context).textTheme.headline5?.copyWith(color: AppTheme().lightSecondaryTextColor),
                ),
                Container(
                  margin: EdgeInsets.only(top: 20),
                  decoration: BoxDecoration(color: AppTheme().tabColor, borderRadius: BorderRadius.circular(10)),
                  padding: EdgeInsets.all(2),
                  child: TabBar(
                    unselectedLabelColor: Theme.of(context).tabBarTheme.unselectedLabelColor,
                    labelColor: Theme.of(context).tabBarTheme.unselectedLabelColor,
                    indicator: BoxDecoration(borderRadius: BorderRadius.circular(10.0), color: Theme.of(context).primaryColorLight),
                    tabs: [
                      Container(
                          child: Tab(
                            text: Keys.topValues.tr(context),
                          ),
                          height: kRadialReactionRadius + 12),
                      Container(
                          child: Tab(
                            text: Keys.topSpeeds.tr(context),
                          ),
                          height: kRadialReactionRadius + 12),
                      Container(
                          child: Tab(
                            text: Keys.topDurations.tr(context),
                          ),
                          height: kRadialReactionRadius + 12),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      TopContentPage(statFn: valueStat, topProvider: topValuesProvider,),
                      TopContentPage(statFn: speedStat, topProvider: topSpeedsProvider,),
                      TopContentPage(statFn: durationStat, topProvider: topDurationsProvider,),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
