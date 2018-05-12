import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:fluttery/gestures.dart';
import 'package:fluttery/layout.dart';

class PolarPosition extends StatelessWidget {
  final Offset origin;
  final PolarCoord coord;
  final Widget child;

  PolarPosition({
    this.origin = const Offset(0.0, 0.0),
    this.coord,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: add this as a toCartesian() method or something like that
    final radialPosition = new Offset(
      origin.dx + (cos(coord.angle) * coord.radius),
      origin.dy + (sin(coord.angle) * coord.radius),
    );

    return new CenterAbout(
      position: radialPosition,
      child: child,
    );
  }
}
