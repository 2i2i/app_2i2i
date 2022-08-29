import 'package:app_2i2i/infrastructure/commons/keys.dart';
import 'package:app_2i2i/infrastructure/commons/utils.dart';
import 'package:app_2i2i/ui/commons/custom_app_bar_holder.dart';
import 'package:app_2i2i/ui/screens/app/wait_page.dart';
import 'package:app_2i2i/ui/screens/search/widgtes/user_info_tile_holder.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../infrastructure/providers/all_providers.dart';

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
      appBar: CustomAppbarHolder(
        backgroundColor: Colors.transparent,
        title: Text(
          Keys.fav.tr(context),
          style: Theme.of(context).textTheme.headline5,
        ),
      ),
      body: favList.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height / 16,
                    child: Image.asset(
                      'assets/join_host.png',
                      fit: BoxFit.fitWidth,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 50,
                  ),
                  Text(
                    Keys.noHostsFound.tr(context),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).disabledColor),
                  ),
                ],
              ),
            )
          : Padding(
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
                  return UserInfoTileHolder(
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
