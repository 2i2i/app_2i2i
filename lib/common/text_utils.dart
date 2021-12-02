import 'package:flutter/material.dart';

class CaptionText extends StatelessWidget {
  final String? title;
  final int? maxLine;
  final Color? textColor;
  final TextAlign? textAlign;
  final FontWeight? fontWeight;

  const CaptionText(
      {Key? key,
      this.title,
      this.maxLine,
      this.textColor,
      this.textAlign,
      this.fontWeight})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(title!,
        textAlign: textAlign,
        style: Theme.of(context)
            .textTheme
            .overline!
            .copyWith(color: textColor, fontWeight: fontWeight),
        maxLines: maxLine);
  }
}

class BodyOneText extends StatelessWidget {
  final String? title;
  final int? maxLine;
  final Color? textColor;
  final TextAlign? textAlign;
  final FontWeight? fontWeight;

  const BodyOneText(
      {Key? key,
      this.title,
      this.maxLine,
      this.textColor,
      this.textAlign,
      this.fontWeight})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(title!,
        textAlign: textAlign,
        style: Theme.of(context)
            .textTheme
            .bodyText1!
            .copyWith(color: textColor, fontWeight: fontWeight),
        maxLines: maxLine);
  }
}

class BodyTwoText extends StatelessWidget {
  final String? title;
  final int? maxLine;
  final Color? textColor;
  final TextAlign? textAlign;
  final FontWeight? fontWeight;

  const BodyTwoText(
      {Key? key,
      this.title,
      this.maxLine,
      this.textColor,
      this.textAlign,
      this.fontWeight})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(title!,
        textAlign: textAlign,
        style: Theme.of(context)
            .textTheme
            .bodyText2!
            .copyWith(color: textColor, fontWeight: fontWeight),
        maxLines: maxLine);
  }
}

class SubtitleText extends StatelessWidget {
  final String? title;
  final int? maxLine;
  final Color? textColor;
  final TextAlign? textAlign;
  final FontWeight? fontWeight;

  const SubtitleText(
      {Key? key,
      this.title,
      this.maxLine,
      this.textColor,
      this.textAlign,
      this.fontWeight})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(title!,
        textAlign: textAlign,
        style: Theme.of(context)
            .textTheme
            .subtitle2!
            .copyWith(color: textColor, fontWeight: fontWeight),
        maxLines: maxLine);
  }
}

class TitleText extends StatelessWidget {
  final String? title;
  final int? maxLine;
  final Color? textColor;
  final TextAlign? textAlign;
  final FontWeight? fontWeight;

  const TitleText(
      {Key? key,
      this.title,
      this.maxLine,
      this.textColor,
      this.textAlign,
      this.fontWeight})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(title!,
        textAlign: textAlign,
        style: Theme.of(context)
            .textTheme
            .subtitle1!
            .copyWith(color: textColor, fontWeight: fontWeight),
        maxLines: maxLine);
  }
}

class ButtonText extends StatelessWidget {
  final String? title;
  final int? maxLine;
  final Color? textColor;
  final TextAlign? textAlign;
  final FontWeight? fontWeight;

  const ButtonText(
      {Key? key,
      this.title,
      this.maxLine,
      this.textColor,
      this.textAlign,
      this.fontWeight})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(title!.toUpperCase(),
        textAlign: textAlign,
        style: Theme.of(context)
            .textTheme
            .caption!
            .copyWith(color: textColor, fontWeight: fontWeight),
        maxLines: maxLine);
  }
}

class HeadLineSixText extends StatelessWidget {
  final String? title;
  final int? maxLine;
  final Color? textColor;
  final TextAlign? textAlign;
  final FontWeight? fontWeight;

  const HeadLineSixText(
      {Key? key,
      this.title,
      this.maxLine,
      this.textColor,
      this.textAlign,
      this.fontWeight})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(title!,
        textAlign: textAlign,
        style: Theme.of(context)
            .textTheme
            .headline6!
            .copyWith(color: textColor, fontWeight: fontWeight),
        maxLines: maxLine);
  }
}
