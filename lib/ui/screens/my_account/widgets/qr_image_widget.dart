
import 'package:app_2i2i/infrastructure/commons/keys.dart';
import 'package:flutter/material.dart';

import '../../../commons/qr_image.dart';

class QrImagePage extends StatelessWidget {
  final String imageUrl;

  const QrImagePage({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 0.0,
      backgroundColor: Colors.white,
      content: Container(
        padding: const EdgeInsets.all(4),
        width: MediaQuery.of(context).size.height * 0.4,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 10),
            Text(
              Keys.scanInWalletConnect.tr(context),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyText1?.copyWith(
                color: Colors.black,
              ),
            ),
            SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: QrWidget(
                message: imageUrl,
                logoSize: 60,
                imageSize: 280,
                hideLogo: true,
                lightOnly: true,
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  foregroundColor: Colors.black
              ),
              onPressed: (){
                Navigator.of(context,rootNavigator: true).pop();
              }, child: Text(Keys.close.tr(context).toUpperCase()),
            )
          ],
        ),
      ),
      contentPadding: EdgeInsets.all(4),
    );
  }
}
