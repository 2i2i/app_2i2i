// import 'package:app_2i2i/app/logging.dart';
import 'package:app_2i2i/app/home/wait_page.dart';
import 'package:app_2i2i/common/progress_dialog.dart';
import 'package:app_2i2i/pages/account/ui/account_info.dart';
import 'package:app_2i2i/services/all_providers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class MyAccountPage extends ConsumerStatefulWidget {
  const MyAccountPage({Key? key}) : super(key: key);

  @override
  _MyAccountPageState createState() => _MyAccountPageState();
}

class _MyAccountPageState extends ConsumerState<MyAccountPage> {
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
            : ListView.builder(
                itemCount: myAccountPageViewModel.numAccounts,
                itemBuilder: (_, i) {
                  return AccountInfo(numAccount: i + 1);
                },
              ),
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
                      await myAccountPageViewModel.addAccount();
                      ProgressDialog.loader(false, context);
                    },
                  ),
                  SpeedDialChild(
                    child: Icon(Icons.folder_open_outlined),
                    onTap: () => debugPrint("SECOND CHILD"),
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
