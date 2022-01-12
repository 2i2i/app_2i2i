import 'package:app_2i2i/infrastructure/commons/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'widgets/top_speeds_page.dart';
import 'widgets/top_durations_page.dart';

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
    controller = new TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                SvgPicture.asset(
                  'assets/icons/hip_logo.svg',
                  height: MediaQuery.of(context).size.height * 0.18,
                  width: MediaQuery.of(context).size.height * 0.18,
                ),
                Text('Who’s Top?'.toUpperCase(),
                    style: Theme.of(context)
                        .textTheme
                        .headline5!
                        .copyWith(fontWeight: FontWeight.bold)),
                Container(
                  margin: EdgeInsets.only(top: 20),
                  decoration: BoxDecoration(
                      color: AppTheme().tabColor,
                      borderRadius: BorderRadius.circular(10)),
                  padding: EdgeInsets.all(2),
                  child: TabBar(
                    unselectedLabelColor:
                        Theme.of(context).tabBarTheme.unselectedLabelColor,
                    labelColor:
                        Theme.of(context).tabBarTheme.unselectedLabelColor,
                    indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: Theme.of(context).primaryColorLight),
                    tabs: [
                      Container(
                          child: Tab(
                            text: 'Top Speeds',
                          ),
                          height: kRadialReactionRadius + 12),
                      Container(
                          child: Tab(
                            text: 'Top Durations',
                          ),
                          height: kRadialReactionRadius + 12),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      TopSpeedsPage(),
                      TopDurationsPage(),
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
