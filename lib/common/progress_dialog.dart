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
}
