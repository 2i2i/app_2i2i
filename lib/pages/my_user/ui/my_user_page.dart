import 'dart:math';

import 'package:app_2i2i/common/progress_dialog.dart';
import 'package:app_2i2i/common/text_utils.dart';
import 'package:app_2i2i/models/bid.dart';
import 'package:app_2i2i/models/user.dart';
import 'package:app_2i2i/pages/home/wait_page.dart';
import 'package:app_2i2i/pages/my_user/provider/my_user_page_view_model.dart';
import 'package:app_2i2i/pages/user_bid/ui/user_bids.dart';
import 'package:app_2i2i/services/all_providers.dart';
import 'package:app_2i2i/services/logging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyUserPage extends ConsumerStatefulWidget {
  const MyUserPage({Key? key}) : super(key: key);

  @override
  _MyUserPageState createState() => _MyUserPageState();
}

class _MyUserPageState extends ConsumerState<MyUserPage> {
  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(myUIDProvider)!;
    final userPrivateAsyncValue = ref.watch(userPrivateProvider(uid));
    final myUserPageViewModel = ref.watch(myUserPageViewModelProvider);

    return myUserPageViewModel == null
        ? WaitPage()
        : Scaffold(
            appBar: AppBar(
              title: Text(myUserPageViewModel.user.name),
            ),

            body: _buildContents(context, ref, myUserPageViewModel,
                userPrivateAsyncValue, myUserPageViewModel.user),
          );
  }

  Widget _buildContents(
      BuildContext context,
      WidgetRef ref,
      MyUserPageViewModel? myUserPageViewModel,
      AsyncValue<UserModelPrivate> userPrivateAsyncValue,
      UserModel user) {
    log('MyUserPage - _buildContents');

    if (myUserPageViewModel == null) return Container();
    if (userPrivateAsyncValue is AsyncLoading) return Container();

    return Column(
      children: [
        Container(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 0),
            child: ElevatedButton.icon(
                onPressed: () async {
                  final newValues = await _editNameAndBio(context, user.name, user.bio);
                  if (newValues != null) {
                    myUserPageViewModel.changeNameAndBio(newValues['name']!, newValues['bio']!);
                  }
                },
                icon: Icon(Icons.edit),
                label: Text('Edit Name and Bio'))),
        Divider(),
        Expanded  (
            child: Row(
          children: [
            Expanded(
                child: UserBids(
              bidsIds: myUserPageViewModel.user.bidsIn,
              title: 'Bids In',
              noBidsText: 'no bids in for user',
              leading: Icon(
                Icons.label_important,
                color: Colors.green,
              ),
              trailingIcon: Icon(Icons.check_circle, color: Colors.green),
              onTrailingIconClick: myUserPageViewModel.acceptBid,
            )),
            VerticalDivider(),
            Expanded(
                child: userPrivateAsyncValue.when(
                    data: (UserModelPrivate userPrivate) {
              log('MyUserPage - _buildContents - data - userPrivate=$userPrivate userPrivate.bidsOut=${userPrivate.bidsOut}');
              return UserBids(
                bidsIds: userPrivate.bidsOut.map((b) => b.bid).toList(),
                title: 'Bids Out',
                noBidsText: 'no bids out for user',
                // onTap: myUserPageViewModel.cancelBid
                leading: Transform.rotate(
                    angle: pi,
                    child: Icon(
                      Icons.label_important,
                      color: Color.fromRGBO(104, 160, 242, 1),
                    )),
                trailingIcon: Icon(
                  Icons.cancel,
                  color: Color.fromRGBO(104, 160, 242, 1),
                ),
                onTrailingIconClick: (Bid bid) async {
                  ProgressDialog.loader(true, context);
                  await myUserPageViewModel.cancelBid(bid);
                  ProgressDialog.loader(false, context);
                },
              );
            }, loading: () {
              log('MyUserPage - _buildContents - loading');
              return const CircularProgressIndicator();
            }, error: (_, __) {
              log('MyUserPage - _buildContents - error');
              return const Center(child: Text('error'));
            })),
          ],
        ))
      ],
    );
  }

  Future<Map<String, String>?> _editNameAndBio(BuildContext context, String currentName, String currentBio) async {
    final TextEditingController name = TextEditingController(text: currentName);
    final TextEditingController bio = TextEditingController(text: currentBio);
    return showDialog<Map<String, String>>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text('Edit Name and Bio'),
            children: <Widget>[
              Container(
                  padding: const EdgeInsets.only(
                      top: 5, left: 20, right: 20, bottom: 10),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText:
                          'my cool username',
                      border: OutlineInputBorder(),
                      label: Text('Name'),
                    ),
                    minLines: 1,
                    maxLines: 1,
                    controller: name,
                  )),
              Container(
                  padding: const EdgeInsets.only(
                      top: 5, left: 20, right: 20, bottom: 10),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText:
                          'name i love to #talk and #cook. can also give #math #lessons',
                      border: OutlineInputBorder(),
                      label: Text('Bio'),
                    ),
                    minLines: 4,
                    maxLines: null,
                    controller: bio,
                  )),
              Container(
                  padding: const EdgeInsets.only(
                      top: 10, left: 50, right: 50, bottom: 10),
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: Color.fromRGBO(173, 154, 178, 1)),
                      child: Text('Cancel'),
                      onPressed: () => Navigator.pop(context, null))),
              Container(
                  padding: const EdgeInsets.only(
                      top: 10, left: 50, right: 50, bottom: 10),
                  child: ElevatedButton(
                      // style: ElevatedButton.styleFrom(primary: Color.fromRGBO(237, 124, 135, 1)),
                      child: Text('Save'),
                      onPressed: () => Navigator.pop(context, {'name': name.text, 'bio': bio.text}))),
            ],
          );
        });
  }
}
