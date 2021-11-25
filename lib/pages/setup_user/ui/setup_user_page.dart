import 'package:app_2i2i/common/progress_dialog.dart';
import 'package:app_2i2i/common/strings.dart';
import 'package:app_2i2i/pages/app/test_banner.dart';
import 'package:app_2i2i/pages/setup_user/provider/setup_user_view_model.dart';
import 'package:app_2i2i/services/all_providers.dart';
import 'package:app_2i2i/services/logging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SetupUserPage extends ConsumerStatefulWidget {
  const SetupUserPage({Key? key}) : super(key: key);

  @override
  _SetupUserPageState createState() => _SetupUserPageState();
}

class _SetupUserPageState extends ConsumerState<SetupUserPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      ref.read(setupUserViewModelProvider).createAuthAndStartAlgorand();
    });
  }

  @override
  Widget build(BuildContext context) {
    SetupUserViewModel setupUserViewModel =
        ref.watch(setupUserViewModelProvider);
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
                  hintText: Strings().yourBioHint,
                  border: OutlineInputBorder(),
                  label: Text(Strings().writeYourBio),
                ),
                minLines: 8,
                maxLines: null,
                onChanged: setupUserViewModel.setBio,
              ),
              padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
            ),
            Container(
              child: Text(
                Strings().bioExample,
              ),
              padding: const EdgeInsets.only(
                  top: 5, left: 20, right: 20, bottom: 10),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
              ),
              child: Text(
                '${Strings().userName}: ${setupUserViewModel.name}',
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
                  child: Text(Strings().save, style: TextStyle(fontSize: 20))),
              padding: const EdgeInsets.only(
                  top: 20, left: 20, right: 20, bottom: 20),
            ),
          ],
        ))));
  }

  void pressGo(BuildContext context, SetupUserViewModel signUpViewModel) async {
    ProgressDialog.loader(true, context);
    await signUpViewModel.createDatabaseUser();
    ProgressDialog.loader(false, context);
    context.goNamed('home');
  }

  bool goButtonReady(signUpViewModel) {
    log('SignUpPage - goButtonReady');
    return signUpViewModel.bioSet && signUpViewModel.workDone;
  }
}