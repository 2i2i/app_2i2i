import 'package:app_2i2i/accounts/abstract_account.dart';
import 'package:app_2i2i/accounts/walletconnect_account.dart';
import 'package:app_2i2i/common/custom_app_bar.dart';
import 'package:app_2i2i/common/custom_dialogs.dart';
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
        appBar: CustomAppbar(
          title: "My Account",
          hideLeading: true,
        ),
        body: Stack(
          fit: StackFit.expand,
          children: [
            Visibility(
              visible: myAccountPageViewModel.isLoading,
              child: WaitPage(),
            ),
            Visibility(
              visible: _displayUri.isNotEmpty,
              child: Center(
                child: QrImage(data: _displayUri),
              ),
            ),
            Visibility(
              visible: _displayUri.isEmpty,
              child: ListView(
                children: List.generate(
                    myAccountPageViewModel.accounts?.length??0,
                    (index) {
                      log(F+' accounts ${myAccountPageViewModel.accounts![index].address}');
                      return AccountInfo(
                        key: ObjectKey(myAccountPageViewModel.accounts![index].address),
                          account: myAccountPageViewModel.accounts![index],
                      );
                    },
                ),
              ),
            )
          ],
        ),
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
                      CustomDialogs.loader(true, context);
                      await myAccountPageViewModel.addLocalAccount();
                       CustomDialogs.loader(false, context,rootNavigator: true);
                    },
                  ),
                  SpeedDialChild(
                    child: Image.asset('walletconnect-circle-white.png'),
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
