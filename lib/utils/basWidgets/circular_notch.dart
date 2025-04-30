import 'package:flutter/material.dart';

class CircularNotch extends NotchedShape {
  final double notchMargin;
  final double centerOffset;

  const CircularNotch({
    required this.notchMargin,
    required this.centerOffset,
  });

  @override
  Path getOuterPath(Rect host, Rect? guest) {
    if (guest == null) {
      return Path()..addRect(host);
    }

    const double s1 = 8;
    const double s2 = 10;

    final double r = guest.width / 2 + notchMargin;
    final double centerX = guest.center.dx + centerOffset;

    final double startPointX = centerX - r - s2;
    final double endPointX = centerX + r + s2;

    final Path path = Path()
      ..moveTo(host.left, host.top)
      ..lineTo(startPointX, host.top)
      ..quadraticBezierTo(
        startPointX + s1,
        host.top,
        startPointX + s1,
        host.top + s1,
      )
      ..arcToPoint(
        Offset(endPointX - s1, host.top + s1),
        radius: Radius.circular(r),
        clockwise: false,
      )
      ..quadraticBezierTo(
        endPointX,
        host.top,
        endPointX + s1,
        host.top,
      )
      ..lineTo(host.right, host.top)
      ..lineTo(host.right, host.bottom)
      ..lineTo(host.left, host.bottom)
      ..close();

    return path;
  }
}