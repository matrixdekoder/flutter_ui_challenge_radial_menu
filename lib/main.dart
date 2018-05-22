import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:radial_menu/radial_menu.dart';

void main() {
  timeDilation = 1.0;
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
              child: new LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return new AnchoredRadialMenu(
                    child: new IconButton(
                        icon: new Icon(
                          Icons.cancel,
                        ),
                        onPressed: () {
                          showMenu(center);
                        }),
                    onSelected: (String itemId) {
                      final snackBar = new SnackBar(
                        content: new Text(
                          'Selected item: $itemId',
                          textAlign: TextAlign.center,
                        ),
                      );
                      Scaffold.of(context).showSnackBar(snackBar);
                    },
                  );
                },
              ),
            ),

            // Tap to place menu
            new ClickPlacementRadialMenu(),
          ],
        ));
  }
}
