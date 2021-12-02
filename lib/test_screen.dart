

import 'package:app_2i2i/test2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({Key? key}) : super(key: key);

  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> with SingleTickerProviderStateMixin{
  late AnimationController controller;
  late Animation<Offset> offset;
  Offset start = Offset.zero;
  Offset end = Offset(1.0,0.0);
  bool visible = false;
  @override
  void initState() {
    controller = AnimationController(vsync: this, duration: Duration(seconds: 8),animationBehavior: AnimationBehavior.normal);
    offset = Tween<Offset>(begin: start, end: end).animate(controller);
    controller.addListener(() {
      if(controller.status == AnimationStatus.completed){
        controller.repeat(reverse: true);
      }
    });
    controller.forward();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Material(
          elevation: 8,
          shadowColor: Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(50),
            ),
            width: MediaQuery.of(context).size.width/4,
            height: 15,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: SlideTransition(
                  position: offset,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Container(
                          color: Colors.red,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          color: Colors.green,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          color: Colors.blue,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          color: Colors.yellow,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ),
        ),
      ),
    );
  }
}


