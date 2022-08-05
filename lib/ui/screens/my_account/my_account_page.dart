import 'package:app_2i2i/infrastructure/commons/keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../infrastructure/providers/all_providers.dart';
import '../app/wait_page.dart';
import 'widgets/account_info.dart';
import 'widgets/add_account_options_widget.dart';

class MyAccountPage extends ConsumerStatefulWidget {
  const MyAccountPage({Key? key}) : super(key: key);

  @override
  _MyAccountPageState createState() => _MyAccountPageState();
}

class _MyAccountPageState extends ConsumerState<MyAccountPage> {
  @override
  void initState() {
    super.initState();
    // Future.delayed(Duration(seconds: 2)).then((value) {
    ref.read(myAccountPageViewModelProvider).initMethod();
    // });
  }

  ValueNotifier<bool> showBottomSheet = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    final myAccountPageViewModel = ref.watch(myAccountPageViewModelProvider);
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Text(
                Keys.wallet.tr(context),
                style: Theme.of(context).textTheme.headline5,
              ),
            ),
            SizedBox(height: 15),
            Expanded(
              child: Builder(builder: (context) {
                if (myAccountPageViewModel.isLoading) {
                  return WaitPage(
                    isCupertino: true,
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: myAccountPageViewModel.walletConnectAccounts.length,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  itemBuilder: (BuildContext context, int index) {
                    String address = myAccountPageViewModel.addresses[index];
                    return AccountInfo(
                      true,
                      index: index,
                      key: ObjectKey(myAccountPageViewModel.addresses[index]),
                      address: address,
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        // onPressed: () => CustomAlertWidget.showBidAlert(context, AddAccountOptionsWidgets()),
        onPressed: () {
          showBottomSheet.value = !showBottomSheet.value;
        },
        child: ValueListenableBuilder(
          valueListenable: showBottomSheet,
          builder: (BuildContext context, bool value, Widget? child) {
            return Icon(
              value ? Icons.close : Icons.add,
              color: Theme.of(context).cardColor,
              size: 35,
            );
          },
        ),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      bottomSheet: BottomSheet(
        onClosing: () {},
        builder: (BuildContext context) {
          return ValueListenableBuilder(
            valueListenable: showBottomSheet,
            builder: (BuildContext context, bool value, Widget? child) {
              return Visibility(
                visible: value,
                child: Container(
                    child: AddAccountOptionsWidgets(showBottom: showBottomSheet),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    )),
              );
            },
          );
        },
        elevation: 0,
        enableDrag: true,
        backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.black : Theme.of(context).scaffoldBackgroundColor,
      ),
    );
  }
}
