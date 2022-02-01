import 'package:app_2i2i/ui/commons/custom.dart';
import 'package:app_2i2i/ui/screens/qr_code/widgets/qr_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class QrCodeWidget extends StatelessWidget {
  final String message;

  const QrCodeWidget({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: Custom.getBoxDecoration(context),
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
                  child: IconButton(onPressed: () {
                    Navigator.of(context).maybePop();
                  }, icon: Icon(Icons.close)),
                ),
              ],
            ),
            QrWidget(
              message: message,
              logoSize: 54,
              imageSize: 180,
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
                          Colors.transparent)),
              alignment: Alignment.center,
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.caption?.copyWith(
                      decoration: TextDecoration.underline,
                    ),
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
                          'Your friend and invite for join 2i2i\n$message');
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