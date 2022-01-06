import 'package:flutter/material.dart';

class CustomImageProfileView extends StatelessWidget {
  final String text;
  final double radius;

  const CustomImageProfileView({Key? key, required this.text, this.radius = 40})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: radius,
      width: radius,
      child: Center(
          child: Text(
        "${text.toString().isNotEmpty ? text : "X"}"
            .substring(0, 1)
            .toUpperCase(),
        style: Theme.of(context).textTheme.headline4,
      )),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Color.fromRGBO(214, 219, 134, 1),
      ),
    );
  }
}

class TextProfileView extends StatelessWidget {
  final String text;
  final double radius;
  final Color? statusColor;
  final VoidCallback? onTap;
  final TextStyle? style;
  final bool hideShadow;
  final bool isRating;
  final bool hideStatus;

  const TextProfileView(
      {Key? key,
      required this.text,
      this.radius = kToolbarHeight,
      this.statusColor,
      this.onTap,
      this.style,
      this.hideShadow = false,
      this.isRating = false,
      this.hideStatus = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: InkWell(
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
              decoration: !hideShadow
                  ? BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                            offset: Offset(2, 4),
                            blurRadius: 14,
                            color: Color.fromRGBO(
                                0, 0, 0, 0.12)
                        ),
                      ],
                    )
                  : null,
              child: Stack(
                children: [
                  Card(
                    elevation: 6,
                    shadowColor:
                        Theme.of(context).inputDecorationTheme.fillColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.0),
                    ),
                    child: Center(
                      child: Text(
                        isRating
                            ? "${text.toString().isNotEmpty ? text : "0"}"
                            : "${text.toString().isNotEmpty ? text : "X"}"
                                .substring(0, 1)
                                .toUpperCase(),
                        style: style ??
                            Theme.of(context)
                                .textTheme
                                .headline6!
                                .copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  if (!hideStatus)
                    Positioned(
                      bottom: 1,
                      right: 1,
                      child: Container(
                        width: 15,
                        height: 15,
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
          color: Theme.of(context).primaryColorLight,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
                offset: Offset(2, 4),
                blurRadius: 10,
                color: Color.fromRGBO(0, 0, 0, 0.12)
            ),
          ],
        ),
      ),
    );
  }
}
