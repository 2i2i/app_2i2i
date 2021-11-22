import 'package:app_2i2i/app/home/models/bid.dart';
import 'package:app_2i2i/app/home/models/user.dart';
import 'package:app_2i2i/services/firestore_database.dart';
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
    await acceptBid({
      'addrB': algorandAddress,
      'bid': bid.id,
    });
  }

  Future cancelBid(Bid bid) async {
    final HttpsCallable cancelBid = functions.httpsCallable('cancelBid');
    await cancelBid({
      'bid': bid.id,
    });
  }

  Future changeBio(String newBio) async {
    await userModelChanger.updateBio(newBio);
  }
}
