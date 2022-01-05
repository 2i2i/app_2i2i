import 'package:app_2i2i/common/theme.dart';
import 'package:app_2i2i/constants/strings.dart';
import 'package:app_2i2i/models/bid.dart';
import 'package:app_2i2i/models/user.dart';
import 'package:app_2i2i/pages/user_bid/ui/widgets/bid_duration_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BidDialogWidget extends ConsumerStatefulWidget {
  final BidIn bidInModel;
  final GestureTapCallback? onTapTalk;
  final UserModel? userModel;

  const BidDialogWidget(
      {Key? key, required this.bidInModel, this.userModel, this.onTapTalk})
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
    return AlertDialog(
      backgroundColor: Theme.of(context).primaryColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(14.0))),
      contentPadding: EdgeInsets.zero,
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
                    child: InkWell(
                      hoverColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        alignment: Alignment.center,
                        child: Text(Strings().ok,
                            style: Theme.of(context).textTheme.subtitle2),
                      ),
                    ),
                  ),
                  Container(
                    height: 26,
                    color: Theme.of(context).disabledColor,
                    width: 1,
                  ),
                  Expanded(
                    child: InkWell(
                      hoverColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () {
                        Navigator.pop(context);
                        widget.onTapTalk!();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        alignment: Alignment.center,
                        child: Text(Strings().talk,
                            style: Theme.of(context)
                                .textTheme
                                .subtitle2!
                                .copyWith(color: AppTheme().green)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
      content: Container(
        width: MediaQuery.of(context).size.height*0.35,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                      child: Text(
                    widget.userModel!.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .headline6!
                        .copyWith(fontWeight: FontWeight.w800),
                  )),
                  SizedBox(width: 6),
                  BidDurationWidget(
                    duration: '${widget.bidInModel.speed.assetId == 0 ? 'ALGO' : widget.bidInModel.speed.assetId}/sec',
                    speed: widget.bidInModel.speed.num.toString(),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: TextFormField(
                autofocus: false,
                readOnly: true,
                textAlign: TextAlign.center,
                initialValue: '\"${widget.userModel!.bio}\"',
                decoration: InputDecoration(
                  filled: true,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                ),
              ),
            ),
            ListTile(
              leading: IconButton(
                onPressed: null,
                icon: SvgPicture.asset('assets/icons/timer.svg'),
              ),
              title: Text('Estimate max duration',
                  style: Theme.of(context).textTheme.bodyText1!.copyWith(
                      color: Theme.of(context).disabledColor,
                      fontWeight: FontWeight.normal)),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('1 min',
                    style: Theme.of(context)
                        .textTheme
                        .subtitle1!
                        .copyWith(fontWeight: FontWeight.w400)),
              ),
            ),
            ListTile(
              leading: IconButton(
                onPressed: null,
                icon: SvgPicture.asset('assets/icons/warning.svg'),
              ),
              title: Text('Warning',
                  style: Theme.of(context).textTheme.bodyText1!.copyWith(
                      color: Theme.of(context).disabledColor,
                      fontWeight: FontWeight.normal)),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('This can be very short',
                    style: Theme.of(context)
                        .textTheme
                        .subtitle1!
                        .copyWith(fontWeight: FontWeight.w400)),
              ),
            ),
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
                Text('${bidInModel.speed.num} [$assetIDString/sec]'),
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
