import 'package:app_2i2i/pages/search/ui/widgtes/star_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/custom_navigation.dart';
import '../../../../routes/app_routes.dart';
import '../../../../services/all_providers.dart';
import '../../../rating/ui/rating_page.dart';

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
          context, RatingPage(userModel: user.data!.value), Routes.RATING),
      child: (user.data!.value.rating ?? 0) > 0
          ? Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  StarWidget(
                    value: (user.data!.value.rating ?? 0) * 5,
                    height: 40,
                    width: 25,
                  ),
                  SizedBox(height: 2),
                  Text('${(user.data!.value.rating ?? 0) * 5}',
                      style: Theme.of(context).textTheme.overline)
                ],
              ),
            )
          : Container(),
    );
  }
}
