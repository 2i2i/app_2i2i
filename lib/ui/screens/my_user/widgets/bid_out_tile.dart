import 'package:app_2i2i/infrastructure/commons/utils.dart';
import 'package:app_2i2i/infrastructure/routes/app_routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../infrastructure/commons/keys.dart';
import '../../../../infrastructure/commons/theme.dart';
import '../../../../infrastructure/models/bid_model.dart';
import '../../../../infrastructure/models/user_model.dart';
import '../../../../infrastructure/providers/all_providers.dart';
import '../../../commons/custom_profile_image_view.dart';

class BidOutTile extends ConsumerWidget {
  final BidOut bidOut;
  final void Function(BidOut bidOut) onCancelClick;

  const BidOutTile({Key? key, required this.bidOut, required this.onCancelClick}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var statusColor = AppTheme().green;
    String bidSpeed = "0";

    final userAsyncValue = ref.watch(userProvider(bidOut.B));
    if (userAsyncValue is AsyncLoading || userAsyncValue is AsyncError) {
      return CupertinoActivityIndicator();
    }

    UserModel user = userAsyncValue.value!;
    bidSpeed = (bidOut.speed.num / MILLION).toString();

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
            Row(
              children: [
                SizedBox(width: 4),
                ProfileWidget(
                  onTap: () => context.pushNamed(Routes.user.nameFromPath(), params: {
                    'uid': user.id,
                  }),
                  stringPath: (user.imageUrl ?? "").isNotEmpty ? user.imageUrl! : user.name,
                  imageType: (user.imageUrl ?? "").isNotEmpty ? ImageType.NETWORK_IMAGE : ImageType.NAME_IMAGE,
                  statusColor: statusColor,
                  radius: 55,
                  borderRadius: 10,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        maxLines: 2,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.subtitle1?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        user.bio,
                        maxLines: 2,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.caption?.copyWith(
                              fontWeight: FontWeight.w400,
                            ),
                      ),
                    ],
                  ),
                ),
                RichText(
                  text: TextSpan(
                    text: bidSpeed,
                    children: [
                      TextSpan(
                        text: ' ALGO/sec',
                        children: [],
                        style: Theme.of(context).textTheme.subtitle1?.copyWith(
                          color: Theme.of(context).textTheme.headline6?.color?.withOpacity(0.7),
                            ),
                      )
                    ],
                    style: Theme.of(context).textTheme.headline6?.copyWith(
                      color: Theme.of(context).textTheme.headline6?.color?.withOpacity(0.7),
                        ),
                  ),
                ),
                SizedBox(width: 8),
                Image.asset(
                  'assets/algo_logo.png',
                  height: 34,
                  width: 34,
                ),
                SizedBox(width: 4),
              ],
            ),
            SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  IconButton(onPressed: () => onCancelClick(bidOut), icon: Icon(Icons.cancel)),
                  Spacer(),
                  Expanded(
                    child: RichText(
                      textAlign: TextAlign.end,
                      text: TextSpan(
                        text: '${Keys.speed.tr(context)} :',
                        children: [TextSpan(text: ' ${bidOut.energy / MILLION} ALGO', children: [], style: Theme.of(context).textTheme.bodyText2)],
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
