import 'dart:io';

import 'package:app_2i2i/infrastructure/routes/app_routes.dart';
import 'package:app_2i2i/ui/commons/custom_alert_widget.dart';
import 'package:app_2i2i/ui/commons/custom_dialogs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';
import '../../../../infrastructure/commons/keys.dart';
import '../../../../infrastructure/data_access_layer/accounts/abstract_account.dart';
import '../../../../infrastructure/data_access_layer/accounts/walletconnect_account.dart';
import '../../../../infrastructure/data_access_layer/services/logging.dart';
import '../../../../infrastructure/providers/all_providers.dart';
import '../../../../infrastructure/providers/my_account_provider/my_account_page_view_model.dart';
import 'qr_image_widget.dart';

class AddAccountOptionsWidgets extends ConsumerStatefulWidget {
  final ValueNotifier? showBottom;
  final ValueChanged<String?>? accountAddListener;

  const AddAccountOptionsWidgets(
      {Key? key, this.showBottom, this.accountAddListener})
      : super(key: key);

  @override
  _AddAccountOptionsWidgetsState createState() =>
      _AddAccountOptionsWidgetsState();
}

class _AddAccountOptionsWidgetsState
    extends ConsumerState<AddAccountOptionsWidgets> {
  String _displayUri = '';

  ValueNotifier<bool> isDialogOpen = ValueNotifier(false);

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
              final address = await _createSession(myAccountPageViewModel,
                  myAccountPageViewModel.accountService!);
              if (widget.accountAddListener != null) {
                widget.accountAddListener!.call(address);
              }
              widget.showBottom?.value = false;
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
            title: Text(Keys.walletAccount.tr(context)),
            subtitle: Text(Keys.walletAccountMsg.tr(context)),
            trailing: Icon(Icons.navigate_next),
          ),
          Padding(
            padding: EdgeInsets.only(left: 85),
            child: Divider(),
          ),
          ListTile(
            onTap: () {
              widget.showBottom?.value = false;
              context.pushNamed(Routes.recover.nameFromPath());
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
            title: Text(Keys.recoverPassphrase.tr(context)),
            subtitle: Text(Keys.recoverPassPhaseMsg.tr(context)),
            trailing: Icon(Icons.navigate_next),
          ),
          Padding(
            padding: EdgeInsets.only(left: 85),
            child: Divider(),
          ),
          ListTile(
            onTap: () async {
              widget.showBottom?.value = false;
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
            title: Text(Keys.addLocalAccount.tr(context)),
            subtitle: Text(Keys.addLocalAccountMsg.tr(context)),
            trailing: Icon(Icons.navigate_next),
          ),
        ],
      ),
    );
  }

  Future<String?> _createSession(MyAccountPageViewModel myAccountPageViewModel,
      AccountService accountService) async {
    final account = WalletConnectAccount.fromNewConnector(
      accountService: accountService,
    );
    // Create a new session
    if (!account.connector.connected) {
      SessionStatus sessionStatus = await account.connector.connect(
        chainId: 4160,
        onDisplayUri: (uri) => _changeDisplayUri(uri),
      );

      isDialogOpen.value = false;
      CustomDialogs.loader(true, context, rootNavigator: true);
      log("$sessionStatus");
      await account.save();
      if (account.address.isNotEmpty)
        await myAccountPageViewModel.updateDBWithNewAccount(account.address,
            type: 'WC');
      await myAccountPageViewModel.updateAccounts();
      await account.setMainAccount();
      CustomDialogs.loader(false, context, rootNavigator: true);
      _displayUri = '';
      return account.address;
    } else {
      log('_MyAccountPageState - _createSession - connector already connected');
      return null;
    }
  }

  Future _changeDisplayUri(String url) async {
    bool isAvailable = false;
    _displayUri = url;
    if (mounted) {
      setState(() {});
    }
    if (kIsWeb) {
      isDialogOpen.value = true;
      await showDialog(
        context: context,
        builder: (context) => ValueListenableBuilder(
          valueListenable: isDialogOpen,
          builder: (BuildContext context, bool value, Widget? child) {
            if (!value) {
              Navigator.of(context).pop();
            }
            return QrImagePage(imageUrl: _displayUri);
          },
        ),
        barrierDismissible: true,
      );
    } else {
      var launchUri;
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        launchUri = Uri(
          scheme: 'algorand-wc',
          host: 'wc',
          queryParameters: {
            'uri': _displayUri,
            'bridge': "https://wallet-connect-d.perawallet.app"
          },
        );
      } else {
        launchUri = Uri.parse(_displayUri);
      }
      try {
        isAvailable = await canLaunchUrl(launchUri);
      } on PlatformException catch (err) {
        print(err);
      }
      if (isAvailable) {
        Future.delayed(Duration.zero).then(
          (value) => showCupertinoDialog(
            context: context,
            builder: (context) => CustomAlertWidget.confirmDialog(
              context,
              description:
                  Keys.transactionConfirmMsg.tr(context),
              title: Keys.pleaseConfirm.tr(context),
              onPressed: () async {
                isAvailable = await launchUrl(launchUri);
              },
            ),
          ),
        );
      } else {
        await launchUrl(
            Uri.parse(Platform.isAndroid
                ? 'https://play.google.com/store/apps/details?id=com.algorand.android'
                : 'https://apps.apple.com/us/app/pera-algo-wallet/id1459898525'),
            mode: LaunchMode.externalApplication);
      }
    }
  }
}
