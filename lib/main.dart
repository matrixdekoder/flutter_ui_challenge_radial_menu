import 'package:flutter/material.dart';

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
            child: IconButton(
              icon: Icon(
                Icons.cancel,
              ),
              onPressed: () {
                showMenu(center);
              },
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
