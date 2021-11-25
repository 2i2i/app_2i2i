import 'package:app_2i2i/pages/home/wait_page.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:app_2i2i/services/all_providers.dart';

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
            eyeStyle: const QrEyeStyle(
              eyeShape: QrEyeShape.circle,
              color: Color.fromRGBO(0, 171, 107, 1),
            ),
            dataModuleStyle: const QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.circle,
              color: Color.fromRGBO(0, 171, 107, 1),
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
        title: Text('qr code'),
      ),
      body: Center(child: qrFutureBuilder),
    );
  }
}
