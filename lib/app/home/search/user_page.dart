import 'package:app_2i2i/app/home/wait_page.dart';
import 'package:app_2i2i/services/logging.dart';
import 'package:app_2i2i/services/all_providers.dart';
import 'package:flutter/material.dart';
import 'package:app_2i2i/app/home/search/user_bids.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class UserPage extends ConsumerWidget {
  UserPage({required this.uid});
  final String uid;

  Row paramsRow(String key, String value) {
    return Row(
      children: [
        Text(key),
        SizedBox(
          width: 10,
        ),
        Text(value),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authStateChanges = ref.watch(authStateChangesProvider);
    if (authStateChanges is AsyncLoading) return WaitPage();
    log('UserPage - build');
    final userPageViewModel = ref.watch(userPageViewModelProvider(uid));
    log('UserPage - build - userPageViewModel=$userPageViewModel');
    if (userPageViewModel == null) return WaitPage();
    log('UserPage - build - userPageViewModel!=null');

    final TextEditingController bio =
        TextEditingController(text: userPageViewModel.user.bio);

    return Scaffold(
      appBar: AppBar(
        title: Text(userPageViewModel.user.name),
        leading: IconButton(
            onPressed: () => context.goNamed('home'),
            // onPressed: () => context.goNamed('home', params: {'tab': 'search'}),
            icon: Icon(
              Icons.navigate_before,
              size: 40,
            )),
      ),
      body: Column(
        children: [
          // params(userPageViewModel.user),
          Container(
            child: TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                label: Text('Bio'),
              ),
              controller: bio,
              minLines: 6,
              maxLines: 10,
              enabled: false,
            ),
            padding:
                const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 10),
          ),
          Divider(),
          Expanded(
              child: UserBids(
            bidsIds: userPageViewModel.user.bidsIn,
            title: 'Bids In',
            noBidsText: 'no bid ins for user',
            leading: Icon(
              Icons.label_important,
              color: Colors.green,
            ),
            // onTap: (_) => null,
          )),
        ],
      ),
      floatingActionButton: authStateChanges.data!.value!.uid == uid
          ? Container()
          : FloatingActionButton(
              onPressed: () => context.goNamed('addbidpage',
                  params: {'uid': userPageViewModel.user.id}),
              tooltip: 'add bid',
              child: const Icon(Icons.add),
            ),
    );
  }
}
