import 'package:app_2i2i/common/theme.dart';
import 'package:app_2i2i/models/bid.dart';
import 'package:app_2i2i/models/user.dart';
import 'package:app_2i2i/repository/firestore_database.dart';
import 'package:app_2i2i/services/all_providers.dart';
import 'package:app_2i2i/services/logging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OtherBidInList extends ConsumerWidget {
  OtherBidInList(
      {required this.B, required this.database});

  final FirestoreDatabase database;
  final UserModel B;
  // final void Function(BidIn bid)? onTrailingIconClick;
  // final void Function(bool isPresent)? alreadyExists;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO add sorting
    // if (user.bidsIn.isEmpty)
    //   return Center(
    //     child: Text('No bid for user',
    //         style: Theme.of(context).textTheme.bodyText2),
    //   );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            padding: const EdgeInsets.only(top: 20, left: 25),
            child: Row(
              children: [
                Text('OTHER BIDS FOR ',
                    style: Theme.of(context).textTheme.subtitle2),
                Text('${B.name}',
                    style: Theme.of(context)
                        .textTheme
                        .subtitle2!
                        .copyWith(color: Theme.of(context).primaryColor)),
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
    // log('==========================\n ${userPrivateAsyncValue is AsyncLoading} ${userPrivateAsyncValue.data?.value.bidsOut.toString()} \n===============');
    if (userPrivateAsyncValue is AsyncLoading) {
      return Container();
    }
    return ListView.builder(
      // itemCount: user.bidsIn.length,
      itemBuilder: (_, ix) {
        return StreamBuilder(
          stream: FirestoreDatabase().bidInsStream(uid: B.id),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData) {
              BidIn bidIn = snapshot.data;
              // bool isItCurrentUserBid = userPrivateAsyncValue
              //     .data!.value.bidsOut
              //     .any((element) => element == bidIn.id);
              // if (isItCurrentUserBid) {
              //   alreadyExists!.call(true);
              // }
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
                    // trailing: Visibility(
                    //   visible: isItCurrentUserBid,
                    //   child: Tooltip(
                    //     message: "Cancel Bid",
                    //     child: IconButton(
                    //       icon: Icon(Icons.cancel_rounded,
                    //           color: Color.fromRGBO(104, 160, 242, 1)),
                    //       onPressed: () => onTrailingIconClick!(bidIn),
                    //     ),
                    //   ),
                    // ),
                  ));
            }
            return Center(child: CircularProgressIndicator());
          },
        );
      },
    );
  }
}


// class OtherBidInList extends ConsumerWidget {
//   OtherBidInList(
//       {required this.user, this.onTrailingIconClick, this.alreadyExists});

//   final FirestoreDatabase database;
//   final UserModel user;
//   final void Function(BidIn bid)? onTrailingIconClick;
//   final void Function(bool isPresent)? alreadyExists;

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     // TODO add sorting
//     // if (user.bidsIn.isEmpty)
//     //   return Center(
//     //     child: Text('No bid for user',
//     //         style: Theme.of(context).textTheme.bodyText2),
//     //   );

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Container(
//             padding: const EdgeInsets.only(top: 20, left: 25),
//             child: Row(
//               children: [
//                 Text('OTHER BIDS FOR ',
//                     style: Theme.of(context).textTheme.subtitle2),
//                 Text('${user.name}',
//                     style: Theme.of(context)
//                         .textTheme
//                         .subtitle2!
//                         .copyWith(color: Theme.of(context).primaryColor)),
//               ],
//             )),
//         Expanded(
//             child: Container(
//                 padding: const EdgeInsets.only(
//                     top: 10, left: 20, right: 20, bottom: 10),
//                 child: _bidsListView(ref, context))),
//       ],
//     );
//   }

//   Widget _bidsListView(WidgetRef ref, BuildContext context) {
//     final myId = ref.read(myUIDProvider);
//     if (myId == null) {
//       return Container();
//     }
//     final userPrivateAsyncValue = ref.watch(userPrivateProvider(myId));
//     log('==========================\n ${userPrivateAsyncValue is AsyncLoading} ${userPrivateAsyncValue.data?.value.bidsOut.toString()} \n===============');
//     if (userPrivateAsyncValue is AsyncLoading) {
//       return Container();
//     }
//     return ListView.builder(
//       // itemCount: user.bidsIn.length,
//       itemBuilder: (_, ix) {
//         return StreamBuilder(
//           stream: FirestoreDatabase().bidInsStream(uid: user.id),
//           builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
//             if (snapshot.hasData) {
//               BidIn bidIn = snapshot.data;
//               database.bool isItCurrentUserBid = userPrivateAsyncValue
//                   .data!.value.bidsOut
//                   .any((element) => element == bidIn.id);
//               if (isItCurrentUserBid) {
//                 alreadyExists!.call(true);
//               }
//               log('bid.speed.num');
//               final String num = bidIn.speed.num.toString();
//               final int assetId = bidIn.speed.assetId;
//               log('assetId');
//               final String assetIDString =
//                   assetId == 0 ? 'ALGO' : assetId.toString();
//               final color = ix % 2 == 0
//                   ? Theme.of(context).primaryColor
//                   : Theme.of(context).cardColor;

//               return Card(
//                   color: color,
//                   child: ListTile(
//                     leading: Icon(Icons.circle, color: AppTheme().gray),
//                     title: Text('$num'),
//                     subtitle: Text('[$assetIDString/sec]'),
//                     trailing: Visibility(
//                       visible: isItCurrentUserBid,
//                       child: Tooltip(
//                         message: "Cancel Bid",
//                         child: IconButton(
//                           icon: Icon(Icons.cancel_rounded,
//                               color: Color.fromRGBO(104, 160, 242, 1)),
//                           onPressed: () => onTrailingIconClick!(bidIn),
//                         ),
//                       ),
//                     ),
//                   ));
//             }
//             return Center(child: CircularProgressIndicator());
//           },
//         );
//       },
//     );
//   }
// }
