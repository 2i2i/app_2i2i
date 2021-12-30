import 'package:app_2i2i/ui/commons/custom_animated_progress_bar.dart';
import 'package:flutter/material.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({Key? key}) : super(key: key);

  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.height / 3;
    double height = 40 * width / 100;
    return Scaffold(
      backgroundColor: Colors.red,
      body: Stack(
        alignment: Alignment.centerRight,
        children: [
          Container(
            height: width,
            width: 28,
            margin: const EdgeInsets.only(right: 30,left: 30),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      type: MaterialType.card,
                      child: SizedBox(
                        height: width,
                        width: 20,
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment:Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Material(
                      shadowColor: Colors.black,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      type: MaterialType.card,
                      child: ProgressBar(
                        height: height,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
