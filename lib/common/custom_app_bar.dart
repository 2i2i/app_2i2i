import 'package:app_2i2i/common/custom_navigation.dart';
import 'package:app_2i2i/pages/qr_code/qr_code_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:app_2i2i/pages/setup_account/ui/setup_account.dart';
import 'package:app_2i2i/routes/app_routes.dart';
import 'package:app_2i2i/common/alert_widget.dart';
import 'package:app_2i2i/common/custom_profile_image_view.dart';

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
          InkWell(
            onTap: () => CustomNavigation.push(context, QRCodePage(), Routes.QRPAGE),
            child: Container(
              padding: EdgeInsets.all(8),
              child: SvgPicture.asset(
                'assets/icons/scan.svg',
                width: 22,
                height: 22,
              ),
            ),
          ),
          InkWell(
            onTap: () {
              AlertWidget.showBidAlert(context);
            },
            child: Container(
              padding: EdgeInsets.all(8),
              child: SvgPicture.asset(
                'assets/icons/star.svg',
                width: 22,
                height: 22,
              ),
            ),
          ),
          SizedBox(width: 4),
          TextProfileView(
            text: "Ravi",
            statusColor: Colors.green,
            radius: kToolbarHeight+4,
            onTap: () => CustomNavigation.push(context, SetupBio(), Routes.SETUP_ACCOUNT),
          ),
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
            width: 55,
            height: 50,
            color: Theme.of(context).iconTheme.color,
          ),
        ));
  }
}
