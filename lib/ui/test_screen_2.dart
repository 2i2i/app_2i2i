import 'package:flutter/material.dart';

class TestScreen2 extends StatefulWidget {
  const TestScreen2({Key? key}) : super(key: key);

  @override
  _TestScreen2State createState() => _TestScreen2State();
}

class _TestScreen2State extends State<TestScreen2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          children: [
            Text(
              Uri.base.toString()
            ),
            SizedBox(height: 100),
            Text(
              Uri.base.query.toString()
            ),
          ],
        ),
      ),
    );
  }
}
