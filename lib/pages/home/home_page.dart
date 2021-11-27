import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with TickerProviderStateMixin {
  late AnimationController controller;
  Timer? timer;

  @override
  void initState() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..addListener(() {
        setState(() {});
      });
    controller.forward();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  bool swapped = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Stack(
          children: <Widget>[
            swapped
                ? firstVideoView(MediaQuery.of(context).size.height, MediaQuery.of(context).size.width)
                : secondVideoView(MediaQuery.of(context).size.height, MediaQuery.of(context).size.width),
            Positioned(
              top: 40,
              left: 40,
              child: InkWell(
                  onTap: () {
                    setState(() {
                      swapped = !swapped;
                    });
                  },
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.0),
                      child: !swapped
                          ? firstVideoView(250, 250)
                          : secondVideoView(250, 250))),
            ),

          ],
        ),
      ),
    );
  }

  Widget firstVideoView(double height, double width) {
    return Container(
        height: height,
        width: width,
        child: Center(child: Text("One")),
        color: Colors.blue);
  }

  Widget secondVideoView(double height, double width) {
    return Container(
        height: height,
        width: width,
        child: Center(child: Text("Two")),
        color: Colors.orange);
  }
}
