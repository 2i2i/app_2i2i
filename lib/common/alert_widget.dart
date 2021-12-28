import 'package:flutter/material.dart';

import '../pages/user_bid/ui/widgets/bid_alert_widget.dart';

class AlertWidget {
  static showBidAlert(BuildContext context) {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16), topRight: Radius.circular(16)),
      ),
      context: context,
      useRootNavigator: true,
      backgroundColor: Theme.of(context).primaryColor,
      builder: (BuildContext context) => BidAlertWidget(),
    );
  }
}
