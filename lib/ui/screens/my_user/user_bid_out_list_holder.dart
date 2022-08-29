import 'package:app_2i2i/ui/screens/my_user/user_bid_out_list.dart';
import 'package:app_2i2i/ui/screens/my_user/user_bid_out_list_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_builder/responsive_builder.dart';

class UserBidOutHolder extends ConsumerWidget {
  Widget build(BuildContext context, WidgetRef ref) {
    return ScreenTypeLayout.builder(
      mobile: (BuildContext context) => UserBidOut(),
      tablet: (BuildContext context) => UserBidOut(),
      desktop: (BuildContext context) => UserBidOutWeb(),
    );
  }
}
