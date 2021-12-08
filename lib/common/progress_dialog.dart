import 'package:app_2i2i/common/strings.dart';
import 'package:app_2i2i/common/text_utils.dart';
import 'package:app_2i2i/common/theme.dart';
import 'package:flutter/material.dart';

class ProgressDialog {
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

  static showConfirmAlertDialog(BuildContext context, VoidCallback onPressed) {
    AlertDialog alert = AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HeadLineSixText(
            title: "Block User",
            fontWeight: FontWeight.w800,
          ),
          SizedBox(height: 4),
          BodyTwoText(title: "Are you sure want to block this user?"),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.block_rounded,size: 40,color: AppTheme().red),
          )
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
          onPressed: onPressed,
          child: ButtonText(
              title: "Block",
              textAlign: TextAlign.center,
              textColor: AppTheme().red,
              fontWeight: FontWeight.w600),
        )
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
