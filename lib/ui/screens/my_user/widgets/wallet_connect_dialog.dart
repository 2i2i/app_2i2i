import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';

import '../../../../infrastructure/commons/keys.dart';
import '../../../../infrastructure/commons/utils.dart';
import '../../../../infrastructure/data_access_layer/accounts/abstract_account.dart';
import '../../../../infrastructure/data_access_layer/accounts/walletconnect_account.dart';
import '../../../../infrastructure/data_access_layer/services/logging.dart';
import '../../../../infrastructure/providers/all_providers.dart';
import '../../../../infrastructure/providers/my_account_provider/my_account_page_view_model.dart';
import '../../../commons/custom_dialogs.dart';
import '../../my_account/widgets/qr_image_widget.dart';

class WalletConnectDialog extends ConsumerStatefulWidget {
  const WalletConnectDialog({Key? key}) : super(key: key);

  @override
  ConsumerState<WalletConnectDialog> createState() => _WalletConnectDialogState();
}

class _WalletConnectDialogState extends ConsumerState<WalletConnectDialog> {
  String _displayUri = '';
  ValueNotifier<bool> isDialogOpen = ValueNotifier(false);

  @override
  void initState() {
    ref.read(myAccountPageViewModelProvider).initMethod();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(kToolbarHeight),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            Keys.walletConnect.tr(context),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.black),
          ),
          SizedBox(height: 16),
          Container(
            height: kToolbarHeight,
            alignment: Alignment.center,
            child: Text(
              Keys.receiveSendCoin.tr(context),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyText1?.copyWith(color: Colors.black),
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(Keys.close.tr(context)),
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    // Share.share('${Keys.comeAndHangOut.tr(context)}:\n$message');
                    final myAccountPageViewModel = ref.read(myAccountPageViewModelProvider);
                    final address = await _createSession(myAccountPageViewModel, myAccountPageViewModel.accountService!);
                    Navigator.of(context).pop(address);
                  },
                  child: Text(Keys.connect.tr(context)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Future<String?> _createSession(MyAccountPageViewModel myAccountPageViewModel, AccountService accountService) async {
    String id = DateTime.now().toString();
    final connector = await WalletConnectAccount.newConnector(id);
    final account = WalletConnectAccount.fromNewConnector(
      accountService: accountService,
      connector: connector,
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
      await account.save(id);
      if (account.address.isNotEmpty) await myAccountPageViewModel.updateDBWithNewAccount(account.address, type: 'WC');
      await myAccountPageViewModel.updateAccounts();
      await account.setMainAccount();
      await myAccountPageViewModel.getWalletAccount();
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
      try {
        if (defaultTargetPlatform == TargetPlatform.iOS) {
          final bridge = await getWCBridge();
          launchUri = Uri(
            scheme: 'algorand-wc',
            host: 'wc',
            queryParameters: {'uri': _displayUri, 'bridge': bridge}, //"https://wallet-connect-d.perawallet.app"},
          );
        } else {
          launchUri = Uri.parse(_displayUri);
        }
        isAvailable = await launchUrl(launchUri);
      } on PlatformException catch (err) {
        print(err);
      }
      if (!isAvailable) {
        await launchUrl(
            Uri.parse(Platform.isAndroid
                ? 'https://play.google.com/store/apps/details?id=com.algorand.android'
                : 'https://apps.apple.com/us/app/pera-algo-wallet/id1459898525'),
            mode: LaunchMode.externalApplication);
      }
    }
  }
}
