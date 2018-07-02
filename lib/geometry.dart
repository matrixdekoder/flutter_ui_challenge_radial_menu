import 'dart:math';

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
