import 'package:app_2i2i/common/text_utils.dart';
import 'package:app_2i2i/common/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TestBanner extends ConsumerStatefulWidget {
  const TestBanner({Key? key, this.widget}) : super(key: key);
  final Widget? widget;

  @override
  _TestBannerState createState() => _TestBannerState();
}

class _TestBannerState extends ConsumerState<TestBanner>
    with SingleTickerProviderStateMixin {
  AnimationController? controller;

  Animation<Offset>? position;

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 750));
    position = Tween<Offset>(begin: Offset(0.0, -4.0), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: controller!, curve: Curves.easeInOutExpo));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          widget.widget!,
          Align(
            alignment: Alignment.topRight,
            child: Container(
              padding: EdgeInsets.only(top: 55, right: 50),
              child: Banner(
                message: "testnet",
                location: BannerLocation.bottomStart,
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(top: 25.0),
              child: SlideTransition(
                position: position!,
                child: Container(
                  height: 100,
                  width: double.infinity,
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/logo.png',
                        height: 80,
                        width: 80,
                      ),
                      Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              Expanded(
                                flex: 2,
                                  child: HeadLineSixText(
                                      title: "You got new bid now!",
                                      textColor: AppTheme().brightBlue)),
                              ElevatedButton(
                                onPressed: () {
                                  showNotification();
                                },
                                child: ButtonText(title: "View Bid",textColor: AppTheme().black,),
                              )
                            ],
                          )),
                    ],
                  ),
                  margin: EdgeInsets.only(left: 10, right: 10),
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: AppTheme().pink,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: ElevatedButton(
              onPressed: () {
                showNotification();
              },
              child: Text("Show Time"),
            ),
          )
        ],
      ),
    );
  }

  showNotification() {
    switch (controller?.status) {
      case AnimationStatus.completed:
        controller?.reverse();
        break;
      case AnimationStatus.dismissed:
        controller?.forward();
        break;
      default:
    }
  }
}
