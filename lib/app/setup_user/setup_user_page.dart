// import 'package:app_2i2i/app/home/home_page.dart';
import 'package:app_2i2i/app/test_banner.dart';
// import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_2i2i/app/setup_user/setup_user_view_model.dart';
import 'package:app_2i2i/services/logging.dart';
import 'package:app_2i2i/services/all_providers.dart';
import 'package:go_router/go_router.dart';

class SetupUserPage extends ConsumerWidget {
  void pressGo(BuildContext context, SetupUserViewModel signUpViewModel) async {
    log('SignUpPage - pressGo');
    await signUpViewModel.createDatabaseUser();
    context.goNamed('home');
    // context.goNamed('home',
    // params: {'tab': EnumToString.convertToString(HomePageTabs.search)});
  }

  bool goButtonReady(signUpViewModel) {
    log('SignUpPage - goButtonReady');
    return signUpViewModel.bioSet && signUpViewModel.workDone;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    log('SetupUserPage - build');
    final setupUserViewModel = ref.watch(setupUserViewModelProvider);
    setupUserViewModel.createAuthAndStartAlgorand();
    log('SetupUserPage - build - setupUserViewModel=$setupUserViewModel');
    return TestBanner(Scaffold(
        appBar: AppBar(
          toolbarHeight: 150,
          title: Image.asset(
            'assets/logo.png',
            scale: 2,
          ),
        ),
        body: SingleChildScrollView(
            child: Column(
          children: [
            Container(
              child: TextField(
                decoration: InputDecoration(
                  hintText:
                      'username\n\nI love to #talk and #cook\nI can #teach',
                  border: OutlineInputBorder(),
                  label: Text('Write your bio'),
                ),
                minLines: 8,
                maxLines: null,
                onChanged: setupUserViewModel.setBio,
              ),
              padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
            ),
            Container(
              child: Text(
                'example: Solli I love #cooking and #design',
              ),
              padding: const EdgeInsets.only(
                  top: 5, left: 20, right: 20, bottom: 10),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
              ),
              child: Text(
                'username: ${setupUserViewModel.name}',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.left,
              ),
              padding: const EdgeInsets.only(
                  top: 20, left: 40, right: 40, bottom: 20),
              margin: const EdgeInsets.only(top: 15, bottom: 20),
            ),
            setupUserViewModel.workDone
                ? Icon(
                    Icons.check,
                    size: 50,
                    color: Color.fromRGBO(60, 84, 68, 1),
                  )
                : Container(
                    child: CircularProgressIndicator(),
                    padding: const EdgeInsets.only(
                        top: 10, left: 20, right: 20, bottom: 20),
                  ),
            setupUserViewModel.workDone
                ? Text('')
                : Text(setupUserViewModel.message),
            Container(
              child: ElevatedButton(
                  onPressed: goButtonReady(setupUserViewModel)
                      ? () => pressGo(context, setupUserViewModel)
                      : null,
                  child: Text('Save', style: TextStyle(fontSize: 20))),
              padding: const EdgeInsets.only(
                  top: 20, left: 20, right: 20, bottom: 20),
            ),
          ],
        ))));
  }
}
