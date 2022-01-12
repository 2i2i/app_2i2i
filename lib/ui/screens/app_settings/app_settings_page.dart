import 'package:app_2i2i/ui/commons/custom.dart';
import 'package:app_2i2i/ui/commons/custom_alert_widget.dart';
import 'package:app_2i2i/ui/commons/custom_navigation.dart';
import 'package:app_2i2i/ui/screens/app_settings/theme_mode_screen.dart';
import 'package:app_2i2i/ui/screens/block_and_friends/friends_list_page.dart';
import 'package:app_2i2i/ui/screens/home/wait_page.dart';
import 'package:app_2i2i/ui/screens/qr_code/widgets/qr_image.dart';
import 'package:app_2i2i/ui/screens/setup_account/setup_account.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../infrastructure/commons/strings.dart';
import '../../../infrastructure/providers/all_providers.dart';
import '../../../infrastructure/routes/app_routes.dart';

class AppSettingPage extends ConsumerStatefulWidget {
  @override
  _AppSettingPageState createState() => _AppSettingPageState();
}

class _AppSettingPageState extends ConsumerState<AppSettingPage> {
  List<String> networkList = ["Main", "Test", "Both"];

  @override
  void initState() {
    getMode();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(myUIDProvider);
    if (uid == null) return WaitPage();
    final user = ref.watch(userProvider(uid));
    if (user is AsyncLoading || user is AsyncError) return WaitPage();
    final message = 'https://2i2i.app/user/$uid';
    var appSettingModel = ref.watch(appSettingProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25,vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
                      logoSize: 60,
                      imageSize: 180,
                    ),
                    SizedBox(height: 16),
                    Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Color(0xffF3F3F7),
                        borderRadius: BorderRadius.circular(4),
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
                      showProfile();
                    },
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          Strings().userName,
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                        Text(
                          user.value?.name ?? '',
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                      ],
                    ),
                    trailing: Icon(
                      Icons.navigate_next,
                    ),
                  ),
                  ListTile(
                    onTap: (){
                      showProfile();
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
            Container(
              decoration: Custom.getBoxDecoration(context),
              child: ListTile(
                onTap: () {
                  CustomNavigation.push(
                      context, ThemeModeScreen(), 'ThemeModeScreen');
                },
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      getThemeModeName(appSettingModel.currentThemeMode),
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    if (appSettingModel.currentThemeMode == ThemeMode.system)
                      Text(
                        'System Defaults',
                        style: Theme.of(context).textTheme.subtitle1?.copyWith(
                            color: Theme.of(context).colorScheme.secondary),
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
                trailing: Icon(
                  Icons.navigate_next,
                ),
              ),
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
                      'Friends',
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    trailing: Icon(
                      Icons.navigate_next,
                    ),
                    onTap: () => CustomNavigation.push(
                        context,
                        FriendsListPage(
                          isForBlockedUser: false,
                        ),
                        Routes.FRIENDS),
                  ),
                  ListTile(
                    onTap: () => CustomNavigation.push(
                        context,
                        FriendsListPage(
                          isForBlockedUser: true,
                        ),
                        Routes.FRIENDS),
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

  Future<void> getMode() async {
    String? networkMode = await ref.read(algorandProvider).getNetworkMode();
    int itemIndex = networkList.indexWhere((element) => element == networkMode);
    if (itemIndex < 0) {
      itemIndex = 0;
    }
    setState(() {});
  }

  String getThemeModeName(ThemeMode? currentThemeMode) {
    if (currentThemeMode == ThemeMode.dark) {
      return 'Dark Mode';
    }
    return 'Light Mode';
  }

  void showProfile() {
    CustomAlertWidget.showBidAlert(
      context,
      WillPopScope(
        onWillPop: () {
          return Future.value(true);
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SetupBio(
            isFromDialog: true,
          ),
        ),
      ),
      isDismissible: true,
    );
  }
}
