import 'package:app_2i2i/infrastructure/models/redeem_coin_model.dart';
import 'package:app_2i2i/ui/commons/custom_alert_widget.dart';
import 'package:app_2i2i/ui/screens/redeem_coin/widgets/redeem_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../infrastructure/commons/keys.dart';
import '../../../infrastructure/commons/utils.dart';
import '../../../infrastructure/providers/all_providers.dart';
import '../app/wait_page.dart';

class RedeemCoinPage extends ConsumerStatefulWidget {
  const RedeemCoinPage({Key? key}) : super(key: key);

  @override
  ConsumerState<RedeemCoinPage> createState() => _RedeemCoinPageState();
}

class _RedeemCoinPageState extends ConsumerState<RedeemCoinPage> {
  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(myUIDProvider)!;
    final redeemCoinModelProviderRef = ref.watch(redeemCoinProvider(uid));

    if (haveToWait(redeemCoinModelProviderRef)) {
      return WaitPage();
    } else if (redeemCoinModelProviderRef is AsyncError) {
      return Scaffold(
        body: Center(
          child: Text(Keys.somethingWantWrong.tr(context), style: Theme.of(context).textTheme.subtitle1),
        ),
      );
    }

    final redeemCoinsList = redeemCoinModelProviderRef.value ?? [];

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
                            CustomAlertWidget.loader(true, context, title: Keys.weAreWaiting.tr(context), message: Keys.confirmInWallet.tr(context));
                            await Future.delayed(Duration(seconds: 6));
                            CustomAlertWidget.loader(false, context);
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
