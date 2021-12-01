import 'package:app_2i2i/common/text_utils.dart';
import 'package:app_2i2i/common/theme.dart';
import 'package:app_2i2i/models/bid.dart';
import 'package:app_2i2i/models/user.dart';
import 'package:app_2i2i/repository/firestore_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OtherBidList extends ConsumerWidget {
  OtherBidList({this.user});

  final UserModel? user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO add sorting
    if (user!.bidsIn.isEmpty)
      return Center(
        child: BodyTwoText(title: 'No bid for user'),
      );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            padding: const EdgeInsets.only(top: 20, left: 25),
            child: Row(
              children: [
                HeadLineSixText(
                    title: 'OTHER BIDS FOR ', textColor: AppTheme().deepPurple),
                HeadLineSixText(
                    title: '${user!.name}', textColor: AppTheme().black),
              ],
            )),
        Expanded(
            child: Container(
                padding: const EdgeInsets.only(
                    top: 10, left: 20, right: 20, bottom: 10),
                child: _bidsListView(ref, context))),
      ],
    );
  }

  ListView _bidsListView(WidgetRef ref, BuildContext context) {
    return ListView.builder(
      itemCount: user!.bidsIn.length,
      itemBuilder: (_, ix) {
        return StreamBuilder(
          stream: FirestoreDatabase().bidStream(id: user!.bidsIn[ix]),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData) {
              Bid bid = snapshot.data;
              final String num = bid.speed.num.toString();
              final int assetId = bid.speed.assetId;
              final String assetIDString =
                  assetId == 0 ? 'ALGO' : assetId.toString();
              final color = ix % 2 == 0
                  ? Color.fromRGBO(223, 239, 223, 1)
                  : Color.fromRGBO(197, 234, 197, 1);

              return Card(
                  color: color,
                  child: ListTile(
                    leading: Icon(Icons.circle, color: AppTheme().gray),
                    title: BodyTwoText(title:'$num'),
                    trailing: BodyTwoText(title:'[$assetIDString/sec]',textColor: AppTheme().brightBlue,),
                  ));
            }
            return Center(child: CircularProgressIndicator());
          },
        );
      },
    );
  }
}
