import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

final demoMenu = new Menu(items: [
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
