import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String title;
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final AutovalidateMode? autovalidateMode;
  final FormFieldValidator<String>? validator;
  const CustomTextField(
      {Key? key,
      required this.title,
      this.hintText,
      this.prefixIcon,
      this.validator,
      this.suffixIcon,
      this.autovalidateMode,
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
          controller: controller,
          autovalidateMode: autovalidateMode,
          validator: validator,
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
        ),
      ],
    );
  }
}
