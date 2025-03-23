import 'package:circular_menu/circular_menu.dart';
import 'package:flutter/material.dart';

class CircleMenu extends StatelessWidget {
  const CircleMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return CircularMenu(radius: 5, items: [
      CircularMenuItem(
          icon: Icons.home,
          onTap: () {
            // callback
          }),
      CircularMenuItem(
          icon: Icons.search,
          onTap: () {
            //callback
          }),
      CircularMenuItem(
          icon: Icons.settings,
          onTap: () {
            //callback
          }),
      CircularMenuItem(
          icon: Icons.star,
          onTap: () {
            //callback
          }),
      CircularMenuItem(
          icon: Icons.pages,
          onTap: () {
            //callback
          }),
    ]);
  }
}
