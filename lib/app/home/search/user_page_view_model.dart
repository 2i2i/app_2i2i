import 'package:app_2i2i/app/home/models/user.dart';
import 'package:cloud_functions/cloud_functions.dart';

class UserPageViewModel {
  UserPageViewModel({required this.functions, required this.user});
  final FirebaseFunctions functions;
  final UserModel user;
}
