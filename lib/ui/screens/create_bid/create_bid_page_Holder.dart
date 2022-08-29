import 'package:app_2i2i/infrastructure/data_access_layer/accounts/abstract_account.dart';
import 'package:app_2i2i/infrastructure/models/bid_model.dart';
import 'package:app_2i2i/infrastructure/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_builder/responsive_builder.dart';

import 'create_bid_page.dart';
import 'create_bid_page_web.dart';

class CreateBidPageRouterObject {
  CreateBidPageRouterObject({required this.bidIns, required this.B, this.sliderHeight, this.min, this.max, this.fullWidth});

  final String B;
  final List<BidInPublic> bidIns;
  final double? sliderHeight;
  final int? min;
  final int? max;
  final bool? fullWidth;
}

class CreateBidPageHolder extends ConsumerStatefulWidget {
  late final String B;
  late final List<BidInPublic> bidIns;
  late final double sliderHeight;
  late final int min;
  late final int max;
  late final fullWidth;

  CreateBidPageHolder({this.sliderHeight = 48, this.max = 10, required this.B, required this.bidIns, this.min = 0, this.fullWidth = false});

  CreateBidPageHolder.fromObject(CreateBidPageRouterObject obj) {
    B = obj.B;
    bidIns = obj.bidIns;
    sliderHeight = obj.sliderHeight ?? 48;
    min = obj.min ?? 0;
    max = obj.max ?? 10;
    fullWidth = obj.fullWidth ?? false;
  }

  @override
  _CreateBidPageHolderState createState() => _CreateBidPageHolderState();
}

class _CreateBidPageHolderState extends ConsumerState<CreateBidPageHolder> with SingleTickerProviderStateMixin {
  AbstractAccount? account;
  Quantity amount = Quantity(num: 0, assetId: 0);
  Quantity speed = Quantity(num: 0, assetId: 0);
  String? comment;
  int maxDuration = 300;
  int maxMaxDuration = 300;
  int minMaxDuration = 10;

  ValueNotifier<bool> isAddSupportVisible = ValueNotifier(false);
  TextEditingController speedController = TextEditingController();
  PageController controller = PageController(initialPage: 0);

  UserModel? userB;
  FocusNode focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout.builder(
      mobile: (BuildContext context) => CreateBidPage(B: widget.B, bidIns: [],),
      tablet: (BuildContext context) => CreateBidPage(B: widget.B, bidIns: [],),
      desktop: (BuildContext context) => CreateBidPageWeb(B: widget.B, bidIns: [],),
    );
  }
}
