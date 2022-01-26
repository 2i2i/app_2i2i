
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../infrastructure/providers/all_providers.dart';
import '../../home/wait_page.dart';
import '../../qr_code/widgets/qr_image.dart';

class NoBidPage extends ConsumerWidget {
  final String noBidsText;

  const NoBidPage({Key? key, required this.noBidsText}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(myUIDProvider);
    if (uid == null) return WaitPage();

    final message = 'https://test.2i2i.app/$uid';
    return Container(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(noBidsText, style: Theme.of(context).textTheme.subtitle2),
          SizedBox(height: kTextTabBarHeight),
          QrWidget(
            imageSize: 120,
            logoSize: 40,
            message: message,
          ),
          SizedBox(height: 10),
          Text(
              'Share your profile link to\nyour friend and invite for join 2i2i',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .subtitle2!),
          SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                flex: 2,
                child: Text(message,
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    style: Theme.of(context).textTheme.bodyText1?.copyWith(
                      decoration: TextDecoration.underline
                    )),
              ),
              Flexible(
                child: IconButton(
                    onPressed: () {
                      Share.share('Your friend and invite for join 2i2i\n$message');
                    },
                    icon: Icon(
                      Icons.share
                    )),
              )
            ],
          ),
        ],
      ),
    );
  }
}
