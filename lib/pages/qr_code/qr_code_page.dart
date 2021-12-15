import 'dart:async';
import 'dart:ui' as ui;

import 'package:app_2i2i/pages/home/wait_page.dart';
import 'package:app_2i2i/services/all_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRCodePage extends ConsumerWidget {
  const QRCodePage({Key? key}) : super(key: key);

  Future<ui.Image> _loadOverlayImage() async {
    final completer = Completer<ui.Image>();
    final byteData = await rootBundle.load('assets/logo.png');
    ui.decodeImageFromList(byteData.buffer.asUint8List(), completer.complete);
    return completer.future;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(myUIDProvider);
    if (uid == null) return WaitPage();

    final message = 'https://test.2i2i.app/user/$uid';

    final qrFutureBuilder = FutureBuilder<ui.Image>(
      future: _loadOverlayImage(),
      builder: (ctx, snapshot) {
        final size = 280.0;
        if (!snapshot.hasData) {
          return Container(width: size, height: size);
        }

        final logoHeight = 60.0;
        final logoWidth = logoHeight * 1.4;

        return CustomPaint(
          size: Size.square(size),
          painter: QrPainter(
            data: message,
            version: QrVersions.auto,
            eyeStyle:  QrEyeStyle(
              eyeShape: QrEyeShape.circle,
              // color: Color.fromRGBO(0, 171, 107, 1),
              color: Theme.of(context).primaryColor,
            ),
            dataModuleStyle:  QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.circle,
              // color: Color.fromRGBO(0, 171, 107, 1),
              color: Theme.of(context).primaryColor,
            ),
            // size: 320.0,
            embeddedImage: snapshot.data,
            embeddedImageStyle:
                QrEmbeddedImageStyle(size: Size(logoWidth, logoHeight)),
          ),
        );
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code'),
      ),
      body: Container(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            qrFutureBuilder,
            SizedBox(
              height: 10,
            ),
            Container(
              padding: const EdgeInsets.all(20.0),
              width: MediaQuery.of(context).size.height * 0.5,
              child: TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                readOnly: true,
                initialValue: message,
                maxLines: null,
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
                        Clipboard.setData(ClipboardData(text: message));
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
