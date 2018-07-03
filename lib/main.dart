import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fluttery/animations.dart';
import 'package:fluttery/layout.dart';

void main() => runApp(new MyApp());

final Menu demoMenu = Menu(items: [
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
      menu: demoMenu,
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
  final Menu menu;
  final Widget child;

  AnchoredRadialMenu({
    this.menu,
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
          menu: widget.menu,
          anchor: anchor,
        );
      },
      child: widget.child,
    );
  }
}

class RadialMenu extends StatefulWidget {
  final Menu menu;
  final Offset anchor;
  final double radius;

  RadialMenu({
    this.menu,
    this.anchor,
    this.radius = 75.0,
  });

  @override
  _RadialMenuState createState() => _RadialMenuState();
}

class _RadialMenuState extends State<RadialMenu> with SingleTickerProviderStateMixin {
  static const Color openBubbleColor = const Color(0xFFAAAAAA);
  static const Color expandedBubbleColor = const Color(0xFF666666);

  RadialMenuController _menuController;

  @override
  void initState() {
    super.initState();

    _menuController = RadialMenuController(
      vsync: this,
    )..addListener(() => setState(() {}));

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
        bubbleColor = openBubbleColor;
        scale = 0.0;
        break;
      case RadialMenuState.closing:
        icon = Icons.menu;
        bubbleColor = openBubbleColor;
        scale = 1.0 - _menuController.progress;
        break;
      case RadialMenuState.opening:
        icon = Icons.menu;
        bubbleColor = openBubbleColor;
        scale = _menuController.progress;
        break;
      case RadialMenuState.open:
        icon = Icons.menu;
        bubbleColor = openBubbleColor;
        scale = 1.0;
        onPressed = () {
          _menuController.expand();
        };
        break;
      case RadialMenuState.expanded:
        icon = Icons.clear;
        bubbleColor = expandedBubbleColor;
        scale = 1.0;
        onPressed = () {
          _menuController.collapse();
        };
        break;
      default:
        icon = Icons.clear;
        bubbleColor = expandedBubbleColor;
        scale = 1.0;
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
          bubbleColor: bubbleColor,
          iconColor: Colors.black,
          onPressed: onPressed,
        ),
      ),
    );
  }

  List<Widget> buildRadialBubbles() {
    final double startAngle = -pi / 2;
    int index = 0;
    int itemCount = widget.menu.items.length;

    return widget.menu.items.map((MenuItem item) {
      final myAngle = startAngle + (2 * pi * (index / itemCount));
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
        angle: myAngle,
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

    double radius = widget.radius;
    double scale = 1.0;

    if (_menuController.state == RadialMenuState.expanding) {
      radius = widget.radius * _menuController.progress;
      scale = _menuController.progress;
    } else if (_menuController.state == RadialMenuState.collapsing) {
      radius = widget.radius * (1.0 - _menuController.progress);
      scale = 1.0 - _menuController.progress;
    }

    return PolarPosition(
      origin: widget.anchor,
      coord: PolarCoord(angle, radius),
      child: Transform(
        transform: Matrix4.identity()..scale(scale, scale),
        alignment: Alignment.center,
        child: IconBubble(
          icon: icon,
          diameter: 50.0,
          bubbleColor: bubbleColor,
          iconColor: iconColor,
          onPressed: () {
            _menuController.activate(id);
          },
        ),
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

    double startAngle;
    double endAngle;
    double radius = widget.radius;
    double opacity = 1.0;
    if (_menuController.state == RadialMenuState.activating) {
      startAngle = -pi / 2 + (activeIndex * 2 * pi / widget.menu.items.length);
      endAngle = (2 * pi) * _menuController.progress + startAngle;
    } else if (_menuController.state == RadialMenuState.dissipating) {
      startAngle = 0.0;
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
            thickness: 50.0,
            color: activeItem.bubbleColor,
            startAngle: startAngle,
            endAngle: endAngle,
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

    final double startAngle = -pi / 2 + (activeIndex * 2 * pi / widget.menu.items.length);
    final double currAngle = (2 * pi) * _menuController.progress + startAngle;

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
        ..addAll([
          buildCenter(),
          buildActivationRibbon(),
          buildActivationBubble(),
        ]),
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
      child: Container(
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

class RadialMenuController extends ChangeNotifier {
  final AnimationController _progress;
  RadialMenuState _state = RadialMenuState.closed;
  String _activationId;

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

  String get activationId => _activationId;

  void open() {
    if (state == RadialMenuState.closed) {
      _state = RadialMenuState.opening;
      _progress.duration = Duration(milliseconds: 250);
      _progress.forward(from: 0.0);
      notifyListeners();
    }
  }

  void close() {
    if (state == RadialMenuState.open) {
      _state = RadialMenuState.closing;
      _progress.duration = Duration(milliseconds: 250);
      _progress.forward(from: 0.0);
      notifyListeners();
    }
  }

  void expand() {
    if (state == RadialMenuState.open) {
      _state = RadialMenuState.expanding;
      _progress.duration = Duration(milliseconds: 150);
      _progress.forward(from: 0.0);
      notifyListeners();
    }
  }

  void collapse() {
    if (state == RadialMenuState.expanded) {
      _state = RadialMenuState.collapsing;
      _progress.duration = Duration(milliseconds: 150);
      _progress.forward(from: 0.0);
      notifyListeners();
    }
  }

  void activate(String menuItemId) {
    if (state == RadialMenuState.expanded) {
      _activationId = menuItemId;
      _state = RadialMenuState.activating;
      _progress.duration = Duration(milliseconds: 500);
      _progress.forward(from: 0.0);
      notifyListeners();
    }
  }
}

enum RadialMenuState {
  closed,
  closing,
  opening,
  open,
  expanding,
  collapsing,
  expanded,
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
