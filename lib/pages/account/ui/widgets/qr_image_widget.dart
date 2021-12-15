import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:qr_flutter/qr_flutter.dart';

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
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              height: MediaQuery.of(context).size.height * 0.30,
              width: MediaQuery.of(context).size.height * 0.30,
              child: QrImage(data: imageUrl,backgroundColor: Colors.white,foregroundColor: Colors.black,),
            ),
            Container(
              padding: const EdgeInsets.all(20.0),
              width: MediaQuery.of(context).size.height * 0.4,
              child: TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                readOnly: true,
                initialValue: imageUrl,
                maxLines: 2,
                textAlign: TextAlign.center,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  isDense: true,
                  suffixIcon: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: IconButton(
                      icon: Icon(
                        Icons.copy,
                        size: 20,
                        color: Theme.of(context).primaryColor,
                      ),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: imageUrl));
                        showToast('Copied to Clipboard',
                            context: context,
                            animation: StyledToastAnimation.slideFromTop,
                            reverseAnimation: StyledToastAnimation.slideToTop,
                            position: StyledToastPosition.top,
                            startOffset: Offset(0.0, -3.0),
                            reverseEndOffset: Offset(0.0, -3.0),
                            duration: Duration(seconds: 4),
                            animDuration: Duration(seconds: 1),
                            curve: Curves.elasticOut,
                            reverseCurve: Curves.fastOutSlowIn);
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
