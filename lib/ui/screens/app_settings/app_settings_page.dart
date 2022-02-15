import 'package:app_2i2i/infrastructure/commons/utils.dart';
import 'package:app_2i2i/ui/commons/custom.dart';
import 'package:app_2i2i/ui/commons/custom_app_bar.dart';
import 'package:app_2i2i/ui/screens/home/wait_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../infrastructure/commons/keys.dart';
import '../../../infrastructure/providers/all_providers.dart';
import '../../../infrastructure/routes/app_routes.dart';

class AppSettingPage extends ConsumerStatefulWidget {
  @override
  _AppSettingPageState createState() => _AppSettingPageState();
}

class _AppSettingPageState extends ConsumerState<AppSettingPage>
    with TickerProviderStateMixin {
  List<String> networkList = ["Main", "Test", "Both"];

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(myUIDProvider);
    var appSettingModel = ref.watch(appSettingProvider);
    if (uid == null) return WaitPage();
    final user = ref.watch(userProvider(uid));
    if (haveToWait(user)) {
      return WaitPage();
    }

    return Scaffold(
      appBar: CustomAppbar(
        title: Text(
          Keys.settings.tr(context),
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
              Keys.account.tr(context),
              style: Theme.of(context).textTheme.subtitle1,
            ),
            SizedBox(height: 12),
            Container(
              decoration: Custom.getBoxDecoration(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ListTile(
                    onTap: () {
                      context.pushNamed(Routes.userSetting.nameFromPath());
                    },
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          Keys.userName.tr(context) + ' ',
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                        Flexible(
                          child: Text(
                            user.value?.name ?? '',
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
                    onTap: () {
                      context.pushNamed(Routes.userSetting.nameFromPath());
                    },
                    title: Text(
                      Keys.bio.tr(context),
                      style: Theme.of(context).textTheme.subtitle1,
                      textAlign: TextAlign.start,
                    ),
                    trailing: Icon(Icons.navigate_next),
                  ),
                  ListTile(
                    onTap: () {
                      context.pushNamed(Routes.account.nameFromPath());
                    },
                    title: Text(
                      Keys.wallet.tr(context),
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
                    onTap: () =>
                        context.pushNamed(Routes.blocks.nameFromPath()),
                    title: Text(
                      Keys.blockList.tr(context),
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    trailing: Icon(
                      Icons.navigate_next,
                    ),
                  ),
                  ListTile(
                    onTap: () =>
                        context.pushNamed(Routes.meetingHistory.nameFromPath()),
                    title: Text(
                      Keys.meetingsHistory.tr(context),
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
              Keys.theme.tr(context),
              style: Theme.of(context).textTheme.subtitle1,
            ),
            SizedBox(height: 12),
            Consumer(
              builder: (BuildContext context, WidgetRef ref, Widget? child) {
                var appSettingModel = ref.watch(appSettingProvider);
                int selectedIndex = 0;
                if (appSettingModel.currentThemeMode == ThemeMode.system) {
                  selectedIndex = 2;
                } else if (appSettingModel.currentThemeMode == ThemeMode.dark) {
                  selectedIndex = 1;
                }
                return Container(
                  decoration: Custom.getBoxDecoration(context),
                  child: TabBar(
                    controller: TabController(
                        length: 3, vsync: this, initialIndex: selectedIndex),
                    indicatorPadding: EdgeInsets.all(3),
                    indicator: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    unselectedLabelColor:
                        Theme.of(context).tabBarTheme.unselectedLabelColor,
                    labelColor:
                        Theme.of(context).tabBarTheme.unselectedLabelColor,
                    tabs: [
                      Tab(
                        text: Keys.light.tr(context),
                      ),
                      Tab(
                        text: Keys.dark.tr(context),
                      ),
                      Tab(
                        text: Keys.auto.tr(context),
                      ),
                    ],
                    onTap: (index) {
                      switch (index) {
                        case 0:
                          appSettingModel.setThemeMode(Keys.light);
                          break;
                        case 1:
                          appSettingModel.setThemeMode(Keys.dark);
                          break;
                        case 2:
                          appSettingModel.setThemeMode(Keys.auto);
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
              Keys.more.tr(context),
              style: Theme.of(context).textTheme.subtitle1,
            ),
            SizedBox(height: 12),
            Container(
              decoration: Custom.getBoxDecoration(context),
              child: Column(
                children: [
                  ListTile(
                    onTap: () =>
                        context.pushNamed(Routes.language.nameFromPath()),
                    title: Text(
                      Keys.language.tr(context),
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    trailing: Text(
                        (appSettingModel.locale?.languageCode ?? 'EN')
                            .toUpperCase()),
                  ),
                  ListTile(
                    onTap: () => context.pushNamed(Routes.faq.nameFromPath()),
                    title: Text(
                      Keys.faq.tr(context),
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
                          Keys.aboutPageUrl.tr(context),
                          forceSafariVC: true,
                          forceWebView: true,
                        );
                      } catch (e) {
                        print(e);
                      }
                    },
                    title: Text(
                      Keys.about.tr(context),
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
}
