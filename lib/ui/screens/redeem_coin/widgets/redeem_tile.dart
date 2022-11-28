import 'package:app_2i2i/infrastructure/data_access_layer/services/logging.dart';
import 'package:app_2i2i/infrastructure/models/fx_model.dart';
import 'package:app_2i2i/infrastructure/models/redeem_coin_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../infrastructure/providers/all_providers.dart';
import '../../../commons/custom.dart';

ValueNotifier<List> showCoinLoaderIds = ValueNotifier([]);

class RedeemTile extends ConsumerWidget {
  const RedeemTile({Key? key, required this.onTap, required this.redeemCoinModel}) : super(key: key);
  final GestureTapCallback? onTap;
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
          //Here we comment line if other wise overlay Ui not shown
          if (!snapshot.hasData)
            return Container(
              // margin: EdgeInsets.symmetric(vertical: 10),
              // padding: EdgeInsets.only(top: 14, left: 14, right: 14, bottom: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    offset: Offset(2, 4),
                    blurRadius: 8,
                    color: Color.fromRGBO(0, 0, 0, 0.12),
                  ),
                ],
              ),
              child: ListTile(
                title: Text(''),
                subtitle: Text(''),
              ),
            );

          final FXValue = snapshot.data;

          bool isSubjective = FXValue == null;
          final isProjectASA = redeemCoinModel.assetId == int.parse(dotenv.env['PROJECT_ASA_ID']!);
          final iconUrl = isProjectASA ? dotenv.env['PROJECT_ASA_ICON_URL']! : (FXValue?.iconUrl ?? '');
          final ASAName = isProjectASA ? dotenv.env['PROJECT_ASA_NAME']! : (FXValue?.getName ?? redeemCoinModel.assetId.toString());

          log('RedeemTile FXValue=$FXValue redeemCoinModel.assetId=${redeemCoinModel.assetId} isProjectASA=$isProjectASA iconUrl=$iconUrl ASAName=$ASAName value=${FXValue?.value}');

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

          Widget child = ListTile(
            leading: ccyLogo,
            title: Text(ASAName, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w400)),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(redeemCoinModel.value.toString(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                  maxLines: 1,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis),
            ),
            trailing: FittedBox(
              fit: BoxFit.scaleDown,
              child: ValueListenableBuilder(
                  valueListenable: showCoinLoaderIds,
                  builder: (BuildContext context, List<dynamic> value, Widget? child) {
                    bool showLoader = value.contains(redeemCoinModel.assetId);
                    return showLoader
                        ? CupertinoActivityIndicator()
                        : InkResponse(
                            onTap: onTap,
                            child: Image.asset('assets/wallet.png', width: 30, height: 30),
                          );
                  }),
            ),
          );

          log("============>$isSubjective");

          if (isSubjective) {
            child = Stack(
              alignment: Alignment.centerRight,
              children: [
                child,
                Text(
                  'Subjective coins\nare not supported yet',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    shadows: <Shadow>[
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.white,
                        offset: Offset(4.0, 4.0),
                      ),
                      Shadow(
                        color: Colors.white,
                        blurRadius: 10.0,
                        offset: Offset(-9.0, 4.0),
                      ),
                    ],
                  ),
                )
              ],
            );
          }

          return AbsorbPointer(
            absorbing: isSubjective,
            child: Container(
              // margin: EdgeInsets.symmetric(vertical: 10),
              // padding: EdgeInsets.only(top: 14, left: 14, right: 14, bottom: 8),
              decoration: BoxDecoration(
                color: !isSubjective ? Theme.of(context).cardColor : Theme.of(context).cardColor.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    offset: Offset(2, 4),
                    blurRadius: 8,
                    color: Color.fromRGBO(0, 0, 0, 0.12),
                  ),
                ],
              ),
              child: child,
            ),
          );
        },
      ),
    );
  }
}
