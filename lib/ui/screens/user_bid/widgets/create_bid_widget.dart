import 'dart:ui' as ui;

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../infrastructure/commons/strings.dart';
import '../../../../infrastructure/commons/theme.dart';
import '../../../../infrastructure/providers/all_providers.dart';
import '../../../commons/custom_text_field.dart';
import '../../my_account/widgets/account_info.dart';

class CreateBidWidget extends ConsumerStatefulWidget {
  final ui.Image image;

  const CreateBidWidget({Key? key, required this.image}) : super(key: key);

  @override
  _CreateBidWidgetState createState() => _CreateBidWidgetState();
}

class _CreateBidWidgetState extends ConsumerState<CreateBidWidget>
    with SingleTickerProviderStateMixin {
  double _value = 0;

  final CarouselController _controller = CarouselController();

  @override
  Widget build(BuildContext context) {
    final myAccountPageViewModel = ref.watch(myAccountPageViewModelProvider);
    return Container(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                      flex: 2,
                      child: Text(Strings().createABid,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headline6!
                              .copyWith(
                              fontWeight: FontWeight.w800,
                              color: Theme.of(context).disabledColor))),
                  IconButton(
                    splashColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close),
                    iconSize: 18,
                  )
                ],
              ),
              Divider(thickness: 1),
              SizedBox(height: 8),
              CustomTextField(
                title: Strings().bidAmount,
                hintText: "0",
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: Text(
                        '${Strings().algoSec}',
                        style: Theme.of(context).textTheme.subtitle2!.copyWith(
                            color: Theme.of(context).shadowColor,
                            fontWeight: FontWeight.normal),
                      ),
                    ),
                    SizedBox(width: 8)
                  ],
                ),
              ),
              SizedBox(height: 10),
              CustomTextField(
                title: Strings().note,
                hintText: Strings().bidNote,
              ),
              SizedBox(height: 10),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.2,
                child: myAccountPageViewModel.isLoading
                    ? Center(child: CupertinoActivityIndicator())
                    : Row(
                  children: [
                    IconButton(
                        iconSize: 20,
                        onPressed: () => _controller.previousPage(),
                        icon: RotatedBox(
                            quarterTurns: 2,
                            child: SvgPicture.asset(
                                'assets/icons/direction.svg'))),
                    Expanded(
                      child: CarouselSlider(
                        items: List.generate(
                            myAccountPageViewModel.accounts!.length,
                                (index) => Column(
                              children: [
                                AccountInfo(
                                  key: ObjectKey(
                                      myAccountPageViewModel
                                          .accounts![index].address),
                                  account: myAccountPageViewModel
                                      .accounts![index],
                                ),
                              ],
                            )),
                        options: CarouselOptions(
                            reverse: false,
                            enableInfiniteScroll: false,
                            enlargeCenterPage: true),
                        carouselController: _controller,
                      ) /*PageView.builder(
                              controller: controller,
                              scrollDirection: Axis.horizontal,
                              itemCount:
                                  myAccountPageViewModel.accounts!.length,
                              itemBuilder: (_, index) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: AccountInfo(
                                    key: ObjectKey(myAccountPageViewModel
                                        .accounts![index].address),
                                    account: myAccountPageViewModel
                                        .accounts![index],
                                  ),
                                );
                              },
                            )*/
                      ,
                    ),
                    IconButton(
                        iconSize: 20,
                        onPressed: () => _controller.nextPage(),
                        icon: SvgPicture.asset(
                            'assets/icons/direction.svg')),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: SliderTheme(
                  data: SliderThemeData(
                      trackHeight: 40,
                      activeTrackColor: AppTheme().thumbColor,
                      thumbColor: Theme.of(context).primaryColor,
                      valueIndicatorColor: AppTheme().thumbColor,
                      activeTickMarkColor: AppTheme().thumbColor,
                      disabledActiveTickMarkColor: AppTheme().thumbColor,
                      disabledActiveTrackColor: AppTheme().thumbColor,
                      disabledInactiveTickMarkColor: AppTheme().thumbColor,
                      disabledInactiveTrackColor: AppTheme().thumbColor,
                      disabledThumbColor: AppTheme().thumbColor,
                      overlayColor: Colors.transparent,
                      inactiveTickMarkColor: AppTheme().thumbColor,
                      inactiveTrackColor: AppTheme().thumbColor,
                      overlappingShapeStrokeColor: AppTheme().thumbColor,
                      trackShape: CustomTrack(mainContext: context, image: widget.image),
                      overlayShape: RoundSliderOverlayShape(overlayRadius: 30),
                      thumbShape: CustomSliderThumbRect(
                          mainContext: context,
                          thumbRadius: 20,
                          thumbHeight: 55,
                          max: 0,
                          min: 10)),
                  child: Container(
                    width: double.infinity,
                    child: Slider(
                      value: _value,
                      onChanged: (val) {
                        _value = val;
                        setState(() {});
                      },
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Cancel'),
                      style: ElevatedButton.styleFrom(
                        primary: Theme.of(context).shadowColor,
                      ),
                    ),
                  ),
                  SizedBox(width: 6),
                  Expanded(
                      child:
                      ElevatedButton(onPressed: () {}, child: Text('Create')))
                ],
              ),
              SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

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
      Rect.fromCenter(
          center: center, width: thumbHeight * 2, height: thumbHeight * 0.9),
      Radius.circular(thumbRadius! * .4),
    );

    final paint = Paint()
      ..color = AppTheme().primaryTextColor
      ..style = PaintingStyle.fill;

    TextSpan span1 = new TextSpan(
        style: Theme.of(mainContext).textTheme.subtitle1!.copyWith(
            color: Theme.of(mainContext).primaryColor,
            fontWeight: FontWeight.w800),
        text: '${getValue(value!)} ');

    TextSpan span2 = new TextSpan(
        style: Theme.of(mainContext)
            .textTheme
            .overline!
            .copyWith(color: Theme.of(mainContext).shadowColor),
        text: '${Strings().algoSec}');

    TextSpan span = new TextSpan(
      children: [span1, span2],
    );

    TextPainter tp = new TextPainter(
        text: span,
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr);
    tp.layout();
    Offset textCenter =
    Offset(center.dx - (tp.width / 2), center.dy - (tp.height / 2));

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

    final ColorTween activeTrackColorTween = ColorTween(
        begin: sliderTheme.disabledActiveTrackColor,
        end: sliderTheme.activeTrackColor);
    final ColorTween inactiveTrackColorTween = ColorTween(
        begin: sliderTheme.disabledInactiveTrackColor,
        end: sliderTheme.inactiveTrackColor);
    final Paint activePaint = Paint()
      ..color = activeTrackColorTween.evaluate(enableAnimation)!;
    final Paint inactivePaint = Paint()
      ..color = inactiveTrackColorTween.evaluate(enableAnimation)!;
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
        text: TextSpan(
            text: "Swipe to bid",
            style: Theme.of(mainContext).textTheme.caption),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr);
    tp.layout();

    final Rect leftTrackSegment = Rect.fromLTRB(
        trackRect.left, trackRect.top, thumbCenter.dx, trackRect.bottom);
    final RRect leftTrack =
    RRect.fromRectAndRadius(leftTrackSegment, Radius.circular(8));
    if (!leftTrackSegment.isEmpty)
      context.canvas.drawRRect(leftTrack, leftTrackPaint);

    final Rect rightTrackSegment = Rect.fromLTRB(
        thumbCenter.dx, trackRect.top, trackRect.right, trackRect.bottom);
    final RRect rightTrack =
    RRect.fromRectAndRadius(rightTrackSegment, Radius.circular(8));
    if (!rightTrackSegment.isEmpty)
      context.canvas.drawRRect(rightTrack, rightTrackPaint);

    tp.paint(
        context.canvas,
        Offset(trackRect.center.dx - (trackRect.bottom),
            trackRect.center.dy - (trackRect.top * 0.5)));

    context.canvas.drawImage(
        image,
        Offset(
          trackRect.center.dx * 1.5,
          trackRect.center.dy - (trackRect.top * 0.5),
        ),
        Paint());
  }
}
