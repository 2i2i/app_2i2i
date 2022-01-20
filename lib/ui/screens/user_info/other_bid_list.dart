import 'package:app_2i2i/infrastructure/commons/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../infrastructure/data_access_layer/repository/firestore_database.dart';
import '../../../infrastructure/data_access_layer/services/logging.dart';
import '../../../infrastructure/models/bid_model.dart';
import '../../../infrastructure/models/user_model.dart';

class OtherBidInList extends ConsumerWidget {
  OtherBidInList({required this.B});
  final UserModel B;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
        return _bidsListView(ref, context);
  }

  Widget _bidsListView(WidgetRef ref, BuildContext context) {
       return StreamBuilder(
        stream: FirestoreDatabase().bidInsPublicStream(uid: B.id),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
                shrinkWrap: true,
                itemCount: snapshot.data.length,
                itemBuilder: (_, ix) {
                  BidInPublic bidIn = snapshot.data[ix];
                  log('bid.speed.num');
                  final String num = bidIn.speed.num.toString();
                  final int assetId = bidIn.speed.assetId;
                  log('assetId');
                  final String assetIDString =
                      assetId == 0 ? 'μALGO' : assetId.toString();
                  final color = ix % 2 == 0
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).cardColor;

                  return Card(
                      color: color,
                      child: ListTile(
                        leading: Icon(Icons.circle, color: AppTheme().gray),
                        title: Text('$num'),
                        subtitle: Text('[$assetIDString/s]'),
                      ));
                });
          }
          return Center(child: CircularProgressIndicator());
        });
  }
}
