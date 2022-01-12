import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrWidget extends ConsumerWidget {
  final imageSize;
  final logoSize;
  final message;

  const QrWidget({
    Key? key,
    this.imageSize,
    this.logoSize,
    required this.message,
  }) : super(key: key);

  Future<ui.Image> _loadOverlayImage() async {
    final completer = Completer<ui.Image>();
    final byteData = await rootBundle.load('assets/logo.png');
    ui.decodeImageFromList(byteData.buffer.asUint8List(), completer.complete);
    return completer.future;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<ui.Image>(
        future: _loadOverlayImage(),
        builder: (ctx, snapshot) {
          final size = imageSize != null ? imageSize : 280.0;
          if (!snapshot.hasData) {
            return Container(width: size.toDouble(), height: size.toDouble());
          }

          final logoHeight = logoSize != null ? logoSize : 60.0;
          final logoWidth = logoHeight * 1.4;

          return CustomPaint(
            size: Size.square(size.toDouble()),
            painter: QrPainter(
              data: message,
              version: QrVersions.auto,
              eyeStyle: QrEyeStyle(
                eyeShape: QrEyeShape.circle,
                // color: Theme.of(context).colorScheme.secondary,
                color: Theme.of(context).iconTheme.color,
              ),
              dataModuleStyle: QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.circle,
                // color: Theme.of(context).colorScheme.secondary,
                color: Theme.of(context).iconTheme.color,
              ),
              embeddedImage: snapshot.data,
              embeddedImageStyle: QrEmbeddedImageStyle(
                  size: Size(logoWidth.toDouble(), logoHeight.toDouble())),
            ),
          );
        });
  }
}
