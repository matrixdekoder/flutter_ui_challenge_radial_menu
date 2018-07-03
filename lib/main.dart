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
  Widget _buildMenu() {
    return IconButton(
      icon: Icon(
        Icons.cancel,
      ),
      onPressed: () {},
    );
  }

  Widget _buildCenterMenu() {
    return AnchoredRadialMenu(
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
        leading: _buildMenu(),
        title: Text(''),
        actions: <Widget>[
          _buildMenu(),
        ],
      ),
      body: Stack(
        children: <Widget>[
          // Center
          Align(
            alignment: Alignment.center,
            child: _buildCenterMenu(),
          ),

          // Middle Left
          Align(
            alignment: Alignment.centerLeft,
            child: _buildMenu(),
          ),

          // Middle Right
          Align(
            alignment: Alignment.centerRight,
            child: _buildMenu(),
          ),

          // Bottom Left
          Align(
            alignment: Alignment.bottomLeft,
            child: _buildMenu(),
          ),

          // Bottom Right
          Align(
            alignment: Alignment.bottomRight,
            child: _buildMenu(),
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
        CenterAbout(
          position: widget.anchor,
          child: IconBubble(
            icon: Icons.clear,
            diameter: 50.0,
            bubbleColor: Color(0xFFAAAAAA),
            iconColor: Colors.black,
          ),
        ),

        // Radial Bubbles
        PolarPosition(
          origin: widget.anchor,
          coord: PolarCoord(-pi / 2, widget.radius),
          child: IconBubble(
            icon: Icons.home,
            diameter: 50.0,
            bubbleColor: Colors.blue,
            iconColor: Colors.white,
          ),
        ),

        PolarPosition(
          origin: widget.anchor,
          coord: PolarCoord(-pi / 2 + (1 * 2 * pi / 5), widget.radius),
          child: IconBubble(
            icon: Icons.search,
            diameter: 50.0,
            bubbleColor: Colors.green,
            iconColor: Colors.white,
          ),
        ),

        PolarPosition(
          origin: widget.anchor,
          coord: PolarCoord(-pi / 2 + (2 * 2 * pi / 5), widget.radius),
          child: IconBubble(
            icon: Icons.alarm,
            diameter: 50.0,
            bubbleColor: Colors.red,
            iconColor: Colors.white,
          ),
        ),

        PolarPosition(
          origin: widget.anchor,
          coord: PolarCoord(-pi / 2 + (3 * 2 * pi / 5), widget.radius),
          child: IconBubble(
            icon: Icons.settings,
            diameter: 50.0,
            bubbleColor: Colors.purple,
            iconColor: Colors.white,
          ),
        ),

        PolarPosition(
          origin: widget.anchor,
          coord: PolarCoord(-pi / 2 + (4 * 2 * pi / 5), widget.radius),
          child: IconBubble(
            icon: Icons.location_on,
            diameter: 50.0,
            bubbleColor: Colors.orange,
            iconColor: Colors.white,
          ),
        ),

        CenterAbout(
          position: widget.anchor,
          child: CustomPaint(
            painter: ActivationPainter(
              radius: widget.radius,
              thickness: 50.0,
              color: Colors.blue,
              startAngle: -pi / 2,
              endAngle: -pi / 2 + pi,
            ),
          ),
        )
      ],
    );
  }
}

class ActivationPainter extends CustomPainter {
  final double radius;
  final double thickness;
  final Color color;
  final double startAngle;
  final double endAngle;
  final Paint activationPaint;

  ActivationPainter({
    this.radius,
    this.thickness,
    this.color,
    this.startAngle,
    this.endAngle,
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
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
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
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bubbleColor,
      ),
      child: Icon(
        icon,
        color: iconColor,
      ),
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
