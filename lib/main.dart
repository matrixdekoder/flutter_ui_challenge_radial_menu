import 'package:flutter/material.dart';

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
            child: _buildMenu(),
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
