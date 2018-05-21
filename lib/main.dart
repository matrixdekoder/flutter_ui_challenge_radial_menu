import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:fluttery/layout.dart';
import 'package:fluttery/gestures.dart';
import 'package:meta/meta.dart';
import 'package:radial_menu/layout.dart';
import 'package:radial_menu/menu.dart';

void main() {
  timeDilation = 10.0;
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Radial Menu',
      theme: new ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final topLeft = "TOP_LEFT";
  final topRight = "TOP_RIGHT";
  final middleLeft = "MIDDLE_LEFT";
  final middleRight = "MIDDLE_RIGHT";
  final bottomLeft = "BOTTOM_LEFT";
  final bottomRight = "BOTTOM_RIGHT";
  final center = "CENTER";

  bool isShowingMenu = false;

  void showMenu(String location) {
    if (!isShowingMenu) {
      // TODO: show menu for location
      print('Opening menu for $location');
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          leading: new AnchoredRadialMenu(
            startAngle: 0.0,
            endAngle: pi / 2,
            child: new IconButton(
                icon: new Icon(
                  Icons.cancel,
                ),
                onPressed: () {
                  showMenu(topLeft);
                }),
          ),
          title: new Text(''),
          actions: <Widget>[
            new AnchoredRadialMenu(
              startAngle: pi,
              endAngle: pi / 2,
              child: new IconButton(
                  icon: new Icon(
                    Icons.cancel,
                  ),
                  onPressed: () {
                    showMenu(topRight);
                  }),
            ),
          ],
        ),
        body: new Stack(
          children: <Widget>[
            // Left center
            new Align(
              alignment: Alignment.centerLeft,
              child: new AnchoredRadialMenu(
                startAngle: -pi / 2,
                endAngle: pi / 2,
                child: new IconButton(
                    icon: new Icon(
                      Icons.cancel,
                    ),
                    onPressed: () {
                      showMenu(middleLeft);
                    }),
              ),
            ),

            // Left bottom
            new Align(
              alignment: Alignment.bottomLeft,
              child: new AnchoredRadialMenu(
                startAngle: -pi / 2,
                endAngle: 0.0,
                child: new IconButton(
                    icon: new Icon(
                      Icons.cancel,
                    ),
                    onPressed: () {
                      showMenu(bottomLeft);
                    }),
              ),
            ),

            // Right center
            new Align(
              alignment: Alignment.centerRight,
              child: new AnchoredRadialMenu(
                startAngle: 3 * pi / 2,
                endAngle: pi / 2,
                child: new IconButton(
                    icon: new Icon(
                      Icons.cancel,
                    ),
                    onPressed: () {
                      showMenu(middleRight);
                    }),
              ),
            ),

            // Right bottom
            new Align(
              alignment: Alignment.bottomRight,
              child: new AnchoredRadialMenu(
                startAngle: 3 * pi / 2,
                endAngle: pi,
                child: new IconButton(
                    icon: new Icon(
                      Icons.cancel,
                    ),
                    onPressed: () {
                      showMenu(bottomRight);
                    }),
              ),
            ),

            // True center
            new Align(
              alignment: Alignment.center,
              child: new AnchoredRadialMenu(
                child: new IconButton(
                    icon: new Icon(
                      Icons.cancel,
                    ),
                    onPressed: () {
                      showMenu(center);
                    }),
              ),
            ),
          ],
        ));
  }
}

class ScreenIntersector {
  // Calculate intersections
  // http://mathworld.wolfram.com/Circle-LineIntersection.html
  Set<Point> intersect(BoxConstraints constraints, Point origin, double menuRadius) {
    print('Screen size: $constraints');

    print('Intersections for point: $origin');

    final radius = menuRadius;
    final topPoints = topIntersections(constraints, origin, radius);
    final bottomPoints = bottomIntersections(constraints, origin, radius);
    final leftPoints = leftIntersections(constraints, origin, radius);
    final rightPoints = rightIntersections(constraints, origin, radius);

    return topPoints..addAll(bottomPoints)..addAll(leftPoints)..addAll(rightPoints);
  }

  Set<Point> topIntersections(BoxConstraints constraints, Point origin, double menuRadius) {
    final intersections = findIntersections(
      new Point(0.0, 0.0) - origin,
      new Point(constraints.maxWidth, 0.0) - origin,
      origin,
      menuRadius,
    );

    print('Top intersections:');
    final topPoints = intersections.map((Point point) {
      Point specificPoint = point + origin;
      print(' - $specificPoint');
      return specificPoint;
    }).toSet();

    topPoints.removeWhere((Point point) {
      return point.x < 0.0 || point.x > constraints.maxWidth;
    });

    return topPoints;
  }

  Set<Point> bottomIntersections(BoxConstraints constraints, Point origin, double menuRadius) {
    final intersections = findIntersections(
      new Point(0.0, constraints.maxHeight) - origin,
      new Point(constraints.maxWidth, constraints.maxHeight) - origin,
      origin,
      menuRadius,
    );

    print('Bottom intersections:');
    final bottomPoints = intersections.map((Point point) {
      Point specificPoint = point + origin;
      print(' - $specificPoint');
      return specificPoint;
    }).toSet();

    bottomPoints.removeWhere((Point point) {
      return point.x < 0.0 || point.x > constraints.maxWidth;
    });

    return bottomPoints;
  }

  Set<Point> leftIntersections(BoxConstraints constraints, Point origin, double menuRadius) {
    final intersections = findIntersections(
      new Point(0.0, 0.0) - origin,
      new Point(0.0, constraints.maxHeight) - origin,
      origin,
      menuRadius,
    );

    print('Left intersections:');
    final leftPoints = intersections.map((Point point) {
      Point specificPoint = point + origin;
      print(' - $specificPoint');
      return specificPoint;
    }).toSet();

    leftPoints.removeWhere((Point point) {
      return point.y < 0.0 || point.y > constraints.maxHeight;
    });

    return leftPoints;
  }

  Set<Point> rightIntersections(BoxConstraints constraints, Point origin, double menuRadius) {
    final intersections = findIntersections(
      new Point(constraints.maxWidth, 0.0) - origin,
      new Point(constraints.maxWidth, constraints.maxHeight) - origin,
      origin,
      menuRadius,
    );

    print('Right intersections:');
    final rightPoints = intersections.map((Point point) {
      Point specificPoint = point + origin;
      print(' - $specificPoint');
      return specificPoint;
    }).toSet();

    rightPoints.removeWhere((Point point) {
      return point.y < 0.0 || point.y > constraints.maxHeight;
    });

    return rightPoints;
  }

  Set<Point> findIntersections(Point p1, Point p2, Point center, double radius) {
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

  @override
  String toString() => '${toDegrees()}°';
}

class AnchoredRadialMenu extends StatefulWidget {
  final double startAngle;
  final double endAngle;
  final Widget child;

  AnchoredRadialMenu({
    this.startAngle = -pi / 2, // default to top of unit circle
    this.endAngle = 2 * pi - (pi / 2), // default to top of unit circle + 360 degrees
    this.child,
  });

  @override
  _AnchoredRadialMenuState createState() => new _AnchoredRadialMenuState();
}

class _AnchoredRadialMenuState extends State<AnchoredRadialMenu> {
  final menuRadius = 75.0;
  final bubbleSize = 50.0;

  Angle startAngle;
  Angle endAngle;

  List<Widget> checkForScreenIntersection(BoxConstraints constraints, Offset anchor) {
    final origin = new Point<double>(anchor.dx, anchor.dy);
    ScreenIntersector intersector = new ScreenIntersector();
    Set<Point> intersections = intersector.intersect(
      constraints,
      origin,
      menuRadius,
    );

    Set<Point> menuPoints = intersections.map((Point intersection) {
      final origin = new Point(anchor.dx, anchor.dy);
      final intersectionPolar = new PolarCoord.fromPoints(origin, intersection);
      final Angle intersectionAngle = new Angle.fromRadians(intersectionPolar.angle);

      final centerOfScreen = new Point(constraints.maxWidth / 2, constraints.maxHeight / 2);
      final Angle angleToCenterOfScreen =
          new Angle.fromRadians(new PolarCoord.fromPoints(origin, centerOfScreen).angle);

      const zero = const Angle.fromRadians(0.0);
      const halfCircle = const Angle.fromRadians(pi);
      const fullCircle = const Angle.fromRadians(2 * pi);
      final Angle centerToIntersectDelta = angleToCenterOfScreen - intersectionAngle;
      final isClockwise = (centerToIntersectDelta >= zero &&
              centerToIntersectDelta <= halfCircle) ||
          (centerToIntersectDelta < zero && (centerToIntersectDelta + fullCircle <= halfCircle));
      final directionMultiplier = isClockwise ? 1 : -1;
      final bubbleRadius = bubbleSize / 2;
      final theta = new Angle.fromRadians(asin(bubbleRadius / menuRadius) * directionMultiplier);
      final menuPointAngle = intersectionAngle + theta;

      print(
          'Angle to center: ${angleToCenterOfScreen.toDegrees()}, Intersection angle: ${intersectionAngle.toDegrees()}');
      print('Going ${isClockwise ? 'clockwise' : 'counter-clockwise'}');
      print('Menu point angle: ${menuPointAngle.toDegrees()}');

      return new Point(
        anchor.dx + (menuRadius * cos(menuPointAngle.toRadians())),
        anchor.dy + (menuRadius * sin(menuPointAngle.toRadians())),
      );
    }).toSet();

    if (menuPoints.length == 2) {
      Angle angle1 =
          new Angle.fromRadians(new PolarCoord.fromPoints(origin, menuPoints.first).angle);
      Angle angle2 =
          new Angle.fromRadians(new PolarCoord.fromPoints(origin, menuPoints.last).angle);

      if (menuPoints.first.y < menuPoints.last.y) {
        startAngle = angle1;
        endAngle = angle2;
      } else {
        startAngle = angle2;
        endAngle = angle1;
      }
      print('Initial start angle: $startAngle');

      final centerOfScreen = new Point(constraints.maxWidth / 2, constraints.maxHeight / 2);

      Angle intersectionAngle = startAngle;

      Angle angleToCenterOfScreen =
          new Angle.fromRadians(new PolarCoord.fromPoints(origin, centerOfScreen).angle);

      final Angle centerToIntersectDelta = angleToCenterOfScreen - intersectionAngle;
      print('angleToCenterOfScreen: $angleToCenterOfScreen, intersectionAngle: $intersectionAngle');
      print('centerToIntersectDelta: $centerToIntersectDelta');
      final isClockwise =
          (centerToIntersectDelta >= Angle.zero && centerToIntersectDelta <= Angle.halfCircle) ||
              (centerToIntersectDelta < Angle.zero &&
                  (centerToIntersectDelta + Angle.fullCircle <= Angle.halfCircle));

      if (!isClockwise) {
        startAngle = new Angle.fromRadians(startAngle.toRadians(forcePositive: true));
        endAngle = new Angle.fromRadians(endAngle.toRadians(forcePositive: true));
      }
    }
    print('Start angle: $startAngle, end angle: $endAngle');

    List<Widget> dots = []..addAll(menuPoints.map((Point point) {
        return createDot(point);
      }));

    return dots;
  }

  Widget createDot(Point position) {
    return new Positioned(
      left: position.x,
      top: position.y,
      child: new FractionalTranslation(
        translation: const Offset(-0.5, -0.5),
        child: new Container(
          width: 20.0,
          height: 20.0,
          decoration: new BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.red,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnchoredOverlay(
      showOverlay: true,
      overlayBuilder: (BuildContext context, Offset anchor) {
        return new LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            List<Widget> dots = checkForScreenIntersection(constraints, anchor);

            return new Stack(
              children: <Widget>[
                new RadialMenu(
                  menu: demoMenu,
                  anchor: anchor,
                  bubbleSize: 50.0,
                  radius: 75.0,
                  startAngle: startAngle != null ? startAngle.toRadians() : widget.startAngle,
                  endAngle: endAngle != null ? endAngle.toRadians() : widget.endAngle,
                ),
              ]..addAll(dots),
            );
          },
        );
      },
      child: widget.child,
    );
  }
}

class RadialMenu extends StatefulWidget {
  final Menu menu;
  final Offset anchor;
  final double bubbleSize;
  final double radius;
  final double startAngle;
  final double endAngle;

  RadialMenu({
    this.menu,
    this.anchor,
    this.bubbleSize,
    this.radius,
    this.startAngle = -pi / 2, // default to top of unit circle
    this.endAngle = 2 * pi - (pi / 2), // default to top of unit circle + 360 degrees
  });

  @override
  _RadialMenuState createState() => new _RadialMenuState();
}

class _RadialMenuState extends State<RadialMenu> with TickerProviderStateMixin {
  RadialMenuController controller;

  @override
  void initState() {
    super.initState();

    controller = new RadialMenuController(
      vsync: this,
    )..addListener(() => setState(() {}));

    new Timer(
      const Duration(seconds: 2),
      () {
        controller.open();
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();

    super.dispose();
  }

  Widget buildCenter() {
    IconData icon;
    Color bubbleColor;
    switch (controller.state) {
      case RadialMenuState.closed:
      case RadialMenuState.closing:
      case RadialMenuState.opening:
      case RadialMenuState.open:
        icon = Icons.menu;
        bubbleColor = const Color(0xFFAAAAAA);
        break;
      default:
        icon = Icons.clear;
        bubbleColor = const Color(0xFF888888);
        break;
    }

    double scale = 1.0;
    if (controller.state == RadialMenuState.closed) {
      scale = 0.0;
    } else if (controller.state == RadialMenuState.opening) {
      scale = controller.progress;
    } else if (controller.state == RadialMenuState.closing) {
      scale = 1.0 - controller.progress;
    }

    return new CenterAbout(
      position: widget.anchor,
      child: new Transform(
        transform: new Matrix4.identity()..scale(scale, scale),
        alignment: Alignment.center,
        child: new IconBubble(
          icon: icon,
          diameter: 50.0,
          foregroundColor: Colors.black,
          backgroundColor: bubbleColor,
          onPressed: () {
            if (controller.state == RadialMenuState.open) {
              controller.expand();
            } else {
              controller.collapse();
            }
          },
        ),
      ),
    );
  }

  List<Widget> buildRadialBubbles() {
    Angle startAngle = new Angle.fromRadians(widget.startAngle);
    final Angle sweepAngle = new Angle.fromRadians(widget.endAngle) - startAngle;
    int index = 0;
    int itemCount = widget.menu.items.length;

    return widget.menu.items.map((MenuItem item) {
      int indexDivisor = sweepAngle == Angle.fullCircle ? itemCount : itemCount - 1;
      final Angle bubbleAngleDiff = sweepAngle * (index / indexDivisor);
      final Angle myAngle = startAngle + bubbleAngleDiff;
      ++index;

      if (controller.state == RadialMenuState.activating ||
          controller.state == RadialMenuState.dissipating) {
        if (controller.activationId == item.id) {
          // Don't render the active item when its activating or dissipating
          return Container();
        }
      }

      return buildRadialBubble(
        id: item.id,
        icon: item.icon,
        iconColor: item.iconColor,
        bubbleColor: item.bubbleColor,
        angle: myAngle.toRadians(),
      );
    }).toList(growable: true);
  }

  Widget buildRadialBubble({
    String id,
    IconData icon,
    Color iconColor,
    Color bubbleColor,
    double angle,
  }) {
    if (controller.state == RadialMenuState.closed ||
        controller.state == RadialMenuState.closing ||
        controller.state == RadialMenuState.opening ||
        controller.state == RadialMenuState.open ||
        controller.state == RadialMenuState.dissipating) {
      return new Container();
    }

    double distanceOut = widget.radius;
    double bubbleDiameter = widget.bubbleSize;

    if (controller.state == RadialMenuState.expanding) {
      distanceOut = widget.radius * controller.progress;
      bubbleDiameter = widget.bubbleSize * lerpDouble(0.3, 1.0, controller.progress);
    } else if (controller.state == RadialMenuState.collapsing) {
      distanceOut = widget.radius * (1.0 - controller.progress);
      bubbleDiameter = widget.bubbleSize * lerpDouble(0.3, 1.0, (1.0 - controller.progress));
    }

    return new PolarPosition(
      origin: widget.anchor,
      coord: new PolarCoord(angle, distanceOut),
      child: new IconBubble(
        icon: icon,
        diameter: bubbleDiameter,
        foregroundColor: iconColor,
        backgroundColor: bubbleColor,
        onPressed: () {
          controller.activate(id);
        },
      ),
    );
  }

  Widget buildActivationRibbon() {
    if (controller.state != RadialMenuState.activating &&
        controller.state != RadialMenuState.dissipating) {
      return new Container();
    }

    MenuItem activeItem =
        widget.menu.items.firstWhere((MenuItem item) => item.id == controller.activationId);
    int activeIndex = widget.menu.items.indexOf(activeItem);

    double ribbonStartAngle;
    double ribbonEndAngle;
    double radius = 75.0;
    double opacity = 1.0;
    if (controller.state == RadialMenuState.activating) {
      final menuSweepAngle = widget.endAngle - widget.startAngle;
      final indexDivisor =
          menuSweepAngle == 2 * pi ? widget.menu.items.length : widget.menu.items.length - 1;
      final initialItemAngle = widget.startAngle + (menuSweepAngle * activeIndex / indexDivisor);

      if (menuSweepAngle == 2 * pi) {
        ribbonStartAngle = initialItemAngle;
        ribbonEndAngle = initialItemAngle + (menuSweepAngle * controller.progress);
      } else {
        ribbonStartAngle =
            initialItemAngle - ((initialItemAngle - widget.startAngle) * controller.progress);
        ribbonEndAngle =
            initialItemAngle + ((widget.endAngle - initialItemAngle) * controller.progress);
      }
    } else if (controller.state == RadialMenuState.dissipating) {
      ribbonStartAngle = widget.startAngle;
      ribbonEndAngle = widget.endAngle;

      radius = 75 * (1.0 + (0.25 * controller.progress));
      opacity = 1.0 - controller.progress;
    }

    return new CenterAbout(
      position: widget.anchor,
      child: new Opacity(
        opacity: opacity,
        child: new CustomPaint(
          painter: new ActivationPainter(
            radius: radius,
            color: activeItem.bubbleColor,
            startAngle: ribbonStartAngle,
            endAngle: ribbonEndAngle,
            thickness: 50.0,
          ),
        ),
      ),
    );
  }

  Widget buildActivationBubble() {
    if (controller.state != RadialMenuState.activating) {
      return new Container();
    }

    MenuItem activeItem =
        widget.menu.items.firstWhere((MenuItem item) => item.id == controller.activationId);
    int activeIndex = widget.menu.items.indexOf(activeItem);

    double currAngle;

    final sweepAngle = widget.endAngle - widget.startAngle;
    final indexDivisor =
        sweepAngle == 2 * pi ? widget.menu.items.length : widget.menu.items.length - 1;
    final initialItemAngle = widget.startAngle + (activeIndex * sweepAngle / indexDivisor);
    if (sweepAngle == 2 * pi) {
      currAngle = (sweepAngle * controller.progress) + initialItemAngle;
    } else {
      final centerAngle = lerpDouble(widget.startAngle, widget.endAngle, 0.5);
      currAngle = lerpDouble(initialItemAngle, centerAngle, controller.progress);
    }

    return buildRadialBubble(
      id: activeItem.id,
      icon: activeItem.icon,
      iconColor: activeItem.iconColor,
      bubbleColor: activeItem.bubbleColor,
      angle: currAngle,
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Stack(
      children: buildRadialBubbles()
        ..addAll(<Widget>[
          // Activation ribbon
          buildActivationRibbon(),

          // Activating bubble
          buildActivationBubble(),

          // Center
          buildCenter(),
        ]),
    );
  }
}

class ActivationPainter extends CustomPainter {
  final double radius;
  final double startAngle;
  final double endAngle;
  final Paint activationPaint;

  ActivationPainter({
    Color color,
    this.radius,
    this.startAngle,
    this.endAngle,
    double thickness,
  }) : activationPaint = new Paint()
          ..color = color
          ..strokeWidth = thickness
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawArc(new Rect.fromLTWH(-radius, -radius, radius * 2, radius * 2), startAngle,
        endAngle - startAngle, false, activationPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class IconBubble extends StatelessWidget {
  final IconData icon;
  final double diameter;
  final Color foregroundColor;
  final Color backgroundColor;
  final VoidCallback onPressed;

  IconBubble({
    this.icon,
    this.diameter,
    this.foregroundColor,
    this.backgroundColor,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      onTap: onPressed,
      child: new Bubble(
        diameter: diameter,
        backgroundColor: backgroundColor,
        child: new Icon(
          icon,
          color: foregroundColor,
        ),
      ),
    );
  }
}

class Bubble extends StatelessWidget {
  final double diameter;
  final Color backgroundColor;
  final Widget child;

  Bubble({
    this.diameter,
    this.backgroundColor,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return new Container(
      width: diameter,
      height: diameter,
      decoration: new BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor,
      ),
      child: child,
    );
  }
}

class RadialMenuController extends ChangeNotifier {
  final Duration openDuration;
  final AnimationController openController;

  final Duration closeDuration;
  final AnimationController closeController;

  final Duration expandDuration;
  final AnimationController expandController;

  final Duration collapseDuration;
  final AnimationController collapseController;

  final Duration activationDuration;
  final AnimationController activationController;

  final Duration dissipationDuration;
  final AnimationController dissipationController;

  final TickerProvider vsync;

  RadialMenuState _state = RadialMenuState.closed;
  double _progress;
  String _activationId; // Only valid in activating and dissipating states.

  RadialMenuController({
    this.openDuration = const Duration(milliseconds: 250),
    this.closeDuration = const Duration(milliseconds: 250),
    this.expandDuration = const Duration(milliseconds: 150),
    this.collapseDuration = const Duration(milliseconds: 150),
    this.activationDuration = const Duration(milliseconds: 500),
    this.dissipationDuration = const Duration(milliseconds: 250),
    @required this.vsync,
  })  : openController = new AnimationController(duration: openDuration, vsync: vsync),
        closeController = new AnimationController(duration: closeDuration, vsync: vsync),
        expandController = new AnimationController(duration: expandDuration, vsync: vsync),
        collapseController = new AnimationController(duration: collapseDuration, vsync: vsync),
        activationController = new AnimationController(duration: activationDuration, vsync: vsync),
        dissipationController = new AnimationController(duration: openDuration, vsync: vsync) {
    openController
      ..addListener(() {
        _progress = openController.value;
        notifyListeners();
      })
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.forward) {
          _state = RadialMenuState.opening;
          _progress = 0.0;
          notifyListeners();
        } else if (status == AnimationStatus.completed) {
          _state = RadialMenuState.open;
          notifyListeners();
        }
      });

    closeController
      ..addListener(() {
        _progress = closeController.value;
        notifyListeners();
      })
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.forward) {
          _state = RadialMenuState.closing;
          _progress = 0.0;
          notifyListeners();
        } else if (status == AnimationStatus.completed) {
          _state = RadialMenuState.closed;
          notifyListeners();
        }
      });

    expandController
      ..addListener(() {
        _progress = expandController.value;
        notifyListeners();
      })
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.forward) {
          _state = RadialMenuState.expanding;
          _progress = 0.0;
          notifyListeners();
        } else if (status == AnimationStatus.completed) {
          _state = RadialMenuState.expanded;
          notifyListeners();
        }
      });

    collapseController
      ..addListener(() {
        _progress = collapseController.value;
        notifyListeners();
      })
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.forward) {
          _state = RadialMenuState.collapsing;
          _progress = 0.0;
          notifyListeners();
        } else if (status == AnimationStatus.completed) {
          _state = RadialMenuState.open;
          notifyListeners();
        }
      });

    activationController
      ..addListener(() {
        _progress = activationController.value;
        notifyListeners();
      })
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.forward) {
          _state = RadialMenuState.activating;
          _progress = 0.0;
          notifyListeners();
        } else if (status == AnimationStatus.completed) {
          _progress = 1.0;
          notifyListeners();

          dissipationController.forward(from: 0.0);
        }
      });

    dissipationController
      ..addListener(() {
        _progress = dissipationController.value;
        notifyListeners();
      })
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.forward) {
          _state = RadialMenuState.dissipating;
          _progress = 0.0;
          notifyListeners();
        } else if (status == AnimationStatus.completed) {
          _state = RadialMenuState.open;
          notifyListeners();
        }
      });
  }

  RadialMenuState get state => _state;

  double get progress => _progress;

  String get activationId => _activationId;

  void open() {
    if (state == RadialMenuState.closed) {
      openController.forward(from: 0.0);
    }
  }

  void close() {
    if (state == RadialMenuState.open) {
      closeController.forward(from: 0.0);
    }
  }

  void expand() {
    if (state == RadialMenuState.open) {
      expandController.forward(from: 0.0);
    }
  }

  void collapse() {
    if (state == RadialMenuState.expanded) {
      collapseController.forward(from: 0.0);
    }
  }

  void activate(String menuItemId) {
    if (state == RadialMenuState.expanded) {
      _activationId = menuItemId;
      activationController.forward(from: 0.0);
    }
  }
}

enum RadialMenuState {
  closed,
  closing,
  opening,
  open,
  expanding,
  expanded,
  collapsing,
  activating,
  dissipating,
}
