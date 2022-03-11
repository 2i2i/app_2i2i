import 'dart:async';

import 'package:flutter/material.dart';

import 'commons/custom_profile_image_view.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({Key? key}) : super(key: key);

  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {

  int val = 0;
  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration(seconds: 1), (timer) {
      val = timer.tick;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            color: Colors.amber,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: ProfileWidget(
                stringPath: "Ravi",
                radius: kToolbarHeight * 1.15,
                showBorder: true,
                style: Theme.of(context).textTheme.headline5,
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 40,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.19,
                width: MediaQuery.of(context).size.height * 0.16,
                color: Colors.black,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ProfileWidget(
                      stringPath: "Ravi",
                      radius: kToolbarHeight * 1.15,
                      showBorder: true,
                      style: Theme.of(context).textTheme.headline5,
                    ),
                    Positioned(
                      child: Icon(Icons.mic, size: 16, color: Colors.white),
                      bottom: 8,
                      left: 8,
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      /*body: Center(
        child: Row(
          children: [
            Builder(
              builder: (BuildContext context) {
                double width = MediaQuery.of(context).size.height / 3;
                double height = (val * width) / 100;
                return Container(
                  height: width,
                  width: 28,
                  margin: const EdgeInsets.only(right: 30, left: 30),
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Material(
                            color: Colors.transparent,
                            shadowColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            type: MaterialType.card,
                            child: SizedBox(
                              height: width,
                              width: 20,
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Material(
                            borderRadius: BorderRadius.circular(20),
                            shadowColor: Colors.black12,
                            type: MaterialType.card,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: ProgressBar(
                                height: width,
                                radius: 0,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Material(
                            color: Colors.grey,
                            shadowColor: Colors.black,
                            type: MaterialType.card,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(20),
                              topLeft: Radius.circular(20),
                            ),
                            child: Container(
                              height: height,
                              width: 20,
                              decoration: BoxDecoration(
                                  color: Colors.white24,
                                  border: Border(bottom: BorderSide())),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            SizedBox(width: 100),
            Builder(
              builder: (BuildContext context) {
                var val = 100 - this.val;
                double width = MediaQuery.of(context).size.height / 3;
                double height = (val * width) / 100;
                return Container(
                  height: width,
                  width: 28,
                  margin: const EdgeInsets.only(right: 30, left: 30),
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Material(
                            color: Colors.transparent,
                            shadowColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            type: MaterialType.card,
                            child: SizedBox(
                              height: width,
                              width: 20,
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Material(
                            borderRadius: BorderRadius.circular(20),
                            shadowColor: Colors.black12,
                            type: MaterialType.card,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: ProgressBar(
                                height: width,
                                radius: 0,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Material(
                            color: Colors.grey,
                            shadowColor: Colors.black,
                            type: MaterialType.card,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(20),
                              topLeft: Radius.circular(20),
                            ),
                            child: Container(
                              height: height,
                              width: 20,
                              decoration: BoxDecoration(
                                  color: Colors.white24,
                                  border: Border(bottom: BorderSide())),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),*/
    );
  }
}
