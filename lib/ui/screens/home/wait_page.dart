import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WaitPage extends StatelessWidget {
  final bool? isCupertino;
  final double? height;

  const WaitPage({Key? key, this.isCupertino, this.height}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if(height is num){
      return SizedBox(
        height: height,
        width: MediaQuery.of(context).size.width,
        child: Builder(
          builder: (context) {
            if(isCupertino == true){
              return Center(child: CupertinoActivityIndicator());
            }
            return Center(
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
            );
          }
        ),
      );
    }
    if(isCupertino == true) {
      return Center(child: CupertinoActivityIndicator());
    }
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.85),
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
