import 'package:app_2i2i/infrastructure/commons/utils.dart';
import 'package:app_2i2i/ui/commons/custom_profile_image_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../infrastructure/providers/all_providers.dart';
import '../../infrastructure/routes/app_routes.dart';
import '../screens/search/widgtes/star_widget.dart';

class CustomAppbarWeb extends ConsumerWidget implements PreferredSizeWidget {
  final List<Widget>? actions;
  final Color backgroundColor;
  final Widget? title;

  const CustomAppbarWeb({this.title, this.actions, this.backgroundColor = Colors.transparent});

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + 20);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.read(myUIDProvider)!;
    final user = ref.watch(userProvider(uid));

    return AppBar(
      backgroundColor: backgroundColor,
      elevation: 0,
      automaticallyImplyLeading: false,
      actions: actions ??
          [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                !(haveToWait(user))
                    ? RectangleBox(
                        onTap: () => context.pushNamed(Routes.ratings.nameFromPath(), params: {'uid': uid}),
                        radius: 46,
                        icon: StarWidget(
                          width: 20,
                          height: 32,
                          value: user.value?.rating ?? 1,
                          startColor: Theme.of(context).colorScheme.secondary,
                        ),
                      )
                    : Container(),
                SizedBox(
                  width: 10,
                ),
                RectangleBox(
                  onTap: () => context.pushNamed(Routes.top.nameFromPath()),
                  radius: 46,
                  icon: SvgPicture.asset(
                    'assets/icons/crown.svg',
                    width: 16,
                    height: 16,
                  ),
                ),
                SizedBox(
                  width:kToolbarHeight,
                )
              ],
            ),
          ],
      toolbarHeight: kToolbarHeight + 20,
      centerTitle: false,
      title: Row(
        children: [
          title ?? SizedBox(width: kToolbarHeight-15,),
          SvgPicture.asset(
            getLogo(context),
            fit: BoxFit.cover,
            width: 55,
            height: 65,
          ),
        ],
      ),
    );
  }

  String getLogo(context) {
    if (Theme.of(context).brightness == Brightness.dark) {
      return 'assets/icons/appbar_icon_dark.svg';
    }
    return 'assets/icons/appbar_icon.svg';
  }
}
