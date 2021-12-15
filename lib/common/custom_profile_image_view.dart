import 'package:flutter/material.dart';

class CustomImageProfileView extends StatelessWidget {
  final String text;
  final double radius;

  const CustomImageProfileView({Key? key, required this.text, this.radius = 40})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: radius,
      width: radius,
      child: Center(
          child: Text(
        "${text.toString().isNotEmpty ? text : "X"}"
            .substring(0, 1)
            .toUpperCase(),
        style: Theme.of(context).textTheme.headline4,
      )),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Color.fromRGBO(214, 219, 134, 1),
      ),
    );
  }
}
