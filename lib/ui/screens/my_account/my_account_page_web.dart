import 'package:app_2i2i/infrastructure/commons/keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../infrastructure/providers/all_providers.dart';
import '../app/wait_page.dart';
import 'widgets/account_info.dart';
import 'widgets/add_account_options_widget.dart';

class MyAccountPageWeb extends ConsumerStatefulWidget {
  const MyAccountPageWeb({Key? key}) : super(key: key);

  @override
  _MyAccountPageState createState() => _MyAccountPageState();
}

class _MyAccountPageState extends ConsumerState<MyAccountPageWeb> {
  @override
  void initState() {
    super.initState();
    ref.read(myAccountPageViewModelProvider).initMethod();
  }

  ValueNotifier<bool> showBottomSheet = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    final myAccountPageViewModel = ref.watch(myAccountPageViewModelProvider);
    return Scaffold(
      backgroundColor: Theme.of(context).splashColor,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              Keys.wallet.tr(context),
              style: Theme.of(context).textTheme.subtitle1,
            ),
            SizedBox(
              height: 15,
            ),
            Text(
              'Here you can manage your wallet, recover with passphrase, add local account....',
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              softWrap: false,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            SizedBox(
              height: kRadialReactionRadius - 8,
            ),
            Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: kRadialReactionRadius * 2,
                  ),
                  Visibility(
                    visible: myAccountPageViewModel.addresses.length > 0,
                    child: ValueListenableBuilder(
                      valueListenable: showBottomSheet,
                      builder: (BuildContext context, bool value, Widget? child) {
                        return IconButton(
                          alignment: Alignment.topCenter,
                          color: Theme.of(context).colorScheme.secondary,
                          onPressed: () {
                            showBottomSheet.value = !showBottomSheet.value;
                          },
                          icon: Icon(
                            value ? Icons.close : Icons.add_box,
                            size: 35,
                          ),
                        );
                      },
                    ),
                  ),
                  Builder(
                    builder: (context) {
                      if (myAccountPageViewModel.isLoading) {
                        return WaitPage(
                          isCupertino: true,
                        );
                      }
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: myAccountPageViewModel.addresses.length,
                        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width / 30, vertical: MediaQuery.of(context).size.height / 50),
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
                    },
                  ),
                  Visibility(
                    visible: myAccountPageViewModel.addresses.length == 0 /* (myAccountPageViewModel.isLoading =! true) &&*/,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height / 6,
                        ),
                        Container(
                          height: MediaQuery.of(context).size.height / 20,
                          child: Image.asset(
                            'assets/no_data.png',
                            fit: BoxFit.fitWidth,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height / 60,
                        ),
                        Text(
                          'No wallet data found !',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).disabledColor),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height / 35,
                        ),
                        ValueListenableBuilder(
                          valueListenable: showBottomSheet,
                          builder: (BuildContext context, bool value, Widget? child) {
                            return IconButton(
                              color: Theme.of(context).colorScheme.secondary,
                              onPressed: () {
                                showBottomSheet.value = !showBottomSheet.value;
                              },
                              icon: Icon(
                                value ? Icons.close : Icons.add_box,
                                size: 35,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
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
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(14),
                    topRight: Radius.circular(14),
                  ),
                  child: Container(
                    child: AddAccountOptionsWidgets(showBottom: showBottomSheet),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                    ),
                  ),
                ),
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
