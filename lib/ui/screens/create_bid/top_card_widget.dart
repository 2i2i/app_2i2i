import 'package:flutter/material.dart';

import '../../../infrastructure/commons/keys.dart';
import '../../../infrastructure/models/user_model.dart';
import '../../commons/custom.dart';
import '../user_info/widgets/user_info_widget.dart';

class TopCard extends StatelessWidget {
  final String minWait;
  final UserModel B;

  const TopCard({Key? key, required this.minWait, required this.B})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: Custom.getBoxDecoration(context),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            Keys.createABid.tr(context),
            style: Theme.of(context).textTheme.headline5,
          ),
          SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.timer,
                size: 17,
                color: Theme.of(context).errorColor,
              ),
              SizedBox(width: 2),
              Text(
                'Est. Wait Time is $minWait',
                style: Theme.of(context)
                    .textTheme
                    .caption
                    ?.copyWith(color: Theme.of(context).errorColor),
              ),
            ],
          ),
          SizedBox(height: 15),
          UserRulesWidget(
            user: B,
            onTapRules: null,
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}

class CustomSliderThumbRect extends SliderComponentShape {
  final double? thumbRadius;
  final BuildContext mainContext;
  final int? min;
  final int? max;

  const CustomSliderThumbRect({
    required this.mainContext,
    this.thumbRadius,
    this.min,
    this.max,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(thumbRadius!);
  }

  @override
  void paint(
      PaintingContext context,
      Offset center, {
        Animation<double>? activationAnimation,
        Animation<double>? enableAnimation,
        bool? isDiscrete,
        TextPainter? labelPainter,
        RenderBox? parentBox,
        SliderThemeData? sliderTheme,
        TextDirection? textDirection,
        double? value,
        double? textScaleFactor,
        Size? sizeWithOverflow,
      }) {
    final Canvas canvas = context.canvas;

    final rRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
          center: center, width: kToolbarHeight, height: kToolbarHeight * 0.6),
      Radius.circular(thumbRadius!),
    );

    final paint = Paint()
      ..color = Theme.of(mainContext).cardColor
      ..style = PaintingStyle.fill;

    TextSpan span = new TextSpan(
        style: Theme.of(mainContext).textTheme.subtitle1,
        text: '${getValue(value!)}s');

    TextPainter tp = new TextPainter(
        text: span,
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr);
    tp.layout();
    Offset textCenter =
    Offset(center.dx - (tp.width / 2), center.dy - (tp.height / 2));
    canvas.drawRRect(rRect, paint);
    tp.paint(canvas, textCenter);
  }

  String getValue(double value) {
    return (min! + (max! - min!) * value).round().toString();
  }
}