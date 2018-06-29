import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fluttery/animations.dart';
import 'package:fluttery/layout.dart';

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

  void showMenu(String location) {
    // TODO:
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(
              Icons.cancel,
            ),
            onPressed: () {
              showMenu(topLeft);
            }),
        actions: <Widget>[
          IconButton(
              icon: Icon(
                Icons.cancel,
              ),
              onPressed: () {
                showMenu(topRight);
              }),
        ],
      ),
      body: Stack(
        children: <Widget>[
          // Center
          Align(
            alignment: Alignment.center,
            child: AnchoredRadialMenu(
              child: IconButton(
                icon: Icon(
                  Icons.cancel,
                ),
                onPressed: () {
                  showMenu(center);
                },
              ),
            ),
          ),

          // Middle left
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: Icon(
                Icons.cancel,
              ),
              onPressed: () {
                showMenu(middleLeft);
              },
            ),
          ),

          // Middle right
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: Icon(
                Icons.cancel,
              ),
              onPressed: () {
                showMenu(middleRight);
              },
            ),
          ),

          // Bottom left
          Align(
            alignment: Alignment.bottomLeft,
            child: IconButton(
              icon: Icon(
                Icons.cancel,
              ),
              onPressed: () {
                showMenu(bottomLeft);
              },
            ),
          ),

          // Bottom right
          Align(
            alignment: Alignment.bottomRight,
            child: IconButton(
              icon: Icon(
                Icons.cancel,
              ),
              onPressed: () {
                showMenu(bottomRight);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AnchoredRadialMenu extends StatefulWidget {
  final Widget child;

  AnchoredRadialMenu({
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
        return RadialMenu(
          anchor: anchor,
        );
      },
      child: widget.child,
    );
  }
}

class RadialMenu extends StatefulWidget {
  final Offset anchor;
  final double radius;
  final double bubbleSize;

  RadialMenu({
    this.anchor,
    this.radius = 75.0,
    this.bubbleSize = 50.0,
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
    )..addListener(() => setState(() {}));

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
        scale = _menuController.progress;
        break;
      case RadialMenuState.open:
        icon = Icons.menu;
        bubbleColor = Color(0xFFAAAAAA);
        onPressed = () {
          _menuController.expand();
        };
        break;
      case RadialMenuState.expanded:
        icon = Icons.clear;
        bubbleColor = Color(0xFF888888);
        onPressed = () {
          _menuController.collapse();
        };
        break;
      default:
        icon = Icons.clear;
        bubbleColor = Color(0xFF888888);
        break;
    }

    return CenterAbout(
      position: widget.anchor,
      child: Transform(
        transform: Matrix4.identity()..scale(scale, scale),
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

  Widget buildRadialBubble({
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
      distanceOut = widget.radius * _menuController.progress;
      bubbleSize = widget.bubbleSize * _menuController.progress;
    } else if (_menuController.state == RadialMenuState.collapsing) {
      distanceOut = widget.radius * (1.0 - _menuController.progress);
      bubbleSize = widget.bubbleSize * (1.0 - _menuController.progress);
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
          _menuController.activate("todo");
        },
      ),
    );
  }

  Widget buildActivation() {
    if (_menuController.state != RadialMenuState.activating &&
        _menuController.state != RadialMenuState.dissipating) {
      return Container();
    }

    double startAngle;
    double endAngle;
    double radius = 75.0;
    double opacity = 1.0;
    if (_menuController.state == RadialMenuState.activating) {
      startAngle = -pi / 2;
      endAngle = (2 * pi) * _menuController.progress + startAngle;
    } else if (_menuController.state == RadialMenuState.dissipating) {
      startAngle = -pi / 2;
      endAngle = 2 * pi;

      radius = widget.radius * (1.0 + (0.25 * _menuController.progress));
      opacity = 1.0 - _menuController.progress;
    }

    return CenterAbout(
      position: widget.anchor,
      child: Opacity(
        opacity: opacity,
        child: CustomPaint(
          painter: ActivationPainter(
            radius: radius,
            color: Colors.blue,
            startAngle: startAngle,
            endAngle: endAngle,
            thickness: 50.0,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        // Center
        buildCenter(),

        // Radial bubbles
        buildRadialBubble(
          icon: Icons.home,
          iconColor: Colors.white,
          bubbleColor: Colors.blue,
          angle: -pi / 2,
        ),

        buildRadialBubble(
          icon: Icons.search,
          iconColor: Colors.white,
          bubbleColor: Colors.green,
          angle: -pi / 2 + (1 * 2 * pi / 5),
        ),

        buildRadialBubble(
          icon: Icons.alarm,
          iconColor: Colors.white,
          bubbleColor: Colors.red,
          angle: -pi / 2 + (2 * 2 * pi / 5),
        ),

        buildRadialBubble(
          icon: Icons.settings,
          iconColor: Colors.white,
          bubbleColor: Colors.purple,
          angle: -pi / 2 + (3 * 2 * pi / 5),
        ),

        buildRadialBubble(
          icon: Icons.location_on,
          iconColor: Colors.white,
          bubbleColor: Colors.orange,
          angle: -pi / 2 + (4 * 2 * pi / 5),
        ),

        buildActivation(),
      ],
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

  RadialMenuController({
    @required TickerProvider vsync,
  }) : _progress = AnimationController(vsync: vsync) {
    _progress
      ..addListener(_onProgressUpdate)
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          _onTransitionCompleted();
        }
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
        _progress.duration = Duration(milliseconds: 250);
        _progress.forward(from: 0.0);
        break;
      case RadialMenuState.dissipating:
        _state = RadialMenuState.open;
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

  void open() {
    if (state == RadialMenuState.closed) {
      _state = RadialMenuState.opening;
      _progress.duration = Duration(milliseconds: 250);
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
      _progress.duration = Duration(milliseconds: 150);
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
