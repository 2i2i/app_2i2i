import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../../../infrastructure/models/bid_model.dart';
import 'bid_out_tile.dart';
import 'bid_out_tile_web.dart';

ValueNotifier<List> showLoaderIds = ValueNotifier([]);

class BidOutTileHolder extends ConsumerWidget {
  final BidOut bidOut;

  BidOutTileHolder({Key? key, required this.bidOut}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScreenTypeLayout.builder(
      mobile: (BuildContext context) => BidOutTile(
        bidOut: bidOut,
      ),
      tablet: (BuildContext context) => BidOutTile(
        bidOut: bidOut,
      ),
      desktop: (BuildContext context) => BidOutTileWeb(
        bidOut: bidOut,
      ),
    );
  }
}
