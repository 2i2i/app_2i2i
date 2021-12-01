import 'dart:math';

import 'package:app_2i2i/common/theme.dart';
import 'package:app_2i2i/models/user.dart';
import 'package:app_2i2i/pages/home/wait_page.dart';
import 'package:app_2i2i/pages/user_bid/ui/other_bid_list.dart';
import 'package:app_2i2i/services/all_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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

  @override
  Widget build(BuildContext context) {
    final authStateChanges = ref.watch(authStateChangesProvider);
    if (authStateChanges is AsyncLoading) return WaitPage();
    final userPageViewModel = ref.watch(userPageViewModelProvider(widget.uid));
    if (userPageViewModel == null) return WaitPage();

    userModel = userPageViewModel.user;
    bioTextController.text = userModel?.bio ?? "";

    final shortBioStart = userModel!.bio.indexOf(RegExp(r'\s')) + 1;
    int aPoint = shortBioStart + 10;
    int bPoint = userModel!.bio.length;
    final shortBioEnd = min(aPoint, bPoint);
    final shortBio = userModel!.bio.substring(shortBioStart, shortBioEnd);
    final score = ((userModel?.upVotes ?? 0) - (userModel?.downVotes ?? 0));
    var statusColor = AppTheme().green;
    if (userModel!.status == 'OFFLINE') statusColor = AppTheme().gray;
    if (userModel!.locked) statusColor = AppTheme().red;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme().lightGray,
        leading: IconButton(
            iconSize: 35,
            onPressed: () => context.goNamed('home'),
            icon: Icon(Icons.navigate_before,color: AppTheme().black)),
        centerTitle: true,
        title: Image.asset('assets/logo.png', height: 30, fit: BoxFit.contain),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: authStateChanges.data!.value!.uid == userModel?.id
            ? null
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CaptionText(
                      title: "Do you want to bid for ${userModel?.name}",
                      textColor: Theme.of(context).hintColor),
                  SizedBox(height: 12),
                  Container(
                    height: 35,
                    child: ElevatedButton(
                  child: ButtonText(title: "BID"),
                        onPressed: () => context.goNamed('addbidpage',
                            params: {'uid': userModel!.id}),
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                AppTheme().lightGreen),
                            shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10))))),
              width: MediaQuery.of(context).size.width / 3.5,
            )
          ],
        ),
      ),
      body: Column(
        children: [
         /* SizedBox(height: 4),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
                color: AppTheme().lightBeige,
                borderRadius: BorderRadius.circular(5)),
            height: kToolbarHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                    iconSize: 35,
                    onPressed: () => context.goNamed('home'),
                    icon: Icon(Icons.navigate_before)),
                SizedBox(width: 10),
                TitleText(title: userModel!.name),
              ],
            ),
          ),*/
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
              title: TitleText(title: userModel!.name,maxLine: 1),
              subtitle: CaptionText(title: shortBio.toString().trim(),textColor: AppTheme().hintColor,maxLine: 1),
              onTap: () => context.goNamed('user', params: {
                'uid': userModel!.id,
              }), // UserPage.show(context, users[ix].id),
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
            child: OtherBidList(user: userModel),
          ),
        ],
      ),
    );
  }

  Widget ratingWidget(score, name, context) {
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