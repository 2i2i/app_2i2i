import 'dart:math';

import 'package:app_2i2i/common/custom_navigation.dart';
import 'package:app_2i2i/common/theme.dart';
import 'package:app_2i2i/models/user.dart';
import 'package:app_2i2i/pages/add_bid/ui/add_bid_page.dart';
import 'package:app_2i2i/pages/home/wait_page.dart';
import 'package:app_2i2i/pages/user_bid/ui/other_bid_list.dart';
import 'package:app_2i2i/routes/app_routes.dart';
import 'package:app_2i2i/services/all_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class UserPage extends ConsumerStatefulWidget {
  UserPage({required this.uid});

  final String uid;

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends ConsumerState<UserPage> {
  final TextEditingController bioTextController = TextEditingController();

  late UserModel B;
  bool isPresent = false;

  @override
  Widget build(BuildContext context) {
    final authStateChanges = ref.watch(authStateChangesProvider);
    if (authStateChanges is AsyncLoading) return WaitPage();

    final myUserPageViewModel = ref.watch(myUserPageViewModelProvider);
    if (myUserPageViewModel == null) return WaitPage();

    final userPageViewModel = ref.watch(userPageViewModelProvider(widget.uid));
    if (userPageViewModel == null) return WaitPage();

    B = userPageViewModel.user;
    bioTextController.text = B.bio;

    final shortBioStart = B.bio.indexOf(RegExp(r'\s')) + 1;
    int aPoint = shortBioStart + 10;
    int bPoint = B.bio.length;
    final shortBioEnd = min(aPoint, bPoint);
    final shortBio = B.bio.substring(shortBioStart, shortBioEnd);
    var statusColor = AppTheme().green;
    if (B.status == 'OFFLINE') statusColor = AppTheme().gray;
    if (B.locked) statusColor = AppTheme().red;

    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/logo.png', height: 30, fit: BoxFit.contain),
        actions: (authStateChanges.data!.value!.uid != B.id)
            ? [
                IconButton(
                    onPressed: () {}, // TODO
                    // async {
                    //   await myUserPageViewModel.setUserPrivate(
                    //       context: context,
                    //       uid: widget.uid,
                    //       userPrivate: UserModelPrivate(friends: [widget.uid]));
                    // },
                    icon: Icon(Icons.favorite_border_rounded)),
                SizedBox(width: 6)
        ]
            : null,
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: authStateChanges.data!.value!.uid == B.id
            ? null
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                      isPresent
                          ? "Your already bid this user, First cancel bid"
                          : "Do you want to bid for ${B.name}",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.caption),
                  SizedBox(height: 12),
                  Visibility(
                    visible: !isPresent,
                    child: ElevatedButton(
                      onPressed: () {
                        if (!isPresent) {
                          CustomNavigation.push(
                              context,
                              AddBidPage(
                                uid: B.id,
                              ),
                              Routes.BIDPAGE);
                        }
                      },
                      child: Text('Add Bid'),
                    ),
                  )
                ],
              ),
      ),
      body: Column(
        children: [
          Card(
            elevation: 4,
            margin:
                const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 10),
            child: ListTile(
              trailing: Icon(Icons.circle, color: statusColor),
              leading: ratingWidget(B.rating, B.name, context),
              title: Text(B.name),
              subtitle: Text(shortBio.toString().trim()),
              // UserPage.show(context, users[ix].id),
            ),
          ),
          Container(
            child: TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                label: Text('Bio'),
              ),
              controller: bioTextController,
              minLines: 6,
              maxLines: 10,
              enabled: false,
            ),
            padding:
                const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 10),
          ),
          Divider(),
          Expanded(
            child: OtherBidInList(
              B: B,
              database: myUserPageViewModel.database,
              // alreadyExists: (bool value) => isPresent = value,
              // onTrailingIconClick: (BidIn bidIn) async {
              //   CustomDialogs.loader(true, context);
              //   await myUserPageViewModel.cancelBid(bidId: bidIn.id, B: B.id);
              //   isPresent = false;
              //   CustomDialogs.loader(false, context);
              // },
            ),
          ),
        ],
      ),
    );
  }

  Widget ratingWidget(score, name, context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            0 <= score
                ? Icon(Icons.change_history, color: Colors.green)
                : Transform.rotate(
                    angle: pi,
                    child: Icon(Icons.change_history,
                        color: Color.fromRGBO(211, 91, 122, 1))),
            SizedBox(height: 4),
            Text(score.toString(), style: Theme.of(context).textTheme.caption)
          ],
        ),
        SizedBox(width: 10),
        Container(
          height: 40,
          width: 40,
          child: Center(
              child: Text("${name.toString().isNotEmpty ? name : "X"}"
                  .substring(0, 1)
                  .toUpperCase())),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color.fromRGBO(214, 219, 134, 1),
          ),
        )
      ],
    );
  }
}
