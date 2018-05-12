import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fluttery/layout.dart';
import 'package:fluttery/gestures.dart';
import 'package:radial_menu/layout.dart';

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
          leading: new IconButton(
              icon: new Icon(
                Icons.cancel,
              ),
              onPressed: () {
                showMenu(topLeft);
              }),
          title: new Text(''),
          actions: <Widget>[
            new IconButton(
                icon: new Icon(
                  Icons.cancel,
                ),
                onPressed: () {
                  showMenu(topRight);
                }),
          ],
        ),
        body: new Stack(
          children: <Widget>[
            // Left center
            new Align(
              alignment: Alignment.centerLeft,
              child: new IconButton(
                  icon: new Icon(
                    Icons.cancel,
                  ),
                  onPressed: () {
                    showMenu(middleLeft);
                  }),
            ),

            // Left bottom
            new Align(
              alignment: Alignment.bottomLeft,
              child: new IconButton(
                  icon: new Icon(
                    Icons.cancel,
                  ),
                  onPressed: () {
                    showMenu(bottomLeft);
                  }),
            ),

            // Right center
            new Align(
              alignment: Alignment.centerRight,
              child: new IconButton(
                  icon: new Icon(
                    Icons.cancel,
                  ),
                  onPressed: () {
                    showMenu(middleRight);
                  }),
            ),

            // Right bottom
            new Align(
              alignment: Alignment.bottomRight,
              child: new IconButton(
                  icon: new Icon(
                    Icons.cancel,
                  ),
                  onPressed: () {
                    showMenu(bottomRight);
                  }),
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

class AnchoredRadialMenu extends StatefulWidget {
  final Widget child;

  AnchoredRadialMenu({
    this.child,
  });

  @override
  _AnchoredRadialMenuState createState() => new _AnchoredRadialMenuState();
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
  final double bubbleSize;
  final double radius;
  final double startAngle;
  final double endAngle;

  RadialMenu({
    this.anchor,
    this.bubbleSize = 50.0,
    this.radius = 75.0,
    this.startAngle = -pi / 2, // default to top of unit circle
    this.endAngle = 2 * pi - (pi / 2), // default to top of unit circle + 360 degrees
  });

  @override
  _RadialMenuState createState() => new _RadialMenuState();
}

class _RadialMenuState extends State<RadialMenu> {
  @override
  Widget build(BuildContext context) {
    return new Stack(
      children: <Widget>[
        // Center
        new CenterAbout(
          position: widget.anchor,
          child: new IconBubble(
            icon: Icons.clear,
            diameter: 50.0,
            foregroundColor: Colors.black,
            backgroundColor: const Color(0xFFAAAAAA),
          ),
        ),

        // Radial
        new PolarPosition(
          origin: widget.anchor,
          coord: new PolarCoord(-pi / 2, widget.radius),
          child: new IconBubble(
            icon: Icons.home,
            diameter: 50.0,
            foregroundColor: Colors.white,
            backgroundColor: Colors.blue,
          ),
        ),

        new PolarPosition(
          origin: widget.anchor,
          coord: new PolarCoord(-pi / 2 + (1 * 2 * pi / 5), widget.radius),
          child: new IconBubble(
            icon: Icons.search,
            diameter: 50.0,
            foregroundColor: Colors.white,
            backgroundColor: Colors.green,
          ),
        ),

        new PolarPosition(
          origin: widget.anchor,
          coord: new PolarCoord(-pi / 2 + (2 * 2 * pi / 5), widget.radius),
          child: new IconBubble(
            icon: Icons.alarm,
            diameter: 50.0,
            foregroundColor: Colors.white,
            backgroundColor: Colors.red,
          ),
        ),

        new PolarPosition(
          origin: widget.anchor,
          coord: new PolarCoord(-pi / 2 + (3 * 2 * pi / 5), widget.radius),
          child: new IconBubble(
            icon: Icons.settings,
            diameter: 50.0,
            foregroundColor: Colors.white,
            backgroundColor: Colors.purple,
          ),
        ),

        new PolarPosition(
          origin: widget.anchor,
          coord: new PolarCoord(-pi / 2 + (4 * 2 * pi / 5), widget.radius),
          child: new IconBubble(
            icon: Icons.location_on,
            diameter: 50.0,
            foregroundColor: Colors.white,
            backgroundColor: Colors.orange,
          ),
        ),
      ],
    );
  }
}

class IconBubble extends StatelessWidget {
  final IconData icon;
  final double diameter;
  final Color foregroundColor;
  final Color backgroundColor;

  IconBubble({
    this.icon,
    this.diameter,
    this.foregroundColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return new Bubble(
      diameter: diameter,
      backgroundColor: backgroundColor,
      child: new Icon(
        icon,
        color: foregroundColor,
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
