import 'package:app_2i2i/models/bid.dart';
import 'package:app_2i2i/models/user.dart';
import 'package:app_2i2i/repository/firestore_database.dart';
import 'package:cloud_functions/cloud_functions.dart';

class MyUserPageViewModel {
  MyUserPageViewModel(
      {required this.database,
      required this.functions,
      required this.user,
      required this.algorandAddress,
      required this.userModelChanger});
  final UserModel user;
  final FirestoreDatabase database;
  final FirebaseFunctions functions;
  final String? algorandAddress;
  final UserModelChanger userModelChanger;

  Future acceptBid(Bid bid) async {
    final HttpsCallable acceptBid = functions.httpsCallable('acceptBid');
    // TODO only get algorandAddress if bid.speed.num != 0
    await acceptBid({
      'addrB': bid.speed.num == 0 ? null : algorandAddress,
      'bid': bid.id,
    });
  }

  Future cancelBid(Bid bid) async {
    final HttpsCallable cancelBid = functions.httpsCallable('cancelBid');
    await cancelBid({
      'bid': bid.id,
    });
  }

  Future changeNameAndBio(String name, String bio) async {
    await userModelChanger.updateNameAndBio(name, bio);
  }
}