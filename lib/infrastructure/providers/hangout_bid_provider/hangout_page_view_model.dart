import 'package:cloud_functions/cloud_functions.dart';

import '../../models/hangout_model.dart';


class HangoutPageViewModel {
  HangoutPageViewModel({required this.functions, required this.hangout});
  final FirebaseFunctions functions;
  final Hangout hangout;
}
