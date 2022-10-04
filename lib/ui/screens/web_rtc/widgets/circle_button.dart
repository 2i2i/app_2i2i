import 'package:flutter/material.dart';

class CircleButton extends StatelessWidget {
  final IconData icon;
  final GestureTapCallback? onTap;
  final Color? backgroundColor;
  final Color? iconColor;

  const CircleButton({Key? key, required this.icon, this.onTap, this.backgroundColor, this.iconColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: CircleAvatar(
          radius: 22,
          child: Icon(
            icon,
            color: iconColor ?? Colors.black,
            size: 20,
          ),
          backgroundColor: backgroundColor ?? Colors.white,
        ),
      ),
    );
  }
}
