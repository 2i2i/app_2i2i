import 'package:app_2i2i/infrastructure/data_access_layer/repository/firestore_database.dart';
import 'package:app_2i2i/infrastructure/providers/all_providers.dart';
import 'package:app_2i2i/ui/commons/custom_dialogs.dart';
import 'package:app_2i2i/ui/screens/home/wait_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../infrastructure/commons/keys.dart';
import '../../../infrastructure/data_access_layer/services/logging.dart';

class RecoverAccountPage extends ConsumerStatefulWidget {
  const RecoverAccountPage({Key? key}) : super(key: key);

  @override
  _RecoverAccountPageState createState() => _RecoverAccountPageState();
}

class _RecoverAccountPageState extends ConsumerState<RecoverAccountPage> {
  int currentIndex = 0;
  List<TextEditingController> listOfString = List.generate(25, (index) => TextEditingController());
  final formGlobalKey = GlobalKey<FormState>();
  bool isInValid = true;

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(myUIDProvider);
    if (uid == null) return WaitPage();
    final database = ref.watch(databaseProvider);

    if (currentIndex >= listOfString.length) {
      currentIndex = listOfString.length - 1;
    }
    if (currentIndex < 0) {
      currentIndex = 0;
    }
    return Scaffold(
        appBar: AppBar(),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            Keys.recoverAccounts.tr(context),
                            style: Theme.of(context).textTheme.headline5,
                          ),
                          SizedBox(height: 5),
                          Text(
                            Keys.recoverAccountWarning.tr(context),
                            style: Theme.of(context).textTheme.caption,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        var clipData = await Clipboard.getData(Clipboard.kTextPlain);
                        if (clipData is ClipboardData) {
                          List<String> lst = clipData.text.toString().split(' ');
                          for (int i = 0; i < lst.length; i++) {
                            listOfString.elementAt(i).text = lst[i];
                          }
                          if (mounted) {
                            setState(() {});
                          }
                        }
                      },
                      icon: Icon(Icons.paste),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Form(
                  key: formGlobalKey,
                  child: GridView.count(
                    shrinkWrap: true,
                    primary: false,
                    crossAxisCount: 2,
                    childAspectRatio: 3,
                    padding: EdgeInsets.only(bottom: 10),
                    children: List.generate(
                      listOfString.length,
                      (index) {
                        String val = listOfString[index].text;
                        bool filled = val.trim().isNotEmpty;
                        if (!filled) {
                          if (currentIndex == index) {
                            val = 'Typing..';
                          } else {
                            val = '---';
                          }
                        }
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Expanded(
                                  child: Text('${index < 9 ? 0 : ""}${(index + 1)}',
                                      style: Theme.of(context).textTheme.bodyMedium)),
                              SizedBox(width: 10),
                              Expanded(
                                flex: 6,
                                child: TextFormField(
                                  textInputAction:
                                      (listOfString.length - 1 == index) ? TextInputAction.done : TextInputAction.next,
                                  controller: listOfString[index],
                                  onChanged: (value) => checkIsInValid(),
                                  // onEditingComplete: () => checkIsInValid(),
                                  cursorColor: Theme.of(context).primaryColorDark,
                                  decoration: new InputDecoration(
                                      focusedBorder: UnderlineInputBorder(
                                          borderSide: new BorderSide(color: Theme.of(context).iconTheme.color!)),
                                      border: UnderlineInputBorder(
                                          borderSide: new BorderSide(color: Theme.of(context).iconTheme.color!)),
                                      errorBorder: UnderlineInputBorder(
                                          borderSide: new BorderSide(color: Theme.of(context).iconTheme.color!)),
                                      isDense: true,
                                      enabledBorder: new UnderlineInputBorder(
                                          borderSide: new BorderSide(color: Theme.of(context).iconTheme.color!))),
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: ElevatedButton(
            onPressed: isInValid ? null : () => onClickRecover(uid, database),
            child: Text(Keys.recover.tr(context)),
          ),
        ));
  }

  void onClickPrevious() {
    if (currentIndex > 0) {
      currentIndex = currentIndex - 1;
    }
    if (mounted) {
      setState(() {});
    }
  }

  void onClickNext() {
    if (!isLast()) {
      currentIndex = currentIndex + 1;
    }
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> onClickRecover(String uid, FirestoreDatabase database) async {
    final myAccountPageViewModel = ref.read(myAccountPageViewModelProvider);
    List<String> keys = listOfString.map((e) => e.text).toList();
    CustomDialogs.loader(true, context);
    try {
      final account = await myAccountPageViewModel.recoverAccount(keys);
      await account.setMainAccount();
      context.pop();
    } catch (e) {
      CustomDialogs.showToastMessage(context, "We cant find account from this keys");
      log(e.toString());
    }
    CustomDialogs.loader(false, context);
  }

  void checkIsInValid() {
    var list = listOfString.map((e) => e.text.trim().isNotEmpty).toSet().toList();
    isInValid = list.contains(false);
    setState(() {});
  }

  bool isLast() => currentIndex == (listOfString.length - 1);
}
