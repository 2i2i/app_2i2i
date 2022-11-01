import 'package:app_2i2i/infrastructure/commons/keys.dart';
import 'package:app_2i2i/infrastructure/data_access_layer/accounts/abstract_account.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../infrastructure/providers/all_providers.dart';
import '../../app/wait_page.dart';
import '../../my_account/widgets/account_asset_info.dart';

class AccountSelectionPage extends ConsumerStatefulWidget {
  const AccountSelectionPage({Key? key}) : super(key: key);

  @override
  _AccountSelectionPageState createState() => _AccountSelectionPageState();
}

class _AccountSelectionPageState extends ConsumerState<AccountSelectionPage> {
  @override
  void initState() {
    super.initState();
    // Future.delayed(Duration(seconds: 2)).then((value) {
    ref.read(myAccountPageViewModelProvider).initMethod();
    // });
  }

  ValueNotifier<bool> showBottomSheet = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    final myAccountPageViewModel = ref.watch(myAccountPageViewModelProvider);
    final addressBalanceCombos = myAccountPageViewModel.addressWithASABalance;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 15),
          Text(
            Keys.wallet.tr(context),
            style: Theme.of(context).textTheme.headline5,
          ),
          SizedBox(height: 15),
          Builder(
            builder: (context) {
              if (myAccountPageViewModel.isLoading) {
                return WaitPage(
                  isCupertino: true,
                );
              }

              if (!myAccountPageViewModel.isLoading && addressBalanceCombos.isEmpty) {
                return Text('No account are available');
              }

              return ListView.builder(
                shrinkWrap: true,
                itemCount: addressBalanceCombos.length,
                padding: EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                itemBuilder: (BuildContext context, int index) {
                  String address = addressBalanceCombos[index].item1;
                  Balance balance = addressBalanceCombos[index].item2;
                  return Container(
                    width: double.infinity,
                    child: Row(
                      children: [
                        Radio(
                          value: true,
                          groupValue: index,
                          onChanged: (value) {},
                        ),
                        Expanded(
                          child: AccountAssetInfo(
                            true,
                            index: index,
                            key: ObjectKey(addressBalanceCombos[index]),
                            address: address,
                            initBalance: balance,
                            isForSelection: true,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
