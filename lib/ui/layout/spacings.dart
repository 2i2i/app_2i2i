/// Namespace for app spacings
abstract class AppSpacings {
  /// Current Scale factor of screen
  static double _scaleFactor = 0.8;

  /// Sets the scale factor used to calculate spacings
  // ignore: avoid_setters_without_getters
  static set scaleFactor(double scaleFactor) {
    // _scaleFactor = 1;
    _scaleFactor = scaleFactor;
  }

  /// Spacing with value of 2 * `scaleFactor`
  static double get s2 => 2 * _scaleFactor;

  /// Spacing with value of 3 * `scaleFactor`
  static double get s3 => 3 * _scaleFactor;

  /// Spacing with value of 4 * `scaleFactor`
  static double get s4 => 4 * _scaleFactor;

  /// Spacing with value of 5 * `scaleFactor`
  static double get s5 => 5 * _scaleFactor;

  /// Spacing with value of 6 * `scaleFactor`
  static double get s6 => 6 * _scaleFactor;

  /// Spacing with value of 8 * `scaleFactor`
  static double get s8 => 8 * _scaleFactor;

  /// Spacing with value of 9 * `scaleFactor`
  static double get s9 => 9 * _scaleFactor;

  /// Spacing with value of 10 * `scaleFactor`
  static double get s10 => 10 * _scaleFactor;

  static double get s11 => 11 * _scaleFactor;

  /// Spacing with value of 12 * `scaleFactor`
  static double get s12 => 12 * _scaleFactor;

  /// Spacing with value of 14 * `scaleFactor`
  static double get s14 => 14 * _scaleFactor;

  /// Spacing with value of 15 * `scaleFactor`
  static double get s15 => 15 * _scaleFactor;

  /// Spacing with value of 16 * `scaleFactor`
  static double get s16 => 16 * _scaleFactor;

  /// Spacing with value of 18 * `scaleFactor`
  static double get s18 => 18 * _scaleFactor;

  /// Spacing with value of 20 * `scaleFactor`
  static double get s20 => 20 * _scaleFactor;

  static double get s22 => 22 * _scaleFactor;

  /// Spacing with value of 24 * `scaleFactor`
  static double get s24 => 24 * _scaleFactor;

  /// Spacing with value of 25 * `scaleFactor`
  static double get s25 => 25 * _scaleFactor;

  /// Spacing with value of 30 * `scaleFactor`
  static double get s30 => 30 * _scaleFactor;

  /// Spacing with value of 32 * `scaleFactor`
  static double get s32 => 32 * _scaleFactor;

  /// Spacing with value of 34 * `scaleFactor`
  static double get s34 => 34 * _scaleFactor;

  /// Spacing with value of 36 * `scaleFactor`
  static double get s36 => 36 * _scaleFactor;

  static double get s35 => 35 * _scaleFactor;

  /// Spacing with value of 40 * `scaleFactor`
  static double get s40 => 40 * _scaleFactor;

  /// Spacing with value of 48 * `scaleFactor`
  static double get s48 => 48 * _scaleFactor;

  static double get s46 => 46 * _scaleFactor;

  /// Spacing with value of 45 * `scaleFactor`
  static double get s45 => 45 * _scaleFactor;

  /// Spacing with value of 48 * `scaleFactor`
  static double get s80 => 80 * _scaleFactor;

  /// Spacing with value of 50 * `scaleFactor`
  static double get s50 => 50 * _scaleFactor;

  /// Spacing with value of 55 * `scaleFactor`
  static double get s55 => 55 * _scaleFactor;

  /// Spacing with value of 56 * `scaleFactor`
  static double get s56 => 56 * _scaleFactor;

  static double get s60 => 60 * _scaleFactor;

  static double get s65 => 65 * _scaleFactor;

  static double get s70 => 70 * _scaleFactor;

  /// Spacing with value of 100 * `scaleFactor`
  static double get s100 => 100 * _scaleFactor;

  /// Spacing with value of 120 * `scaleFactor`
  static double get s120 => 120 * _scaleFactor;

  /// Spacing with value of 130 * `scaleFactor`
  static double get s130 => 130 * _scaleFactor;

  /// Spacing with value of 150 * `scaleFactor`
  static double get s150 => 150 * _scaleFactor;

  static double get s180 => 180 * _scaleFactor;

  /// Spacing with value of 200 * `scaleFactor`
  static double get s200 => 200 * _scaleFactor;

  /// Spacing with value of 250 * `scaleFactor`
  static double get s250 => 250 * _scaleFactor;

  /// Spacing with value of 350 * `scaleFactor`
  static double get s350 => 350 * _scaleFactor;

  /// Spacing with value of 300 * `scaleFactor`
  static double get s300 => 300 * _scaleFactor;

  /// Spacing with value of 400 * `scaleFactor`
  static double get s400 => 400 * _scaleFactor;

  static double get s420 => 420 * _scaleFactor;

  static double get s430 => 430 * _scaleFactor;

  static double get s435 => 435 * _scaleFactor;

  static double get s480 => 480 * _scaleFactor;

  /// Spacing with value of 405 * `scaleFactor`
  static double get s405 => 405 * _scaleFactor;

  /// Spacing that returns the passed value * `scaleFactor`
  static double customValue(num value) => value.toDouble() * _scaleFactor;
}
