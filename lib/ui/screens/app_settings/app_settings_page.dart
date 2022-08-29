import 'dart:io';

import 'package:app_2i2i/infrastructure/commons/utils.dart';
import 'package:app_2i2i/ui/commons/custom.dart';
import 'package:app_2i2i/ui/commons/custom_app_bar.dart';
import 'package:app_2i2i/ui/screens/app/wait_page.dart';
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
import '../../commons/custom_alert_widget.dart';
import '../home/bottom_nav_bar.dart';

class AppSettingPage extends ConsumerStatefulWidget {
  @override
  _AppSettingPageState createState() => _AppSettingPageState();
}

class _AppSettingPageState extends ConsumerState<AppSettingPage> with TickerProviderStateMixin {
  List<String> networkList = ["Main", "Test", "Both"];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
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
      key: _scaffoldKey,
      appBar: CustomAppbar(
        backgroundColor: Colors.transparent,
        title: Text(
          Keys.settings.tr(context),
          style: Theme.of(context).textTheme.headline5,
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 30),
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
                    onTap: () {
                      context.pushNamed(Routes.userSetting.nameFromPath());
                      currentIndex.value = 4;
                    },
                    title: Text(
                      Keys.bio.tr(context),
                      style: Theme.of(context).textTheme.subtitle1,
                      textAlign: TextAlign.start,
                    ),
                    trailing: Icon(Icons.navigate_next),
                  ),
                  ListTile(
                    onTap: () => context.pushNamed(Routes.account.nameFromPath()),
                    title: Row(
                      children: [
                        Text(
                          Keys.wallet.tr(context),
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                        Visibility(
                          visible: !(appSettingModel.isTappedOnKey),
                          child: Padding(
                            padding: EdgeInsets.only(left: 12),
                            child: new Icon(Icons.brightness_1, size: 12.0, color: Colors.redAccent),
                          ),
                        ),
                      ],
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
            SizedBox(height: 20),
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
                    onTap: () => context.pushNamed(Routes.language.nameFromPath()),
                    title: Text(
                      Keys.language.tr(context),
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    trailing: Text((appSettingModel.locale?.languageCode ?? 'EN').toUpperCase()),
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
                    subtitle: appSettingModel.updateRequired
                        ? Text(Keys.updateAvailable.tr(context), style: Theme.of(context).textTheme.caption?.copyWith(color: Colors.amber))
                        : null,
                    iconColor: Colors.amber,
                    trailing: appSettingModel.updateRequired
                        ? RotatedBox(
                      quarterTurns: 1,
                      child: Icon(
                        Icons.arrow_circle_left_rounded,
                      ),
                    )
                        : Text("${appSettingModel.version}", style: Theme.of(context).textTheme.caption?.copyWith(color: Theme.of(context).disabledColor)),
                  ),
                  ListTile(
                    onTap: () async {
                      CustomAlertWidget.confirmDialog(
                        context,
                        title: "Logout",
                        description: "Are you sure want to logout?",
                        onPressed: () async {
                          await signUpViewModel.signOutFromAuth();
                        },
                        yesButtonTextStyle: TextStyle(color: Theme.of(context).errorColor),
                        noButtonTextStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
                      );
                    },
                    title: Text(Keys.logOut.tr(context), style: Theme.of(context).textTheme.caption?.copyWith(color: Theme.of(context).errorColor)),
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
              // decoration: Custom.getBoxDecoration(context),
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
            SizedBox(height: 16),
            TextButton(
                onPressed: () async {
                  await signUpViewModel.deleteUser(
                      title: "${Keys.deleteAccount.tr(context)}!",
                      description: Keys.deleteAccountMessage.tr(context),
                      mainContext: _scaffoldKey.currentContext ?? context);
                },
                child: Text(
                  Keys.deleteAccount.tr(context),
                  style: Theme.of(context).textTheme.caption?.copyWith(color: Theme.of(context).errorColor),
                ))
          ],
        ),
      ),
    );
  }
}
