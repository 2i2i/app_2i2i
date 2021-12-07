import 'package:app_2i2i/common/text_utils.dart';
import 'package:app_2i2i/common/theme.dart';
import 'package:app_2i2i/constants/strings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class CustomDialogs {
  static loader(bool isLoading, BuildContext context) {
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
                  height: 90,
                  width: 90,
                  child: CircularProgressIndicator()),
              Image.asset('assets/logo.png',width: 60,height: 60,)
            ],
          ),
        ),
      ),
    );

    if (!isLoading) {
      Navigator.pop(context);
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

  static inAppRatingDialog(BuildContext context) {
    AlertDialog ratingDialog = AlertDialog(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HeadLineSixText(
            title: Strings().appRatingTitle,
            fontWeight: FontWeight.w800,
          ),
          SizedBox(height: 5),
          BodyTwoText(
              title: Strings().appRatingMessage,
              textColor: AppTheme().hintColor),
        ],
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      actionsPadding: EdgeInsets.only(bottom: 10, right: 10),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: ButtonText(
              title: Strings().cancel,
              textAlign: TextAlign.center, 
              fontWeight: FontWeight.w600),
        ),
        TextButton(
          onPressed: () {},
          child: ButtonText(
              title: Strings().appRatingSubmitButton,
              textAlign: TextAlign.center,
              textColor: AppTheme().brightBlue,
              fontWeight: FontWeight.w600),
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
                initialRating: 3,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                glowColor: Colors.white,
                unratedColor: Colors.grey.shade300,
                itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  print(rating);
                },
              ),
            ),
            Container(
              // width: MediaQuery.of(context).size.width * 0.8,
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: TextFormField(
                decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                      borderSide: BorderSide(
                        color: Colors.transparent,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                      borderSide: BorderSide(
                        color: Colors.transparent,
                      ),
                    ),
                    border: new OutlineInputBorder(
                      borderRadius: new BorderRadius.circular(5.0),
                      borderSide: new BorderSide(color: Colors.transparent),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade300,
                    focusColor: Colors.grey.shade300),
                maxLines: 5,
              ),
            ),
          ],
        ),
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
            onWillPop: () async {
              return false;
            },
            child: ratingDialog);
      },
    );
  }
}
