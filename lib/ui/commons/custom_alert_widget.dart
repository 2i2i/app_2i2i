import 'dart:io';

import 'package:app_2i2i/infrastructure/commons/keys.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../infrastructure/commons/keys.dart';

class CustomAlertWidget {
  static showBidAlert(BuildContext context, Widget child,
      {bool isDismissible = true, Color? backgroundColor}) {
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
      backgroundColor: backgroundColor ?? Theme.of(context).canvasColor,
      builder: (BuildContext context) => child,
      isDismissible: isDismissible,
    );
  }

  static Future showErrorDialog(BuildContext context, String errorMessage,
      {String? title, String? errorStacktrace}) async {
    Widget messageWidget = Text(
      errorMessage,
      textAlign: TextAlign.justify,
    );
    if (errorStacktrace?.isNotEmpty ?? false) {
      messageWidget = Column(
        children: [
          SizedBox(height: 8),
          Text(
            errorMessage,
            textAlign: TextAlign.justify,
          ),
          Container(
              decoration: BoxDecoration(
                  color: Colors.red.shade200,
                  borderRadius: BorderRadius.circular(12)),
              margin: EdgeInsets.only(top: 8),
              padding: EdgeInsets.all(8),
              child: Text(
                errorStacktrace!,
                textAlign: TextAlign.justify,
                maxLines: 2,
              )),
          SizedBox(height: 8),
        ],
      );
    }
    var dialog = CupertinoAlertDialog(
      title: Text(
        title ?? Keys.error.tr(context),
        style: TextStyle(
          color: Theme.of(context).errorColor,
        ),
      ),
      content: messageWidget,
      actions: [
        TextButton(
          style: TextButton.styleFrom(
              primary: Theme.of(context).colorScheme.secondary),
          onPressed: () {
            Navigator.of(context).maybePop();
          },
          child: Text(Keys.okay.tr(context)),
        ),
      ],
    );
    return Future.delayed(Duration.zero).then((value) =>
        showCupertinoDialog(context: context, builder: (context) => dialog));
  }

  static Future<void> confirmDialog(BuildContext context, {required String title, required String description, required VoidCallback onPressed,TextStyle? yesButtonTextStyle,TextStyle? noButtonTextStyle}) async {
    var cupertinoDialog = CupertinoAlertDialog(
      title: Text(title),
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(description),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).maybePop(),
          child: Text(Keys.no.tr(context),style: noButtonTextStyle),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onPressed();
          },
          child: Text(Keys.yes.tr(context),style: yesButtonTextStyle),
        ),
      ],
    );
    var materialDialog = AlertDialog(
      title: Text(title),
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(description),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).maybePop(),
          child: Text(Keys.no.tr(context)),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onPressed();
          },
          child: Text(Keys.yes.tr(context)),
        ),
      ],
    );
    if (Platform.isIOS) {
      await showCupertinoDialog(
        context: context,
        builder: (context) => cupertinoDialog,
      );
    } else {
      await showDialog(
        context: context,
        builder: (context) => materialDialog,
      );
    }
  }
}
