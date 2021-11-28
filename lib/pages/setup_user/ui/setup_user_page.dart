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
                  hintText: Strings().yourNameHint,
                  border: OutlineInputBorder(),
                  label: Text(Strings().writeYourName),
                ),
                minLines: 1,
                maxLines: 1,
                onChanged: setupUserViewModel.setName,
              ),
              padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
            ),
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
            setupUserViewModel.nameSet && setupUserViewModel.bioSet && setupUserViewModel.workDone ? Container(
              child: ElevatedButton(
                  onPressed: () => pressGo(context, setupUserViewModel),
                  child: Text(Strings().save, style: TextStyle(fontSize: 20))),
              padding: const EdgeInsets.only(
                  top: 20, left: 20, right: 20, bottom: 20),
            ) : Container(),
          ],
        ))));
  }

  void pressGo(BuildContext context, SetupUserViewModel setupUserViewModel) async {
    log('SignUpPage - pressGo - 1');
    ProgressDialog.loader(true, context);
    log('SignUpPage - pressGo - 2');
    await setupUserViewModel.updateBio();
    log('SignUpPage - pressGo - 3');
    ProgressDialog.loader(false, context);
    log('SignUpPage - pressGo - 4');
    context.goNamed('home');
  }
}
