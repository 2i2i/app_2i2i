import 'dart:math';

import 'package:app_2i2i/models/user.dart';
import 'package:app_2i2i/app/home/my_user/my_user_page_view_model.dart';
import 'package:app_2i2i/app/home/wait_page.dart';
import 'package:app_2i2i/services/logging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_2i2i/app/home/search/user_bids.dart';
import 'package:app_2i2i/services/all_providers.dart';

class MyUserPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    log('MyUserPage - build');
    final uid = ref.watch(myUIDProvider)!;
    log('MyUserPage - build - uid=$uid');
    final userPrivateAsyncValue = ref.watch(userPrivateProvider(uid));
    log('MyUserPage - build - userPrivateAsyncValue=$userPrivateAsyncValue');
    final myUserPageViewModel = ref.watch(myUserPageViewModelProvider);
    log('MyUserPage - build - myUserPageViewModel=$myUserPageViewModel');
    // final algorandAddressValue = ref.watch(algorandAddressProvider);
    // log('MyUserPage - build - algorandAddressValue=$algorandAddressValue');

    if (myUserPageViewModel == null) return WaitPage();

    return Scaffold(
      appBar: AppBar(
        title: Text(myUserPageViewModel.user.name),
      ),
      body: _buildContents(
          context,
          ref,
          myUserPageViewModel,
          // algorandAddressValue,
          userPrivateAsyncValue,
          myUserPageViewModel.user),
    );
  }
}

Future<String?> _editBio(BuildContext context, String currentBio) async {
  final TextEditingController bio = TextEditingController(text: currentBio);
  return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Edit Bio'),
          children: <Widget>[
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
                    onPressed: () => Navigator.pop(context, bio.text))),
          ],
        );
      });
}

Widget _buildContents(
    BuildContext context,
    WidgetRef ref,
    MyUserPageViewModel? myUserPageViewModel,
    // AsyncValue<String?> algorandAddressValue,
    AsyncValue<UserModelPrivate> userPrivateAsyncValue,
    UserModel user) {
  log('MyUserPage - _buildContents');

  if (myUserPageViewModel == null) return Container();
  // if (algorandAddressValue is AsyncLoading) return Container();
  if (userPrivateAsyncValue is AsyncLoading) return Container();

  return Column(
    children: [
      Container(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 0),
          child: ElevatedButton.icon(
              onPressed: () async {
                final newBio = await _editBio(context, user.bio);
                if (newBio != null) {
                  myUserPageViewModel.changeBio(newBio);
                }
              },
              icon: Icon(Icons.edit),
              label: Text('Edit Bio'))),
      Divider(),
      Expanded(
          child: Row(
        children: [
          Expanded(
              child: UserBids(
            bidsIds: myUserPageViewModel.user.bidsIn,
            title: 'Bids In',
            noBidsText: 'no bids in for user',
            // onTap: myUserPageViewModel.acceptBid,
            leading: Icon(
              Icons.label_important,
              color: Colors.green,
            ),
            trailingIcon: Icon(Icons.check_circle, color: Colors.green),
            onTrailingIconClick: myUserPageViewModel.acceptBid,
            // trailing: IconButton(onPressed: onPressed, icon: ),
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
              onTrailingIconClick: myUserPageViewModel.cancelBid,
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
