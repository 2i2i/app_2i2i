import 'package:app_2i2i/infrastructure/commons/utils.dart';
import 'package:app_2i2i/ui/commons/custom_app_bar_web_search.dart';
import 'package:app_2i2i/ui/screens/app/wait_page.dart';
import 'package:app_2i2i/ui/screens/search/widgtes/user_info_tile_holder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../infrastructure/commons/keys.dart';
import '../../../infrastructure/models/user_model.dart';
import '../../../infrastructure/providers/all_providers.dart';

class SearchPageWeb extends ConsumerStatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPageWeb> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(searchFilterProvider.state).state = <String>[];
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppbarWebSearch(),
      body: Column(
        children: [
          SizedBox(height: 10),
          Expanded(
            child: _buildContents(context, ref),
          ),
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
    userList.removeWhere((element) => element?.id == mainUserID);
    userList.sort((u1, u2) => usersSort(u1!, u2!, filter));
    if (userList.isEmpty) {
      return WaitPage(isCupertino: true);
    }
    if (userListProvider.value?.isEmpty ?? true) {
      return Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: MediaQuery.of(context).size.height / 16,
              child: Icon(
                Icons.search_off_sharp,
                size: 26,
              ),
            ),
            Text(
              Keys.noHostsFound.tr(context),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).disabledColor),
            ),
          ],
        ),
      );
    }

    return ScrollConfiguration(
      behavior: MyBehavior(),
      child: GridView.builder(
        itemCount: userList.length,
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width / 35,
          vertical: MediaQuery.of(context).size.height / 25,
        ),
        itemBuilder: (_, index) => UserInfoTileHolder(
          user: userList[index]!,
          myUid: mainUserID,
          isForBlockedUser: false,
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          childAspectRatio: MediaQuery.of(context).size.height * 0.0018,
          crossAxisSpacing: MediaQuery.of(context).size.height * 0.050,
          mainAxisSpacing: MediaQuery.of(context).size.height * 0.050,
        ),
      ),
    );
  }
}
