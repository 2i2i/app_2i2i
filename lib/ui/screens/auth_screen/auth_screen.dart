import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
        CustomAlertWidget.showBottomSheet(
          context,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: UserSetting(fromBottomSheet: true),
          ),
          enableDrag: false,
          isDismissible: false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppConfig().ALGORAND_NET == AlgorandNet.mainnet
          ? (kIsWeb
              ? AppBar(
                  leading: Container(),
                  toolbarHeight: 20,
                  title: Text('web app is in alpha version'),
                  titleTextStyle: Theme.of(context).textTheme.bodyText2?.copyWith(color: Theme.of(context).cardColor),
                  centerTitle: true,
                  backgroundColor: Colors.green,
                )
              : null)
          : AppBar(
              leading: Container(),
              toolbarHeight: 20,
              title: Text(AlgorandNet.testnet.name + ' - v1.1.7' + (widget.updateAvailable ? ' - update: reload page' : '')),
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
