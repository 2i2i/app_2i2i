import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({Key? key}) : super(key: key);

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  @override
  Widget build(BuildContext context) {
    final size = 280.0;
    final logoHeight = 60.0;
    final logoWidth = logoHeight * 1.4;

    return QrImage(
      data: "Hang out with me on 2i2i https://test.2i2i.app/user/g3UdQ8vcWXeVTLTaCp7hVBleY2s1",
      version: QrVersions.auto,
      size: size.toDouble(),
      gapless: true,
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
      embeddedImage: AssetImage('assets/logo.png'),
      embeddedImageStyle: QrEmbeddedImageStyle(size: Size(logoWidth.toDouble(), logoHeight.toDouble())),
    );
  }
}
