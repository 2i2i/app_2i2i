import 'package:app_2i2i/infrastructure/commons/theme.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String title;
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final AutovalidateMode? autovalidateMode;
  final FocusNode? focusNode;
  final FormFieldValidator<String>? validator;
  const CustomTextField(
      {Key? key,
      required this.title,
      this.hintText,
      this.prefixIcon,
      this.validator,
      this.suffixIcon,
      this.autovalidateMode,
      this.controller,
      this.onChanged, this.focusNode})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.caption,
        ),
        SizedBox(height: 4),
        TextFormField(
          focusNode: focusNode,
          controller: controller,
          autovalidateMode: autovalidateMode,
          validator: validator,
          autofocus: false,
          style: TextStyle(color: AppTheme().cardDarkColor),
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
