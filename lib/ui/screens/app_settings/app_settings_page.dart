import 'package:app_2i2i/infrastructure/commons/utils.dart';
import 'package:app_2i2i/ui/commons/custom.dart';
import 'package:app_2i2i/ui/commons/custom_app_bar.dart';
import 'package:app_2i2i/ui/screens/home/wait_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../infrastructure/commons/strings.dart';
import '../../../infrastructure/providers/all_providers.dart';
import '../../../infrastructure/routes/app_routes.dart';

class AppSettingPage extends ConsumerStatefulWidget {
  @override
  _AppSettingPageState createState() => _AppSettingPageState();
}

class _AppSettingPageState extends ConsumerState<AppSettingPage> with TickerProviderStateMixin{
  List<String> networkList = ["Main", "Test", "Both"];

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(myUIDProvider);
    if (uid == null) return WaitPage();
    final hangout = ref.watch(hangoutProvider(uid));
    if (haveToWait(hangout)) {
      return WaitPage();
    }

    return Scaffold(
      appBar: CustomAppbar(
        title: Text(
          Strings().settings,
          style: Theme.of(context).textTheme.headline5,
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 30),
        // padding: const EdgeInsets.symmetric(horizontal: 30,vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            //profile
            Text(
              Strings().account,
              style: Theme.of(context).textTheme.subtitle1,
            ),
            SizedBox(height: 12),
            Container(
              decoration: Custom.getBoxDecoration(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ListTile(
                    onTap: (){
                      context.pushNamed(Routes.hangoutSetting.nameFromPath());
                    },
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          Strings().userName+' ',
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                        Flexible(
                          child: Text(
                            hangout.value?.name ?? '',
                            style: Theme.of(context).textTheme.subtitle1,
                            softWrap: false,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                    trailing: Icon(
                      Icons.navigate_next,
                    ),
                  ),
                  ListTile(
                    onTap: (){
                      context.pushNamed(Routes.hangoutSetting.nameFromPath());
                    },
                    title: Text(
                      Strings().bio,
                      style: Theme.of(context).textTheme.subtitle1,
                      textAlign: TextAlign.start,
                    ),
                    trailing: Icon(Icons.navigate_next),
                  ),
                  ListTile(
                    onTap: (){
                      context.pushNamed(Routes.account.nameFromPath());
                    },
                    title: Text(
                      Strings().wallet,
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    trailing: Icon(
                      Icons.navigate_next,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            //others

            Container(
              decoration: Custom.getBoxDecoration(context),
              child: Column(
                children: [
                  ListTile(
                    onTap: () => context.pushNamed(Routes.blocks.nameFromPath()),
                    title: Text(
                      Strings().blockList,
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    trailing: Icon(
                      Icons.navigate_next,
                    ),
                  ),
                  ListTile(
                    onTap: () => context.pushNamed(Routes.meetingHistory.nameFromPath()),
                    title: Text(
                      Strings().meetingsHistory,
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    trailing: Icon(
                      Icons.navigate_next,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            //theme
            Text(
              'Theme',
              style: Theme.of(context).textTheme.subtitle1,
            ),
            SizedBox(height: 12),
            Consumer(
              builder: (BuildContext context, WidgetRef ref, Widget? child) {
                var appSettingModel = ref.watch(appSettingProvider);
                int selectedIndex = 0;
                if(appSettingModel.currentThemeMode == ThemeMode.system){
                  selectedIndex = 2;
                }else if(appSettingModel.currentThemeMode == ThemeMode.dark){
                  selectedIndex = 1;
                }
                return Container(
                  decoration: Custom.getBoxDecoration(context),
                  child: TabBar(
                    controller: TabController(length: 3, vsync: this,initialIndex: selectedIndex),
                    indicatorPadding: EdgeInsets.all(3),
                    indicator: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    unselectedLabelColor: Theme.of(context).tabBarTheme.unselectedLabelColor,
                    labelColor: Theme.of(context).tabBarTheme.unselectedLabelColor,
                    tabs: [
                      Tab(
                        text: 'Light',
                      ),
                      Tab(
                        text: 'Dark',
                      ),
                      Tab(
                        text: 'Auto',
                      ),
                    ],
                    onTap: (index){
                      switch (index) {
                        case 0:
                          appSettingModel.setThemeMode("LIGHT");
                          break;
                        case 1:
                          appSettingModel.setThemeMode("DARK");
                          break;
                        case 2:
                          appSettingModel.setThemeMode("AUTO");
                          break;
                      }
                    },
                  ),
                );
              },
            ),
            SizedBox(height: 20),

            //link
            Text(
              'Others',
              style: Theme.of(context).textTheme.subtitle1,
            ),
            SizedBox(height: 12),
            Container(
              decoration: Custom.getBoxDecoration(context),
              child: Column(
                children: [
                  ListTile(
                    onTap: () => context.pushNamed(Routes.faq.nameFromPath()),
                    title: Text(
                      Strings().faq,
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    trailing: Icon(
                      Icons.navigate_next,
                    ),
                  ),
                  ListTile(
                    onTap: () async {
                      try {
                        await launch(
                          Strings().aboutPageUrl,
                          forceSafariVC: true,
                          forceWebView: true,
                        );
                      } catch (e) {
                        print(e);
                      }
                    },
                    title: Text(
                      Strings().about,
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    trailing: Icon(
                      Icons.navigate_next,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            //lgout
            /*Text(
              'Logout',
              style: Theme.of(context).textTheme.subtitle1,
            ),
            SizedBox(height: 12),
            Container(
              decoration: Custom.getBoxDecoration(context),
              child: ListTile(
                onTap: (){
                  FirebaseAuth.instance.signOut();
                },
                leading: Icon(
                  Icons.logout,
                  color: Theme.of(context).errorColor,
                ),
                title: Text(
                  'Logout',
                  style: Theme.of(context)
                      .textTheme
                      .subtitle1
                      ?.copyWith(color: Theme.of(context).errorColor),
                ),
                trailing: Icon(
                  Icons.navigate_next,
                ),
              ),
            ),*/
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  String getThemeModeName(ThemeMode? currentThemeMode) {
    if (currentThemeMode == ThemeMode.dark) {
      return 'Dark Mode';
    }
    return 'Light Mode';
  }
}
