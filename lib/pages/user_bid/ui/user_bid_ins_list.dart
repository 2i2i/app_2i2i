import 'package:app_2i2i/common/custom_dialogs.dart';
import 'package:app_2i2i/models/bid.dart';
import 'package:app_2i2i/pages/user_bid/ui/widgets/no_bid_page.dart';
import 'package:app_2i2i/repository/firestore_database.dart';
import 'package:app_2i2i/services/all_providers.dart';
import 'package:app_2i2i/services/logging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:app_2i2i/common/custom_profile_image_view.dart';
import 'package:app_2i2i/common/theme.dart';

import 'widgets/bid_dialog_widget.dart';

class UserBidInsList extends ConsumerWidget {
  UserBidInsList({
    required this.uid,
    required this.titleWidget,
    required this.noBidsText,
    required this.onTap,
  });

  final String uid;
  final Widget titleWidget;
  final String noBidsText;

  final void Function(BidIn bid) onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder(
        stream: FirestoreDatabase().bidInsStream(uid: uid),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          log('UserBidInsList - build - snapshot.hasData=${snapshot.hasData}');
          if (snapshot.hasData) {
            log('UserBidInsList - build - snapshot.data.length=${snapshot.data.length}');
            if (snapshot.data.length == 0) {
              return NoBidPage(noBidsText: noBidsText);
            }

            return ListView.builder(
                itemCount: snapshot.data.length,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemBuilder: (_, ix) {
                  BidIn bid = snapshot.data[ix];

                  final userModel = ref.watch(bidUserProvider(bid.id));
                  if (userModel == null)
                    return Center(child: CircularProgressIndicator());

                  var statusColor = AppTheme().green;
                  if (userModel.status == 'OFFLINE')
                    statusColor = AppTheme().gray;
                  if (userModel.locked) statusColor = AppTheme().red;

                  return InkResponse(
                    onTap: () => CustomDialogs.infoDialog(
                      context: context,
                      child: BidDialogWidget(
                        bidInModel: bid,
                        onTapTalk: () => onTap(bid),userModel: userModel,
                      )
                    ),
                    child: Card(
                        child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextProfileView(
                            radius: 50,
                            text: "${userModel.name}",
                            statusColor: statusColor,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            '${userModel.name}',
                            style: Theme.of(context).textTheme.subtitle1,
                          ),
                        ),
                      ],
                    )),
                  );
                });
          }
          return Center(child: CircularProgressIndicator());
        });
  }
}
