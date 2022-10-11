import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../infrastructure/commons/keys.dart';
import '../../../../infrastructure/commons/theme.dart';
import '../../../../infrastructure/models/bid_model.dart';
import '../../../../infrastructure/models/user_model.dart';
import '../../../../infrastructure/providers/all_providers.dart';
import '../../../../infrastructure/routes/app_routes.dart';
import '../../../commons/custom_alert_widget.dart';
import '../../../commons/custom_profile_image_view.dart';

ValueNotifier<List> showLoaderIds = ValueNotifier([]);

class BidOutTile extends ConsumerWidget {
  final BidOut bidOut;

  BidOutTile({Key? key, required this.bidOut}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var statusColor = AppTheme().green;
    String bidSpeed = "0";

    final userAsyncValue = ref.watch(userProvider(bidOut.B));
    if (userAsyncValue is AsyncLoading || userAsyncValue is AsyncError) {
      return CupertinoActivityIndicator();
    }

    UserModel user = userAsyncValue.value!;
    bidSpeed = (bidOut.speed.num / pow(10, 6)).toString();

    if (user.status == Status.OFFLINE) {
      statusColor = AppTheme().gray;
    }
    if (user.status == Status.IDLE) {
      statusColor = Colors.amber;
    }
    if (user.isInMeeting()) {
      statusColor = AppTheme().red;
    }
    String firstNameChar = user.name;
    if (firstNameChar.isNotEmpty) {
      firstNameChar = firstNameChar.substring(0, 1);
    }

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          children: [
            ListTile(
              leading: ProfileWidget(
                stringPath: (user.imageUrl ?? "").isEmpty ? user.name : user.imageUrl!,
                imageType: (user.imageUrl ?? "").isEmpty ? ImageType.NAME_IMAGE : ImageType.NETWORK_IMAGE,
                radius: 60,
                borderRadius: 10,
                hideShadow: true,
                showBorder: false,
                onTap: () => context.pushNamed(Routes.user.nameFromPath(), params: {
                  'uid': user.id,
                }),
                statusColor: statusColor,
                style: Theme.of(context).textTheme.headline5,
              ),
              title: Text(
                "${user.name}",
                maxLines: 2,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: RichText(
                  text: TextSpan(
                    text: bidSpeed,
                    children: [
                      TextSpan(
                        text: ' ALGO/sec',
                        children: [],
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).textTheme.headline6?.color?.withOpacity(0.7),
                            ),
                      )
                    ],
                    style: Theme.of(context).textTheme.headline6?.copyWith(
                          color: Theme.of(context).textTheme.headline6?.color?.withOpacity(0.7),
                        ),
                  ),
                ),
              ),
              trailing: Image.asset(
                'assets/algo_logo.png',
                height: 34,
                width: 34,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => CustomAlertWidget.confirmDialog(
                      context,
                      title: Keys.cancelBid.tr(context),
                      description: Keys.cancelBidMsg.tr(context),
                      onPressed: () async {
                        if (!showLoaderIds.value.contains(bidOut.id)) {
                          showLoaderIds.value.add(bidOut.id);
                          showLoaderIds.value = List.from(showLoaderIds.value);
                          await ref.read(myUserPageViewModelProvider)?.cancelOwnBid(bidOut: bidOut, context: context);
                        }
                      },
                      yesButtonTextStyle: TextStyle(color: Theme.of(context).errorColor),
                      noButtonTextStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
                    ),
                    icon: ValueListenableBuilder(
                      valueListenable: showLoaderIds,
                      builder: (BuildContext context, List<dynamic> value, Widget? child) {
                        bool showLoader = value.contains(bidOut.id);
                        return showLoader ? CupertinoActivityIndicator() : Icon(Icons.cancel);
                      },
                    ),
                  ),
                  Spacer(),
                  Expanded(
                    child: RichText(
                      textAlign: TextAlign.end,
                      text: TextSpan(
                        text: '${Keys.speed.tr(context)} :',
                        children: [TextSpan(text: ' ${bidOut.energy / pow(10, 6)} ALGO', children: [], style: Theme.of(context).textTheme.bodyText2)],
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
