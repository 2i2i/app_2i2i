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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        width: MediaQuery.of(context).size.height * 0.4,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: kToolbarHeight,
              alignment: Alignment.center,
              margin: EdgeInsets.only(top: 4),
              child: Text(
                Keys.scanInWalletConnect.tr(context),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyText1?.copyWith(
                      color: Theme.of(context).iconTheme.color,
                    ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
              child: QrWidget(
                message: imageUrl,
                logoSize: 60,
                imageSize: 280,
                hideLogo: true,
                lightOnly: true,
              ),
            ),
            Divider(),
            Container(
              height: kToolbarHeight,
              width: MediaQuery.of(context).size.height * 0.4,
              alignment: Alignment.center,
              margin: EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.secondary),
                      ),
                      child: Text(
                        Keys.close.tr(context),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Theme.of(context).primaryColor),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      contentPadding: EdgeInsets.all(4),
    );
  }
}
