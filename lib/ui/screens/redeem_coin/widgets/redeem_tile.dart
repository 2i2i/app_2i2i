import 'package:algorand_dart/algorand_dart.dart';
import 'package:app_2i2i/infrastructure/commons/utils.dart';
import 'package:app_2i2i/infrastructure/models/redeem_coin_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../infrastructure/providers/all_providers.dart';
import '../../../commons/custom.dart';

class RedeemTile extends ConsumerWidget {
  final GestureTapCallback? onTap;

  const RedeemTile({Key? key, required this.redeemCoinModel, this.onTap}) : super(key: key);

  final RedeemCoinModel redeemCoinModel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ccyLogo = Image.network(
      'https://asa-list.tinyman.org/assets/${redeemCoinModel.asaId}/icon.png',
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

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: Custom.getBoxDecoration(context),
      child: ListTile(
        leading: ccyLogo,
        title: FutureBuilder<Asset>(
          future: ref.read(myAccountPageViewModelProvider).getAsset(int.parse(redeemCoinModel.asaId)),
          builder: (BuildContext context, AsyncSnapshot<Asset> snapshot) {
            if (snapshot.hasData) {
              return Text(snapshot.data?.params.name ?? "ASA", style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w400));
            }
            return Text("ASA", style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w400));
          },
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Text(redeemCoinModel.asaId,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              maxLines: 1,
              softWrap: true,
              overflow: TextOverflow.ellipsis),
        ),
        trailing: InkResponse(
          onTap: onTap,
          child: Image.asset('assets/wallet.png', width: 30, height: 30),
        ),
      ),
    );
  }

  String getTime(DateTime? createdAt) {
    String time = "";
    if (createdAt is DateTime) {
      DateTime meetingTime = createdAt.toLocalDateTime();
      DateFormat formatDate = new DateFormat("yyyy-MM-dd\nhh:mm:a");
      time = formatDate.format(meetingTime.toLocal());
    }
    return time;
  }
}
