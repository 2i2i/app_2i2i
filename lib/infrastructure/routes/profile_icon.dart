// TODO where to move this file?

import 'package:app_2i2i/infrastructure/commons/keys.dart';
import 'package:app_2i2i/infrastructure/data_access_layer/repository/secure_storage_service.dart';
import 'package:app_2i2i/infrastructure/models/bid_model.dart';
import 'package:app_2i2i/infrastructure/providers/all_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProfileIcon extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final normalReturn = selectedIcon('assets/icons/person.svg', context);
    final userId = ref.watch(myUIDProvider);
    if (userId == null) {
      return normalReturn;
    }

    final bidInList = ref.watch(bidInsPublicProvider(userId));
    if ((bidInList.value ?? []).isEmpty) {
      return normalReturn;
    }
    List<BidInPublic> bids = bidInList.value ?? [];
    if (bids.isEmpty) {
      return normalReturn;
    }

    return FutureBuilder(
        future: SecureStorage().read(Keys.myReadBids),
        builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
          if (snapshot.data == null) {
            return normalReturn;
          }
          List<String> localIds = snapshot.data!.split(',').toSet().toList();
          List serverIds = bids.map((e) => e.id).toSet().toList();
          bool anyNew = serverIds.any((element) => !localIds.contains(element));
          if (!anyNew) {
            return normalReturn;
          }

          return SizedBox(

          );
        });
  }

  Widget selectedIcon(String iconPath, BuildContext context, {bool isSelected = false}) {
    return SvgPicture.asset(iconPath,height: 25, color: isSelected ? Theme.of(context).colorScheme.secondary : null,);
  }
}
