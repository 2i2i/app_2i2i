import 'package:flutter/material.dart';

class CustomAlertWidget {
  static showBidAlert(BuildContext context,Widget child) {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      context: context,
      useRootNavigator: false,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).primaryColor,
      builder: (BuildContext context) => child,
    );
  }
}
