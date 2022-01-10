import 'package:app_2i2i/infrastructure/providers/all_providers.dart';
import 'package:app_2i2i/ui/commons/custom_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RecoverAccountPage extends ConsumerStatefulWidget {
  const RecoverAccountPage({Key? key}) : super(key: key);

  @override
  _RecoverAccountPageState createState() => _RecoverAccountPageState();
}

class _RecoverAccountPageState extends ConsumerState<RecoverAccountPage> {
  int currentIndex = 0;
  List<TextEditingController> listOfString =
      List.generate(25, (index) => TextEditingController());

  @override
  Widget build(BuildContext context) {
    if (currentIndex >= listOfString.length) {
      currentIndex = listOfString.length - 1;
    }
    if (currentIndex < 0) {
      currentIndex = 0;
    }
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
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
                        'Recover account',
                        style: Theme.of(context).textTheme.headline5,
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Fill all 25 valid keys of your account that you want to recover',
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    var clipData =
                        await Clipboard.getData(Clipboard.kTextPlain);
                    if (clipData is ClipboardData) {
                      List<String> lst = clipData.text.toString().split(',');
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
            Expanded(
              child: GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                childAspectRatio: 5,
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
                    return ListTile(
                      contentPadding: EdgeInsets.symmetric(vertical: 5),
                      onTap: () {
                        currentIndex = index;
                        if (mounted) {
                          setState(() {});
                        }
                      },
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).primaryColor,
                        radius: 10,
                        child: Text(
                          '${index + 1}',
                          style: Theme.of(context)
                              .textTheme
                              .caption
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                      title: Text(
                        '$val',
                        style: Theme.of(context).textTheme.subtitle2?.copyWith(
                            color: filled
                                ? null
                                : Theme.of(context).disabledColor),
                        maxLines: 2,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomSheet(
        enableDrag: false,
        elevation: 20,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        constraints: BoxConstraints(
          minHeight: 100,
        ),
        builder: (BuildContext context) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 20),
                Text(
                  (currentIndex + 1).toString(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headline5,
                ),
                SizedBox(height: 20),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey.shade200,
                    child: IconButton(
                      icon: Icon(Icons.navigate_before),
                      onPressed: currentIndex == 0
                          ? null
                          : () {
                              onClickPrevious();
                            },
                    ),
                  ),
                  title: TextFormField(
                    autofocus: false,
                    controller: listOfString.elementAt(currentIndex),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: 'Enter value',
                      filled: true,
                      fillColor: Colors.grey.shade200,
                    ),
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (val) {
                      onClickNext();
                    },
                  ),
                  trailing: CircleAvatar(
                    backgroundColor: Colors.grey.shade200,
                    child: IconButton(
                      icon: Icon(Icons.navigate_next),
                      onPressed: isLast()
                          ? null
                          : () {
                              onClickNext();
                            },
                    ),
                  ),
                ),
                SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: ElevatedButton(
                    onPressed: isInValid()
                        ? null
                        : () {
                            onClickRecover();
                          },
                    child: Text('Recover'),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          );
        },
        onClosing: () {},
      ),
    );
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

  Future<void> onClickRecover() async {
    final myAccountPageViewModel = ref.read(myAccountPageViewModelProvider);
    List<String> keys = listOfString.map((e) => e.text).toList();
    CustomDialogs.loader(true, context);
    try {
      await myAccountPageViewModel.recoverAccount(keys);
      Navigator.of(context).maybePop();
    } catch (e) {
      print(e);
    }
    CustomDialogs.loader(false, context);
  }

  bool isInValid() {
    var list =
        listOfString.map((e) => e.text.trim().isNotEmpty).toSet().toList();
    return list.contains(false);
  }

  bool isLast() => currentIndex == (listOfString.length - 1);
}
