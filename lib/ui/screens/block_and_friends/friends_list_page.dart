import 'package:app_2i2i/ui/screens/home/wait_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../infrastructure/providers/all_providers.dart';
import '../search/widgtes/user_info_tile.dart';

class FriendsListPage extends ConsumerStatefulWidget {
  final bool isForBlockedUser;

  const FriendsListPage({Key? key, required this.isForBlockedUser})
      : super(key: key);

  @override
  _FriendsListPageState createState() => _FriendsListPageState();
}

class _FriendsListPageState extends ConsumerState<FriendsListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.isForBlockedUser ? 'Blocked Users' : 'Friends List',
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
    List<String> friendsList = [];
    final myId = ref.read(myUIDProvider)!;
    final userPrivateAsyncValue = ref.watch(userPrivateProvider(myId));

    if (userPrivateAsyncValue is AsyncLoading) {
      return WaitPage();
    }

    if (widget.isForBlockedUser) {
      friendsList = userPrivateAsyncValue.value?.blocked ?? [];
    } else {
      friendsList = userPrivateAsyncValue.value?.friends ?? [];
    }

    if (friendsList.isEmpty) {
      return Center(
          child: Text(
        'No users found',
        style: Theme.of(context).textTheme.subtitle2,
      ));
    }
    return ListView.separated(
      itemCount: friendsList.length,
      shrinkWrap: true,
      primary: false,
      itemBuilder: (_, index) {
        final user = ref.watch(userProvider(friendsList[index]));
        if (user is AsyncLoading || user is AsyncError)
          return CupertinoActivityIndicator();
        return UserInfoTile(
          userModel: user.value!,
          myUIDProvider: myId,
          isForBlockedUser: widget.isForBlockedUser,
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
    );
  }
}
