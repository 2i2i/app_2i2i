import 'dart:io';

import 'package:app_2i2i/infrastructure/commons/utils.dart';
import 'package:app_2i2i/ui/commons/custom.dart';
import 'package:app_2i2i/ui/commons/custom_app_bar_holder.dart';
import 'package:app_2i2i/ui/screens/app/wait_page.dart';
import 'package:app_2i2i/ui/screens/faq/faq_screen_holder.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:store_redirect/store_redirect.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../infrastructure/commons/keys.dart';
import '../../../infrastructure/data_access_layer/services/logging.dart';
import '../../../infrastructure/providers/all_providers.dart';
import '../../../infrastructure/routes/app_routes.dart';
import '../home/bottom_nav_bar.dart';
import '../my_account/my_account_page_web.dart';

class AppSettingPageWeb extends ConsumerStatefulWidget {
  @override
  _AppSettingPageState createState() => _AppSettingPageState();
}

class _AppSettingPageState extends ConsumerState<AppSettingPageWeb> with TickerProviderStateMixin {
  List<String> networkList = ["Main", "Test", "Both"];

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ref.read(appSettingProvider).setDropDownValue();
      ref.read(setupUserViewModelProvider).getAuthList();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(myUIDProvider);
    final signUpViewModel = ref.watch(setupUserViewModelProvider);
    var appSettingModel = ref.watch(appSettingProvider);

    if (uid == null) return WaitPage();

    final user = ref.watch(userProvider(uid));
    if (haveToWait(user)) {
      return WaitPage();
    }

    return Scaffold(
      appBar: CustomAppbarHolder(
        backgroundColor: Colors.transparent,
        title: Text(
          Keys.settings.tr(context),
          style: Theme.of(context).textTheme.headline5,
        ),
        actions: <Widget>[
          Container(),
        ],
      ),
      key: _scaffoldKey,
      drawerEnableOpenDragGesture: false,
      endDrawerEnableOpenDragGesture: false,
      drawerEdgeDragWidth: 0,
      extendBody: true,
      endDrawer: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: FittedBox(
          alignment: Alignment.centerRight,
          fit: BoxFit.contain,
          child: Container(
            width: MediaQuery.of(context).size.width / 3,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
            ),
            clipBehavior: Clip.antiAliasWithSaveLayer,
            child: FAQScreenHolder(),
          ),
        ),
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: kToolbarHeight,
          ),
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    Keys.account.tr(context),
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      ///profile
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              decoration: Custom.getBoxDecoration(context),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  ListTile(
                                    onTap: () {
                                      context.pushNamed(Routes.userSetting.nameFromPath());
                                      currentIndex.value = 4;
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
                                    onTap: () => context.pushNamed(Routes.meetingHistory.nameFromPath()),
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
                            SizedBox(height: MediaQuery.of(context).size.height / 35),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ///theme
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
                                              controller: TabController(length: 3, vsync: this, initialIndex: selectedIndex),
                                              indicatorPadding: EdgeInsets.all(3),
                                              indicator: BoxDecoration(
                                                color: Theme.of(context).colorScheme.secondary,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              unselectedLabelColor: Theme.of(context).tabBarTheme.unselectedLabelColor,
                                              labelColor: Theme.of(context).tabBarTheme.unselectedLabelColor,
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
                                                    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
                                                    break;
                                                  case 1:
                                                    appSettingModel.setThemeMode(Keys.dark);
                                                    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
                                                    break;
                                                  case 2:
                                                    var brightness = MediaQuery.of(context).platformBrightness;
                                                    bool isDarkMode = brightness == Brightness.dark;
                                                    SystemChrome.setSystemUIOverlayStyle(isDarkMode ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark);
                                                    appSettingModel.setThemeMode(Keys.auto);
                                                    break;
                                                }
                                              },
                                            ),
                                          );
                                        },
                                      ),

                                      ///others
                                      Container(
                                        decoration: Custom.getBoxDecoration(context),
                                        child: Column(
                                          children: [
                                            Visibility(
                                              visible: false,
                                              child: ListTile(
                                                onTap: () => context.pushNamed(Routes.blocks.nameFromPath()),
                                                title: Text(
                                                  Keys.blockList.tr(context),
                                                  style: Theme.of(context).textTheme.subtitle1,
                                                ),
                                                trailing: Icon(
                                                  Icons.navigate_next,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(
                                  width: kToolbarHeight,
                                ),

                                /// language DropDownMenu
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        Keys.language.tr(context),
                                        style: Theme.of(context).textTheme.subtitle1,
                                      ),
                                      SizedBox(height: 12),
                                      Container(
                                        decoration: Custom.getBoxDecoration(context),
                                        child: ButtonTheme(
                                          alignedDropdown: true,
                                          child: DropdownButton<LanguageModel>(
                                            isExpanded: true,
                                            focusColor: Theme.of(context).scaffoldBackgroundColor,
                                            dropdownColor: Theme.of(context).cardColor,
                                            underline: SizedBox(),
                                            borderRadius: BorderRadius.circular(10),
                                            value: appSettingModel.dropdownValue,
                                            icon: RotatedBox(
                                              quarterTurns: 1,
                                              child: const Icon(
                                                Icons.navigate_next,
                                              ),
                                            ),
                                            hint: Text('Select Language'),
                                            items: appSettingModel.languageList.map<DropdownMenuItem<LanguageModel>>((value) {
                                              return DropdownMenuItem<LanguageModel>(
                                                value: value,
                                                child: Text(value.title ?? ""),
                                              );
                                            }).toList(),
                                            onChanged: (newValue) => ref.read(appSettingProvider).setDropDownValue(value: newValue!),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: kToolbarHeight),

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
                          onTap: () {
                            _scaffoldKey.currentState?.openEndDrawer();
                          },
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
                              await launchUrl(Uri.parse(Keys.aboutPageUrl.tr(context)));
                            } catch (e) {
                              log("$e");
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
                        ListTile(
                          onTap: () {
                            if (appSettingModel.updateRequired) {
                              StoreRedirect.redirect(
                                androidAppId: "app.i2i2",
                                iOSAppId: "app.2i2i",
                              );
                            }
                          },
                          title: Text(
                            Keys.appVersion.tr(context),
                            style: Theme.of(context).textTheme.subtitle1,
                          ),
                          trailing: Text(
                            "${appSettingModel.version}",
                            style: Theme.of(context).textTheme.caption?.copyWith(color: Theme.of(context).disabledColor),
                          ),
                        ),
                        ListTile(
                          onTap: () async {
                            await signUpViewModel.signOutFromAuth();
                            currentIndex.value = 1;
                            context.go(Routes.myUser);
                          },
                          title: Text(
                            Keys.logOut.tr(context),
                            style: Theme.of(context).textTheme.caption?.copyWith(color: Theme.of(context).errorColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  //connect social
                  Visibility(
                    visible: !signUpViewModel.authList.contains('google.com') && !signUpViewModel.authList.contains('apple.com'),
                    child: Text(
                      Keys.connectAccount.tr(context),
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                  ),
                  SizedBox(height: 12),
                  Container(
                    child: Row(
                      children: [
                        Visibility(
                          visible: !signUpViewModel.authList.contains('google.com'),
                          child: FloatingActionButton.small(
                            onPressed: () async {
                              await signUpViewModel.signInWithGoogle(context, linkWithCredential: true);
                              await ref.read(setupUserViewModelProvider).getAuthList();
                            },
                            heroTag: 'google',
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            child: Image.asset('assets/google.png', height: 25, width: 25),
                          ),
                        ),
                        Visibility(
                          child: FloatingActionButton.small(
                            onPressed: () async {
                              await signUpViewModel.signInWithTwitter(context, linkWithCredential: true);
                              await ref.read(setupUserViewModelProvider).getAuthList();
                            },
                            heroTag: 'twitter',
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            child: Image.asset('assets/twitter.png', height: 25, width: 25),
                          ),
                          visible: !kIsWeb && !signUpViewModel.authList.contains('twitter.com'),
                        ),
                        Visibility(
                          child: FloatingActionButton.small(
                            heroTag: 'apple',
                            onPressed: () async {
                              await signUpViewModel.signInWithApple(context, linkWithCredential: true);
                              await ref.read(setupUserViewModelProvider).getAuthList();
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            child: Image.asset('assets/apple.png', height: 25, width: 25),
                          ),
                          visible: !kIsWeb && Platform.isIOS && !signUpViewModel.authList.contains('apple.com'),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: kToolbarHeight),
                  TextButton(
                    onPressed: () async {
                      await signUpViewModel.deleteUser(
                          title: "Delete account!", description: "Are you sure want to delete your account permanently from 2i2i?", mainContext: context);
                    },
                    child: Text(
                      'Delete Account',
                      style: Theme.of(context).textTheme.caption?.copyWith(color: Theme.of(context).errorColor),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: kToolbarHeight * 2,
            child: VerticalDivider(),
          ),
          Expanded(
            flex: 2,
            child: MyAccountPageWeb(),
          ),
          SizedBox(
            width: kToolbarHeight,
          ),
        ],
      ),
    );
  }
}

class LanguageModel {
  String? title;
  String? languageCode;
  String? countryCode;

  LanguageModel({this.title, this.languageCode, this.countryCode});

  LanguageModel.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    languageCode = json['languageCode'];
    countryCode = json['countryCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['languageCode'] = this.languageCode;
    data['countryCode'] = this.countryCode;
    return data;
  }
}
