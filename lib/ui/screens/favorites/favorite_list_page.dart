import 'package:app_2i2i/infrastructure/commons/keys.dart';
import 'package:app_2i2i/infrastructure/commons/utils.dart';
import 'package:app_2i2i/ui/commons/custom_app_bar.dart';
import 'package:app_2i2i/ui/screens/app/wait_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../infrastructure/providers/all_providers.dart';
import '../search/widgtes/user_info_tile.dart';

class FavoriteListPage extends ConsumerStatefulWidget {
  const FavoriteListPage({Key? key}) : super(key: key);

  @override
  _FavoriteListPageState createState() => _FavoriteListPageState();
}

class _FavoriteListPageState extends ConsumerState<FavoriteListPage> {
  @override
  Widget build(BuildContext context) {
    List<String> favList = [];
    final myUid = ref.read(myUIDProvider)!;
    final myUserAsyncValue = ref.watch(userProvider(myUid));
    if (haveToWait(myUserAsyncValue)) {
      return WaitPage();
    }
    favList = myUserAsyncValue.value!.friends;

    return Scaffold(
      appBar: CustomAppbar(
        backgroundColor: Colors.transparent,
        title: Text(
          Keys.fav.tr(context),
          style: Theme.of(context).textTheme.headline5,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.only(right: 20, left: 20, bottom: 10, top: kIsWeb ? 15 : 31),
        child: ListView.separated(
          itemCount: favList.length,
          shrinkWrap: true,
          primary: false,
          itemBuilder: (_, index) {
            final user = ref.watch(userProvider(favList[index]));
            if (haveToWait(user)) {
              return Container();
            }
            return UserInfoTile(
              user: user.value!,
              myUid: myUid,
              isForBlockedUser: false,
            );
          },
          separatorBuilder: (BuildContext context, int index) {
            /*final user = users[index];
        if (user.id == mainUserID) {
          return Container();
        }*/
            return Divider(
              color: Colors.transparent,
            );
          },
        ),
      ),
    );
  }
}
