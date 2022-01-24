import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../infrastructure/data_access_layer/repository/firestore_database.dart';
import '../../../infrastructure/models/hangout_model.dart';
import 'widgets/other_bid_tile.dart';

class OtherBidInList extends ConsumerWidget {
  OtherBidInList({required this.B});
  final Hangout B;

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
                padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 8),
                itemCount: snapshot.data.length,
                itemBuilder: (_, ix) {
                  return OtherBidTile(
                    otherBidList: snapshot.data,
                    index: ix,
                    hangout: B,
                  );
                });
          }
          return Center(child: CircularProgressIndicator());
        });
  }
}
