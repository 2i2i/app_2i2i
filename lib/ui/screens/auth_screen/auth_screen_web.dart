import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../infrastructure/commons/app_config.dart';
import '../../../infrastructure/data_access_layer/repository/algorand_service.dart';
import '../../../infrastructure/models/user_model.dart';
import '../../../infrastructure/providers/all_providers.dart';
import '../../../infrastructure/routes/named_routes.dart';
import '../home/bottom_nav_bar_holder_.dart';
import '../rating/add_rating_page.dart';
import '../user_setting/user_setting.dart';

class AuthScreenWeb extends ConsumerStatefulWidget {
  final Widget pageChild;

  const AuthScreenWeb({required this.pageChild, Key? key}) : super(key: key);

  @override
  ConsumerState<AuthScreenWeb> createState() => _AuthScreenWebState();
}

class _AuthScreenWebState extends ConsumerState<AuthScreenWeb> {
  final GlobalKey<ScaffoldState> _key = GlobalKey();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final uid = ref.read(myUIDProvider);
      if (uid is String) {
        UserModel? userModel = await ref.read(setupUserViewModelProvider).getUserInfoModel(uid);
        if (userModel == null) {
          final database = ref.read(databaseProvider);
          await database.createUser(uid);
          _key.currentState!.openEndDrawer();
        } else if (userModel.name.isEmpty) {
          _key.currentState!.openEndDrawer();
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      drawerEnableOpenDragGesture: false,
      endDrawerEnableOpenDragGesture: false,
      drawerEdgeDragWidth: 0,
      endDrawer: GestureDetector(
        onHorizontalDragEnd: (v) {},
        child: Stack(
          children: [
            AbsorbPointer(
              absorbing: true,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: FittedBox(
                alignment: Alignment.centerRight,
                fit: BoxFit.scaleDown,
                child: Container(
                  width: MediaQuery.of(context).size.width / 3,
                  height: MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width / 35),
                    child: UserSetting(
                      fromBottomSheet: true,
                      //key: _key,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
      appBar: AppConfig().ALGORAND_NET == AlgorandNet.mainnet
          ? null
          : AppBar(
              actions: <Widget>[
                new Container(),
              ],
              leading: Container(),
              toolbarHeight: 20,
              title: Text(AlgorandNet.testnet.name + ' - v41'),
              titleTextStyle: Theme.of(context).textTheme.bodyText2?.copyWith(color: Theme.of(context).cardColor),
              centerTitle: true,
              backgroundColor: Colors.green,
            ),
      body: Row(
        children: [
          BottomNavBarHolder(),
          Expanded(
            child: SafeArea(
              child: widget.pageChild,
            ),
          ),
        ],
      ),
      bottomSheet: AddRatingPage(),
    );
  }
}
