import 'package:app_2i2i/infrastructure/commons/keys.dart';
import 'package:app_2i2i/infrastructure/data_access_layer/accounts/abstract_account.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../infrastructure/providers/all_providers.dart';
import '../../app/wait_page.dart';
import '../../my_account/widgets/account_asset_info.dart';

class AccountSelectionPage extends ConsumerStatefulWidget {
  final Function(String addr) onTapRedeemCoin;

  const AccountSelectionPage({
    Key? key,
    required this.onTapRedeemCoin,
  }) : super(key: key);

  @override
  _AccountSelectionPageState createState() => _AccountSelectionPageState();
}

class _AccountSelectionPageState extends ConsumerState<AccountSelectionPage> {
  @override
  void initState() {
    super.initState();
    ref.read(myAccountPageViewModelProvider).initMethod();
  }

  ValueNotifier<bool> showBottomSheet = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    final myAccountPageViewModel = ref.watch(myAccountPageViewModelProvider);
    final addressBalanceCombos = myAccountPageViewModel.addressWithASABalance;
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.width * 1.12,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Text(
                Keys.wallet.tr(context),
                style: Theme.of(context).textTheme.headline5,
              ),
            ),
            Flexible(
              child: Builder(
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
                    primary: false,
                    padding: EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                    itemBuilder: (BuildContext context, int index) {
                      String address = addressBalanceCombos[index].item1;
                      Balance balance = addressBalanceCombos[index].item2;
                      return Container(
                        width: double.infinity,
                        child: Row(
                          children: [
                            Radio(
                              value: myAccountPageViewModel.selectedAccountIndex,
                              groupValue: index,
                              onChanged: (value) {
                                myAccountPageViewModel.setSelectedIndexValue(index);
                              },
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
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
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
                    onPressed: () {
                      Navigator.of(context).pop();
                      String address = addressBalanceCombos[myAccountPageViewModel.selectedAccountIndex].item1;
                      widget.onTapRedeemCoin.call(address);
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.secondary),
                    ),
                    child: Text(
                      Keys.redeemCoin.tr(context),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Theme.of(context).primaryColor),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
