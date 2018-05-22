import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:fluttery/gestures.dart';

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
      intersectionPoint:
          new Point(radius * cos(arc.from.toRadians()), radius * sin(arc.from.toRadians())),
      intersectionAngle: arc.from,
      rotationDirection: arc.direction == RadialDirection.clockwise
          ? RadialDirection.clockwise
          : RadialDirection.counterClockwise,
      radius: radius,
      extraSpace: extraSpace,
      pushOutFromVerticalWall: false,
    ),
    to: _adjustAngleToMakeRoom(
      intersectionPoint:
          new Point(radius * cos(arc.to.toRadians()), radius * sin(arc.to.toRadians())),
      intersectionAngle: arc.to,
      rotationDirection: arc.direction == RadialDirection.clockwise
          ? RadialDirection.counterClockwise
          : RadialDirection.clockwise,
      radius: radius,
      extraSpace: extraSpace,
      pushOutFromVerticalWall: false,
    ),
    direction: arc.direction,
  );
}

Angle _adjustAngleToMakeRoom({
  Point intersectionPoint,
  Angle intersectionAngle,
  RadialDirection rotationDirection,
  double radius,
  double extraSpace,
  bool pushOutFromVerticalWall,
}) {
  print('Adjusting angle $intersectionAngle to make room for $extraSpace pts. '
      'Direction: ${radialDirectionName(rotationDirection)}');
  print('Intersection point: $intersectionPoint');
  final isClockwise = rotationDirection == RadialDirection.clockwise;
  final directionMultiplier = isClockwise ? 1.0 : -1.0;
  final bubbleRadius = extraSpace;
  final theta = new Angle.fromRadians(asin(bubbleRadius / radius) * directionMultiplier);
//  final theta = pushOutFromVerticalWall
//      ? new Angle.fromRadians(asin(bubbleRadius / radius) * directionMultiplier)
//      : new Angle.fromRadians((pi / 2) -
//          acos((intersectionPoint.y - bubbleRadius) / radius) * -1 * directionMultiplier);
//      : (new Angle.fromRadians(acos((intersectionPoint.y - bubbleRadius) / radius)) -
//              new Angle.fromRadians(acos(bubbleRadius / radius))) *
//          directionMultiplier;
//  return intersectionAngle + theta;
//  return theta;
  return intersectionAngle + theta;
}

class Angle {
  static const zero = const Angle.fromRadians(0.0);
  static const halfCircle = const Angle.fromRadians(pi);
  static const fullCircle = const Angle.fromRadians(2 * pi);

  final _radians;

  const Angle.fromRadians(this._radians);

  const Angle.fromDegrees(double degrees) : _radians = 2 * pi * degrees / 360;

  const Angle.fromPercent(double percent)
      : _radians = 2 * pi * percent,
        assert(percent >= 0.0 && percent <= 1.0, 'Percent must be within range [0.0, 1.0]');

  Angle operator +(Angle other) => new Angle.fromRadians(_radians + other._radians);

  Angle operator -(Angle other) => new Angle.fromRadians(_radians - other._radians);

  Angle operator *(double multiplier) => new Angle.fromRadians(_radians * multiplier);

  Angle operator /(double divisor) => new Angle.fromRadians(_radians / divisor);

  bool operator >(Angle other) =>
      toRadians(forcePositive: true) % (2 * pi) > other.toRadians(forcePositive: true) % (2 * pi);

  bool operator >=(Angle other) => this > other || this == other;

  bool operator <(Angle other) =>
      toRadians(forcePositive: true) % (2 * pi) < other.toRadians(forcePositive: true) % (2 * pi);

  bool operator <=(Angle other) => this < other || this == other;

  @override
  bool operator ==(other) =>
      other is Angle &&
      toRadians(forcePositive: true) % (2 * pi) == other.toRadians(forcePositive: true) % (2 * pi);

  @override
  int get hashCode => _radians.hashCode;

  double toRadians({forcePositive = false}) =>
      !forcePositive || _radians >= 0.0 ? _radians : _radians + 2 * pi;

  double toDegrees({forcePositive = false}) =>
      360 * toRadians(forcePositive: forcePositive) / (2 * pi);

  double toPercent() => toRadians(forcePositive: false) / (2 * pi);

  RadialDirection shortestDirectionTo(Angle other) {
    print('Shortest direction from $this to $other');
    final positiveStartAngle = toRadians(forcePositive: true);
    final positiveEndAngle = toRadians(forcePositive: true);

    if (positiveStartAngle > positiveEndAngle) {
      return positiveStartAngle - positiveEndAngle <= pi
          ? RadialDirection.counterClockwise
          : RadialDirection.clockwise;
    } else {
      return positiveEndAngle - positiveStartAngle <= pi
          ? RadialDirection.clockwise
          : RadialDirection.counterClockwise;
    }
  }

  @override
  String toString() => '${toDegrees()}°';
}

class Arc {
  final Angle from;
  final Angle to;
  final RadialDirection direction;

  const Arc.clockwise({
    this.from,
    this.to,
  }) : direction = RadialDirection.clockwise;

  const Arc.counterClockwise({
    this.from,
    this.to,
  }) : direction = RadialDirection.counterClockwise;

  const Arc({
    this.from,
    this.to,
    this.direction,
  });

  bool contains(Angle angle) {
    final double positiveStartAngle = from.toRadians(forcePositive: true);
    final double positiveEndAngle = to.toRadians(forcePositive: true);
    final double positiveAngle = angle.toRadians(forcePositive: true);

    if (direction == RadialDirection.clockwise) {
      if (positiveEndAngle > positiveStartAngle) {
        return positiveStartAngle <= positiveAngle && positiveAngle <= positiveEndAngle;
      } else {
        return !(positiveStartAngle <= positiveAngle && positiveAngle <= positiveEndAngle);
      }
    } else {
      if (positiveEndAngle > positiveStartAngle) {
        return !(positiveStartAngle <= positiveAngle && positiveAngle <= positiveEndAngle);
      } else {
        return positiveStartAngle <= positiveAngle && positiveAngle <= positiveEndAngle;
      }
    }
  }

  Angle sweepAngle() {
    final double positiveStartAngle = from.toRadians(forcePositive: true);
    final double positiveEndAngle = to.toRadians(forcePositive: true);

    if (direction == RadialDirection.clockwise) {
      if (positiveEndAngle > positiveStartAngle) {
        return new Angle.fromRadians(positiveEndAngle - positiveStartAngle);
      } else {
        return new Angle.fromRadians(((2 * pi) - positiveStartAngle) + positiveEndAngle);
      }
    } else {
      if (positiveEndAngle > positiveStartAngle) {
        return new Angle.fromRadians(((2 * pi) - positiveEndAngle) + positiveStartAngle) * -1.0;
      } else {
        return new Angle.fromRadians(positiveStartAngle - positiveEndAngle) * -1.0;
      }
    }
  }

  @override
  String toString() {
    return 'Arc: ${from.toDegrees(forcePositive: true)}, '
        '${to.toDegrees(forcePositive: true)}, '
        '${radialDirectionName(direction)}';
  }
}

enum RadialDirection {
  clockwise,
  counterClockwise,
}

String radialDirectionName(RadialDirection direction) {
  switch (direction) {
    case RadialDirection.clockwise:
      return 'clockwise';
    case RadialDirection.counterClockwise:
      return 'counter-clockwise';
  }
  throw Exception('Invalid RadialDirection: $direction');
}
