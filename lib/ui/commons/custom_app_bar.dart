import 'package:app_2i2i/infrastructure/commons/utils.dart';
import 'package:app_2i2i/ui/commons/custom_navigation.dart';
import 'package:app_2i2i/ui/commons/custom_profile_image_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../infrastructure/providers/all_providers.dart';
import '../../infrastructure/routes/app_routes.dart';
import '../screens/rating/rating_page.dart';
import '../screens/search/widgtes/star_widget.dart';
import '../screens/top/top_page.dart';

class CustomAppbar extends ConsumerWidget implements PreferredSizeWidget {
  final List<Widget>? actions;
  final Color? backgroundColor;

  CustomAppbar({this.actions, this.backgroundColor});

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + 50);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.read(myUIDProvider)!;
    final hangout = ref.watch(hangoutProvider(uid));

    return AppBar(
      backgroundColor: backgroundColor,
      elevation: 0,
      actions: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            !(haveToWait(hangout))
                ? RectangleBox(
                    onTap: () => context.pushNamed(Routes.ratings.nameFromPath(),params: {'uid':uid}),
                    // onTap: () => AlertWidget.showBidAlert(context, CreateBidWidget()),
                    radius: 46,
                    icon: StarWidget(
                      width: 20,
                      height: 32,
                      value: hangout.value?.rating ?? 1,
                      startColor: Theme.of(context).colorScheme.secondary,
                    ),
                  )
                : Container(),
            SizedBox(
              width: 10,
            ),
            RectangleBox(
              onTap: () => context.pushNamed(Routes.top),
              radius: 46,
              icon: SvgPicture.asset(
                'assets/icons/crown.svg',
                width: 16,
                height: 16,
              ),
            ),
            SizedBox(
              width: 10,
            )
          ],
        ),
      ],
      toolbarHeight: kToolbarHeight + 50,
      centerTitle: false,
      title: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SvgPicture.asset(
          getLogo(context),
          fit: BoxFit.fill,
          width: 55,
          height: 65,
        ),
      ),
    );
  }

  String getLogo(context)  {
    if(Theme.of(context).brightness == Brightness.dark){
      return 'assets/icons/appbar_icon_dark.svg';
    }
    return 'assets/icons/appbar_icon.svg';
  }
}
