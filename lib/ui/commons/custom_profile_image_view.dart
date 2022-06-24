import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum ImageType {
  ASSENT_IMAGE,
  NETWORK_IMAGE,
  NAME_IMAGE,
}

class ProfileWidget extends StatefulWidget {
  final String stringPath;
  final double radius;
  final Color? statusColor;
  final VoidCallback? onTap;
  final TextStyle? style;
  final bool hideShadow;
  final bool isRating;
  final bool showBorder;
  final bool showEdit;
  final ImageType imageType;

  const ProfileWidget(
      {Key? key,
      required this.stringPath,
      this.radius = kToolbarHeight,
      this.statusColor,
      this.onTap,
      this.imageType = ImageType.NAME_IMAGE,
      this.style,
      this.hideShadow = false,
      this.isRating = false,
      this.showBorder = false,
      this.showEdit = false})
      : super(key: key);

  @override
  State<ProfileWidget> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  ImageType? imageType;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.stringPath.contains('http') || widget.stringPath.contains('https')) {
      imageType = ImageType.NETWORK_IMAGE;
    } else {
      imageType = widget.imageType;
    }
    return InkWell(
      onTap: widget.onTap,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,
      child: Container(
        width: widget.radius,
        height: widget.radius,
        child: Stack(
          children: [
            Card(
              elevation: 6,
              //shadowColor: Theme.of(context).inputDecorationTheme.fillColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Center(
                child: imageView(context),
              ),
            ),
            if (widget.statusColor != null)
              Positioned(
                bottom: 1,
                right: 1,
                child: Container(
                  width: 18,
                  height: 18,
                  child: Material(
                    color: widget.statusColor,
                    shape: CircleBorder(side: BorderSide(color: Colors.white, width: 3)),
                    // child: Icon(Icons.check, color: Colors.white,),
                  ),
                ),
              ),
            if (widget.showEdit)
              Positioned(
                bottom: 1,
                right: 1,
                child: Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0), // half of height and width of Image
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: RotatedBox(quarterTurns: 3, child: Icon(Icons.edit, size: 14)),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }

  Widget imageView(BuildContext context) {
    switch (imageType) {
      case ImageType.ASSENT_IMAGE:
        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.file(File(widget.stringPath), fit: BoxFit.cover, width: widget.radius, height: widget.radius),
        );
      case ImageType.NETWORK_IMAGE:
        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: CachedNetworkImage(
            imageUrl: widget.stringPath,
            width: widget.radius,
            height: widget.radius,
            fit: BoxFit.cover,
            placeholder: (context, url) => CupertinoActivityIndicator(),
            errorWidget: (context, url, error) => Icon(Icons.error),
          ),
        );
      case ImageType.NAME_IMAGE:
      default:
        return Text(
          widget.isRating
              ? "${widget.stringPath.toString().isNotEmpty ? widget.stringPath : "0"}"
              : "${widget.stringPath.toString().isNotEmpty ? widget.stringPath : "X"}".substring(0, 1).toUpperCase(),
          style: widget.style ?? Theme.of(context).textTheme.headline5,
        );
    }
  }
}

class RectangleBox extends StatelessWidget {
  final Widget icon;
  final double radius;
  final double curveRadius;
  final GestureTapCallback? onTap;

  const RectangleBox({Key? key, required this.icon, required this.radius, this.onTap, this.curveRadius = 18}) : super(key: key);

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
          borderRadius: BorderRadius.circular(curveRadius),
          boxShadow: [
            BoxShadow(offset: Offset(2, 4), blurRadius: 18, color: Color.fromRGBO(0, 0, 0, 0.12)),
          ],
        ),
      ),
    );
  }
}
