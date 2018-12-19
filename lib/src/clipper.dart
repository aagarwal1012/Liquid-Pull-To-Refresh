import 'dart:math';

import 'package:flutter/material.dart';

class HillClipper extends CustomClipper<Path> {
  final double centreHeight;
  final double curveHeight;

  HillClipper({
    this.centreHeight,
    this.curveHeight,
  });

  @override
  Path getClip(Size size) {
    var path = new Path();
    if (size.height > centreHeight) {
      path.lineTo(0.0, centreHeight);

      path.quadraticBezierTo(size.width / 4, centreHeight + curveHeight,
          size.width / 2, centreHeight + curveHeight);

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
