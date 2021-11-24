import 'package:app_2i2i/app/home/wait_page.dart';
import 'package:app_2i2i/common/progress_dialog.dart';
import 'package:app_2i2i/services/all_providers.dart';
import 'package:app_2i2i/services/logging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AddBidPage extends ConsumerStatefulWidget {
  const AddBidPage({Key? key, required this.uid}) : super(key: key);

  final String uid;

  @override
  _AddBidPageState createState() => _AddBidPageState(uid: uid);
}

class _AddBidPageState extends ConsumerState<AddBidPage> {
  _AddBidPageState({required this.uid});
  final String uid;
  int speedNum = 0;
  int assetIndex = 0;
  double budgetPercentage = 100.0;
  late String chosenAssetString;
  int numAccount = 1;

  AppBar appBar(String name) {
    return AppBar(
      title: Text('Add bid for $name'),
      leading: IconButton(
          onPressed: () => context.goNamed('user', params: {'uid': uid}),
          icon: Icon(
            Icons.navigate_before,
            size: 40,
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    log('_AddBidPageState - build');

    final addBidPageViewModel =
        ref.watch(addBidPageViewModelProvider(uid)).state;
    log('_AddBidPageState - addBidPageViewModel=$addBidPageViewModel');
    if (addBidPageViewModel == null) return WaitPage();
    if (addBidPageViewModel.submitting) return WaitPage();

    final balancesTestnet = ref.watch(balancesTestnetProvider);
    log('_AddBidPageState - balancesTestnet=$balancesTestnet');
    if (balancesTestnet is AsyncLoading || balancesTestnet.data == null)
      return WaitPage();

    if (balancesTestnet.data!.value.isEmpty)
      return Scaffold(
        appBar: appBar(addBidPageViewModel.user.name),
        body: Center(
          child: Text('No accounts connected'),
        ),
      );

    log('addBidPageViewModel.balancesStrings=${addBidPageViewModel.balancesStrings}');

    chosenAssetString =
        addBidPageViewModel.balancesStrings(numAccount)[assetIndex];

    return Scaffold(
      appBar: appBar(addBidPageViewModel.user.name),
      body: Column(
        children: [
          Container(
              padding: const EdgeInsets.only(
                  top: 20, left: 20, right: 20, bottom: 10),
              child: TextField(
                decoration: InputDecoration(
                  hintText:
                      'How many coin/sec? (in base units, e.g. microAlgo)',
                  border: OutlineInputBorder(),
                  label: Text('Speed'),
                ),
                onChanged: (value) {
                  setState(() {
                    speedNum = int.parse(value);
                  });
                },
              )),
          Container(
            padding:
                const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 10),
            child: Text(
              'Num Account',
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          Container(
              padding: const EdgeInsets.only(
                  top: 0, left: 20, right: 20, bottom: 100),
              child: DropdownButton<int>(
                onChanged: (int? newValue) {
                  setState(() {
                    numAccount = newValue!;
                  });
                },
                value: numAccount,
                items: [
                  for (var i = 1; i <= addBidPageViewModel.balances.length; i++)
                    DropdownMenuItem<int>(
                      child: Text(i.toString()),
                      value: i,
                    )
                ],
              )),
          Container(
            padding:
                const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 10),
            child: Text(
              'Asset ID',
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          Container(
              padding: const EdgeInsets.only(
                  top: 0, left: 20, right: 20, bottom: 100),
              child: DropdownButton<String>(
                onChanged: (String? newValue) {
                  setState(() {
                    assetIndex = addBidPageViewModel
                        .balancesStrings(numAccount)
                        .indexOf(newValue!);
                    chosenAssetString = newValue;
                  });
                },
                value: chosenAssetString,
                items: addBidPageViewModel
                    .balancesStrings(numAccount)
                    .map((e) => DropdownMenuItem<String>(
                          child: Text(e),
                          value: e,
                        ))
                    .toList(),
              )),
          Container(
            padding:
                const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 10),
            child: Text(
              'Budget',
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          Container(
            child: Slider(
                min: 0,
                max: 100,
                divisions: 100,
                value: budgetPercentage,
                onChanged: (x) {
                  setState(() {
                    budgetPercentage = x;
                  });
                }),
          ),
          Container(
            padding:
                const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 10),
            child: Text(
              'Max duration: ' +
                  addBidPageViewModel.duration(
                      numAccount, speedNum, assetIndex, budgetPercentage),
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          ElevatedButton(
            onPressed: addBidPageViewModel.submitting
                ? null
                : () async {
                    log('await addBidPageViewModel.addBid() - assetIndex=$assetIndex - speedNum=$speedNum');
                    ProgressDialog.loader(true, context);
                    await addBidPageViewModel.addBid(
                        numAccount: numAccount,
                        assetIndex: assetIndex,
                        speedNum: speedNum,
                        budgetPercentage: budgetPercentage).then((value) {
                          print('$value');
                    });
                    ProgressDialog.loader(false, context);
                    context.goNamed('user', params: {'uid': uid});
                  },
            child: Text('Add', style: Theme.of(context).textTheme.headline6),
          ),
        ],
      ),
    );
  }
}
