import 'package:app_2i2i/infrastructure/commons/strings.dart';
import 'package:app_2i2i/infrastructure/commons/utils.dart';
import 'package:app_2i2i/ui/screens/home/wait_page.dart';
import 'package:flutter/cupertino.dart';
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
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(right: 30,left: 30, bottom: 10,top: kIsWeb?15:31),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            Text(
              Strings().fav,
              style: Theme.of(context).textTheme.headline5,
            ),
            SizedBox(height: 20),
            Expanded(child: buildListView())
          ],
        ),
      ),
    );
  }

  Widget buildListView() {
    List<String> favList = [];
    final myUid = ref.read(myUIDProvider)!;
    final myHangoutAsyncValue = ref.watch(hangoutProvider(myUid));
    if (haveToWait(myHangoutAsyncValue)) {
      return WaitPage();
    }
    favList = myHangoutAsyncValue.value!.friends;

    if (favList.isEmpty) {
      return Center(
          child: Text(
        'No users found',
        style: Theme.of(context).textTheme.subtitle2,
      ));
    }
    return ListView.separated(
      itemCount: favList.length,
      shrinkWrap: true,
      primary: false,
      itemBuilder: (_, index) {
        final hangout = ref.watch(hangoutProvider(favList[index]));
        if (haveToWait(hangout)) {
          return CupertinoActivityIndicator();
        }
        return UserInfoTile(
          hangout: hangout.value!,
          myUid: myUid,
          isForBlockedUser: false,
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        /*final hangout = users[index];
        if (hangout.id == mainUserID) {
          return Container();
        }*/
        return Divider(
          color: Colors.transparent,
        );
      },
    );
  }
}
