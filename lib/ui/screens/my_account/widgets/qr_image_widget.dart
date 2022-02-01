import 'package:app_2i2i/infrastructure/commons/strings.dart';
import 'package:app_2i2i/ui/commons/custom.dart';
import 'package:flutter/material.dart';

import '../../qr_code/widgets/qr_image.dart';

class QrImagePage extends StatelessWidget {
  final String imageUrl;

  const QrImagePage({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 0.0,
      backgroundColor: Colors.white,
      child: Container(
        padding: const EdgeInsets.all(4),
        width: MediaQuery.of(context).size.height * 0.4,
        decoration: Custom.getBoxDecoration(context),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AppBar(
              leading: Container(),
              centerTitle: true,
              title: Text(Strings().scanQr),
              backgroundColor: Colors.transparent,
              actions: [
                IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: QrWidget(
                message: imageUrl,
                logoSize: 60,
                imageSize: 280,
                hideLogo: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
