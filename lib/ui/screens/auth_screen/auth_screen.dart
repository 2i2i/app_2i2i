import 'package:app_2i2i/ui/screens/home/wait_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../infrastructure/commons/utils.dart';
import '../../../infrastructure/models/user_model.dart';
import '../../../infrastructure/providers/all_providers.dart';
import '../../../infrastructure/providers/setup_user_provider/setup_user_view_model.dart';
import '../../../infrastructure/routes/named_routes.dart';
import '../home/error_page.dart';
import '../rating/add_rating_page.dart';
import '../user_setting/user_setting.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  @override
  void initState() {
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      final uid = ref.read(myUIDProvider);
      if (uid is String) {
        UserModel? userModel =
            await ref.read(setupUserViewModelProvider).getUserInfoModel(uid);
        if (userModel == null) {
          final database = ref.read(databaseProvider);
          await database.createUser(uid);
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(myUIDProvider);
    if (uid != null) {
      final myUserAsyncValue = ref.watch(userProvider(uid));
      if (haveToWait(myUserAsyncValue)) {
        return WaitPage();
      }
      if (myUserAsyncValue.value is UserModel) {
        final UserModel user = myUserAsyncValue.value!;
        if (user.name.trim().isEmpty) {
          return BottomSheet(
            enableDrag: true,
            backgroundColor: Theme.of(context).cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            elevation: 12,
            builder: (BuildContext context) {
              return WillPopScope(
                onWillPop: () {
                  return Future.value(true);
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: UserSetting(
                    fromBottomSheet: true,
                  ),
                ),
              );
            },
            onClosing: () {},
          );
        }
      }
    }
    return AddRatingPage(showRating: NamedRoutes.showRating);
  }
}
