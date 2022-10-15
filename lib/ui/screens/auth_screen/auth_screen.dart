import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../infrastructure/commons/app_config.dart';
import '../../../infrastructure/data_access_layer/repository/algorand_service.dart';
import '../../../infrastructure/models/user_model.dart';
import '../../../infrastructure/providers/all_providers.dart';
import '../../commons/custom_alert_widget.dart';
import '../home/bottom_nav_bar.dart';
import '../rating/add_rating_page.dart';
import '../user_setting/user_setting.dart';

class AuthScreen extends ConsumerStatefulWidget {
  final Widget pageChild;
  final bool updateAvailable;

  const AuthScreen({required this.pageChild, required this.updateAvailable, Key? key}) : super(key: key);

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  int count = 0;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      createUserBottomSheet();
    });
    super.initState();
  }

  Future<void> createUserBottomSheet() async {
    final uid = ref.read(myUIDProvider);
    if (uid is String) {
      final database = ref.watch(databaseProvider);
      UserModel? userModel = await database.getUser(uid);
      if (userModel?.name.isEmpty ?? false) {
        CustomAlertWidget.showBottomSheet(context,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: UserSetting(fromBottomSheet: true),
            ),
            enableDrag: false,
            isDismissible: false);
      } else {
        await ref.read(appSettingProvider).checkIfUpdateAvailable();
        var appSettingModel = ref.watch(appSettingProvider);
        if (appSettingModel.updateRequired && !appSettingModel.isPressLater) {
          String version = Platform.isAndroid ? (appSettingModel.appVersion?.androidVersion ?? "0") : (appSettingModel.appVersion?.iosVersion ?? "0");
          String packageVersion = appSettingModel.packageInfo?.version ?? "0";
          CustomAlertWidget.updateAlertDialog(
            context,
            title: 'Update App?',
            description: 'A new version is available! Version $version is now available-you have $packageVersion. Would you like to update to now?',
            isForceUpdate: (appSettingModel.appVersion?.minAppVersion ?? "0") == packageVersion,
            releaseNote: appSettingModel.appVersion?.releaseNote ?? "",
            secondActionOnPressed: () => appSettingModel.setPressLater(true),
            updateOnPressed: () async {
              if (appSettingModel.updateRequired && !Platform.isIOS) {
                await launchUrl(Uri.parse('https://play.google.com/store/apps/details?id=app.i2i2'), mode: LaunchMode.externalApplication);
              }
              if (Platform.isIOS) {
                await launchUrl(Uri.parse('https://itunes.apple.com/app/id1609689141'), mode: LaunchMode.externalApplication);
              }
            },
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppConfig().ALGORAND_NET == AlgorandNet.mainnet
          ? null
          : AppBar(
              leading: Container(),
              toolbarHeight: 20,
              title: Text(AlgorandNet.testnet.name + ' - v55' + (widget.updateAvailable ? ' - update: reload page' : '')),
              titleTextStyle: Theme.of(context).textTheme.bodyText2?.copyWith(color: Theme.of(context).cardColor),
              centerTitle: true,
              backgroundColor: Colors.green,
            ),
      // body: SafeArea(child: widget.pageChild),
      body: SafeArea(child: widget.pageChild),
      bottomSheet: AddRatingPage(),
      bottomNavigationBar: BottomNavBar(),
    );
  }
}
