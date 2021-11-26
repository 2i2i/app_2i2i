import 'package:app_2i2i/accounts/abstract_account.dart';
import 'package:app_2i2i/accounts/walletconnect_account.dart';
import 'package:app_2i2i/common/progress_dialog.dart';
import 'package:app_2i2i/pages/account/provider/my_account_page_view_model.dart';
import 'package:app_2i2i/pages/account/ui/account_info.dart';
import 'package:app_2i2i/pages/home/wait_page.dart';
import 'package:app_2i2i/repository/algorand_service.dart';
import 'package:app_2i2i/services/all_providers.dart';
import 'package:app_2i2i/services/logging.dart';
import 'package:flutter/cupertino.dart';
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

  Future _createSession(MyAccountPageViewModel myAccountPageViewModel,
      AccountService accountService, AlgorandService algorand) async {
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

    final algorand = ref.watch(algorandProvider);

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
                      return AccountInfo(
                          account: myAccountPageViewModel.accounts![i]);
                    },
                  )),
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () async {
        //     final assetIdString = await _optIn(context);
        //     if (assetIdString == null) return;
        //     final assetId = int.tryParse(assetIdString);
        //     if (assetId == null) return;

        //     await myAccountPageViewModel.optIn(assetId);
        //   },
        //   tooltip: 'ASA opt-in',
        //   child: const Text('Opt-In'),
        //   shape: RoundedRectangleBorder(
        //       borderRadius: BorderRadius.all(Radius.circular(15.0))),
        // ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              // FloatingActionButton.extended(
              //   onPressed: () async {
              //     final assetIdString = await _optIn(context);
              //     if (assetIdString == null) return;
              //     final assetId = int.tryParse(assetIdString);
              //     if (assetId == null) return;

              //     await myAccountPageViewModel.optIn(assetId);
              //   },
              //   label: Row(
              //     children: [
              //       const Icon(Icons.system_security_update),
              //       const Text('Opt-In')
              //     ],
              //   ),
              //   tooltip: 'ASA opt-in',
              // ),
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
                      await _createSession(myAccountPageViewModel,
                          myAccountPageViewModel.accountService!, algorand);
                    },
                  ),
                ],
              ),
            ],
          ),
        ));
  }
}

// Future<String?> _optIn(BuildContext context) async {
//   final TextEditingController assetId = TextEditingController();
//   return showDialog<String>(
//       context: context,
//       builder: (BuildContext context) {
//         return SimpleDialog(
//           title: const Text('ASA Opt-In'),
//           children: <Widget>[
//             Container(
//                 padding: const EdgeInsets.only(
//                     top: 5, left: 20, right: 20, bottom: 10),
//                 child: TextField(
//                   decoration: InputDecoration(
//                     hintText: 'numeric asset id',
//                     border: OutlineInputBorder(),
//                     label: Text('Asset Id'),
//                   ),
//                   // minLines: 1,
//                   maxLines: 1,
//                   controller: assetId,
//                 )),
//             Container(
//                 padding: const EdgeInsets.only(
//                     top: 10, left: 50, right: 50, bottom: 10),
//                 child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                         primary: Color.fromRGBO(173, 154, 178, 1)),
//                     child: Text('Cancel'),
//                     onPressed: () => Navigator.pop(context, null))),
//             Container(
//                 padding: const EdgeInsets.only(
//                     top: 10, left: 50, right: 50, bottom: 10),
//                 child: ElevatedButton(
//                     // style: ElevatedButton.styleFrom(primary: Color.fromRGBO(237, 124, 135, 1)),
//                     child: Text('Opt In'),
//                     onPressed: () => Navigator.pop(context, assetId.text))),
//           ],
//         );
//       });
// }
