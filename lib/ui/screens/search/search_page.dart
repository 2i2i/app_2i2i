import 'package:app_2i2i/infrastructure/commons/theme.dart';
import 'package:app_2i2i/infrastructure/commons/utils.dart';
import 'package:app_2i2i/ui/commons/custom_app_bar.dart';
import 'package:app_2i2i/ui/screens/home/wait_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../../infrastructure/commons/keys.dart';
import '../../../infrastructure/models/user_model.dart';
import '../../../infrastructure/providers/all_providers.dart';
import '../../../infrastructure/routes/app_routes.dart';
import '../../commons/custom_alert_widget.dart';
import '../user_setting/user_setting.dart';
import 'widgtes/user_info_tile.dart';

class SearchPage extends ConsumerStatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  TextEditingController _searchController = TextEditingController();
  bool isAlreadyShowed = false;

  final GlobalObjectKey mainKey = GlobalObjectKey('mainKey');

  @override
  void initState() {
    CustomAlertWidget.showHintWidget(context, ref, [mainKey]);
    super.initState();
  }

  void initMethod() {
    Future.delayed(Duration(seconds: 3)).then((value) {
      final uid = ref.watch(myUIDProvider)!;
      final userProviderVal = ref.watch(userProvider(uid));
      bool isLoaded = !(haveToWait(userProviderVal));
      if (isLoaded && userProviderVal.asData?.value is UserModel) {
        final UserModel user = userProviderVal.asData!.value;
        if (user.name.isEmpty) {
          CustomAlertWidget.showBidAlert(
            context,
            WillPopScope(
              onWillPop: () {
                return Future.value(true);
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: UserSetting(
                  fromBottomSheet: true,
                ),
              ),
            ),
            isDismissible: false,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppbar(
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              style: TextStyle(color: AppTheme().cardDarkColor),
              autofocus: false,
              controller: _searchController,
              decoration: InputDecoration(
                hintText: Keys.searchUserHint.tr(context),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.text = '';
                          _searchController.clear();
                          ref.watch(searchFilterProvider.state).state =
                              <String>[];
                        },
                        iconSize: 20,
                        icon: Icon(
                          Icons.close,
                        ),
                      )
                    : IconButton(icon: Container(), onPressed: null),
                filled: true,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                prefixIcon: Icon(Icons.search_rounded),
                // suffixIcon: Icon(Icons.mic),
              ),
              onChanged: (value) {
                value = value.trim().toLowerCase();
                ref.watch(searchFilterProvider.state).state =
                    value.isEmpty ? <String>[] : value.split(RegExp(r'\s'));
              },
            ),
          ),
          SizedBox(height: 10),
          Expanded(child: _buildContents(context, ref)),
        ],
      ),
    );
  }

  int usersSort(UserModel u1, UserModel u2, List<String> keywords) {
    // status
    if (u1.status == Status.ONLINE && u2.status != Status.ONLINE) return -1;
    if (u1.status != Status.ONLINE && u2.status == Status.ONLINE) return 1;
    if (u1.status == Status.IDLE && u2.status != Status.IDLE) return -1;
    if (u1.status != Status.IDLE && u2.status == Status.IDLE) return 1;
    // both ONLINE xor neither
    if (u1.isInMeeting() && !u2.isInMeeting()) return 1;
    if (!u1.isInMeeting() && u2.isInMeeting()) return -1;
    // both inMeeting xor not

    // keywords
    if (keywords.isNotEmpty) {
      final u1Tags = UserModel.tagsFromBio(u1.bio).toSet();
      final u2Tags = UserModel.tagsFromBio(u2.bio).toSet();
      final keywordsSet = keywords.toSet();
      final u1Match = keywordsSet.intersection(u1Tags).length;
      final u2Match = keywordsSet.intersection(u2Tags).length;
      if (u2Match < u1Match) return -1;
      if (u1Match < u2Match) return 1;
    }

    // rating
    if (u2.rating < u1.rating) return -1;
    if (u1.rating < u2.rating) return 1;

    // name
    return u1.name.compareTo(u2.name);
  }

  Widget _buildContents(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(searchFilterProvider.state).state;
    final mainUserID = ref.watch(myUIDProvider)!;
    var userListProvider = ref.watch(searchUsersStreamProvider);
    if (haveToWait(userListProvider)) {
      return WaitPage(isCupertino: true);
    }

    List<UserModel?> userList = userListProvider.value!;
    userList.removeWhere((element) => element == null);
    userList.removeWhere((element) => element?.name.isEmpty ?? false);
    userList.removeWhere((element) => element?.id == mainUserID);
    userList.sort((u1, u2) => usersSort(u1!, u2!, filter));
    return ScrollConfiguration(
      behavior: MyBehavior(),
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        // physics: ClampingScrollPhysics(),
        itemCount: userList.length,
        itemBuilder: (context, index) {
          Widget userTileWidget = UserInfoTile(
            user: userList[index]!,
            myUid: mainUserID,
            isForBlockedUser: false,
            marginBottom: 0,
          );

          if (index == 0)
            return Container(
              margin: EdgeInsets.only(bottom: 10),
              child: Showcase(
                title: '2i2i User',
                description: 'Tap info user and bid to hangout',
                key: mainKey,
                disposeOnTap: true,
                onTargetClick: () {
                  ref.read(appSettingProvider).checkIfHintShowed('mainKey');
                  context.pushNamed(Routes.user.nameFromPath(), params: {
                    'uid': userList[index]!.id,
                  });
                },
                radius: BorderRadius.circular(10),
                child: userTileWidget,
              ),
            );
          return Container(
            child: userTileWidget,
            margin: EdgeInsets.only(bottom: 10),
          );
        },
      ),
    );
  }
}
