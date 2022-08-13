import 'dart:io';

import 'package:app_2i2i/infrastructure/data_access_layer/services/logging.dart';
import 'package:app_2i2i/ui/commons/custom_alert_widget.dart';
import 'package:app_2i2i/ui/layout/spacings.dart';
import 'package:app_2i2i/ui/screens/my_account/widgets/qr_image_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../infrastructure/commons/utils.dart';
import '../../../../infrastructure/data_access_layer/accounts/abstract_account.dart';
import '../../../../infrastructure/data_access_layer/accounts/walletconnect_account.dart';
import '../../../../infrastructure/providers/all_providers.dart';
import '../../../../infrastructure/providers/my_account_provider/my_account_page_view_model.dart';

class ConnectDialog extends ConsumerStatefulWidget {
  const ConnectDialog({Key? key}) : super(key: key);

  @override
  ConsumerState<ConnectDialog> createState() => _ConnectDialogState();
}

class _ConnectDialogState extends ConsumerState<ConnectDialog> {
  int selectedIndex = 1;
  String walletConnectAddress = '';
  bool isFailed = false;

  String _displayUri = '';
  ValueNotifier<bool> isDialogOpen = ValueNotifier(false);

  @override
  void initState() {
    ref.read(myAccountPageViewModelProvider).initMethod();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(AppSpacings.s22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                divider(theme),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        checkContainer(true, false, theme),
                        Text('Accept Bid'),
                      ],
                    ),
                    Column(
                      children: [
                        checkContainer(walletConnectAddress.isNotEmpty, selectedIndex == 1, theme, isFailed),
                        Text('Wallet Connect'),
                      ],
                    ),
                    Column(
                      children: [
                        checkContainer(false, selectedIndex == 2, theme),
                        Text('Start Talk'),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: AppSpacings.s80),
            Text(
              getDescForSelected(),
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.justify,
            ),
            Visibility(
              visible: isFailed,
              child: Padding(
                padding: EdgeInsets.only(top: AppSpacings.s10),
                child: Text(
                  'Fail to connect. Please try again.',
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.errorColor),
                  textAlign: TextAlign.justify,
                ),
              ),
            ),
            SizedBox(height: AppSpacings.s80),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Cancel'),
                  ),
                ),
                SizedBox(width: AppSpacings.s12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (selectedIndex == 1) {
                        onClickConnect();
                      } else {
                        Navigator.of(context).pop(walletConnectAddress);
                      }
                    },
                    child: Text(selectedIndex == 1 ? (isFailed ? 'Retry' : 'Connect') : 'Talk'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  String getDescForSelected() {
    if (selectedIndex == 1) {
      return 'This is paid call and user will pay you for each second. Wallet is required to be connected for make transactions.';
    }
    return 'Your wallet has been connected successfully. Press talk to start video call.';
  }

  Widget checkContainer(bool check, bool selected, ThemeData theme, [bool? isFailed]) {
    return Container(
      color: theme.brightness == Brightness.dark ? Colors.black : Colors.white,
      padding: EdgeInsets.symmetric(vertical: AppSpacings.s10),
      child: Icon(
        isFailed == true
            ? Icons.cancel
            : check
                ? Icons.check_circle
                : Icons.circle_outlined,
        color: isFailed == true
            ? theme.errorColor
            : check || selected
                ? theme.colorScheme.secondary
                : null,
      ),
    );
  }

  Padding divider(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacings.s10, left: AppSpacings.s30, right: AppSpacings.s30),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: theme.colorScheme.secondary,
              thickness: 2,
            ),
          ),
          Expanded(
            child: Divider(
              color: selectedIndex == 2 ? theme.colorScheme.secondary : theme.iconTheme.color,
              thickness: 2,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> onClickConnect() async {
    final myAccountPageViewModel = ref.read(myAccountPageViewModelProvider);
    String? address = await _createSession(myAccountPageViewModel, myAccountPageViewModel.accountService!);
    isFailed = address == null || address.isEmpty;
    if (!isFailed) {
      walletConnectAddress = address!;
      selectedIndex = 2;
    }
    setState(() {});
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
      await account.connector.connect(
        chainId: 4160,
        onDisplayUri: (uri) => _changeDisplayUri(uri),
      );

      isDialogOpen.value = false;
      CustomAlertWidget.loader(true, context, rootNavigator: true);
      await account.save(id);
      if (account.address.isNotEmpty) await myAccountPageViewModel.updateDBWithNewAccount(account.address, type: 'WC');
      await myAccountPageViewModel.updateAccounts();
      await account.setMainAccount();
      await myAccountPageViewModel.getWalletAccount();
      CustomAlertWidget.loader(false, context, rootNavigator: true);
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
