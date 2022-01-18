import 'package:app_2i2i/ui/commons/custom_alert_widget.dart';
import 'package:app_2i2i/ui/commons/custom_app_bar.dart';
import 'package:app_2i2i/ui/commons/custom_navigation.dart';
import 'package:app_2i2i/ui/screens/my_account/create_local_account.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../infrastructure/data_access_layer/accounts/abstract_account.dart';
import '../../../infrastructure/data_access_layer/accounts/walletconnect_account.dart';
import '../../../infrastructure/data_access_layer/services/logging.dart';
import '../../../infrastructure/providers/all_providers.dart';
import '../../../infrastructure/providers/my_account_provider/my_account_page_view_model.dart';
import '../home/wait_page.dart';
import 'recover_account.dart';
import 'widgets/account_info.dart';
import 'widgets/qr_image_widget.dart';

class MyAccountPage extends ConsumerStatefulWidget {
  const MyAccountPage({Key? key}) : super(key: key);

  @override
  _MyAccountPageState createState() => _MyAccountPageState();
}

class _MyAccountPageState extends ConsumerState<MyAccountPage> {
  // wallet connect part
  String _displayUri = '';
  bool isDialogOpen = false;

  Future _createSession(MyAccountPageViewModel myAccountPageViewModel,
      AccountService accountService) async {
    final account = WalletConnectAccount.fromNewConnector(
      accountService: accountService,
    );
    // Create a new session
    if (!account.connector.connected) {
      await account.connector.createSession(
        chainId: 4160,
        onDisplayUri: (uri) => _changeDisplayUri(uri),
      );
      await account.save();
      await myAccountPageViewModel.updateAccounts();
      await account.setMainAccount();
      _displayUri = '';
      if (isDialogOpen && mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    } else {
      log('_MyAccountPageState - _createSession - connector already connected');
    }
  }

  bool isMobile = defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.android;

  Future _changeDisplayUri(String uri) async {
    log('_changeDisplayUri - uri=$uri');
    _displayUri = uri;
    if (mounted) {
      setState(() {});
    }
    if (isMobile) {
      await launch(uri);
    } else {
      isDialogOpen = true;
      await showDialog(
        context: context,
        builder: (context) => QrImagePage(imageUrl: _displayUri),
        barrierDismissible: false,
      );
    }
  }
  // wallet connect part

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
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            itemBuilder: (BuildContext context, int index) {
              return AccountInfo(
                true,
                key: ObjectKey(myAccountPageViewModel.accounts![index].address),
                account: myAccountPageViewModel.accounts![index],
              );
            },
          )
        ],
      ),
      /*floatingActionButton: Padding(
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
        ),*/
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          onClickAdd(context);
        },
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

  void onClickAdd(BuildContext context) {
    CustomAlertWidget.showBidAlert(
      context,
      Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              onTap: () async {
                Navigator.of(context).maybePop();
                final myAccountPageViewModel =
                    ref.read(myAccountPageViewModelProvider);
                await _createSession(myAccountPageViewModel,
                    myAccountPageViewModel.accountService!);
              },
              leading: Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        spreadRadius: 0.5,
                      )
                    ]),
                alignment: Alignment.center,
                child: Image.asset(
                  'assets/wallet_connect.png',
                  height: 30,
                  width: 30,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              title: Text('Wallet account'),
              subtitle: Text('I want to connect a 3rd party wallet'),
              trailing: Icon(Icons.navigate_next),
            ),
            Padding(
              padding: EdgeInsets.only(left: 85),
              child: Divider(),
            ),
            ListTile(
              onTap: () {
                Navigator.of(context).maybePop();
                Future.delayed(Duration.zero).then(
                  (value) {
                    CustomNavigation.push(
                        context, RecoverAccountPage(), 'recover');
                  },
                );
              },
              leading: Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        spreadRadius: 0.5,
                      )
                    ]),
                alignment: Alignment.center,
                child: SvgPicture.asset(
                  'assets/icons/recover.svg',
                  height: 15,
                  width: 15,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              title: Text('Recover with passphase'),
              subtitle: Text('I know the 25 secret words'),
              trailing: Icon(Icons.navigate_next),
            ),
            Padding(
              padding: EdgeInsets.only(left: 85),
              child: Divider(),
            ),
            ListTile(
              onTap: () async {
                Navigator.of(context).maybePop();
                Future.delayed(Duration.zero).then((value) {
                  CustomNavigation.push(
                      context, CreateLocalAccount(), 'CreateLocalAccount');
                });
              },
              leading: Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        spreadRadius: 0.5,
                      )
                    ]),
                alignment: Alignment.center,
                child: SvgPicture.asset(
                  'assets/icons/wallet.svg',
                  height: 15,
                  width: 15,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              title: Text('Add Local Account'),
              subtitle: Text('Create a local account on this device'),
              trailing: Icon(Icons.navigate_next),
            ),
          ],
        ),
      ),
    );
  }
}
