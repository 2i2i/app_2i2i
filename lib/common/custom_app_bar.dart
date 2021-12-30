import 'package:app_2i2i/common/alert_widget.dart';
import 'package:app_2i2i/common/custom_navigation.dart';
import 'package:app_2i2i/common/custom_profile_image_view.dart';
import 'package:app_2i2i/common/theme.dart';
import 'package:app_2i2i/pages/setup_account/ui/setup_account.dart';
import 'package:app_2i2i/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
                onTap: () => AlertWidget.showBidAlert(context),
                radius: 46,
                icon: SvgPicture.asset(
                  'assets/icons/star.svg',
                  width: 20,
                  height: 20,
                  color: AppTheme().pink,
                ),
              ),
              SizedBox(
                width: 10,
              ),
              RectangleBox(
                onTap: () => CustomNavigation.push(context, SetupBio(), Routes.SETUP_ACCOUNT),
                radius: 46,
                icon: SvgPicture.asset(
                  'assets/icons/crown_icon.svg',
                  width: 20,
                  height: 20,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ],
          ),
          /*InkWell(
            onTap: () => CustomNavigation.push(context, QRCodePage(), Routes.QRPAGE),
            child: Container(
              padding: EdgeInsets.all(8),
              child: SvgPicture.asset(
                'assets/icons/scan.svg',
                width: 22,
                height: 22,
                color: Color(0xffFC6F88),
              ),
            ),
          ),*/

          SizedBox(
            width: 10,
          )
        ],
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
