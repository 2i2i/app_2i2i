import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String title;
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;

  final FormFieldValidator<String>? validator;

  final AutovalidateMode? autovalidateMode;

  const CustomTextField(
      {Key? key,
      required this.title,
      this.hintText,
      this.prefixIcon,
      this.suffixIcon,
      this.autovalidateMode,
      this.validator,
      this.controller, this.onChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: Theme.of(context)
                .textTheme
                .caption,
        ),
        SizedBox(height: 4),
        TextFormField(
          autovalidateMode: autovalidateMode,
          controller: controller,
          autofocus: false,
          style: Theme.of(context)
              .textTheme
              .subtitle1,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
          ),
          validator: validator,
        ),
      ],
    );
  }
}
