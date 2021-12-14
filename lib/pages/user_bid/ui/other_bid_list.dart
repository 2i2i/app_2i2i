import 'package:app_2i2i/common/theme.dart';
import 'package:app_2i2i/models/bid.dart';
import 'package:app_2i2i/models/user.dart';
import 'package:app_2i2i/repository/firestore_database.dart';
import 'package:app_2i2i/services/all_providers.dart';
import 'package:app_2i2i/services/logging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OtherBidList extends ConsumerWidget {
  OtherBidList(
      {required this.user,
      this.onTrailingIconClick,
      this.alreadyExists});

  final UserModel user;
  final void Function(Bid bid)? onTrailingIconClick;
  final void Function(bool isPresent)? alreadyExists;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO add sorting
    if (user.bidsIn.isEmpty)
      return Center(
        child: Text('No bid for user',
            style: Theme.of(context).textTheme.bodyText2),
      );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            padding: const EdgeInsets.only(top: 20, left: 25),
            child: Row(
              children: [
                Text('OTHER BIDS FOR ',
                    style: Theme.of(context).textTheme.headline6),
                Text('${user.name}',
                    style: Theme.of(context).textTheme.headline6),
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

  Widget _bidsListView(WidgetRef ref, BuildContext context) {
    final myId = ref.read(myUIDProvider);
    if (myId == null) {
      return Container();
    }
    final userPrivateAsyncValue = ref.watch(userPrivateProvider(myId));
    log('==========================\n ${userPrivateAsyncValue is AsyncLoading} ${userPrivateAsyncValue.data?.value.bidsOut.toString()} \n===============');
    if(userPrivateAsyncValue is AsyncLoading){
      return Container();
    }
    return ListView.builder(
      itemCount: user.bidsIn.length,
      itemBuilder: (_, ix) {
        return StreamBuilder(
          stream: FirestoreDatabase().bidStream(id: user.bidsIn[ix]),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData) {
              Bid bid = snapshot.data;
              bool isItCurrentUserBid = userPrivateAsyncValue.data!.value.bidsOut.any((element) => element.bid == bid.id);
              if (isItCurrentUserBid) {
                alreadyExists!.call(true);
              }
              log('bid.speed.num');
              final String num = bid.speed.num.toString();
              final int assetId = bid.speed.assetId;
              log('assetId');
              final String assetIDString =
                  assetId == 0 ? 'ALGO' : assetId.toString();
              final color = ix % 2 == 0
                  ? Color.fromRGBO(223, 239, 223, 1)
                  : Color.fromRGBO(197, 234, 197, 1);

              return Card(
                  color: color,
                  child: ListTile(
                    leading: Icon(Icons.circle, color: AppTheme().gray),
                    title: Text('$num',
                        style: Theme.of(context).textTheme.bodyText1),
                    subtitle: Text('[$assetIDString/sec]',
                        style: Theme.of(context).textTheme.bodyText2),
                    trailing: Visibility(
                      visible: isItCurrentUserBid,
                      child: Tooltip(
                        message: "Cancel Bid",
                        child: IconButton(
                          icon: Icon(Icons.cancel_rounded,
                              color: Color.fromRGBO(104, 160, 242, 1)),
                          onPressed: () => onTrailingIconClick!(bid),
                        ),
                      ),
                    ),
                  ));
            }
            return Center(child: CircularProgressIndicator());
          },
        );
      },
    );
  }
}
