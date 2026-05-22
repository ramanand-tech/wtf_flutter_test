/// 8pt spacing system (Section 4).
abstract class AppSpacing {
  static const double unit = 8;
  static const double xs = unit;
  static const double sm = unit * 2;
  static const double md = unit * 3;
  static const double lg = unit * 4;
  static const double xl = unit * 5;
}

/// Standard motion durations (150–250ms).
abstract class AppMotion {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 200);
  static const Duration slow = Duration(milliseconds: 250);
}
