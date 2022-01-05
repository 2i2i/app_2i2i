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
        decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(8)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close)),
            ),
            QrWidget(
              message: imageUrl,
              logoSize: 60,
              imageSize: 280,
            ),
            IconButton(
                padding: EdgeInsets.zero,
                onPressed: null,
                icon: Container())
          ],
        ),
      ),
    );
  }
}
