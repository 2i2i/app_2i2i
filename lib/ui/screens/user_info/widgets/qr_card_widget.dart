import 'package:app_2i2i/infrastructure/commons/theme.dart';
import 'package:app_2i2i/ui/commons/qr_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class QrCodeWidget extends StatelessWidget {
  final String message;

  const QrCodeWidget({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme().mainTheme(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              leading: Container(),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: IconButton(
                      onPressed: () {
                        Navigator.of(context).maybePop();
                      },
                      icon: Icon(Icons.close)),
                ),
              ],
            ),
            QrWidget(
              message: message,
              logoSize: 54,
              imageSize: 180,
              lightOnly: true,
            ),
            SizedBox(height: 16),
            Container(
              height: 40,
              decoration: BoxDecoration(
                // color: Color(0xffF3F3F7),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                    width: 0.5,
                    color: Theme.of(context).iconTheme.color ??
                        Colors.transparent),
              ),
              alignment: Alignment.center,
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyText1?.copyWith(
                    decoration: TextDecoration.underline, color: Colors.black),
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Clipboard.setData(
                        ClipboardData(
                          text: message,
                        ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Copied Link!')),
                      );
                      Navigator.of(context).maybePop();
                    },
                    child: Text('Copy'),
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Share.share(
                          'Come and hang out with me on 2i2i:\n$message');
                      Navigator.of(context).maybePop();
                    },
                    child: Text('Share'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
