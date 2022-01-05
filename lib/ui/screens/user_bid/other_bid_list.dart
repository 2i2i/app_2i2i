import 'package:app_2i2i/infrastructure/commons/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../infrastructure/data_access_layer/repository/firestore_database.dart';
import '../../../infrastructure/data_access_layer/services/logging.dart';
import '../../../infrastructure/models/bid_model.dart';
import '../../../infrastructure/models/user_model.dart';
import '../../../infrastructure/providers/all_providers.dart';

class OtherBidInList extends ConsumerWidget {
  OtherBidInList({required this.B, required this.database});

  final FirestoreDatabase database;
  final UserModel B;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
        return _bidsListView(ref, context);
  }

  Widget _bidsListView(WidgetRef ref, BuildContext context) {
    final myId = ref.read(myUIDProvider)!;
    final userPrivateAsyncValue = ref.watch(userPrivateProvider(myId));
    if (userPrivateAsyncValue is AsyncLoading) {
      return Container();
    }

    return StreamBuilder(
        stream: FirestoreDatabase().bidInsStream(uid: B.id),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
                shrinkWrap: true,
                itemCount: snapshot.data.length,
                itemBuilder: (_, ix) {
                  BidIn bidIn = snapshot.data[ix];
                  log('bid.speed.num');
                  final String num = bidIn.speed.num.toString();
                  final int assetId = bidIn.speed.assetId;
                  log('assetId');
                  final String assetIDString =
                      assetId == 0 ? 'ALGO' : assetId.toString();
                  final color = ix % 2 == 0
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).cardColor;

                  return Card(
                      color: color,
                      child: ListTile(
                        leading: Icon(Icons.circle, color: AppTheme().gray),
                        title: Text('$num'),
                        subtitle: Text('[$assetIDString/sec]'),
                      ));
                });
          }
          return Center(child: CircularProgressIndicator());
        });
  }
}