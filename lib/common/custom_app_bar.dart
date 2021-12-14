// import 'package:app_2i2i/common/theme.dart';
// import 'package:flutter/material.dart';
//
// class CustomAppbar extends StatelessWidget implements PreferredSizeWidget {
//   final Widget? leading;
//   final String? title;
//   final bool hideLeading;
//
//   final List<Widget>? actions;
//
//   CustomAppbar(
//       {this.leading, this.title, this.actions, this.hideLeading = false});
//
//   @override
//   Size get preferredSize => Size.fromHeight(kToolbarHeight);
//
//   @override
//   Widget build(BuildContext context) {
//     return AppBar(
//       backgroundColor: AppTheme().lightGray,
//       automaticallyImplyLeading: hideLeading,
//       leading: hideLeading
//           ? null
//           : leading != null
//               ? leading
//               : BackButton(),
//       centerTitle: true,
//       actions: actions,
//       title: title != null
//           ? Text(title ?? "",style: Theme.of(context).textTheme.headline2)
//           : Image.asset('assets/logo.png', height: 30, fit: BoxFit.contain),
//     );
//   }
// }
