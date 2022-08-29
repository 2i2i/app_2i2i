import 'package:app_2i2i/infrastructure/commons/utils.dart';
import 'package:app_2i2i/ui/commons/custom_profile_image_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../infrastructure/commons/keys.dart';
import '../../infrastructure/commons/theme.dart';
import '../../infrastructure/providers/all_providers.dart';
import '../../infrastructure/routes/app_routes.dart';
import '../screens/search/widgtes/star_widget.dart';

class CustomAppbarWebSearch extends ConsumerStatefulWidget implements PreferredSizeWidget {
  final List<Widget>? actions;
  final Color backgroundColor;
  final Widget? title;

  CustomAppbarWebSearch({this.title, this.actions, this.backgroundColor = Colors.transparent});

  @override
  ConsumerState<CustomAppbarWebSearch> createState() => _CustomAppbarWebSearchState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + 20);
}

class _CustomAppbarWebSearchState extends ConsumerState<CustomAppbarWebSearch> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final uid = ref.read(myUIDProvider)!;
    final user = ref.watch(userProvider(uid));

    return AppBar(
      backgroundColor: widget.backgroundColor,
      elevation: 0,
      automaticallyImplyLeading: false,
      actions: widget.actions ??
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
                  width: kToolbarHeight,
                )
              ],
            ),
          ],
      toolbarHeight: kToolbarHeight + 20,
      centerTitle: false,
      title: Row(
        children: [
          SizedBox(
            width: kToolbarHeight - 15,
          ),
          widget.title ??
              SvgPicture.asset(
                getLogo(context),
                fit: BoxFit.cover,
                width: 55,
                height: 65,
              ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.015),
              child: Card(
                margin: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.020,
                ),
                color: Colors.transparent,
                elevation: 0,
                child: TextFormField(
                  style: TextStyle(color: AppTheme().cardDarkColor),
                  autofocus: false,
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: Keys.searchUserHint.tr(context),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController.text = '';
                              _searchController.clear();
                              ref.watch(searchFilterProvider.state).state = <String>[];
                            },
                            iconSize: 20,
                            icon: Icon(
                              Icons.close,
                            ),
                          )
                        : IconButton(icon: Container(), onPressed: null),
                    filled: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                  onChanged: (value) {
                    value = value.trim().toLowerCase();
                    ref.watch(searchFilterProvider.state).state = value.isEmpty
                        ? <String>[]
                        : value.split(
                            RegExp(r'\s'),
                          );
                  },
                ),
              ),
            ),
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

/* Widget _buildContents(BuildContext context, WidgetRef ref) {
    final filter = ref
        .watch(searchFilterProvider.state)
        .state;
    final mainUserID = ref.watch(myUIDProvider)!;
    var userListProvider = ref.watch(searchUsersStreamProvider);
    if (haveToWait(userListProvider)) {
      return WaitPage(isCupertino: true);
    }
  }*/
}
