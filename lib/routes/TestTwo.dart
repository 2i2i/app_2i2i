import 'package:flutter/material.dart';

import 'app_routes.dart';

class TestTwoScreen extends StatefulWidget {
  final Object? data;
  const TestTwoScreen({Key? key, this.data}) : super(key: key);

  @override
  _TestTwoScreenState createState() => _TestTwoScreenState();
}

class _TestTwoScreenState extends State<TestTwoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Screen twp'
        ),
      ),
      body: ElevatedButton(
        onPressed: () {
          Navigator.of(context).pushNamed(Routes.SOLLI,arguments: 'hhh');
        },
        child: Text('Screen 1 ${widget.data}'),
      ),
    );
  }
}
