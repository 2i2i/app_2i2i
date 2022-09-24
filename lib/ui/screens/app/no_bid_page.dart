import 'package:app_2i2i/infrastructure/commons/utils.dart';
import 'package:app_2i2i/ui/layout/spacings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../infrastructure/commons/keys.dart';
import '../../../infrastructure/providers/all_providers.dart';
import '../../commons/qr_image.dart';
import 'wait_page.dart';

class NoBidPage extends ConsumerWidget {
  final String noBidsText;

  const NoBidPage({Key? key, required this.noBidsText}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(myUIDProvider);
    if (uid == null) return WaitPage();
    final userModel = ref.watch(userProvider(uid));
    if (haveToWait(userModel)) return WaitPage();
    String? message;
    if (userModel.value?.url?.isNotEmpty ?? false) {
      message = userModel.value!.url!;
    }
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height / 1.3,
      alignment: Alignment.center,
      child: ScrollConfiguration(
        behavior: MyBehavior(),
        child: SingleChildScrollView(
          physics: ClampingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: kTextTabBarHeight),
              Text(noBidsText, style: Theme.of(context).textTheme.subtitle2?.copyWith(color: Theme.of(context).disabledColor)),
              SizedBox(height: kTextTabBarHeight),
              Container(
                // decoration: Custom.getBoxDecoration(context, color: Colors.white, radius: 10),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: QrWidget(
                    imageSize: MediaQuery.of(context).size.height * 0.18,
                    logoSize: MediaQuery.of(context).size.height * 0.04,
                    message: message ?? '',
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
                  if (message?.isNotEmpty ?? false)
                    Flexible(
                      flex: 2,
                      child: Text(
                        message ?? '',
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(decoration: TextDecoration.underline),
                      ),
                    ),
                  if (message?.isEmpty ?? true && !kIsWeb)
                    Flexible(
                      flex: 2,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: AppSpacings.s20, vertical: AppSpacings.s10),
                        child: LinearProgressIndicator(),
                      ),
                    ),
                  Visibility(
                    visible: message?.isNotEmpty ?? false,
                    child: IconButton(
                        onPressed: () => Share.share('${Keys.joinInvite.tr(context)}\n$message'),
                        icon: Icon(
                          Icons.share,
                          size: 20,
                        )),
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
