import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WaitPage extends StatelessWidget {
  final bool? isCupertino;

  WaitPage([this.isCupertino]);

  @override
  Widget build(BuildContext context) {
    if(isCupertino == true) {
      return Center(child: CupertinoActivityIndicator());
    }
    return Scaffold(
      backgroundColor:
          Theme.of(context).scaffoldBackgroundColor.withOpacity(0.85),
      body: isCupertino == true
          ? Center(child: CupertinoActivityIndicator())
          : Center(
              child: Container(
                height: 110,
                width: 110,
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
  }
}
