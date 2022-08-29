import 'package:app_2i2i/infrastructure/commons/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../infrastructure/commons/keys.dart';
import '../../../../infrastructure/commons/theme.dart';
import '../../../../infrastructure/models/bid_model.dart';
import '../../../../infrastructure/models/user_model.dart';
import '../../../../infrastructure/providers/all_providers.dart';
import '../../../commons/custom_profile_image_view.dart';

ValueNotifier<List> showLoaderIds = ValueNotifier([]);

class BidOutTileWeb extends ConsumerWidget {
  final BidOut bidOut;

  BidOutTileWeb({Key? key, required this.bidOut}) : super(key: key);

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
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 15),
        child: Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ProfileWidget(
                    stringPath: (user.imageUrl ?? "").isEmpty ? user.name : user.imageUrl!,
                    imageType: (user.imageUrl ?? "").isEmpty ? ImageType.NAME_IMAGE : ImageType.NETWORK_IMAGE,
                    radius: 60,
                    borderRadius: 12,
                    hideShadow: true,
                    showBorder: false,
                    statusColor: statusColor,
                    style: Theme.of(context).textTheme.headline5,
                  ),
                  Padding(
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
                  Image.asset(
                    'assets/algo_logo.png',
                    height: 34,
                    width: 34,
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.015,
                  vertical: MediaQuery.of(context).size.width * 0.01,
                ),
                child: Text(
                  "${user.name}",
                  maxLines: 2,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              Flexible(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.003),
                  child: ListTile(
                      leading: IconButton(
                        onPressed: () async {
                          if (!showLoaderIds.value.contains(bidOut.id)) {
                            showLoaderIds.value.add(bidOut.id);
                            showLoaderIds.value = List.from(showLoaderIds.value);
                            await ref.read(myUserPageViewModelProvider)?.cancelOwnBid(bidOut: bidOut);
                          }
                        },
                        icon: ValueListenableBuilder(
                          valueListenable: showLoaderIds,
                          builder: (BuildContext context, List<dynamic> value, Widget? child) {
                            bool showLoader = value.contains(bidOut.id);
                            return showLoader ? CupertinoActivityIndicator() : Icon(Icons.cancel);
                          },
                        ),
                      ),
                      trailing: RichText(
                        textAlign: TextAlign.end,
                        text: TextSpan(
                          text: '${Keys.speed.tr(context)} :',
                          children: [TextSpan(text: ' ${bidOut.energy / MILLION} ALGO', children: [], style: Theme.of(context).textTheme.bodyText2)],
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                      )),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
