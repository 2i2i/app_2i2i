import 'package:app_2i2i/ui/commons/custom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:app_2i2i/ui/commons/custom_profile_image_view.dart';
import '../../infrastructure/routes/app_routes.dart';
import '../screens/hip/hip_page.dart';
import '../screens/rating/rating_page.dart';

class CustomAppbar extends StatelessWidget implements PreferredSizeWidget {
  final List<Widget>? actions;

  CustomAppbar({this.actions});

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + 50);

  @override
  Widget build(BuildContext context) {
    return AppBar(
        elevation: 0,
        actions: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              RectangleBox(
                onTap: () => CustomNavigation.push(context, RatingPage(),Routes.RATING),
                // onTap: () => AlertWidget.showBidAlert(context, CreateBidWidget()),
                radius: 46,
                icon: SvgPicture.asset(
                  'assets/icons/star.svg',
                  width: 20,
                  height: 20,
                ),
              ),
              SizedBox(
                width: 10,
              ),
              RectangleBox(
                onTap: () => CustomNavigation.push(context, HipPage(), Routes.HIPPAGE),
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
          ),],
        toolbarHeight: kToolbarHeight + 50,
        centerTitle: false,
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SvgPicture.asset(
            'assets/icons/appbar_icon.svg',
            fit: BoxFit.fill,
            width: 55,
            height: 65,
          ),
        ));
  }
}
