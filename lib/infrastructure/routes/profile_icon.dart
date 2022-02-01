// TODO where to move this file?

import 'package:app_2i2i/infrastructure/commons/keys.dart';
import 'package:app_2i2i/infrastructure/data_access_layer/repository/secure_storage_service.dart';
import 'package:app_2i2i/infrastructure/data_access_layer/services/logging.dart';
import 'package:app_2i2i/infrastructure/models/bid_model.dart';
import 'package:app_2i2i/infrastructure/providers/all_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProfileIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final normalReturn = selectedIcon('assets/icons/person.svg', context);

    return Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) {
      final userId = ref.watch(myUIDProvider);
      if (userId == null) return normalReturn;

      final bidInList = ref.watch(bidInsPublicProvider(userId));
      if (bidInList.value == null) return normalReturn;
      List<BidInPublic> bids = bidInList.asData!.value;
      if (bids.isEmpty) return normalReturn;

      return FutureBuilder(
          future: SecureStorage().read(Keys.myReadBids),
          builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
            if (snapshot.data == null) return normalReturn;
            log('snapshot.data=${snapshot.data}');
            List<String> localIds = snapshot.data!.split(',').toSet().toList();
            List serverIds = bids.map((e) => e.id).toSet().toList();
            bool anyNew =
                serverIds.any((element) => !localIds.contains(element));
            if (!anyNew) return normalReturn;

            return SizedBox(
              height: 30,
              width: 30,
              child: Stack(
                children: [
                  selectedIcon('assets/icons/person.svg', context),
                  Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      height: 15,
                      width: 15,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
            );
          });
    });
  }

  Widget selectedIcon(String iconPath, BuildContext context,
      {bool isSelected = false}) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: SvgPicture.asset(iconPath,
          color: isSelected ? Theme.of(context).colorScheme.secondary : null),
    );
  }
}
