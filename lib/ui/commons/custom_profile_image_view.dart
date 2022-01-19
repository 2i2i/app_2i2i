import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfileWidget extends StatelessWidget {
  final String stringPath;
  final double radius;
  final Color? statusColor;
  final VoidCallback? onTap;
  final TextStyle? style;
  final bool hideShadow;
  final bool isRating;
  final bool showBorder;

  const ProfileWidget(
      {Key? key,
      required this.stringPath,
      this.radius = kToolbarHeight,
      this.statusColor,
      this.onTap,
      this.style,
      this.hideShadow = false,
      this.isRating = false,
      this.showBorder = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: radius,
            height: radius,
            decoration: BoxDecoration(
              boxShadow: !hideShadow ||
                      stringPath.contains('http') ||
                      stringPath.contains('https')
                  ? [
                      BoxShadow(
                          offset: Offset(2, 4),
                          blurRadius: 20,
                          color: Theme.of(context).shadowColor,
                      ),
                    ]
                  : null,
            ),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: showBorder?Border.all(
                      width: 0.3,
                      color: Theme.of(context).disabledColor
                    ):null,
                    borderRadius: BorderRadius.circular(20)
                  ),
                  child: Card(
                    elevation: 6,
                    shadowColor: Theme.of(context).inputDecorationTheme.fillColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Center(
                      child: stringPath.contains('http') ||
                              stringPath.contains('https')
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: CachedNetworkImage(
                                imageUrl: stringPath,
                                placeholder: (context, url) =>
                                    CupertinoActivityIndicator(),
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.error),
                              ),
                            )
                          : Text(
                              isRating
                                  ? "${stringPath.toString().isNotEmpty ? stringPath : "0"}"
                                  : "${stringPath.toString().isNotEmpty ? stringPath : "X"}"
                                      .substring(0, 1)
                                      .toUpperCase(),
                              style: style ??
                                  Theme.of(context)
                                      .textTheme
                                      .headline5,
                            ),
                    ),
                  ),
                ),
                if (statusColor != null)
                  Positioned(
                    bottom: 1,
                    right: 1,
                    child: Container(
                      width: 18,
                      height: 18,
                      child: Material(
                        color: statusColor,
                        shape: CircleBorder(
                            side: BorderSide(color: Colors.white, width: 3)),
                        // child: Icon(Icons.check, color: Colors.white,),
                      ),
                    ),
                  )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RectangleBox extends StatelessWidget {
  final Widget icon;
  final double radius;
  final GestureTapCallback? onTap;

  const RectangleBox({Key? key, required this.icon,required this.radius, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      child: Container(
        height: radius,
        width: radius,
        child: Center(child: icon),
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
                offset: Offset(2, 4),
                blurRadius: 18,
                color: Color.fromRGBO(0, 0, 0, 0.12)
            ),
          ],
        ),
      ),
    );
  }
}
