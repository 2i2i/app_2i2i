import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'custom_profile_image_view.dart';

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
          TextProfileView(text: "Ravi",statusColor: Colors.green,),
          SizedBox(width: 10,)
        ],
        toolbarHeight: kToolbarHeight + 50,
        centerTitle: false,
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SvgPicture.asset(
                'assets/icons/appbar_icon.svg',
                width: 55,
                height: 50,
              ),
              SizedBox(width: 4),
              Text("2i2i",
                  style: Theme.of(context)
                      .textTheme
                      .headline5!
                      .copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
        ));
  }
}
