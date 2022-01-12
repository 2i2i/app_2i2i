import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../infrastructure/commons/strings.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';

class CustomDialogs {
  static loader(bool isLoading, BuildContext context, {bool rootNavigator = true}) {
    AlertDialog alert = AlertDialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      content: Center(
        child: Container(
          height: 110,
          width: 110,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                  height: 90, width: 90, child: CircularProgressIndicator()),
              Image.asset(
                'assets/logo.png',
                width: 60,
                height: 60,
              )
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
            Strings().appRatingTitle,
            style: Theme.of(context).textTheme.headline4,
          ),
          SizedBox(height: 5),
          Text(
            Strings().appRatingMessage,
            style: Theme.of(context).textTheme.bodyText2,
          ),
        ],
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      actionsPadding: EdgeInsets.only(bottom: 10, right: 10),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.of(context, rootNavigator: rootNavigator).pop(),
          child:
              Text(Strings().cancel, style: Theme.of(context).textTheme.button),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context, rootNavigator: rootNavigator).pop();
            onPressed(totalRating / 5, ratingFeedBack.text);
          },
          child: Text(Strings().appRatingSubmitButton,
              style: Theme.of(context).textTheme.button),
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

  static infoDialog(
      {required BuildContext context,
      required Widget child,
      bool rootNavigator = true}) async {
    showDialog(
      barrierDismissible: false,
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
