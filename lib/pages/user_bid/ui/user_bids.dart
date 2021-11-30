import 'dart:math';

import 'package:app_2i2i/common/text_utils.dart';
import 'package:app_2i2i/common/theme.dart';
import 'package:app_2i2i/models/bid.dart';
import 'package:app_2i2i/models/user.dart';
import 'package:app_2i2i/repository/firestore_database.dart';
import 'package:app_2i2i/services/all_providers.dart';
import 'package:app_2i2i/services/logging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserBids extends ConsumerWidget {
  UserBids({
    required this.bidsIds,
    required this.title,
    required this.noBidsText,
    // required this.onTap,
    required this.leading,
    this.trailingIcon,
    this.onTrailingIconClick,
  });

  final String title;
  final String noBidsText;
  final List<String> bidsIds;

  // final void Function(Bid bid) onTap;
  final Widget leading;
  final Icon? trailingIcon;
  final void Function(Bid bid)? onTrailingIconClick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO add sorting
    if (bidsIds.isEmpty)
      return Center(
        child: Text(noBidsText),
      );
    log('UserBids - bidsIds=$bidsIds');
    log('UserBids - bidsIds.length=${bidsIds.length}');

    return Column(
      children: [
        Container(
            padding: const EdgeInsets.only(top: 10),
            child: Center(
                child:
                    Text(title, style: Theme.of(context).textTheme.headline6))),
        Expanded(
            child: Container(
                padding: const EdgeInsets.only(
                    top: 20, left: 20, right: 20, bottom: 10),
                child: _bidsListView(ref, context))),
      ],
    );
  }

  ListView _bidsListView(WidgetRef ref, BuildContext context) {
    return ListView.builder(
      itemCount: bidsIds.length,
      // itemCount: 2,
      itemBuilder: (_, ix) {
        log('UserBidUserBidssIn - ListView.builder - itemBuilder');
        final bidAsyncValue = ref.watch(bidStreamProvider(bidsIds[ix]));
        log('UserBids - ListView.builder - itemBuilder - ix=$ix');
        log('UserBids - ListView.builder - itemBuilder - bidsInIds[ix]=${bidsIds[ix]}');
        log('UserBids - ListView.builder - itemBuilder - bidAsyncValue=$bidAsyncValue');

        return bidAsyncValue.when(
            data: (Bid bid) {
              final String num = bid.speed.num.toString();
              final int assetId = bid.speed.assetId;
              final String assetIDString =
                  assetId == 0 ? 'ALGO' : assetId.toString();
              final color = ix % 2 == 0
                  ? Color.fromRGBO(223, 239, 223, 1)
                  : Color.fromRGBO(197, 234, 197, 1);

              return StreamBuilder<UserModel>(
                stream: FirestoreDatabase().userStream(uid: bid.B),
                builder: (BuildContext context, var snapshot) {
                  if (snapshot.hasData) {
                    UserModel? user = snapshot.data;
                    final score = ((user?.upVotes ?? 0) - (user?.downVotes ?? 0));
                    final shortBioStart = (user?.bio.indexOf(RegExp(r'\s')) ?? 0) + 1;
                    int aPoint = shortBioStart + 10;
                    int? bPoint = user?.bio.length;
                    final shortBioEnd = min(aPoint, bPoint!);
                    final shortBio =
                        user?.bio.substring(shortBioStart, shortBioEnd);
                    return Container(
                      child: ListTile(
                        onTap: () => onTrailingIconClick!(bid),
                        leading: ratingWidget(score, user?.name, context),
                        title: TitleText(title: user?.name),
                        subtitle: Text(shortBio!),
                        trailing: CaptionText(
                          title: "$assetIDString/sec".toUpperCase(),
                          textColor: AppTheme().brightBlue,
                        ),
                      ),
                      margin: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                          border:
                              Border.all(color: Colors.grey.withOpacity(0.6)),
                          borderRadius: BorderRadius.circular(10)),
                    );
                  }
                  return CircularProgressIndicator();
                },
              );

              return Container(
                  // decoration: BoxDecoration(
                  //   borderRadius: BorderRadius.circular(100),
                  // ),
                  child: Card(
                      color: color,
                      child: Column(children: [
                        ListTile(
                          leading: leading,
                          trailing: trailingIcon == null
                              ? null
                              : IconButton(
                              onPressed: () => onTrailingIconClick!(bid),
                              icon: trailingIcon!),
                          title: Text('$num'),
                          // subtitle: Text('[$assetIDString/sec]'),
                          // tileColor: color,
                          // onTap: () => onTap(bid),
                        ),
                        Text('[$assetIDString/sec]'),
                      ])));
            },
            loading: () => const Text('loading'),
            error: (_, __) => const Text('error'));
      },
    );
  }

  Widget ratingWidget(score, name, BuildContext context) {
    final scoreString = (0 <= score ? '+' : '-') + score.toString();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            0 <= score
                ? Icon(Icons.change_history, color: Colors.green)
                : Transform.rotate(
                    angle: pi,
                    child: Icon(Icons.change_history,
                        color: Color.fromRGBO(211, 91, 122, 1))),
            SizedBox(height: 4),
            Text(scoreString, style: Theme.of(context).textTheme.caption)
          ],
        ),
        SizedBox(width: 10),
        Container(
          height: 40,
          width: 40,
          child: Center(
              child: Text("${name.toString().isNotEmpty ? name : "X"}"
                  .substring(0, 1)
                  .toUpperCase())),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color.fromRGBO(214, 219, 134, 1),
          ),
        )
      ],
    );
  }
}
