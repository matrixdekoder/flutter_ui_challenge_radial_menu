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
    return new Scaffold(
      appBar: new AppBar(
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
        return new RadialMenu(
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
          child: Container(
            width: 50.0,
            height: 50.0,
            color: Colors.red,
          ),
        ),

        // Radial bubbles
        new PolarPosition(
          origin: widget.anchor,
          coord: new PolarCoord(-pi / 2, widget.radius),
          child: new Container(
            width: 50.0,
            height: 50.0,
            color: Colors.green,
          ),
        ),

        new PolarPosition(
          origin: widget.anchor,
          coord: new PolarCoord(-pi / 2 + (1 * 2 * pi / 5), widget.radius),
          child: new Container(
            width: 50.0,
            height: 50.0,
            color: Colors.green,
          ),
        ),

        new PolarPosition(
          origin: widget.anchor,
          coord: new PolarCoord(-pi / 2 + (2 * 2 * pi / 5), widget.radius),
          child: new Container(
            width: 50.0,
            height: 50.0,
            color: Colors.green,
          ),
        ),

        new PolarPosition(
          origin: widget.anchor,
          coord: new PolarCoord(-pi / 2 + (3 * 2 * pi / 5), widget.radius),
          child: new Container(
            width: 50.0,
            height: 50.0,
            color: Colors.green,
          ),
        ),

        new PolarPosition(
          origin: widget.anchor,
          coord: new PolarCoord(-pi / 2 + (4 * 2 * pi / 5), widget.radius),
          child: new Container(
            width: 50.0,
            height: 50.0,
            color: Colors.green,
          ),
        ),
      ],
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
