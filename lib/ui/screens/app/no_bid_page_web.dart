import 'package:app_2i2i/infrastructure/commons/app_config.dart';
import 'package:app_2i2i/infrastructure/commons/utils.dart';
import 'package:app_2i2i/infrastructure/data_access_layer/repository/algorand_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../infrastructure/commons/keys.dart';
import '../../../infrastructure/providers/all_providers.dart';
import '../../commons/custom.dart';
import '../../commons/qr_image.dart';
import 'wait_page.dart';

class NoBidPageWeb extends ConsumerWidget {
  final String noBidsText;

  const NoBidPageWeb({Key? key, required this.noBidsText}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(myUIDProvider);
    if (uid == null) return WaitPage();

    final domain = AppConfig().ALGORAND_NET == AlgorandNet.mainnet ? '2i2i.app' : 'test.2i2i.app';
    final message = 'https://$domain/user/$uid';
    return Container(
      height: MediaQuery.of(context).size.height,
      alignment: Alignment.center,
      color: Colors.transparent,
      child: ScrollConfiguration(
        behavior: MyBehavior(),
        child: SingleChildScrollView(
          physics: ClampingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: MediaQuery.of(context).size.height / 16,
                child: Image.asset(
                  'assets/join_host.png',
                  fit: BoxFit.fitWidth,
                  color: Theme.of(context).hintColor,
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 50,
              ),
              Text(
                noBidsText,
                style: Theme.of(context).textTheme.subtitle2?.copyWith(color: Theme.of(context).disabledColor),
              ),
              SizedBox(height: kTextTabBarHeight),
              Container(
                decoration: Custom.getBoxDecoration(context, color: Colors.white, radius: 10),
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: QrWidget(
                    imageSize: MediaQuery.of(context).size.height * 0.15,
                    logoSize: MediaQuery.of(context).size.height * 0.04,
                    message: message,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text(Keys.inviteFriend.tr(context),
                  textAlign: TextAlign.center, style: Theme.of(context).textTheme.subtitle2?.copyWith(color: Theme.of(context).disabledColor)),
              SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    flex: 2,
                    child: Text(message,
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(decoration: TextDecoration.underline)),
                  ),
                  IconButton(
                    onPressed: () {
                      Share.share('${Keys.joinInvite.tr(context)}\n$message');
                    },
                    icon: Icon(
                      Icons.share,
                      size: 25,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
