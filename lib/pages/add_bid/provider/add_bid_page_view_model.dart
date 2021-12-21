import 'package:app_2i2i/accounts/abstract_account.dart';
import 'package:app_2i2i/common/utils.dart';
import 'package:app_2i2i/models/bid.dart';
import 'package:app_2i2i/models/user.dart';
import 'package:app_2i2i/repository/algorand_service.dart';
import 'package:app_2i2i/repository/firestore_database.dart';
import 'package:app_2i2i/services/logging.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddBidPageViewModel {
  AddBidPageViewModel({
    required this.uid,
    required this.database,
    required this.functions,
    required this.algorand,
    required this.B,
    required this.accounts,
    required this.accountService,
  });

  final String uid;
  final FirebaseFunctions functions;
  final UserModel B;
  final AlgorandService algorand;
  final AccountService accountService;
  final List<AbstractAccount> accounts;
  final FirestoreDatabase database;

  bool submitting = false;

  String duration(AbstractAccount account, int speedNum, Balance balance) {
    if (speedNum == 0) {
      return 'forever';
    }
    final budget = balance.assetHolding.amount;
    final seconds = budget / speedNum;
    return secondsToSensibleTimePeriod(seconds.round());
  }

  Future addBid({
    // required FireBaseMessagingService fireBaseMessaging,
    required AbstractAccount? account,
    required Balance? balance,
    required int speedNum,
  }) async {
    log('AddBidPageViewModel - addBid');

    final int speedAssetId = speedNum == 0 ? 0 : balance!.assetHolding.assetId;
    log('AddBidPageViewModel - addBid - speedAssetId=$speedAssetId');

    final speed = Speed(num: speedNum, assetId: speedAssetId);

    // TODO clean separation into firestore_service and firestore_database
    final net = AlgorandNet.testnet;
    final bidId = database.newDocId(path: 'users/$uid/bidOuts');
    final bidOutRef =
        FirebaseFirestore.instance.collection('users/$uid/bidOuts').doc(bidId);
    final bidOut = BidOut(id: bidId, B: B.id, speed: speed, net: net);
    final bidInRef = FirebaseFirestore.instance
        .collection('users/${B.id}/bidIns')
        .doc(bidId);
    final bidIn = BidIn(id: bidId, speed: speed, net: net);
    final bidInPrivateRef = FirebaseFirestore.instance
        .collection('users/${B.id}/bidIns')
        .doc(bidId)
        .collection('private')
        .doc('main');
    final bidInPrivate = BidInPrivate(A: uid, addrA: account?.address);
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.set(bidOutRef, bidOut.toMap(), SetOptions(merge: false));
      transaction.set(bidInRef, bidIn.toMap(), SetOptions(merge: false));
      transaction.set(
          bidInPrivateRef, bidInPrivate.toMap(), SetOptions(merge: false));
    });
  }
}
