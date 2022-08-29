import 'package:flutter/material.dart';
import '../../../infrastructure/commons/keys.dart';
import '../../commons/custom.dart';
import 'widgets/top_speeds_page.dart';
import 'widgets/top_durations_page.dart';

class TopPageWeb extends StatefulWidget {
  const TopPageWeb({Key? key}) : super(key: key);

  @override
  _TopPageWebState createState() => _TopPageWebState();
}

class _TopPageWebState extends State<TopPageWeb> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: CustomAppbarHolder(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Image.asset(
            'assets/icons/hip_logo_p.png',
            fit: BoxFit.contain,
            height: MediaQuery.of(context).size.height * 0.14,
            width: MediaQuery.of(context).size.height * 0.14,
          ),
          Text(
            Keys.whoTop.tr(context).toUpperCase(),
            style: Theme.of(context).textTheme.headline5,
          ),
          SizedBox(height: MediaQuery.of(context).size.height /30),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width / 35),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          decoration: Custom.getBoxDecoration(context),
                          height: MediaQuery.of(context).size.height / 20,
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  Keys.topSpeeds.tr(context).toUpperCase(),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Icon(Icons.call_made,size: 22,color: Theme.of(context).colorScheme.secondary,),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height / 55,
                        ),
                        Expanded(child: Padding(
                          padding: const EdgeInsets.only(bottom: 30),
                          child: TopSpeedsPage(),
                        )),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 9,
                    child: VerticalDivider(),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.height / 20,
                          decoration: Custom.getBoxDecoration(context),
                          child: Center(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  Keys.topDurations.tr(context).toUpperCase(),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Icon(Icons.access_time,size: 20,color: Theme.of(context).colorScheme.secondary,)
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height / 55,
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 30),
                            child: TopDurationsPage(),
                          ),
                        ),
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
