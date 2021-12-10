import 'package:app_2i2i/common/text_utils.dart';
import 'package:app_2i2i/common/theme.dart';
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
          child: TitleText(
              title: "${text.toString().isNotEmpty ? text : "X"}"
                  .substring(0, 1)
                  .toUpperCase())),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme().lightGreen,
      ),
    );
  }
}
