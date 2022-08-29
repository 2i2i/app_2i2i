import 'package:app_2i2i/infrastructure/models/bid_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_builder/responsive_builder.dart';
import '../../../infrastructure/models/user_model.dart';
import 'other_bid_list_web.dart';

class OtherBidInListHolder extends ConsumerWidget {
  OtherBidInListHolder({required this.user, required this.bidIns});

  final UserModel user;
  final List<BidInPublic> bidIns;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScreenTypeLayout.builder(
      mobile: (BuildContext context) => OtherBidInListWeb(
        bidIns: [],
        user: user,
      ),
      tablet: (BuildContext context) => OtherBidInListWeb(
        bidIns: [],
        user: user,
      ),
      desktop: (BuildContext context) => OtherBidInListWeb(
        bidIns: [],
        user: user,
      ),
    );
  }
}
