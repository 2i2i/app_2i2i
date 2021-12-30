import 'package:cloud_functions/cloud_functions.dart';

import '../../models/user_model.dart';


class UserPageViewModel {
  UserPageViewModel({required this.functions, required this.user});
  final FirebaseFunctions functions;
  final UserModel user;
}
