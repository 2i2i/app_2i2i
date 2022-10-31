import 'package:app_2i2i/infrastructure/data_access_layer/services/logging.dart';
import 'package:app_2i2i/ui/commons/custom_alert_widget.dart';
import 'package:app_2i2i/ui/layout/spacings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../infrastructure/commons/keys.dart';
import '../../../../infrastructure/data_access_layer/accounts/abstract_account.dart';
import '../../../../infrastructure/data_access_layer/accounts/walletconnect_account.dart';
import '../../../../infrastructure/providers/all_providers.dart';
import '../../../../infrastructure/providers/my_account_provider/my_account_page_view_model.dart';
import '../../../commons/custom.dart';

class ConnectDialog extends ConsumerStatefulWidget {
  const ConnectDialog({Key? key}) : super(key: key);

  @override
  ConsumerState<ConnectDialog> createState() => _ConnectDialogState();
}

class _ConnectDialogState extends ConsumerState<ConnectDialog> {
  int selectedIndex = 1;
  String walletConnectAddress = '';
  bool isFailed = false;

  // String _displayUri = ''; // never used
  ValueNotifier<bool> isDialogOpen = ValueNotifier(false);

  @override
  void initState() {
    ref.read(myAccountPageViewModelProvider).initMethod();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Padding(
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
                      Text(Keys.acceptBid.tr(context)),
                    ],
                  ),
                  Column(
                    children: [
                      checkContainer(walletConnectAddress.isNotEmpty, selectedIndex == 1, theme, isFailed),
                      Text(Keys.walletConnect.tr(context)),
                    ],
                  ),
                  Column(
                    children: [
                      checkContainer(false, selectedIndex == 2, theme),
                      Text(Keys.startTalk.tr(context)),
                    ],
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: AppSpacings.s40),
          Text(
            getDescForSelected(context),
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.justify,
          ),
          Visibility(
            visible: isFailed,
            child: Padding(
              padding: EdgeInsets.only(top: AppSpacings.s10),
              child: Text(
                Keys.failToConnect.tr(context),
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.errorColor),
                textAlign: TextAlign.justify,
              ),
            ),
          ),
          SizedBox(height: AppSpacings.s40),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(Keys.cancel.tr(context)),
                ),
              ),
              SizedBox(width: AppSpacings.s12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (selectedIndex == 1) {
                      onClickConnect();
                    } else if (!isFailed) {
                      Navigator.of(context).pop(walletConnectAddress);
                    }
                  },
                  child: Text(selectedIndex == 1 ? (isFailed ? Keys.retry.tr(context) : Keys.connect.tr(context)) : Keys.talk.tr(context)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  String getDescForSelected(BuildContext context) {
    if (selectedIndex == 1) {
      return Keys.walletDesMsg1.tr(context);
    }
    return Keys.walletDesMsg2.tr(context);
  }

  Widget checkContainer(bool check, bool selected, ThemeData theme, [bool? isFailed]) {
    return Container(
      color: Theme.of(context).cardColor,
      padding: EdgeInsets.symmetric(vertical: AppSpacings.s8),
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
        size: 28,
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
        onDisplayUri: (uri) => Custom.changeDisplayUri(context, uri, isDialogOpen: isDialogOpen),
      );

      isDialogOpen.value = false;
      CustomAlertWidget.loader(true, context, rootNavigator: true);
      await account.save(id);
      if (account.address.isNotEmpty) await myAccountPageViewModel.updateDBWithNewAccount(account.address, type: 'WC');
      await myAccountPageViewModel.updateAccounts();
      await account.setMainAccount();
      await myAccountPageViewModel.getWalletAccount();
      CustomAlertWidget.loader(false, context, rootNavigator: true);
      // _displayUri = ''; // never used
      return account.address;
    } else {
      log('_MyAccountPageState - _createSession - connector already connected');
      return null;
    }
  }
}
