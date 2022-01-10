import 'package:flutter/material.dart';

/// Clipper for [LiquidPullToRefresh]
class CurveHillClipper extends CustomClipper<Path> {
  final double centreHeight;
  double curveHeight;
  final double peakHeight;
  final double peakWidth;

  CurveHillClipper({
    required this.centreHeight,
    required this.curveHeight,
    required this.peakHeight,
    required this.peakWidth,
  });

  @override
  Path getClip(Size size) {
    var path = new Path();
    if (size.height >= centreHeight) {
      if (curveHeight > (size.height - centreHeight)) {
        curveHeight = size.height - centreHeight;
      }

      path.lineTo(0.0, centreHeight);

      path.quadraticBezierTo(size.width / 4, centreHeight + curveHeight,
          (size.width / 2) - (peakWidth / 2), centreHeight + curveHeight);

      path.quadraticBezierTo(
          (size.width / 2) - (peakWidth / 4),
          centreHeight + curveHeight - peakHeight,
          (size.width / 2),
          centreHeight + curveHeight - peakHeight);

      path.quadraticBezierTo(
          (size.width / 2) + (peakWidth / 4),
          centreHeight + curveHeight - peakHeight,
          (size.width / 2) + (peakWidth / 2),
          centreHeight + curveHeight);

      path.quadraticBezierTo(size.width * 3 / 4, centreHeight + curveHeight,
          size.width, centreHeight);

      path.lineTo(size.width, 0.0);

      path.lineTo(0.0, 0.0);
    } else {
      path.lineTo(0.0, size.height);
      path.lineTo(size.width, size.height);
      path.lineTo(size.width, 0.0);
      path.lineTo(0.0, 0.0);
    }

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
