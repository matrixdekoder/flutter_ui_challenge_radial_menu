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

  RadialMenu({
    this.anchor,
    this.radius = 75.0,
  });

  @override
  _RadialMenuState createState() => _RadialMenuState();
}

class _RadialMenuState extends State<RadialMenu> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        // Center
        CenterAbout(
          position: widget.anchor,
          child: IconBubble(
            icon: Icons.clear,
            diameter: 50.0,
            iconColor: Colors.black,
            bubbleColor: Color(0xFFAAAAAA),
          ),
        ),

        // Radial bubbles
        PolarPosition(
          origin: widget.anchor,
          coord: PolarCoord(-pi / 2, widget.radius),
          child: IconBubble(
            icon: Icons.home,
            diameter: 50.0,
            iconColor: Colors.white,
            bubbleColor: Colors.blue,
          ),
        ),

        PolarPosition(
          origin: widget.anchor,
          coord: PolarCoord(-pi / 2 + (1 * 2 * pi / 5), widget.radius),
          child: IconBubble(
            icon: Icons.search,
            diameter: 50.0,
            iconColor: Colors.white,
            bubbleColor: Colors.green,
          ),
        ),

        PolarPosition(
          origin: widget.anchor,
          coord: PolarCoord(-pi / 2 + (2 * 2 * pi / 5), widget.radius),
          child: IconBubble(
            icon: Icons.alarm,
            diameter: 50.0,
            iconColor: Colors.white,
            bubbleColor: Colors.red,
          ),
        ),

        PolarPosition(
          origin: widget.anchor,
          coord: PolarCoord(-pi / 2 + (3 * 2 * pi / 5), widget.radius),
          child: IconBubble(
            icon: Icons.settings,
            diameter: 50.0,
            iconColor: Colors.white,
            bubbleColor: Colors.purple,
          ),
        ),

        PolarPosition(
          origin: widget.anchor,
          coord: PolarCoord(-pi / 2 + (4 * 2 * pi / 5), widget.radius),
          child: IconBubble(
            icon: Icons.location_on,
            diameter: 50.0,
            iconColor: Colors.white,
            bubbleColor: Colors.orange,
          ),
        ),

        CenterAbout(
          position: widget.anchor,
          child: CustomPaint(
            painter: ActivationPainter(
              radius: 75.0,
              color: Colors.blue,
              startAngle: -pi / 2,
              endAngle: pi,
              thickness: 50.0,
            ),
          ),
        ),
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

  IconBubble({
    this.icon,
    this.diameter,
    this.iconColor,
    this.bubbleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Bubble(
      diameter: diameter,
      backgroundColor: bubbleColor,
      child: new Icon(
        icon,
        color: iconColor,
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
