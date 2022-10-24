import 'package:app_2i2i/infrastructure/data_access_layer/services/logging.dart';
import 'package:app_2i2i/infrastructure/models/fx_model.dart';
import 'package:app_2i2i/infrastructure/models/redeem_coin_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../infrastructure/providers/all_providers.dart';
import '../../../commons/custom.dart';

class RedeemTile extends ConsumerWidget {
  final GestureTapCallback? onTap;

  const RedeemTile({Key? key, required this.redeemCoinModel, this.onTap}) : super(key: key);

  final RedeemCoinModel redeemCoinModel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    log('RedeemTile');

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: Custom.getBoxDecoration(context),
      child: FutureBuilder<FXModel?>(
        future: ref.read(myAccountPageViewModelProvider).getFX(redeemCoinModel.assetId),
        builder: (BuildContext context, AsyncSnapshot<FXModel?> snapshot) {
          if (snapshot.hasData) {
            final FXValue = snapshot.data;

            final isProjectASA = redeemCoinModel.assetId == int.parse(dotenv.env['PROJECT_ASA_ID']!);
            final iconUrl = isProjectASA ? dotenv.env['PROJECT_ASA_ICON_URL']! : (FXValue?.iconUrl ?? '');
            final ASAName = isProjectASA ? dotenv.env['PROJECT_ASA_NAME']! : (FXValue?.getName ?? redeemCoinModel.assetId.toString());

            log('RedeemTile FXValue=$FXValue redeemCoinModel.assetId=${redeemCoinModel.assetId} isProjectASA=$isProjectASA iconUrl=$iconUrl ASAName=$ASAName');

            final ccyLogo = Image.network(
              iconUrl,
              width: 40,
              height: 40,
              fit: BoxFit.fill,
              errorBuilder: (context, error, stackTrace) => Image.asset(
                'assets/algo_logo.png',
                width: 40,
                height: 40,
                fit: BoxFit.fill,
              ),
            );


            return ListTile(
              leading: ccyLogo,
              title: Text(ASAName, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w400)),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(redeemCoinModel.value.toString(),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800), maxLines: 1, softWrap: true, overflow: TextOverflow.ellipsis),
              ),
              trailing: InkResponse(
                onTap: onTap,
                child: Image.asset('assets/wallet.png', width: 30, height: 30),
              ),
            );
          }
          return Container();
        },
      ),
    );
  }
}
