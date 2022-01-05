import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String title;
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextEditingController? controller;

  const CustomTextField(
      {Key? key,
      required this.title,
      this.hintText,
      this.prefixIcon,
      this.suffixIcon,
      this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: Theme.of(context)
                .textTheme
                .caption!
                .copyWith(color: Theme.of(context).shadowColor)),
        SizedBox(height: 4),
        TextField(
          controller: controller,
          autofocus: false,
          style: Theme.of(context)
              .textTheme
              .subtitle2!
              .copyWith(fontWeight: FontWeight.normal),
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}
