import 'package:app_2i2i/infrastructure/commons/strings.dart';
import 'package:app_2i2i/ui/commons/custom_alert_widget.dart';
import 'package:app_2i2i/ui/commons/custom_app_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../infrastructure/providers/all_providers.dart';
import '../home/wait_page.dart';
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
    Future.delayed(Duration(seconds: 2)).then((value) {
      ref.read(myAccountPageViewModelProvider).initMethod();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final myAccountPageViewModel = ref.watch(myAccountPageViewModelProvider);
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: Padding(
        padding: EdgeInsets.only(right: 15,left: 15, bottom: 10,top: kIsWeb?10:31),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Text(
                Strings().wallet,
                style: Theme.of(context).textTheme.headline5,
              ),
            ),
            SizedBox(height: 15),
            Expanded(
              child: Builder(
                builder: (context) {
                  if(myAccountPageViewModel.isLoading){
                    return WaitPage(isCupertino: true,);
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: myAccountPageViewModel.accounts?.length ?? 0,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    itemBuilder: (BuildContext context, int index) {
                      return AccountInfo(
                        true,
                        key: ObjectKey(myAccountPageViewModel.accounts![index].address),
                        account: myAccountPageViewModel.accounts![index],
                      );
                    },
                  );
                }
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => CustomAlertWidget.showBidAlert(context, AddAccountOptionsWidgets()),
        child: Icon(
          Icons.add,
          color: Theme.of(context).cardColor,
          size: 35,
        ),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
