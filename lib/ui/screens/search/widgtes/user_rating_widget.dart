
import 'package:app_2i2i/ui/commons/custom_navigation.dart';
import 'package:app_2i2i/ui/screens/search/widgtes/star_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../infrastructure/providers/all_providers.dart';
import '../../../../infrastructure/routes/app_routes.dart';
import '../../rating/rating_page.dart';

class UserRatingWidget extends ConsumerStatefulWidget {
  const UserRatingWidget({Key? key}) : super(key: key);

  @override
  _UserRatingWidgetState createState() => _UserRatingWidgetState();
}

class _UserRatingWidgetState extends ConsumerState<UserRatingWidget> {
  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(myUIDProvider)!;
    final user = ref.watch(userProvider(uid));
    if (user is AsyncLoading || user is AsyncError) {
      return Container();
    }
    return InkWell(
      onTap: () => CustomNavigation.push(
          context, RatingPage(userModel: user.asData!.value), Routes.RATING),
      child: (user.asData!.value.rating ?? 0) > 0
          ? Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  StarWidget(
                    value: (user.asData!.value.rating ?? 0) * 5,
                    height: 40,
                    width: 25,
                  ),
                  SizedBox(height: 2),
                  Text('${(user.asData!.value.rating ?? 0) * 5}',
                      style: Theme.of(context).textTheme.overline)
                ],
              ),
            )
          : Container(),
    );
  }
}
