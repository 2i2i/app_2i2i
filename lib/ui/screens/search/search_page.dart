import 'dart:math';

import 'package:app_2i2i/ui/commons/custom_alert_widget.dart';
import 'package:app_2i2i/ui/commons/custom_app_bar.dart';
import 'package:app_2i2i/ui/commons/custom_profile_image_view.dart';
import 'package:app_2i2i/ui/screens/setup_account/setup_account.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../infrastructure/commons/strings.dart';
import '../../../infrastructure/data_access_layer/repository/firestore_database.dart';
import '../../../infrastructure/models/user_model.dart';
import '../../../infrastructure/providers/all_providers.dart';
import 'widgtes/user_info_tile.dart';

class SearchPage extends ConsumerStatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  @override
  void initState() {
    initMethod();
    super.initState();
  }

  void initMethod() {
    Future.delayed(Duration(seconds: 3)).then((value) {
      final uid = ref.watch(myUIDProvider)!;
      final user = ref.watch(userProvider(uid));
      bool isLoaded = !(user is AsyncLoading && user is AsyncError);
      if (isLoaded && user.asData?.value is UserModel) {
        final UserModel myUser = user.asData!.value;
        if (myUser.name.isEmpty) {
          CustomAlertWidget.showBidAlert(
            context,
            WillPopScope(
              onWillPop: () {
                return Future.value(true);
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SetupBio(
                  isFromDialog: true,
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
      appBar: CustomAppbar(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              autofocus: false,
              decoration: InputDecoration(
                hintText: Strings().searchUserHint,
                filled: true,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                prefixIcon: Icon(Icons.search_rounded),
                suffixIcon: Icon(Icons.mic),
              ),
              onChanged: (value) {
                value = value.trim();
                ref.watch(searchFilterProvider.state).state =
                    value.isEmpty ? <String>[] : value.split(RegExp(r'\s'));
              },
            ),
          ),
          SizedBox(height: 20),
          Expanded(child: _buildContents(context, ref)),
        ],
      ),
    );
  }

  int usersSort(UserModel u1, UserModel u2, List<String> keywords) {
    if (u1.status == 'ONLINE' && u2.status != 'ONLINE') return -1;
    if (u1.status != 'ONLINE' && u2.status == 'ONLINE') return 1;
    // both ONLINE xor OFFLINE
    if (u1.isInMeeting() && !u2.isInMeeting()) return 1;
    if (!u1.isInMeeting() && u2.isInMeeting()) return -1;
    // both inMeeting xor not

    if (keywords.isNotEmpty) {
      final u1Tags = UserModel.tagsFromBio(u1.bio).toSet();
      final u2Tags = UserModel.tagsFromBio(u2.bio).toSet();
      final keywordsSet = keywords.toSet();
      final u1Match = keywordsSet.intersection(u1Tags).length;
      final u2Match = keywordsSet.intersection(u2Tags).length;
      if (u2Match < u1Match) return -1;
      if (u1Match < u2Match) return 1;
    }

    if (u2.rating < u1.rating) return -1;
    if (u1.rating < u2.rating) return 1;

    return -1;
  }

  Widget _buildContents(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(searchFilterProvider.state).state;
    final mainUserID = ref.watch(myUIDProvider)!;
    return StreamBuilder(
      stream: FirestoreDatabase().usersStream(tags: filter),
      builder:
          (BuildContext contextMain, AsyncSnapshot<List<UserModel>> snapshot) {
        if (snapshot.hasData) {
          final users = snapshot.data!;
          users.sort((u1, u2) => usersSort(u1, u2, filter));
          users.removeWhere((element) => element.id == mainUserID);
          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            itemCount: users.length,
            itemBuilder: (_, index) => UserInfoTile(
              userModel: users[index],
              myUIDProvider: mainUserID,
              isForBlockedUser: false,
            ),
            separatorBuilder: (BuildContext context, int index) {
              final user = users[index];
              if (user.id == mainUserID) {
                return Container();
              }
              return Divider(
                color: Colors.transparent,
              );
            },
          );
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}
