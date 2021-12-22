import 'dart:io';

import 'package:app_2i2i/common/custom_profile_image_view.dart';
import 'package:flutter/material.dart';

class ProfileWidget extends StatelessWidget {
  final File? imageFile;
  final String imageUrlString;

  const ProfileWidget({Key? key, this.imageFile, required this.imageUrlString})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if ((imageFile?.path ?? "").isNotEmpty) {
      return Image.network(imageFile!.path, fit: BoxFit.cover);
    } else if (imageUrlString.contains('http')) {
      return Image.network(imageFile!.path, fit: BoxFit.cover);
    } else if (imageUrlString.isNotEmpty) {
      return CustomImageProfileView(
        text: imageUrlString,
        radius: MediaQuery.of(context).size.height * 0.052,
      );
    } else {
      return Icon(Icons.account_circle_outlined, size: kTextTabBarHeight);
    }
  }
}
