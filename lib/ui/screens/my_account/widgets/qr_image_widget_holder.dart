import 'package:app_2i2i/ui/screens/my_account/widgets/qr_image_widget.dart';
import 'package:app_2i2i/ui/screens/my_account/widgets/qr_image_widget_web.dart';
import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

class QrImagePageHolder extends StatelessWidget {
  final String imageUrl;

  const QrImagePageHolder({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout.builder(
      mobile: (BuildContext context) => QrImagePage(imageUrl: imageUrl.toString(),),
      tablet: (BuildContext context) => QrImagePage(imageUrl: imageUrl.toString(),),
      desktop: (BuildContext context) => QrImagePageWeb(imageUrl: imageUrl.toString(),),
    );
  }
}
