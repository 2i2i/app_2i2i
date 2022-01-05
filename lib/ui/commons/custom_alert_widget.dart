import 'package:flutter/material.dart';

import '../screens/user_bid/widgets/bid_alert_widget.dart';

class CustomAlertWidget {
  static showBidAlert(BuildContext context) {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16), topRight: Radius.circular(16)),
      ),
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).primaryColor,
      builder: (BuildContext context) => child,
    );
  }
}
