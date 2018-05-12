import 'package:flutter/material.dart';
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

  RadialMenu({
    this.anchor,
  });

  @override
  _RadialMenuState createState() => new _RadialMenuState();
}

class _RadialMenuState extends State<RadialMenu> {
  @override
  Widget build(BuildContext context) {
    return new CenterAbout(
      position: widget.anchor,
      child: new Container(
        width: 50.0,
        height: 50.0,
        color: Colors.red,
      ),
    );
  }
}
