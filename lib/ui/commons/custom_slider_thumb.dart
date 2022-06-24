import 'package:app_2i2i/infrastructure/commons/keys.dart';
import 'package:app_2i2i/infrastructure/commons/theme.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class CustomSliderThumbRect extends SliderComponentShape {
  final double? thumbRadius;
  final BuildContext mainContext;
  final thumbHeight;
  final int? min;
  final int? max;

  const CustomSliderThumbRect({
    required this.mainContext,
    this.thumbRadius,
    this.thumbHeight,
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
      Rect.fromCenter(center: center, width: thumbHeight * 2, height: thumbHeight * 0.9),
      Radius.circular(thumbRadius! * .4),
    );

    final paint = Paint()
      ..color = AppTheme().primaryTextColor
      ..style = PaintingStyle.fill;

    TextSpan span1 = new TextSpan(
        style: Theme.of(mainContext).textTheme.subtitle1!.copyWith(color: Theme.of(mainContext).primaryColor, fontWeight: FontWeight.w800),
        text: '${getValue(value!)} ');

    TextSpan span2 = new TextSpan(
        style: Theme.of(mainContext).textTheme.overline!.copyWith(color: Theme.of(mainContext).shadowColor), text: '${Keys.algoSec.tr(mainContext)}');

    TextSpan span = new TextSpan(
      children: [span1, span2],
    );

    TextPainter tp = new TextPainter(text: span, textAlign: TextAlign.left, textDirection: TextDirection.ltr);
    tp.layout();
    Offset textCenter = Offset(center.dx - (tp.width / 2), center.dy - (tp.height / 2));

    final Path shadowPath = Path()..addRRect(rRect);
    canvas.drawRRect(rRect, paint);
    canvas.drawShadow(shadowPath, Colors.grey.withAlpha(50), 4.0, false);
    tp.paint(canvas, textCenter);
  }

  String getValue(double value) {
    return (min! + (max! - min!) * value).round().toString();
  }
}

class CustomTrack extends SliderTrackShape with BaseSliderTrackShape {
  final double? thumbRadius;
  final BuildContext mainContext;
  final ui.Image image;
  final thumbHeight;
  final int? min;
  final int? max;

  const CustomTrack({
    required this.mainContext,
    this.thumbRadius,
    required this.image,
    this.thumbHeight,
    this.min,
    this.max,
  });

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    bool isDiscrete = false,
    bool isEnabled = false,
  }) {
    assert(sliderTheme.disabledActiveTrackColor != null);
    assert(sliderTheme.disabledInactiveTrackColor != null);
    assert(sliderTheme.activeTrackColor != null);
    assert(sliderTheme.inactiveTrackColor != null);
    assert(sliderTheme.thumbShape != null);
    if (sliderTheme.trackHeight! <= 0) {
      return;
    }

    final ColorTween activeTrackColorTween = ColorTween(begin: sliderTheme.disabledActiveTrackColor, end: sliderTheme.activeTrackColor);
    final ColorTween inactiveTrackColorTween = ColorTween(begin: sliderTheme.disabledInactiveTrackColor, end: sliderTheme.inactiveTrackColor);
    final Paint activePaint = Paint()..color = activeTrackColorTween.evaluate(enableAnimation)!;
    final Paint inactivePaint = Paint()..color = inactiveTrackColorTween.evaluate(enableAnimation)!;
    final Paint leftTrackPaint;
    final Paint rightTrackPaint;
    switch (textDirection) {
      case TextDirection.ltr:
        leftTrackPaint = activePaint;
        rightTrackPaint = inactivePaint;
        break;
      case TextDirection.rtl:
        leftTrackPaint = inactivePaint;
        rightTrackPaint = activePaint;
        break;
    }

    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    TextPainter tp = new TextPainter(
        text: TextSpan(text: "Swipe to bid", style: Theme.of(mainContext).textTheme.caption), textAlign: TextAlign.center, textDirection: TextDirection.ltr);
    tp.layout();

    final Rect leftTrackSegment = Rect.fromLTRB(trackRect.left, trackRect.top, thumbCenter.dx, trackRect.bottom);
    final RRect leftTrack = RRect.fromRectAndRadius(leftTrackSegment, Radius.circular(8));
    if (!leftTrackSegment.isEmpty) context.canvas.drawRRect(leftTrack, leftTrackPaint);

    final Rect rightTrackSegment = Rect.fromLTRB(thumbCenter.dx, trackRect.top, trackRect.right, trackRect.bottom);
    final RRect rightTrack = RRect.fromRectAndRadius(rightTrackSegment, Radius.circular(8));
    if (!rightTrackSegment.isEmpty) context.canvas.drawRRect(rightTrack, rightTrackPaint);

    tp.paint(context.canvas, Offset(trackRect.center.dx - (trackRect.bottom), trackRect.center.dy - (trackRect.top * 0.5)));

    context.canvas.drawImage(
        image,
        Offset(
          trackRect.center.dx * 1.5,
          trackRect.center.dy - (trackRect.top * 0.5),
        ),
        Paint());
  }
}
