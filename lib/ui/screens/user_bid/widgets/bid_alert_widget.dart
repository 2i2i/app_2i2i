import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:app_2i2i/ui/commons/custom_navigation.dart';
import 'package:app_2i2i/ui/commons/custom_profile_image_view.dart';
import '../../../../infrastructure/routes/app_routes.dart';
import '../../setup_account/setup_account.dart';
import 'bid_speed_widget.dart';

class BidAlertWidget extends StatefulWidget {
  const BidAlertWidget({Key? key}) : super(key: key);

  @override
  _BidAlertWidgetState createState() => _BidAlertWidgetState();
}

class _BidAlertWidgetState extends State<BidAlertWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                    flex: 2,
                    child: Text('James’s Bid',
                        style: Theme.of(context).textTheme.headline6!.copyWith(
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context).disabledColor))),
                Container(
                  width: kToolbarHeight * 2.48,
                  child: BidSpeedWidget(
                    speed: '5',
                    unit: 'μAlgo/sec',
                  ),
                ),
                IconButton(
                  splashColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close),
                  iconSize: 18,
                )
              ],
            ),
            Divider(thickness: 1),
            SizedBox(height: 8),
            Row(
              children: [
                TextProfileView(
                  text: "Ravi",
                  statusColor: Colors.green,
                  onTap: () => CustomNavigation.push(
                      context, SetupBio(), Routes.SETUP_ACCOUNT),
                ),
                Expanded(
                  child: Container(
                    child: Text('\“We have same bio.\”'),
                    padding: EdgeInsets.all(18),
                    margin: EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                              offset: Offset(4, 4),
                              blurRadius: 8,
                              color: Color.fromRGBO(
                                  0, 0, 0, 0.12) // changes position of shadow
                              ),
                        ],
                        color: Theme.of(context).primaryColorLight,
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(24),
                            topLeft: Radius.circular(24),
                            bottomRight: Radius.circular(24))),
                  ),
                )
              ],
            ),
            SizedBox(height: kRadialReactionRadius),
            Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).primaryColorLight,
                  borderRadius: BorderRadius.circular(8)),
              padding: EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                leading: IconButton(
                  onPressed: null,
                  icon: SvgPicture.asset('assets/icons/timer.svg'),
                ),
                title: Text('Estimate max duration',
                    style: Theme.of(context).textTheme.bodyText1!.copyWith(
                        color: Theme.of(context).disabledColor,
                        fontWeight: FontWeight.normal)),
                trailing: Text('1 min',
                    style: Theme.of(context)
                        .textTheme
                        .subtitle1!
                        .copyWith(fontWeight: FontWeight.w400)),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).primaryColorLight,
                  borderRadius: BorderRadius.circular(8)),
              margin: EdgeInsets.only(top: 8),
              padding: EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                leading: IconButton(
                  onPressed: null,
                  icon: SvgPicture.asset('assets/icons/warning.svg'),
                ),
                title: Text('Warning',
                    style: Theme.of(context).textTheme.bodyText1!.copyWith(
                        color: Theme.of(context).disabledColor,
                        fontWeight: FontWeight.normal)),
                trailing: Text('This can be very short',
                    style: Theme.of(context)
                        .textTheme
                        .subtitle1!
                        .copyWith(fontWeight: FontWeight.w400)),
              ),
            ),
            SizedBox(height: kRadialReactionRadius + 4),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Cancel'),
                    style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).shadowColor,
                    ),
                  ),
                ),
                SizedBox(width: 6),
                Expanded(
                    child:
                        ElevatedButton(onPressed: () {}, child: Text('Talk')))
              ],
            ),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
