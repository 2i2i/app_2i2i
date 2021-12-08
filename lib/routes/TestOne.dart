import 'package:flutter/material.dart';

import 'app_routes.dart';

class TestOneScreen extends StatefulWidget {
  final Object? data;
  const TestOneScreen({Key? key, this.data}) : super(key: key);

  @override
  _TestOneScreenState createState() => _TestOneScreenState();
}

class _TestOneScreenState extends State<TestOneScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Screen one'
        ),
      ),
      body: ElevatedButton(
        onPressed: () {
          Navigator.of(context).pushNamed(Routes.IMI);
        },
        child: Text('Screen 2 ${widget.data}'),
      ),
    );
  }
}
