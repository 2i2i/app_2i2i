import 'package:app_2i2i/infrastructure/commons/utils.dart';
import 'package:app_2i2i/infrastructure/providers/all_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../infrastructure/commons/strings.dart';
import '../../../../infrastructure/models/bid_model.dart';
import '../../../../infrastructure/models/user_model.dart';

class BidDialogWidget extends ConsumerStatefulWidget {
  final BidInPublic bidIn;
  final GestureTapCallback? onTapTalk;
  final UserModel? userModel;

  const BidDialogWidget(
      {Key? key, required this.bidIn, this.userModel, this.onTapTalk})
      : super(key: key);

  @override
  _BidDialogWidgetState createState() => _BidDialogWidgetState();
}

class _BidDialogWidgetState extends ConsumerState<BidDialogWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bidInPrivateAsyncValue =
        ref.watch(bidInPrivateProvider(widget.bidIn.id));
    final estMaxDurationAsyncValue =
        ref.watch(estMaxDurationProvider(widget.bidIn.id));
    final isMainAccountEmptyAsyncValue = ref.watch(isMainAccountEmptyProvider);
    String coins = widget.bidIn.speed.num.toString() +
        ' ${widget.bidIn.speed.assetId == 0 ? 'μALGO' : widget.bidIn.speed.assetId}/s';
    return AlertDialog(
      backgroundColor: Theme.of(context).primaryColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(14.0),
        ),
      ),
      contentPadding: EdgeInsets.only(top: 8),
      insetPadding: EdgeInsets.zero,
      actionsPadding: EdgeInsets.zero,
      actions: [
        Container(
          width: MediaQuery.of(context).size.height * 0.35,
          child: Column(
            children: [
              SizedBox(height: 10, child: Divider()),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(Strings().cancel),
                    ),
                  ),
                  Container(
                    height: 26,
                    color: Theme.of(context).disabledColor,
                    width: 1,
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        widget.onTapTalk?.call();
                      },
                      child: Text(Strings().talk),
                      style: TextButton.styleFrom(
                          primary: Theme.of(context).colorScheme.secondary),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
      content: Container(
        width: MediaQuery.of(context).size.height * 0.35,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 8),
            Text(
              widget.userModel!.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.headline6,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: TextFormField(
                autofocus: false,
                readOnly: true,
                textAlign: TextAlign.center,
                initialValue: bidInPrivateAsyncValue.when(
                    data: (bidInPrivate) =>
                        '\"${bidInPrivate?.comment ?? ''}\"',
                    error: (_, __) => '',
                    loading: () => ''),
                decoration: InputDecoration(
                  filled: true,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                ),
              ),
            ),
            ListTile(
              leading: Image.asset(
                'assets/algo_logo.png',
                width: 35,
                height: 35,
              ),
              title: Text(
                coins,
                style: Theme.of(context).textTheme.subtitle1,
              ),
              isThreeLine: false,
            ),
            ListTile(
              leading: IconButton(
                onPressed: null,
                icon: SvgPicture.asset('assets/icons/timer.svg'),
              ),
              title: Text(
                'Estimate max duration',
                style: Theme.of(context).textTheme.bodyText1,
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  estMaxDurationAsyncValue.when(
                      data: (double? estMaxDuration) {
                        if (estMaxDuration == null || estMaxDuration.isInfinite)
                          return Strings().forever;
                        final estMaxDurationInt = estMaxDuration.floor();
                        return secondsToSensibleTimePeriod(estMaxDurationInt);
                      },
                      error: (_, __) => 'error',
                      loading: () => ''),
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              ),
            ),
            isMainAccountEmptyAsyncValue.when(
                data: (bool? isMainAccountEmpty) {
                  if (isMainAccountEmpty == null) return Container();
                  if (!isMainAccountEmpty) return Container();
                  if (0 == widget.bidIn.speed.num ||
                      100000 <= widget.bidIn.speed.num) return Container();
                  return ListTile(
                    leading: IconButton(
                      onPressed: null,
                      icon: SvgPicture.asset('assets/icons/warning.svg'),
                    ),
                    title: Text(
                      'Warning',
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Your account is empty. If the call is too short, you cannot get your coins.',
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                    ),
                  );
                },
                error: (_, __) => Container(),
                loading: () => Container()),
/*          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('name: '),
                Text(user.name),
              ],
            ),
            SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('comment: '),
                Text(bidInPrivate.comment ?? ''),
              ],
            ),
            SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('speed: '),
                Text('${bidInModel.speed.num} [$assetIDString/s]'),
              ],
            ),
            SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('est. max duration: '),
                Text('$maxDurationString'),
              ],
            ),
            SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('warning: '),
                Text('this might be a very short call'),
              ],
            ),*/
          ],
        ),
      ),
    );
  }
}
