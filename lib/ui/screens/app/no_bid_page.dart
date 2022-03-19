import 'package:app_2i2i/infrastructure/commons/app_config.dart';
import 'package:app_2i2i/infrastructure/data_access_layer/repository/algorand_service.dart';
import 'package:app_2i2i/ui/commons/custom_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../infrastructure/commons/keys.dart';
import '../../../infrastructure/providers/all_providers.dart';
import '../../commons/custom.dart';
import '../../commons/qr_image.dart';
import 'wait_page.dart';
import 'package:flutter/services.dart';

class NoBidPage extends ConsumerWidget {
  final String noBidsText;

  const NoBidPage({Key? key, required this.noBidsText}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(myUIDProvider);
    if (uid == null) return WaitPage();

    final domain =
        AppConfig().ALGORAND_NET == AlgorandNet.mainnet ? '2i2i.app' : 'test.2i2i.app';
    final message = 'https://$domain/user/$uid';
    return Container(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(noBidsText,
              style: Theme.of(context)
                  .textTheme
                  .subtitle2
                  ?.copyWith(color: Theme.of(context).disabledColor)),
          SizedBox(height: kTextTabBarHeight),
          Container(
            decoration: Custom.getBoxDecoration(context,
                color: Colors.white, radius: 10),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: QrWidget(
                imageSize: 120,
                logoSize: 40,
                message: message,
              ),
            ),
          ),
          SizedBox(height: 10),
          Text(Keys.inviteFriend.tr(context),
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .subtitle2
                  ?.copyWith(color: Theme.of(context).disabledColor)),
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
                    style: Theme.of(context)
                        .textTheme
                        .bodyText1!
                        .copyWith(decoration: TextDecoration.underline)),
              ),
              IconButton(
                  onPressed: () async {
                    await Clipboard.setData(new ClipboardData(text: message));
                    CustomDialogs.showToastMessage(
                        context, Keys.copyMessage.tr(context));
                  },
                  icon: Icon(Icons.copy)),
              IconButton(
                  onPressed: () {
                    Share.share('${Keys.joinInvite.tr(context)}\n$message');
                  },
                  icon: Icon(Icons.share)),
            ],
          ),
        ],
      ),
    );
  }
}
