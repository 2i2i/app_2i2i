import 'dart:io';

import 'package:app_2i2i/infrastructure/commons/keys.dart';
import 'package:app_2i2i/ui/commons/custom.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';

import '../../infrastructure/commons/keys.dart';
import '../../infrastructure/commons/theme.dart';

class CustomAlertWidget {
  static showBottomSheet(BuildContext context, {required Widget child, bool isDismissible = true, bool enableDrag = true, Color? backgroundColor}) {
    return showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      context: context,
      useRootNavigator: false,
      enableDrag: enableDrag,
      isScrollControlled: true,
      backgroundColor: backgroundColor ?? Theme.of(context).canvasColor,
      builder: (BuildContext context) => WillPopScope(
          onWillPop: () {
            return Future.value(isDismissible);
          },
          child: SafeArea(child: Padding(padding: MediaQuery.of(context).viewInsets, child: child))),
      isDismissible: isDismissible,
    );
  }

  static Future showErrorDialog(BuildContext context, String errorMessage, {String? title, String? errorStacktrace}) async {
    Widget messageWidget = Text(
      errorMessage,
    );
    if (errorStacktrace?.isNotEmpty ?? false) {
      messageWidget = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 8),
          Text(
            errorMessage,
          ),
          SizedBox(height: 8),
          Container(
              decoration: BoxDecoration(color: Colors.red.shade200, borderRadius: BorderRadius.circular(12)),
              margin: EdgeInsets.only(top: 8),
              padding: EdgeInsets.all(8),
              child: Text(
                errorStacktrace!,
                maxLines: 2,
              )),
          SizedBox(height: 8),
        ],
      );
    }
    var cupertinoDialog = CupertinoAlertDialog(
      title: Text(
        title ?? Keys.error.tr(context),
        style: TextStyle(
          color: Theme.of(context).errorColor,
        ),
      ),
      content: messageWidget,
      actions: [
        TextButton(
          style: TextButton.styleFrom(primary: Theme.of(context).colorScheme.secondary),
          onPressed: () => Navigator.of(context).pop(),
          child: Text(Keys.okay.tr(context)),
        ),
      ],
    );
    var materialDialog = AlertDialog(
      title: Text(
        title ?? Keys.error.tr(context),
        style: TextStyle(
          color: Theme.of(context).errorColor,
        ),
      ),
      content: messageWidget,
      actions: [
        TextButton(
          style: TextButton.styleFrom(primary: Theme.of(context).colorScheme.secondary),
          onPressed: () => Navigator.of(context).pop(),
          child: Text(Keys.okay.tr(context)),
        ),
      ],
    );
    return Future.delayed(Duration.zero).then((value) async {
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
    });
  }

  static Future<void> confirmDialog(BuildContext context,
      {required String title,
      required String description,
      required VoidCallback onPressed,
      TextStyle? yesButtonTextStyle,
      TextStyle? noButtonTextStyle}) async {
    var cupertinoDialog = CupertinoAlertDialog(
      title: Text(title),
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(description),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).maybePop(),
          child: Text(Keys.no.tr(context), style: noButtonTextStyle),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onPressed();
          },
          child: Text(Keys.yes.tr(context), style: yesButtonTextStyle),
        ),
      ],
    );
    var materialDialog = AlertDialog(
      title: Text(title),
      elevation: 2,
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

  static loader(bool isLoading, BuildContext context, {String title = '', String message = '', bool rootNavigator = false}) {
    AlertDialog alert = AlertDialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      content: Center(
        child: Container(
          padding: EdgeInsets.all(8),
          decoration: Custom.getBoxDecoration(context, color: Colors.white, radius: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 110,
                width: 110,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: LinearProgressIndicator(
                        minHeight: 1,
                      ),
                    ),
                    SizedBox(height: 20),
                    Image.asset(
                      'assets/logo.png',
                      width: 80,
                      height: 80,
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: false, //title.isNotEmpty,
                child: Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ),
              ),
              Visibility(
                visible: message.isNotEmpty,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    message,
                    style: Theme.of(context).textTheme.headline6?.copyWith(color: AppTheme().black),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (!isLoading) {
      Navigator.of(context, rootNavigator: rootNavigator).pop();
    } else {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return WillPopScope(
              onWillPop: () async {
                return false;
              },
              child: alert);
        },
      );
    }
  }

  static inAppRatingDialog(BuildContext context, {required Function onPressed, bool rootNavigator = false}) {
    double totalRating = 5;
    TextEditingController ratingFeedBack = TextEditingController();
    AlertDialog ratingDialog = AlertDialog(
      backgroundColor: Theme.of(context).cardColor,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            Keys.appRatingTitle.tr(context),
            style: Theme.of(context).textTheme.headline4,
          ),
          SizedBox(height: 10),
          // Text(
          //   Strings().appRatingMessage,
          //   style: Theme.of(context).textTheme.bodyText2,
          // ),
        ],
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      actionsPadding: EdgeInsets.only(bottom: 10, right: 10),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context, rootNavigator: rootNavigator).pop(),
          child: Text(Keys.cancel.tr(context)),
        ),
        TextButton(
          style: TextButton.styleFrom(
            primary: Theme.of(context).colorScheme.secondary,
          ),
          onPressed: () {
            Navigator.of(context, rootNavigator: rootNavigator).pop();
            onPressed(totalRating / 5, ratingFeedBack.text);
          },
          child: Text(Keys.appRatingSubmitButton.tr(context)),
        )
      ],
      content: Container(
        width: MediaQuery.of(context).size.width / 4,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 20, top: 8),
              child: RatingBar.builder(
                initialRating: totalRating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                glowColor: Colors.white,
                unratedColor: Colors.grey.shade300,
                itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => Icon(
                  Icons.star_rounded,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  totalRating = rating;
                },
              ),
            ),
            Container(
              // width: MediaQuery.of(context).size.width * 0.8,
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: TextFormField(
                controller: ratingFeedBack,
                maxLines: 5,
              ),
            ),
          ],
        ),
      ),
    );
    showDialog(
      useRootNavigator: rootNavigator,
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: ratingDialog,
        );
      },
    );
  }

  static customAlertDialog(bool isLoading, BuildContext context,
      {String title = '', String message = '', bool rootNavigator = false, required VoidCallback? onPressed}) async {
    AlertDialog child = AlertDialog(
      backgroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Container(
              height: 110,
              width: 110,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: Image.asset(
                'assets/logo.png',
                width: 80,
                height: 80,
              ),
            ),
          ),
          Visibility(
            visible: message.isNotEmpty,
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                message,
                style: Theme.of(context).textTheme.titleSmall,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tap Open button you will redirect to wallet application, if application is not installed you will redirect to play store.',
            style: Theme.of(context).textTheme.caption,
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context, rootNavigator: rootNavigator).pop(),
          child: Text(Keys.cancel.tr(context)),
        ),
        TextButton(
          style: TextButton.styleFrom(
            primary: Theme.of(context).colorScheme.secondary,
          ),
          onPressed: onPressed,
          child: Text(Keys.openApp.tr(context)),
        )
      ],
    );
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
            onWillPop: () async {
              return false;
            },
            child: child);
      },
    );
  }

  static showToastMessage(BuildContext context, String message) {
    showToast(message,
        context: context,
        animation: StyledToastAnimation.slideFromTop,
        reverseAnimation: StyledToastAnimation.slideToTop,
        position: StyledToastPosition.top,
        startOffset: Offset(0.0, -3.0),
        reverseEndOffset: Offset(0.0, -3.0),
        duration: Duration(seconds: 4),
        animDuration: Duration(seconds: 1),
        curve: Curves.elasticOut,
        reverseCurve: Curves.fastOutSlowIn);
  }
}
