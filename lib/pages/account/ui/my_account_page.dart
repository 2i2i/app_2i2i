
import 'package:app_2i2i/accounts/abstract_account.dart';
import 'package:app_2i2i/accounts/walletconnect_account.dart';
import 'package:app_2i2i/common/progress_dialog.dart';
import 'package:app_2i2i/pages/account/provider/my_account_page_view_model.dart';
import 'package:app_2i2i/pages/account/ui/account_info.dart';
import 'package:app_2i2i/pages/home/wait_page.dart';
import 'package:app_2i2i/services/all_providers.dart';
import 'package:app_2i2i/services/logging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:qr_flutter/qr_flutter.dart';

class MyAccountPage extends ConsumerStatefulWidget {
  const MyAccountPage({Key? key}) : super(key: key);

  @override
  _MyAccountPageState createState() => _MyAccountPageState();
}

class _MyAccountPageState extends ConsumerState<MyAccountPage> {
  // wallet connect part
  // should ideally not be in ui, but i cannot get it work right now
  // Create a connector
  // final _connector = WalletConnect(
  //   bridge: 'https://bridge.walletconnect.org',
  //   clientMeta: const PeerMeta(
  //     name: 'WalletConnect',
  //     description: 'WalletConnect Developer App',
  //     url: 'https://walletconnect.org',
  //     icons: [
  //       'https://gblobscdn.gitbook.com/spaces%2F-LJJeCjcLrr53DcT1Ml7%2Favatar.png?alt=media'
  //     ],
  //   ),
  // );
  String _displayUri = '';
  void _changeDisplayUri(String uri) {
    log('_changeDisplayUri - uri=$uri');
    setState(() {
      _displayUri = uri;
    });
  }

  Future _createSession(MyAccountPageViewModel myAccountPageViewModel, AccountService accountService) async {
    final account = WalletConnectAccount.fromNewConnector(accountService: accountService);
    // Create a new session
    if (!account.connector.connected) {
      // connector.on(
      //     'connect',
      //     (session) => log(
      //         '_MyAccountPageState - _createSession - connect - session=$session'));
      // connector.on(
      //     'session_update',
      //     (session) => log(
      //         '_MyAccountPageState - _createSession - session_update - session=$session'));
      // connector.on(
      //     'disconnect',
      //     (session) => log(
      //         '_MyAccountPageState - _createSession - disconnect - session=$session'));
      final session = await account.connector.createSession(
        chainId: 4160,
        onDisplayUri: (uri) => _changeDisplayUri(uri),
      );
      log('_MyAccountPageState - _createSession - session=$session');
      await account.save();
      await myAccountPageViewModel.updateAccounts();
      _displayUri = '';
      setState(() {});
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
        appBar: AppBar(
          title: const Text('My Account'),
        ),
        body: myAccountPageViewModel.isLoading
            ? WaitPage()
            : (_displayUri.isNotEmpty
                ? Center(child: QrImage(data: _displayUri))
                : ListView.builder(
                    itemCount: myAccountPageViewModel.accounts!.length,
                    itemBuilder: (_, i) {
                      return AccountInfo(account: myAccountPageViewModel.accounts![i]);
                    },
                  )),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SpeedDial(
                icon: Icons.add,
                tooltip: 'Add account',
                children: [
                  SpeedDialChild(
                    child: Icon(Icons.new_label),
                    onTap: () async {
                      ProgressDialog.loader(true, context);
                      await myAccountPageViewModel.addLocalAccount();
                      ProgressDialog.loader(false, context);
                    },
                  ),
                  SpeedDialChild(
                    child: Icon(Icons.folder_open_outlined),
                    onTap: () async {
                      await _createSession(myAccountPageViewModel, myAccountPageViewModel.accountService!);
                    },
                  ),
                ],
              ),
            ],
          ),
        ));
  }
}
