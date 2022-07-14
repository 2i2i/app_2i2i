// Flutter imports:
// Project imports:
import 'package:app_2i2i/ui/layout/scale_factors.dart';
import 'package:app_2i2i/ui/layout/spacings.dart';
import 'package:flutter/widgets.dart';

import 'breakpoints.dart';
import 'screen_size.dart';

/// Signature for the individual builders (`small`, `medium`, etc.).
typedef ResponsiveLayoutWidgetBuilder = Widget Function(BuildContext, Widget?);

/// {@template responsive_layout_builder}
/// A wrapper around [LayoutBuilder] which exposes builders for
/// various responsive breakpoints.
/// {@endtemplate}
class ResponsiveLayoutBuilder extends StatelessWidget {
  /// {@macro responsive_layout_builder}
  const ResponsiveLayoutBuilder({
    Key? key,
    required this.small,
    required this.medium,
    required this.large,
    required this.xLarge,
    this.child,
  }) : super(key: key);

  /// [ResponsiveLayoutWidgetBuilder] for small layout.
  final ResponsiveLayoutWidgetBuilder small;

  /// [ResponsiveLayoutWidgetBuilder] for medium layout.
  final ResponsiveLayoutWidgetBuilder medium;

  /// [ResponsiveLayoutWidgetBuilder] for large layout.
  final ResponsiveLayoutWidgetBuilder large;

  /// [ResponsiveLayoutWidgetBuilder] for xLarge layout.
  final ResponsiveLayoutWidgetBuilder xLarge;

  /// Optional child widget which will be passed to
  /// builders as a way to share/optimize shared layout.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < DeviceBreakpoints.small) {
          DeviceScreenSize.screenSize = ScreenSize.small;
          AppSpacings.scaleFactor = DeviceScaleFactors.smallScaleFactor;
          return small(context, child);
        } else if (constraints.maxWidth < DeviceBreakpoints.medium) {
          DeviceScreenSize.screenSize = ScreenSize.medium;
          AppSpacings.scaleFactor = DeviceScaleFactors.mediumScaleFactor;
          return medium(context, child);
        } else if (constraints.maxWidth < DeviceBreakpoints.large) {
          DeviceScreenSize.screenSize = ScreenSize.large;
          AppSpacings.scaleFactor = DeviceScaleFactors.largeScaleFactor;
          return large(context, child);
        } else {
          DeviceScreenSize.screenSize = ScreenSize.xLarge;
          AppSpacings.scaleFactor = DeviceScaleFactors.xLargeScaleFactor;
          return xLarge(context, child);
        }
      },
    );
  }
}
