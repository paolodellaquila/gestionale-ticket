import 'package:flutter/material.dart';

class Breakpoints {
  static const mobile = 768.0;
  static const tablet = 1024.0;
}

extension ResponsiveContext on BuildContext {
  bool get isMobile => MediaQuery.sizeOf(this).width < Breakpoints.mobile;
  bool get isDesktop => MediaQuery.sizeOf(this).width >= Breakpoints.mobile;
}
