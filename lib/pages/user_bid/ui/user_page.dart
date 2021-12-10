import 'dart:math';

import 'package:app_2i2i/common/custom_app_bar.dart';
import 'package:app_2i2i/common/custom_dialogs.dart';
import 'package:app_2i2i/common/custom_navigation.dart';
import 'package:app_2i2i/common/theme.dart';
import 'package:app_2i2i/models/bid.dart';
import 'package:app_2i2i/models/user.dart';
import 'package:app_2i2i/pages/add_bid/ui/add_bid_page.dart';
import 'package:app_2i2i/pages/home/wait_page.dart';
import 'package:app_2i2i/pages/user_bid/ui/other_bid_list.dart';
import 'package:app_2i2i/routes/app_routes.dart';
import 'package:app_2i2i/services/all_providers.dart';
import 'package:app_2i2i/services/logging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/text_utils.dart';

class UserPage extends ConsumerStatefulWidget {
  UserPage({required this.uid});

  final String uid;

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends ConsumerState<UserPage> {
  final TextEditingController bioTextController = TextEditingController();

  UserModel? userModel;
  bool isPresent = false;

  @override
  Widget build(BuildContext context) {
    final authStateChanges = ref.watch(authStateChangesProvider);
    if (authStateChanges is AsyncLoading) return WaitPage();

    final myUserPageViewModel = ref.watch(myUserPageViewModelProvider);
    if (myUserPageViewModel == null) return WaitPage();

    final userPageViewModel = ref.watch(userPageViewModelProvider(widget.uid));
    if (userPageViewModel == null) return WaitPage();

    userModel = userPageViewModel.user;
    bioTextController.text = userModel?.bio ?? '';

    final shortBioStart = userModel!.bio.indexOf(RegExp(r'\s')) + 1;
    int aPoint = shortBioStart + 10;
    int bPoint = userModel!.bio.length;
    final shortBioEnd = min(aPoint, bPoint);
    final shortBio = userModel!.bio.substring(shortBioStart, shortBioEnd);
    final score = userModel!.upVotes - userModel!.downVotes;
    var statusColor = AppTheme().green;
    if (userModel!.status == 'OFFLINE') statusColor = AppTheme().gray;
    if (userModel!.locked) statusColor = AppTheme().red;

    return Scaffold(
      appBar: CustomAppbar(
        actions: (authStateChanges.data!.value!.uid != userModel!.id)
            ? [
                IconButton(
                    onPressed: () {}, // TODO
                    // async {
                    //   await myUserPageViewModel.setUserPrivate(
                    //       context: context,
                    //       uid: widget.uid,
                    //       userPrivate: UserModelPrivate(friends: [widget.uid]));
                    // },
                    icon: Icon(Icons.favorite_border_rounded,
                        color: AppTheme().black)),
                SizedBox(width: 6)
              ]
            : null,
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: authStateChanges.data!.value!.uid == userModel!.id
            ? null
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CaptionText(
                      maxLine: 1,
                      title: isPresent
                          ? "Your already bid this user, First cancel bid"
                          : "Do you want to bid for ${userModel!.name}",
                      textColor: Theme.of(context).hintColor),
                  SizedBox(height: 12),
                  Visibility(
                    visible: !isPresent,
                    child: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              AppTheme().buttonBackground),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.0),
                          ))),
                      onPressed: () {
                        if (!isPresent) {
                          CustomNavigation.push(
                              context,
                              AddBidPage(
                                uid: userModel!.id,
                              ),
                              Routes.BIDPAGE);
                        }
                      },
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: ButtonText(
                            textAlign: TextAlign.center,
                            title: "ADD BID",
                            textColor: AppTheme().black),
                      ),
                    ),
                  )
                ],
              ),
      ),
      body: Column(
        children: [
          Container(
            margin:
                const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 10),
            decoration: BoxDecoration(
                border:
                    Border.all(color: Colors.grey.withOpacity(0.6), width: 1.5),
                borderRadius: BorderRadius.circular(5)),
            child: ListTile(
              trailing: Icon(Icons.circle, color: statusColor),
              leading: ratingWidget(score, userModel!.name, context),
              title: TitleText(title: userModel!.name, maxLine: 1),
              subtitle: CaptionText(
                  title: shortBio.toString().trim(),
                  textColor: AppTheme().hintColor,
                  maxLine: 1),
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
            child: OtherBidList(
              user: userModel!,
              alreadyExists: (bool value) => isPresent = value,
              onTrailingIconClick: (Bid bid) async {
                CustomDialogs.loader(true, context);
                await myUserPageViewModel.cancelBid(bid);
                isPresent = false;
                CustomDialogs.loader(false, context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget ratingWidget(score, name, context) {
    log('ratingWidget');
    final scoreString = (0 <= score ? '+' : '-') + score.toString();

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
            Text(scoreString, style: Theme.of(context).textTheme.caption)
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
