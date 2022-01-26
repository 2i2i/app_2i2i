import 'package:app_2i2i/infrastructure/data_access_layer/accounts/local_account.dart';
import 'package:app_2i2i/infrastructure/routes/app_routes.dart';
import 'package:app_2i2i/ui/commons/custom_dialogs.dart';
import 'package:app_2i2i/ui/commons/custom_navigation.dart';
import 'package:app_2i2i/ui/screens/my_account/create_local_account.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:url_launcher/url_launcher.dart';

import '../../../../infrastructure/commons/strings.dart';
import '../../../../infrastructure/data_access_layer/accounts/abstract_account.dart';
import '../../../../infrastructure/data_access_layer/accounts/walletconnect_account.dart';
import '../../../../infrastructure/data_access_layer/services/logging.dart';
import '../../../../infrastructure/providers/all_providers.dart';
import '../../../../infrastructure/providers/my_account_provider/my_account_page_view_model.dart';
import 'keys_widget.dart';
import 'qr_image_widget.dart';

class AddAccountOptionsWidgets extends ConsumerStatefulWidget {
  const AddAccountOptionsWidgets({Key? key}) : super(key: key);

  @override
  _AddAccountOptionsWidgetsState createState() =>
      _AddAccountOptionsWidgetsState();
}

class _AddAccountOptionsWidgetsState
    extends ConsumerState<AddAccountOptionsWidgets> {
  String _displayUri = '';

  bool isDialogOpen = false;

  bool isMobile = defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.android;
  late BuildContext buildContext;
  @override
  Widget build(BuildContext context) {
    buildContext = context;
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            onTap: () async {
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
            title: Text(Strings().walletAccount),
            subtitle: Text(Strings().walletAccountMsg),
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
                  context.pushNamed(Routes.recover.nameFromPath());
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
            title: Text(Strings().recoverPassphrase),
            subtitle: Text(Strings().recoverPassPhaseMsg),
            trailing: Icon(Icons.navigate_next),
          ),
          Padding(
            padding: EdgeInsets.only(left: 85),
            child: Divider(),
          ),
          ListTile(
            onTap: () async {
                Navigator.of(context).maybePop();
                context.pushNamed(Routes.createLocalAccount.nameFromPath());
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
            title: Text(Strings().addLocalAccount),
            subtitle: Text(Strings().addLocalAccountMsg),
            trailing: Icon(Icons.navigate_next),
          ),
        ],
      ),
    );
  }
  var val;
  onClickVerify(Map value){
    Navigator.of(context,rootNavigator: true).pop();
    val = value;
    print('value before $value');
    Future.delayed(Duration(seconds: 2)).then((value) {
      print('value after $val');
      Navigator.of(buildContext).pushNamed(
        Routes.verifyPerhaps,
        arguments:value,
      );
    });
  }

  Future _createSession(MyAccountPageViewModel myAccountPageViewModel, AccountService accountService) async {
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
      if (isDialogOpen) {
        Navigator.of(context,rootNavigator: true).pop();
        Navigator.of(context).pop();
      }
    } else {
      log('_MyAccountPageState - _createSession - connector already connected');
    }
  }

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
}
