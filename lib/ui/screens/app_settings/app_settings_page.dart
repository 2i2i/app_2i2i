import 'package:app_2i2i/infrastructure/commons/utils.dart';
import 'package:app_2i2i/ui/commons/custom.dart';

import 'package:app_2i2i/ui/screens/app_settings/theme_mode_screen.dart';
import 'package:app_2i2i/ui/screens/block_and_friends/friends_list_page.dart';
import 'package:app_2i2i/ui/screens/home/wait_page.dart';
import 'package:app_2i2i/ui/screens/qr_code/widgets/qr_image.dart';
import 'package:app_2i2i/ui/screens/hangout_setting/hangout_setting.dart';
import 'package:flutter/foundation.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:share_plus/share_plus.dart';

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
    final message = 'https://test.2i2i.app/user/$uid';
    var appSettingModel = ref.watch(appSettingProvider);

    return Scaffold(

      body: SingleChildScrollView(
        padding: EdgeInsets.only(right: 30,left: 30, bottom: 10,top: kIsWeb?10:31),
        // padding: const EdgeInsets.symmetric(horizontal: 30,vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 5),
            Text(
              'Settings',
              style: Theme.of(context).textTheme.headline5,
            ),
            SizedBox(height: 15),
            Text(
              'QR code',
              style: Theme.of(context).textTheme.subtitle1,
            ),
            SizedBox(height: 12),
            Container(
              decoration: Custom.getBoxDecoration(context),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 20.0),
                child: Column(
                  children: [
                    Text(
                      Strings().shareQr,
                      style: Theme.of(context).textTheme.bodyText1,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    QrWidget(
                      message: message,
                      logoSize: 54,
                      imageSize: 180,
                    ),
                    SizedBox(height: 16),
                    Container(
                      height: 40,
                      decoration: BoxDecoration(
                        // color: Color(0xffF3F3F7),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          width: 0.5,
                          color: Theme.of(context).iconTheme.color??Colors.transparent
                        )
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        message,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.caption?.copyWith(
                              decoration: TextDecoration.underline,
                            ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(
                                  text: message,
                                ),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Copied Link!')),
                              );
                            },
                            child: Text('Copy'),
                          ),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Share.share(
                                  'Your friend and invite for join 2i2i\n$message');
                            },
                            child: Text('Share'),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            //profile
            Text(
              'Profile',
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

            //others
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
                    title: Text(
                      'Favorites',
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    trailing: Icon(
                      Icons.navigate_next,
                    ),
                    // onTap: () => context.pushNamed(Routes.favorites),
                    onTap: () => context.pushNamed(Routes.favorites.nameFromPath()),
                  ),
                  ListTile(
                    onTap: () => context.pushNamed(Routes.blocks.nameFromPath()),
                    title: Text(
                      'Blocked users',
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
            /*Text(Strings().selectNetworkMode,
                style: Theme.of(context)
                    .textTheme
                    .subtitle1!
                    .copyWith(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                  ),
                  child: DropdownButton(
                    isExpanded: true,
                    focusColor: Colors.transparent,
                    underline: Container(),
                    value: _value,
                    borderRadius: BorderRadius.circular(10),
                    items: List.generate(
                        networkList.length,
                        (index) => DropdownMenuItem(
                              child: Text(networkList[index]),
                              value: index,
                            )),
                    onChanged: (int? value) async {
                      setState(() {
                        _value = value!;
                      });
                      await algorand
                          .setNetworkMode(networkList[_value].toString());
                    },
                  ),
                ),
              ),
            ),
            Divider(),
            SizedBox(height: 8),
            SignOutButton(),*/
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
