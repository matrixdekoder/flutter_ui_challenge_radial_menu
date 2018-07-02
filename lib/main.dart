import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fluttery/animations.dart';
import 'package:fluttery/layout.dart';
import 'package:radial_menu/geometry.dart';
import 'package:radial_menu/radial_menu_collisions.dart';

final demoMenu = new Menu(items: [
  new MenuItem(
    id: "1",
    icon: Icons.home,
    iconColor: Colors.white,
    bubbleColor: Colors.blue,
  ),
  new MenuItem(
    id: "2",
    icon: Icons.search,
    iconColor: Colors.white,
    bubbleColor: Colors.green,
  ),
  new MenuItem(
    id: "3",
    icon: Icons.alarm,
    iconColor: Colors.white,
    bubbleColor: Colors.red,
  ),
  new MenuItem(
    id: "4",
    icon: Icons.settings,
    iconColor: Colors.white,
    bubbleColor: Colors.purple,
  ),
  new MenuItem(
    id: "5",
    icon: Icons.location_on,
    iconColor: Colors.white,
    bubbleColor: Colors.orange,
  ),
]);

void main() => runApp(new MyApp());

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

  Widget _buildAnchoredMenu() {
    return AnchoredRadialMenu(
      menu: demoMenu,
      startAngle: -pi / 2,
      endAngle: 3 * pi / 2,
      onSelected: (String menuItemId) {
        print('Selected: $menuItemId');
      },
      child: IconButton(
        icon: Icon(
          Icons.cancel,
        ),
        onPressed: () {},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: _buildAnchoredMenu(),
        actions: <Widget>[
          _buildAnchoredMenu(),
        ],
      ),
      body: Stack(
        children: <Widget>[
          // Center
          Align(
            alignment: Alignment.center,
            child: _buildAnchoredMenu(),
          ),

          // Middle left
          Align(
            alignment: Alignment.centerLeft,
            child: _buildAnchoredMenu(),
          ),

          // Middle right
          Align(
            alignment: Alignment.centerRight,
            child: _buildAnchoredMenu(),
          ),

          // Bottom left
          Align(
            alignment: Alignment.bottomLeft,
            child: _buildAnchoredMenu(),
          ),

          // Bottom right
          Align(
            alignment: Alignment.bottomRight,
            child: _buildAnchoredMenu(),
          ),
        ],
      ),
    );
  }
}

class AnchoredRadialMenu extends StatefulWidget {
  final Menu menu;
  final double radius;
  final double bubbleSize;
  final double startAngle;
  final double endAngle;
  final Function(String menuItemId) onSelected;
  final Widget child;

  AnchoredRadialMenu({
    this.menu,
    this.radius = 75.0,
    this.bubbleSize = 50.0,
    this.startAngle = -pi / 2,
    this.endAngle = 3 * pi / 2,
    this.onSelected,
    this.child,
  });

  @override
  _AnchoredRadialMenuState createState() => _AnchoredRadialMenuState();
}

class _AnchoredRadialMenuState extends State<AnchoredRadialMenu> {
  @override
  Widget build(BuildContext context) {
    return AnchoredOverlay(
      showOverlay: true,
      overlayBuilder: (BuildContext context, Offset anchor) {
        return CollidingRadialMenu(
          anchor: anchor,
          menu: widget.menu,
          menuRadius: widget.radius,
          bubbleSize: widget.bubbleSize,
          onSelected: widget.onSelected,
        );
      },
      child: widget.child,
    );
  }
}

class CollidingRadialMenu extends StatefulWidget {
  final Menu menu;
  final Offset anchor;
  final double menuRadius;
  final double bubbleSize;
  final double startAngle;
  final double endAngle;
  final bool debugMode;
  final void Function(String itemId) onSelected;
  final Widget child;

  CollidingRadialMenu({
    this.menu,
    this.anchor,
    this.menuRadius = 75.0,
    this.bubbleSize = 50.0,
    this.startAngle = -pi / 2, // default to top of unit circle
    this.endAngle = 2 * pi - (pi / 2), // default to top of unit circle + 360 degrees
    this.onSelected,
    this.debugMode = false,
    this.child,
  });

  @override
  _CollidingRadialMenuState createState() => new _CollidingRadialMenuState();
}

class _CollidingRadialMenuState extends State<CollidingRadialMenu> {
  Arc radialArc;

  void _findNonCollidingArc(BoxConstraints constraints) {
    final origin = new Point<double>(widget.anchor.dx, widget.anchor.dy);
    final screenSize = new Size(constraints.maxWidth, constraints.maxHeight);
    final centerOfScreen = new Point(constraints.maxWidth / 2, constraints.maxHeight / 2);

    // Find where menu circle intersects the screen boundaries.
    Set<Point> intersections = intersect(
      screenSize,
      origin,
      widget.menuRadius + (widget.bubbleSize / 2),
    );

    if (intersections.length > 2) {
      print('${intersections.length} POINTS INTERSECTION');
      intersections = _reduceIntersections(intersections, origin, centerOfScreen);
    }

    if (intersections.length == 2) {
      print('Intersection points: ${intersections.first}, ${intersections.last}');

      // Choose a start angle and end angle based on menu points.
      radialArc = _createStartAndEndAnglesFromTwoPoints(
        intersections,
        origin,
        centerOfScreen,
      );

      // Adjust screen intersection points to leave room for bubble radii.
      radialArc = rotatePointsToMakeRoom(
        arc: radialArc,
        origin: origin,
        direction: centerOfScreen,
        radius: widget.menuRadius,
        extraSpace: widget.bubbleSize / 2,
      );
    } else {
      radialArc = new Arc(
        from: new Angle.fromRadians(widget.startAngle),
        to: new Angle.fromRadians(widget.endAngle),
        direction: RadialDirection.clockwise,
      );
    }
  }

  List<Widget> _buildDebugPoints(BoxConstraints constraints, Offset anchor) {
    final origin = new Point<double>(anchor.dx, anchor.dy);

    if (radialArc.sweepAngle() != Angle.fullCircle) {
      // Create debug dots
      Point startPoint = new Point(
        origin.x + (widget.menuRadius * cos(radialArc.from.toRadians())),
        origin.y + (widget.menuRadius * sin(radialArc.from.toRadians())),
      );

      Point endPoint = new Point(
        origin.x + (widget.menuRadius * cos(radialArc.to.toRadians())),
        origin.y + (widget.menuRadius * sin(radialArc.to.toRadians())),
      );

      List<Widget> dots = []..add(_createDot(startPoint))..add(_createDot(endPoint));

      return dots;
    } else {
      return const [];
    }
  }

  Arc _createStartAndEndAnglesFromTwoPoints(
    Set<Point> menuEdgePoints,
    Point origin,
    Point centerOfScreen,
  ) {
    if (menuEdgePoints.length != 2) {
      return const Arc.clockwise(
        from: Angle.zero,
        to: Angle.fullCircle,
      );
    }

    final directionToCenter =
        new Angle.fromRadians(new PolarCoord.fromPoints(origin, centerOfScreen).angle);

    bool isOnLeftSideOfScreen = origin.x < centerOfScreen.x;
    final isClockwise = isOnLeftSideOfScreen;
    print('isClockwise: $isClockwise');

    Angle angle1 =
        new Angle.fromRadians(new PolarCoord.fromPoints(origin, menuEdgePoints.first).angle);
    Arc arc1 = new Arc(
      from: angle1,
      to: directionToCenter,
      direction: isClockwise ? RadialDirection.clockwise : RadialDirection.counterClockwise,
    );
    Angle angle2 =
        new Angle.fromRadians(new PolarCoord.fromPoints(origin, menuEdgePoints.last).angle);
    Arc arc2 = new Arc(
      from: angle2,
      to: directionToCenter,
      direction: isClockwise ? RadialDirection.clockwise : RadialDirection.counterClockwise,
    );

    Angle startAngle;
    Angle endAngle;

    if (isClockwise) {
      // Menu should rotate clockwise.
      print('Menu should radiate clockwise.');
      print('Angle to center of screen is $directionToCenter');

      if (arc1.sweepAngle().toRadians().abs() < arc2.sweepAngle().toRadians().abs()) {
        print('$angle1 is closest to center, its the starting angle.');
        startAngle = angle1;
        endAngle = angle2;
      } else {
        print('$angle2 is closest to center, its the starting angle.');
        startAngle = angle2;
        endAngle = angle1;
      }
    } else {
      // Menu should rotate counter-clockwise.
      print('Menu should radiate counter-clockwise');
      if (arc1.sweepAngle().toRadians().abs() < arc2.sweepAngle().toRadians().abs()) {
        startAngle = angle1;
        endAngle = angle2;
      } else {
        startAngle = angle2;
        endAngle = angle1;
      }
    }
    print('Initial start angle: $startAngle');

    Angle intersectionAngle = startAngle;

    Angle angleToCenterOfScreen =
        new Angle.fromRadians(new PolarCoord.fromPoints(origin, centerOfScreen).angle);

    final Angle centerToIntersectDelta = angleToCenterOfScreen - intersectionAngle;
    print('angleToCenterOfScreen: $angleToCenterOfScreen, intersectionAngle: $intersectionAngle');
    print('centerToIntersectDelta: $centerToIntersectDelta');

    if (!isClockwise) {
      startAngle = new Angle.fromRadians(startAngle.toRadians(forcePositive: true));
      endAngle = new Angle.fromRadians(endAngle.toRadians(forcePositive: true));
    }

    print('Start angle: $startAngle, end angle: $endAngle');
    return isClockwise
        ? new Arc.clockwise(from: startAngle, to: endAngle)
        : new Arc.counterClockwise(from: startAngle, to: endAngle);
  }

  Set<Point> _reduceIntersections(Set<Point> intersections, Point origin, Point centerOfScreen) {
    Set<Point> twoPoints = new Set();

    final Angle directionToCenter =
        new Angle.fromRadians(new PolarCoord.fromPoints(origin, centerOfScreen).angle);

    Point closestClockwise;
    Angle closestClockwiseAngle;
    Point closestCounterClockwise;
    Angle closestCounterClockwiseAngle;

    for (Point intersection in intersections) {
      Angle intersectionAngle =
          new Angle.fromRadians(new PolarCoord.fromPoints(origin, intersection).angle);
      if (closestClockwise == null) {
        closestClockwise = intersection;
        closestClockwiseAngle = intersectionAngle;
      } else if (directionToCenter - intersectionAngle <
          directionToCenter - closestClockwiseAngle) {
        closestClockwise = intersection;
        closestClockwiseAngle = intersectionAngle;
      }

      if (closestCounterClockwise == null) {
        closestCounterClockwise = intersection;
        closestCounterClockwiseAngle = intersectionAngle;
      } else if (intersectionAngle - directionToCenter <
          closestCounterClockwiseAngle - directionToCenter) {
        closestCounterClockwise = intersection;
        closestCounterClockwiseAngle = intersectionAngle;
      }
    }
    twoPoints.add(closestClockwise);
    twoPoints.add(closestCounterClockwise);

    return twoPoints;
  }

  Widget _createDot(Point position) {
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
    return new LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        _findNonCollidingArc(constraints);
        List<Widget> dots = widget.debugMode ? _buildDebugPoints(constraints, widget.anchor) : [];

        return new Stack(
          children: <Widget>[
            new RadialMenu(
              menu: demoMenu,
              anchor: widget.anchor,
              bubbleSize: 50.0,
              radius: 75.0,
              arc: radialArc ??
                  new Arc(
                    from: new Angle.fromRadians(widget.startAngle),
                    to: new Angle.fromRadians(widget.endAngle),
                    direction: RadialDirection.clockwise,
                  ),
              onSelected: widget.onSelected,
            ),
          ]..addAll(dots),
        );
      },
    );
  }
}

class RadialMenu extends StatefulWidget {
  final Offset anchor;
  final Menu menu;
  final double radius;
  final double bubbleSize;
  final Arc arc;
  final Function(String menuItemId) onSelected;

  RadialMenu({
    this.anchor,
    this.menu,
    this.radius = 75.0,
    this.bubbleSize = 50.0,
    this.arc = const Arc(
      from: Angle.fromRadians(-pi / 2),
      to: Angle.fromRadians(2 * pi - (pi / 2)),
      direction: RadialDirection.clockwise,
    ),
    this.onSelected,
  });

  @override
  _RadialMenuState createState() => _RadialMenuState();
}

class _RadialMenuState extends State<RadialMenu> with SingleTickerProviderStateMixin {
  RadialMenuController _menuController;

  @override
  void initState() {
    super.initState();

    _menuController = RadialMenuController(
      vsync: this,
    )
      ..addListener(() => setState(() {}))
      ..addSelectionListener(widget.onSelected);

    // Automatically open menu for testing.
    Timer(
      Duration(seconds: 2),
      () {
        _menuController.open();
      },
    );
  }

  @override
  void dispose() {
    _menuController.dispose();
    super.dispose();
  }

  Widget buildCenter() {
    IconData icon;
    Color bubbleColor;
    double scale = 1.0;
    double rotation = 0.0;
    VoidCallback onPressed;
    switch (_menuController.state) {
      case RadialMenuState.closed:
        icon = Icons.menu;
        bubbleColor = Color(0xFFAAAAAA);
        scale = 0.0;
        break;
      case RadialMenuState.closing:
        icon = Icons.menu;
        bubbleColor = Color(0xFFAAAAAA);
        scale = 1.0 - _menuController.progress;
        break;
      case RadialMenuState.opening:
        icon = Icons.menu;
        bubbleColor = Color(0xFFAAAAAA);
        scale = Interval(0.0, 1.0, curve: Curves.elasticOut).transform(_menuController.progress);
        if (0.0 < _menuController.progress && _menuController.progress < 0.5) {
          rotation = lerpDouble(
            0.0,
            pi / 4,
            Interval(0.0, 0.5).transform(_menuController.progress),
          );
        } else if (_menuController.progress >= 0.5) {
          rotation = lerpDouble(
            pi / 4,
            0.0,
            Interval(0.5, 1.0).transform(_menuController.progress),
          );
        }
        break;
      case RadialMenuState.open:
        icon = Icons.menu;
        bubbleColor = Color(0xFFAAAAAA);
        onPressed = () {
          _menuController.expand();
        };
        break;
      case RadialMenuState.expanding:
        icon = Icons.clear;
        bubbleColor = Color(0xFF666666);
        rotation = Interval(0.0, 0.5, curve: Curves.easeOut).transform(_menuController.progress) *
            (pi / 2);
        break;
      case RadialMenuState.collapsing:
        icon = Icons.menu;
        bubbleColor = Color(0xFFAAAAAA);
        rotation = (pi / 2) - (_menuController.progress * (pi / 2));
        break;
      case RadialMenuState.expanded:
        icon = Icons.clear;
        bubbleColor = Color(0xFF666666);
        rotation = pi / 2;
        onPressed = () {
          _menuController.collapse();
        };
        break;
      case RadialMenuState.activating:
        icon = Icons.clear;
        bubbleColor = Color(0xFF666666);
        scale = lerpDouble(
          1.0,
          0.0,
          Interval(0.0, 0.9, curve: Curves.easeOut).transform(_menuController.progress),
        );
        break;
      case RadialMenuState.dissipating:
        icon = Icons.menu;
        bubbleColor = Color(0xFFAAAAAA);
        scale = lerpDouble(
          0.0,
          1.0,
          Interval(0.0, 1.0, curve: Curves.elasticOut).transform(_menuController.progress),
        );
        if (0.0 < _menuController.progress && _menuController.progress < 0.5) {
          rotation = lerpDouble(
            0.0,
            pi / 4,
            Interval(0.0, 0.5).transform(_menuController.progress),
          );
        } else if (_menuController.progress >= 0.5) {
          rotation = lerpDouble(
            pi / 4,
            0.0,
            Interval(0.5, 1.0).transform(_menuController.progress),
          );
        }
        break;
    }

    return CenterAbout(
      position: widget.anchor,
      child: Transform(
        transform: Matrix4.identity()
          ..scale(scale, scale)
          ..rotateZ(rotation),
        alignment: Alignment.center,
        child: IconBubble(
          icon: icon,
          diameter: 50.0,
          iconColor: Colors.black,
          bubbleColor: bubbleColor,
          onPressed: onPressed,
        ),
      ),
    );
  }

  List<Widget> buildRadialBubbles() {
    final Angle startAngle = widget.arc.from;
    final Angle sweepAngle = widget.arc.sweepAngle();
    int index = 0;
    int itemCount = widget.menu.items.length;

    return widget.menu.items.map((MenuItem item) {
      int indexDivisor = sweepAngle == Angle.fullCircle ? itemCount : itemCount - 1;
      final Angle bubbleAngleDiff = sweepAngle * (index / indexDivisor);
      final Angle myAngle = startAngle + bubbleAngleDiff;
      ++index;

      if ((_menuController.state == RadialMenuState.activating ||
              _menuController.state == RadialMenuState.dissipating) &&
          _menuController.activationId == item.id) {
        return Container();
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
    if (_menuController.state == RadialMenuState.closed ||
        _menuController.state == RadialMenuState.closing ||
        _menuController.state == RadialMenuState.opening ||
        _menuController.state == RadialMenuState.open ||
        _menuController.state == RadialMenuState.dissipating) {
      return Container();
    }

    double distanceOut = widget.radius;
    double bubbleSize = widget.bubbleSize;

    if (_menuController.state == RadialMenuState.expanding) {
      distanceOut = widget.radius * Curves.elasticOut.transform(_menuController.progress);
      bubbleSize = widget.bubbleSize *
          lerpDouble(0.5, 1.0,
              Interval(0.0, 0.3, curve: Curves.easeOut).transform(_menuController.progress));
    } else if (_menuController.state == RadialMenuState.collapsing) {
      distanceOut = widget.radius * (1.0 - _menuController.progress);
      bubbleSize = widget.bubbleSize * lerpDouble(0.3, 1.0, (1.0 - _menuController.progress));
    }

    return PolarPosition(
      origin: widget.anchor,
      coord: PolarCoord(angle, distanceOut),
      child: IconBubble(
        icon: icon,
        diameter: bubbleSize,
        iconColor: iconColor,
        bubbleColor: bubbleColor,
        onPressed: () {
          _menuController.activate(id);
        },
      ),
    );
  }

  Widget buildActivationRibbon() {
    if (_menuController.state != RadialMenuState.activating &&
        _menuController.state != RadialMenuState.dissipating) {
      return Container();
    }

    MenuItem activeItem =
        widget.menu.items.firstWhere((MenuItem item) => item.id == _menuController.activationId);
    int activeIndex = widget.menu.items.indexOf(activeItem);

    Angle startAngle;
    Angle endAngle;
    double radius = 75.0;
    double opacity = 1.0;
    if (_menuController.state == RadialMenuState.activating) {
      double activeBubblePercent = activeIndex / widget.menu.items.length;
      startAngle = Angle.fromRadians(-pi / 2) + (Angle.fullCircle * activeBubblePercent);
      endAngle = Angle.fullCircle * _menuController.progress + startAngle;

      final Angle menuSweepAngle = widget.arc.sweepAngle();
      final double indexDivisor = menuSweepAngle == Angle.fullCircle
          ? widget.menu.items.length.toDouble()
          : (widget.menu.items.length - 1).toDouble();
      final Angle initialItemAngle =
          widget.arc.from + (menuSweepAngle * activeIndex.toDouble() / indexDivisor);

      if (menuSweepAngle == Angle.fullCircle) {
        startAngle = initialItemAngle;
        endAngle = initialItemAngle + (menuSweepAngle * _menuController.progress);
      } else {
        startAngle =
            initialItemAngle - ((initialItemAngle - widget.arc.from) * _menuController.progress);
        endAngle =
            initialItemAngle + ((widget.arc.to - initialItemAngle) * _menuController.progress);
      }
    } else if (_menuController.state == RadialMenuState.dissipating) {
      startAngle = widget.arc.from;
      endAngle = widget.arc.to;

      final adjustedProgress = Interval(0.0, 0.5).transform(_menuController.progress);
      radius = widget.radius * (1.0 + (0.25 * adjustedProgress));
      opacity = 1.0 - adjustedProgress;
    }

    return CenterAbout(
      position: widget.anchor,
      child: Opacity(
        opacity: opacity,
        child: CustomPaint(
          painter: ActivationPainter(
            radius: radius,
            color: activeItem.bubbleColor,
            startAngle: startAngle.toRadians(),
            endAngle: endAngle.toRadians(),
            thickness: 50.0,
          ),
        ),
      ),
    );
  }

  Widget buildActivationBubble() {
    if (_menuController.state != RadialMenuState.activating) {
      return Container();
    }

    MenuItem activeItem =
        widget.menu.items.firstWhere((MenuItem item) => item.id == _menuController.activationId);
    int activeIndex = widget.menu.items.indexOf(activeItem);
    double currAngle;

    final sweepAngle = widget.arc.to.toRadians() - widget.arc.from.toRadians();
    final indexDivisor =
        sweepAngle == 2 * pi ? widget.menu.items.length : widget.menu.items.length - 1;
    final initialItemAngle =
        widget.arc.from.toRadians() + (activeIndex * sweepAngle / indexDivisor);
    if (sweepAngle == 2 * pi) {
      currAngle = (sweepAngle * _menuController.progress) + initialItemAngle;
    } else {
      final centerAngle = lerpDouble(widget.arc.from.toRadians(), widget.arc.to.toRadians(), 0.5);
      currAngle = lerpDouble(initialItemAngle, centerAngle, _menuController.progress);
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
    return Stack(
      children: buildRadialBubbles()
        ..addAll([buildCenter(), buildActivationRibbon(), buildActivationBubble()]),
    );
  }
}

class ActivationPainter extends CustomPainter {
  final double radius;
  final Color color;
  final double startAngle;
  final double endAngle;
  final double thickness;
  final Paint activationPaint;

  ActivationPainter({
    this.radius,
    this.color,
    this.startAngle,
    this.endAngle,
    this.thickness,
  }) : activationPaint = new Paint()
          ..color = color
          ..strokeWidth = thickness
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawArc(
      Rect.fromLTWH(
        -radius,
        -radius,
        radius * 2,
        radius * 2,
      ),
      startAngle,
      endAngle - startAngle,
      false,
      activationPaint,
    );
  }

  @override
  bool shouldRepaint(ActivationPainter old) {
    return old.radius != radius ||
        old.color != color ||
        old.startAngle != startAngle ||
        old.endAngle != endAngle ||
        old.thickness != endAngle;
  }
}

class IconBubble extends StatelessWidget {
  final IconData icon;
  final double diameter;
  final Color iconColor;
  final Color bubbleColor;
  final VoidCallback onPressed;

  IconBubble({
    this.icon,
    this.diameter,
    this.iconColor,
    this.bubbleColor,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Bubble(
        diameter: diameter,
        backgroundColor: bubbleColor,
        child: new Icon(
          icon,
          color: iconColor,
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
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor,
      ),
      child: child,
    );
  }
}

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
    final radialPosition = Offset(
      origin.dx + (cos(coord.angle) * coord.radius),
      origin.dy + (sin(coord.angle) * coord.radius),
    );

    return CenterAbout(
      position: radialPosition,
      child: child,
    );
  }
}

class RadialMenuController extends ChangeNotifier {
  final AnimationController _progress;
  RadialMenuState _state = RadialMenuState.closed;
  String _activationId;
  List<Function(String menuItemId)> _onSelectedListeners;

  RadialMenuController({
    @required TickerProvider vsync,
  })  : _progress = AnimationController(vsync: vsync),
        _onSelectedListeners = [] {
    _progress
      ..addListener(_onProgressUpdate)
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          _onTransitionCompleted();
        }
      });
  }

  @override
  void dispose() {
    _onSelectedListeners.clear();
    super.dispose();
  }

  void addSelectionListener(Function(String menuItemid) onSelected) {
    _onSelectedListeners.add(onSelected);
  }

  void _notifySelectionListeners() {
    _onSelectedListeners.forEach((listener) {
      listener(_activationId);
    });
  }

  void _onProgressUpdate() {
    notifyListeners();
  }

  void _onTransitionCompleted() {
    switch (_state) {
      case RadialMenuState.closing:
        _state = RadialMenuState.closed;
        break;
      case RadialMenuState.opening:
        _state = RadialMenuState.open;
        break;
      case RadialMenuState.expanding:
        _state = RadialMenuState.expanded;
        break;
      case RadialMenuState.collapsing:
        _state = RadialMenuState.open;
        break;
      case RadialMenuState.activating:
        _state = RadialMenuState.dissipating;
        _progress.duration = Duration(milliseconds: 500);
        _progress.forward(from: 0.0);
        break;
      case RadialMenuState.dissipating:
        _notifySelectionListeners();
        _state = RadialMenuState.open;
        _activationId = null;
        break;
      case RadialMenuState.closed:
      case RadialMenuState.open:
      case RadialMenuState.expanded:
        throw Exception('Invalid state during a transition: $_state');
        break;
    }

    notifyListeners();
  }

  RadialMenuState get state => _state;

  double get progress => _progress.value;

  String get activationId => _activationId;

  void open() {
    if (state == RadialMenuState.closed) {
      _state = RadialMenuState.opening;
      _progress.duration = Duration(milliseconds: 500);
      _progress.forward(from: 0.0);
    }
  }

  void close() {
    if (state == RadialMenuState.open) {
      _state = RadialMenuState.closing;
      _progress.duration = Duration(milliseconds: 250);
      _progress.forward(from: 0.0);
    }
  }

  void expand() {
    if (state == RadialMenuState.open) {
      _state = RadialMenuState.expanding;
      _progress.duration = Duration(milliseconds: 500);
      _progress.forward(from: 0.0);
    }
  }

  void collapse() {
    if (state == RadialMenuState.expanded) {
      _state = RadialMenuState.collapsing;
      _progress.duration = Duration(milliseconds: 150);
      _progress.forward(from: 0.0);
    }
  }

  void activate(String menuItemId) {
    if (state == RadialMenuState.expanded) {
      _activationId = menuItemId;
      _state = RadialMenuState.activating;
      _progress.duration = Duration(milliseconds: 500);
      _progress.forward(from: 0.0);
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

class Menu {
  final List<MenuItem> items;

  Menu({
    this.items,
  });
}

class MenuItem {
  final String id;
  final IconData icon;
  final Color iconColor;
  final Color bubbleColor;

  MenuItem({
    this.id,
    this.icon,
    this.iconColor,
    this.bubbleColor,
  });
}
