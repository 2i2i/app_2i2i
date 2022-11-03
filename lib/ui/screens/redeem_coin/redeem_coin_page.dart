import 'package:app_2i2i/infrastructure/data_access_layer/services/logging.dart';
import 'package:app_2i2i/infrastructure/models/redeem_coin_model.dart';
import 'package:app_2i2i/infrastructure/providers/all_providers.dart';
import 'package:app_2i2i/ui/commons/custom_alert_widget.dart';
import 'package:app_2i2i/ui/screens/redeem_coin/widgets/account_selection_page.dart';
import 'package:app_2i2i/ui/screens/redeem_coin/widgets/redeem_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../infrastructure/commons/keys.dart';
import '../../../infrastructure/commons/utils.dart';
import '../app/wait_page.dart';

class RedeemCoinPage extends ConsumerStatefulWidget {
  const RedeemCoinPage({Key? key}) : super(key: key);

  @override
  ConsumerState<RedeemCoinPage> createState() => _RedeemCoinPageState();
}

class _RedeemCoinPageState extends ConsumerState<RedeemCoinPage> {
  @override
  void initState() {
    ref.read(myAccountPageViewModelProvider).initMethod();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final myAccountPageViewModel = ref.watch(myAccountPageViewModelProvider);
    log(B + '_RedeemCoinPageState');

    final uid = ref.watch(myUIDProvider)!;
    log(B + '_RedeemCoinPageState, uid=$uid');
    final redeemCoinModelProviderRef = ref.watch(redeemCoinProvider(uid));
    log(B + '_RedeemCoinPageState, redeemCoinModelProviderRef=$redeemCoinModelProviderRef');

    if (haveToWait(redeemCoinModelProviderRef) || haveToWait(myAccountPageViewModel)) {
      log(B + '_RedeemCoinPageState haveToWait(redeemCoinModelProviderRef)');
      return WaitPage();
    } else if (redeemCoinModelProviderRef is AsyncError || myAccountPageViewModel is AsyncError) {
      log(B + '_RedeemCoinPageState redeemCoinModelProviderRef is AsyncError');
      return Scaffold(
        body: Center(
          child: Text(Keys.somethingWantWrong.tr(context), style: Theme.of(context).textTheme.subtitle1),
        ),
      );
    }

    log(B + '_RedeemCoinPageState, 2');

    final redeemCoinsList = redeemCoinModelProviderRef.value ?? [];

    log('_RedeemCoinPageState, redeemCoinsList=$redeemCoinsList redeemCoinsList.length=${redeemCoinsList.length}');

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Text(
                Keys.redeemCoin.tr(context),
                style: Theme.of(context).textTheme.headline5,
              ),
            ),
            SizedBox(height: 15),
            Expanded(
              flex: 5,
              child: redeemCoinsList.isEmpty
                  ? Center(
                      child: Text(
                        Keys.noRedeemCoinsFound.tr(context),
                        style: Theme.of(context).textTheme.subtitle2,
                      ),
                    )
                  : ListView.builder(
                      itemCount: redeemCoinsList.length,
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      itemBuilder: (BuildContext context, int index) {
                        RedeemCoinModel redeemCoinModel = redeemCoinsList[index];
                        return RedeemTile(
                          redeemCoinModel: redeemCoinModel,
                          onTap: () async {
                            CustomAlertWidget.showBottomSheet(
                              context,
                              child: AccountSelectionPage(
                                onTapRedeemCoin: (String address) async {
                                  CustomAlertWidget.loader(true, context);
                                  await ref.read(redeemCoinViewModelProvider).redeemCoin(assetId: redeemCoinModel.assetId, addr: address, context: context);
                                  CustomAlertWidget.loader(false, context);
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
