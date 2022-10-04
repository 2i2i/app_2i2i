import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WaitPage extends StatelessWidget {
  final bool? isCupertino;
  final double? height;
  final String? title;
  final String? message;

  const WaitPage({Key? key, this.isCupertino, this.title, this.message, this.height}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (height is num) {
      return SizedBox(
        height: height,
        width: MediaQuery.of(context).size.width,
        child: Builder(builder: (context) {
          if (isCupertino == true) {
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
                  Container(height: 90, width: 90, child: CircularProgressIndicator()),
                  Image.asset(
                    'assets/logo.png',
                    width: 60,
                    height: 60,
                  )
                ],
              ),
            ),
          );
        }),
      );
    }
    if (isCupertino == true) {
      return Center(child: CupertinoActivityIndicator());
    }
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.85),
      body: isCupertino == true
          ? Center(child: CupertinoActivityIndicator())
          : Center(
              child: Column(
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
                          width: 60,
                          height: 60,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                  Text(
                    title ?? '',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  SizedBox(height: 10),
                  Text(
                    message ?? '',
                    style: Theme.of(context).textTheme.caption,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
    );
  }
}
