import 'package:app_2i2i/ui/commons/qr_image.dart';
// import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../infrastructure/commons/keys.dart';

class QrCodeWidget extends StatefulWidget {
  final String uid;

  const QrCodeWidget({Key? key, required this.uid}) : super(key: key);

  @override
  State<QrCodeWidget> createState() => _QrCodeWidgetState();
}

class _QrCodeWidgetState extends State<QrCodeWidget> {
  /*FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;

  Future<String> createDeepLinkUrl() async {
    try {
      final DynamicLinkParameters
      parameters = DynamicLinkParameters(
        uriPrefix: "https://2i2i.page.link",
        link: Uri.parse("https://2i2i.page.link/share/user=${widget.uid}"),
        androidParameters: const AndroidParameters(
          packageName: 'app.i2i2',
        ),
      );
      final ShortDynamicLink shortLink = await dynamicLinks.buildShortLink(parameters);
      return shortLink.shortUrl.toString();
    } catch (e) {
      print(e);
    }
    return "";
  }*/

  @override
  Widget build(BuildContext context) {
    final userURL = "https://i2i2.page.link/share?uid=${widget.uid}";
    return Padding(
      padding: EdgeInsets.only(top: kToolbarHeight, right: kToolbarHeight, left: kToolbarHeight, bottom: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          QrWidget(
            message: userURL,
            imageSize: MediaQuery.of(context).size.height * 0.225,
            logoSize: MediaQuery.of(context).size.height * 0.04,
            lightOnly: true,
          ),
          SizedBox(height: 16),
          Container(
            height: kToolbarHeight,
            decoration: BoxDecoration(
              // color: Color(0xffF3F3F7),
              borderRadius: BorderRadius.circular(4),
              // border: Border.all(width: 0.5, color: Theme.of(context).iconTheme.color ?? Colors.transparent),
            ),
            alignment: Alignment.center,
            child: Text(
              userURL,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyText1?.copyWith(decoration: TextDecoration.underline, color: Colors.black),
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(Keys.close.tr(context)),
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Share.share('${Keys.comeAndHangOut.tr(context)}:\n${userURL}');
                    Navigator.of(context).maybePop();
                  },
                  child: Text(Keys.share.tr(context)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
