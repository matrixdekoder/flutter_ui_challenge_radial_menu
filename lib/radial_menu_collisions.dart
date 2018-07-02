import 'dart:math';
import 'dart:ui';

import 'package:radial_menu/geometry.dart';

Set<Point> intersect(Size size, Point origin, double menuRadius) {
  print('Screen size: $size');

  print('Intersections for point: $origin');

  final radius = menuRadius;
  final topPoints = _topIntersections(size, origin, radius);
  final bottomPoints = _bottomIntersections(size, origin, radius);
  final leftPoints = _leftIntersections(size, origin, radius);
  final rightPoints = _rightIntersections(size, origin, radius);

  return topPoints..addAll(bottomPoints)..addAll(leftPoints)..addAll(rightPoints);
}

Set<Point> _topIntersections(Size screenSize, Point origin, double menuRadius) {
  final intersections = _findIntersections(
    new Point(0.0, 0.0) - origin,
    new Point(screenSize.width, 0.0) - origin,
    menuRadius,
  );

  print('Top intersections:');
  final topPoints = intersections.map((Point point) {
    Point specificPoint = point + origin;
    print(' - $specificPoint');
    return specificPoint;
  }).toSet();

  topPoints.removeWhere((Point point) {
    return point.x < 0.0 || point.x > screenSize.width;
  });
  print('Found ${topPoints.length} top intersections.');

  return topPoints;
}

Set<Point> _bottomIntersections(Size screenSize, Point origin, double menuRadius) {
  final intersections = _findIntersections(
    new Point(0.0, screenSize.height) - origin,
    new Point(screenSize.width, screenSize.height) - origin,
    menuRadius,
  );

  print('Bottom intersections:');
  final bottomPoints = intersections.map((Point point) {
    Point specificPoint = point + origin;
    print(' - $specificPoint');
    return specificPoint;
  }).toSet();

  bottomPoints.removeWhere((Point point) {
    return point.x < 0.0 || point.x > screenSize.width;
  });
  print('Found ${bottomPoints.length} bottom intersections.');

  return bottomPoints;
}

Set<Point> _leftIntersections(Size screenSize, Point origin, double menuRadius) {
  final intersections = _findIntersections(
    new Point(0.0, 0.0) - origin,
    new Point(0.0, screenSize.height) - origin,
    menuRadius,
  );

  print('Left intersections:');
  final leftPoints = intersections.map((Point point) {
    Point specificPoint = point + origin;
    print(' - $specificPoint');
    return specificPoint;
  }).toSet();

  leftPoints.removeWhere((Point point) {
    return point.y < 0.0 || point.y > screenSize.height;
  });
  print('Found ${leftPoints.length} left intersections.');

  return leftPoints;
}

Set<Point> _rightIntersections(Size screenSize, Point origin, double menuRadius) {
  final intersections = _findIntersections(
    new Point(screenSize.width, 0.0) - origin,
    new Point(screenSize.width, screenSize.height) - origin,
    menuRadius,
  );

  print('Right intersections:');
  final rightPoints = intersections.map((Point point) {
    Point specificPoint = point + origin;
    print(' - $specificPoint');
    return specificPoint;
  }).toSet();

  rightPoints.removeWhere((Point point) {
    return point.y < 0.0 || point.y > screenSize.height;
  });
  print('Found ${rightPoints.length} right intersections.');

  return rightPoints;
}

// Calculate intersections
// http://mathworld.wolfram.com/Circle-LineIntersection.html
//
// As stated on the website, this finds intersections assuming a circle
// origin of (0.0, 0.0) therefore input points [p1] and [p2] should be
// offset by the actual circle origin before calling this method.
Set<Point> _findIntersections(Point p1, Point p2, double radius) {
  final double dx = p2.x - p1.x;
  final double dy = p2.y - p1.y;
  final double dSgn = dy >= 0 ? 1.0 : -1.0;
  final double dr = sqrt(pow(dx, 2) + pow(dy, 2));
  final double D = (p1.x * p2.y) - (p2.x * p1.y);

  final discriminant = (pow(radius, 2) * pow(dr, 2)) - pow(D, 2);
  if (discriminant <= 0) {
    // No intersection.
    return new Set<Point<double>>();
  }

  final xIntersect1 =
      ((D * dy) + (dSgn * dx * sqrt((pow(radius, 2) * pow(dr, 2)) - pow(D, 2)))) / pow(dr, 2);
  final yIntersect1 =
      (-(D * dx) + (dy.abs() * sqrt((pow(radius, 2) * pow(dr, 2)) - pow(D, 2)))) / pow(dr, 2);

  final xIntersect2 =
      ((D * dy) - (dSgn * dx * sqrt((pow(radius, 2) * pow(dr, 2)) - pow(D, 2)))) / pow(dr, 2);
  final yIntersect2 =
      (-(D * dx) - (dy.abs() * sqrt((pow(radius, 2) * pow(dr, 2)) - pow(D, 2)))) / pow(dr, 2);

  return [
    new Point(xIntersect1, yIntersect1),
    new Point(xIntersect2, yIntersect2),
  ].toSet();
}

Arc rotatePointsToMakeRoom({
  Arc arc,
  Point origin,
  Point direction,
  double radius,
  double extraSpace,
}) {
  return new Arc(
    from: _adjustAngleToMakeRoom(
      intersectionAngle: arc.from,
      rotationDirection: arc.direction == RadialDirection.clockwise
          ? RadialDirection.clockwise
          : RadialDirection.counterClockwise,
      radius: radius,
      extraSpace: extraSpace,
    ),
    to: _adjustAngleToMakeRoom(
      intersectionAngle: arc.to,
      rotationDirection: arc.direction == RadialDirection.clockwise
          ? RadialDirection.counterClockwise
          : RadialDirection.clockwise,
      radius: radius,
      extraSpace: extraSpace,
    ),
    direction: arc.direction,
  );
}

Angle _adjustAngleToMakeRoom({
  Angle intersectionAngle,
  RadialDirection rotationDirection,
  double radius,
  double extraSpace,
}) {
  print('Adjusting angle $intersectionAngle to make room for $extraSpace pts. '
      'Direction: ${radialDirectionName(rotationDirection)}');
  final isClockwise = rotationDirection == RadialDirection.clockwise;
  final directionMultiplier = isClockwise ? 1.0 : -1.0;
  final bubbleRadius = extraSpace;
  final theta = new Angle.fromRadians(asin(bubbleRadius / radius) * directionMultiplier);
  return intersectionAngle + theta;
}
