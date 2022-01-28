import 'package:app_2i2i/infrastructure/commons/strings.dart';
import 'package:app_2i2i/infrastructure/commons/utils.dart';
import 'package:app_2i2i/ui/screens/home/wait_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../infrastructure/providers/all_providers.dart';
import '../search/widgtes/user_info_tile.dart';

class BlockListPage extends ConsumerStatefulWidget {
  const BlockListPage({Key? key}) : super(key: key);

  @override
  _BlockListPageState createState() => _BlockListPageState();
}

class _BlockListPageState extends ConsumerState<BlockListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: EdgeInsets.only(right: 30, left: 30, bottom: 10, top: kIsWeb ? 15 : 31),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              Strings().blockList,
              style: Theme.of(context).textTheme.headline5,
            ),
            SizedBox(height: 20),
            Expanded(
              child: Builder(
                builder: (BuildContext context) {
                  List<String> blockList = [];
                  final myId = ref.read(myUIDProvider)!;
                  final userPrivateAsyncValue =
                      ref.watch(userPrivateProvider(myId));

                  if (haveToWait(userPrivateAsyncValue)) {
                    return WaitPage();
                  }

                  blockList = userPrivateAsyncValue.value?.blocked ?? [];

                  if (blockList.isEmpty) {
                    return Center(
                      child: Text(
                        'No users found',
                        style: Theme.of(context).textTheme.subtitle2,
                      ),
                    );
                  }
                  return ListView.separated(
                    itemCount: blockList.length,
                    shrinkWrap: true,
                    primary: false,
                    itemBuilder: (_, index) {
                      final hangout =
                          ref.watch(hangoutProvider(blockList[index]));
                      if (haveToWait(hangout)) {
                        return CupertinoActivityIndicator();
                      }
                      return UserInfoTile(
                        hangout: hangout.value!,
                        myUIDProvider: myId,
                        isForBlockedUser: true,
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
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
