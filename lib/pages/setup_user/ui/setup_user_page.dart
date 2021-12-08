import 'package:app_2i2i/common/custom_dialogs.dart';
import 'package:app_2i2i/common/custom_navigation.dart';
import 'package:app_2i2i/constants/strings.dart';
import 'package:app_2i2i/common/text_utils.dart';
import 'package:app_2i2i/common/theme.dart';
import 'package:app_2i2i/pages/app/test_banner.dart';
import 'package:app_2i2i/pages/home/home_page.dart';
import 'package:app_2i2i/pages/setup_user/provider/setup_user_view_model.dart';
import 'package:app_2i2i/services/all_providers.dart';
import 'package:app_2i2i/services/logging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SetupUserPage extends ConsumerStatefulWidget {
  const SetupUserPage({Key? key}) : super(key: key);

  @override
  _SetupUserPageState createState() => _SetupUserPageState();
}

class _SetupUserPageState extends ConsumerState<SetupUserPage> {
  @override
  void initState() {
    super.initState();
    /*WidgetsBinding.instance!.addPostFrameCallback((_) {
      ref.read(setupUserViewModelProvider).createAuthAndStartAlgorand();
    });*/
  }

  @override
  Widget build(BuildContext context) {
    SetupUserViewModel setupUserViewModel =
        ref.watch(setupUserViewModelProvider);
    return TestBanner(
        widget: Scaffold(
            appBar: AppBar(
              toolbarHeight: 100,
              title: Image.asset(
                'assets/logo.png',
                scale: 5,
              ),
            ),
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: setupUserViewModel.nameSet &&
                        setupUserViewModel.bioSet &&
                        setupUserViewModel.workDone
                    ? () {
                        pressGo(context, setupUserViewModel);
                      }
                    : null,
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        setupUserViewModel.nameSet &&
                                setupUserViewModel.bioSet &&
                                setupUserViewModel.workDone
                            ? AppTheme().buttonBackground
                            : Theme.of(context).disabledColor.withOpacity(0.2)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.0),
                    ))),
                child: ListTile(
                    leading: setupUserViewModel.workDone
                        ? Icon(
                            Icons.check,
                            color: Color.fromRGBO(60, 84, 68, 1),
                          )
                        : Column(
                          children: [
                            Container(child: CircularProgressIndicator(),height: 40,width: 40,),
                          ],
                        ),
                    contentPadding: EdgeInsets.zero,
                    trailing: Icon(Icons.arrow_forward_ios_rounded),
                    title: ButtonText(
                        textAlign: TextAlign.center,
                        title: "Save and Enter",
                        textColor: AppTheme().black)),
              ),
            ),
            body: SingleChildScrollView(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                    ? Text('')
                    : Text(setupUserViewModel.message),
              ],
            ))));
  }

  void pressGo(BuildContext context, SetupUserViewModel setupUserViewModel) async {
    log('SignUpPage - pressGo - 1');
    CustomDialogs.loader(true, context);
    log('SignUpPage - pressGo - 2');
    await setupUserViewModel.updateBio();
    log('SignUpPage - pressGo - 3');
    CustomDialogs.loader(false, context);
    log('SignUpPage - pressGo - 4');
    CustomNavigation.push(context, HomePage());
  }
}
