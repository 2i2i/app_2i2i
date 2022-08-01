import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../infrastructure/commons/app_config.dart';
import '../../../infrastructure/data_access_layer/repository/algorand_service.dart';
import '../../../infrastructure/models/user_model.dart';
import '../../../infrastructure/providers/all_providers.dart';
import '../../../infrastructure/routes/app_routes.dart';
import '../../commons/custom.dart';
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
      ref.read(appSettingProvider).getTappedOnKey();
      final uid = ref.read(myUIDProvider);
      if (uid is String) {
        UserModel? userModel = await ref.read(setupUserViewModelProvider).getUserInfoModel(uid);
        if (userModel == null) {
          final database = ref.read(databaseProvider);
          await database.createUser(uid);
          CustomAlertWidget.showBottomSheet(context,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: UserSetting(
                  fromBottomSheet: true,
                ),
              ),
              enableDrag: false,
              isDismissible: false);
        } else if (userModel.name.isEmpty) {
          CustomAlertWidget.showBottomSheet(context,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: UserSetting(
                  fromBottomSheet: true,
                ),
              ),
              enableDrag: false,
              isDismissible: false);
        }
      }

      userIdNav.addListener(() {
        if (userIdNav.value.isNotEmpty) {
          context.pushNamed(Routes.user.nameFromPath(), params: {'uid': userIdNav.value});
          userIdNav.value = '';
        }
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppConfig().ALGORAND_NET == AlgorandNet.mainnet
          ? null
          : AppBar(
              leading: Container(),
              toolbarHeight: 20,
              title: Text(AlgorandNet.testnet.name + ' - v41' + (widget.updateAvailable ? ' - update: reload page' : '')),
              titleTextStyle: Theme.of(context).textTheme.bodyText2?.copyWith(color: Theme.of(context).cardColor),
              centerTitle: true,
              backgroundColor: Colors.green,
            ),
      body: SafeArea(child: widget.pageChild),
      bottomSheet: AddRatingPage(),
      bottomNavigationBar: BottomNavBar(),
    );
  }
}
