import 'package:cloud_functions/cloud_functions.dart';
import '../../models/user_model.dart';

class UserPageViewModel {
  UserPageViewModel({required this.user});

  final UserModel user;
}
