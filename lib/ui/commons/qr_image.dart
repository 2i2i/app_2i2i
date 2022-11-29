import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrWidget extends ConsumerWidget {
  final imageSize;
  final logoSize;
  final String message;
  final bool? hideLogo;
  final bool lightOnly;
  final Color? color;

  const QrWidget({
    Key? key,
    this.imageSize,
    this.logoSize,
    this.hideLogo,
    this.color,
    required this.message,
    this.lightOnly = false,
  }) : super(key: key);

  Future<ui.Image> _loadOverlayImage(BuildContext context) async {
    final completer = Completer<ui.Image>();
    String path = 'assets/logo.png';
    var byteData;
    // if(Theme.of(context).brightness == Brightness.dark){
    //   path = 'assets/logo_dark.png';
    // }
    byteData = await rootBundle.load(path);
    ui.decodeImageFromList(byteData.buffer.asUint8List(), completer.complete);
    return completer.future;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<ui.Image>(
        future: _loadOverlayImage(context),
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
              // color: lightOnly?Colors.black:Theme.of(context).canvasColor,
              data: message,
              version: QrVersions.auto,
              color: color ?? Theme.of(context).iconTheme.color,

              eyeStyle: QrEyeStyle(
                eyeShape: QrEyeShape.circle,
                // color: Theme.of(context).colorScheme.secondary,
                color: Colors.black,
              ),
              dataModuleStyle: QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.circle,
                // color: Theme.of(context).colorScheme.secondary,
                color: Colors.black,
              ),
              embeddedImage: (hideLogo ?? false) ? null : snapshot.data,
              embeddedImageStyle: QrEmbeddedImageStyle(size: Size(logoWidth.toDouble(), logoHeight.toDouble())),
            ),
          );
        });
  }
}
