import 'package:app_2i2i/accounts/abstract_account.dart';
import 'package:app_2i2i/accounts/walletconnect_account.dart';
import 'package:app_2i2i/common/custom_dialogs.dart';
import 'package:app_2i2i/pages/home/wait_page.dart';
import 'package:app_2i2i/pages/my_account/provider/my_account_page_view_model.dart';
import 'package:app_2i2i/pages/my_account/ui/widgets/qr_image_widget.dart';
import 'package:app_2i2i/services/all_providers.dart';
import 'package:app_2i2i/services/logging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_2i2i/common/custom_app_bar.dart';
import 'package:app_2i2i/constants/strings.dart';
import 'package:app_2i2i/pages/my_account/ui/widgets/account_info.dart';

class MyAccountPage extends ConsumerStatefulWidget {
  const MyAccountPage({Key? key}) : super(key: key);

  @override
  _MyAccountPageState createState() => _MyAccountPageState();
}

class _MyAccountPageState extends ConsumerState<MyAccountPage> {
  // wallet connect part
  String _displayUri = '';
  Future _changeDisplayUri(String uri) async {
    log('_changeDisplayUri - uri=$uri');
    setState(() {
      _displayUri = uri;
    });
    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android) {
      await launch(uri);
    } else {
      await showDialog(
        context: context,
        builder: (context) => QrImagePage(imageUrl: _displayUri),
        barrierDismissible: false,
      );
    }
  }

  Future _createSession(MyAccountPageViewModel myAccountPageViewModel,
      AccountService accountService) async {
    final account =
        WalletConnectAccount.fromNewConnector(accountService: accountService);
    // Create a new session
    if (!account.connector.connected) {
      final session = await account.connector.createSession(
        chainId: 4160,
        onDisplayUri: (uri) => _changeDisplayUri(uri),
      );
      log('_MyAccountPageState - _createSession - session=$session');
      await account.save();
      await myAccountPageViewModel.updateAccounts();
      _displayUri = '';
    } else {
      log('_MyAccountPageState - _createSession - connector already connected');
    }
  }
  // wallet connect part

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      ref.read(myAccountPageViewModelProvider).initMethod();
    });
  }

  @override
  Widget build(BuildContext context) {
    final myAccountPageViewModel = ref.watch(myAccountPageViewModelProvider);

    return Scaffold(
        appBar: CustomAppbar(),
        body: Stack(
          fit: StackFit.expand,
          children: [
            Visibility(
              visible: myAccountPageViewModel.isLoading,
              child: WaitPage(),
            ),
            ListView.builder(
              itemCount: myAccountPageViewModel.accounts?.length ?? 0,
              padding: EdgeInsets.symmetric(horizontal: 20,vertical: 4),
              itemBuilder: (BuildContext context, int index) {
                return AccountInfo(
                  key: ObjectKey(
                      myAccountPageViewModel.accounts![index].address),
                  account: myAccountPageViewModel.accounts![index],
                );
              },
            )
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
       /* floatingActionButton: Padding(
          padding: const EdgeInsets.all(8.0),
          child: FloatingActionButton.extended(
            onPressed: () {
              // Add your onPressed code here!
            },
            label: Text(Strings().newCardTitle,style: Theme.of(context).textTheme.subtitle1!.copyWith(
              color: Theme.of(context).primaryColorLight
            ),),
            icon: Icon(Icons.add,color: Theme.of(context).primaryColorLight),
            backgroundColor: Theme.of(context).colorScheme.secondary,
          ),
        ),*/
        floatingActionButton: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SpeedDial(
            iconTheme: IconThemeData(
              color: Theme.of(context).primaryColorLight
            ),
            label: Text(Strings().newCardTitle,style: Theme.of(context).textTheme.bodyText1!.copyWith(
                color: Theme.of(context).primaryColorLight
            ),),
            icon: Icons.add,
            backgroundColor: Theme.of(context).colorScheme.secondary,
            children: [
              SpeedDialChild(
                child: Icon(Icons.smartphone),
                onTap: () async {
                  CustomDialogs.loader(true, context);
                  await myAccountPageViewModel.addLocalAccount();
                  CustomDialogs.loader(false, context, rootNavigator: true);
                },
              ),
              SpeedDialChild(
                child: Image.asset('walletconnect-circle-white.png'),
                onTap: () async {
                  await _createSession(myAccountPageViewModel,
                      myAccountPageViewModel.accountService!);
                },
              ),
            ],
          ),
        ));
  }
}