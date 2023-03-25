import 'dart:math';

import 'package:alalameya_api/Screens/contacts.dart';
import 'package:alalameya_api/main.dart';
import 'package:alalameya_api/Screens/products.dart';
import 'package:alalameya_api/Screens/projects.dart';
import 'package:flutter/material.dart';

int enableBottom = 0;

class BottomBar extends StatefulWidget {
  final int bottmBarIndex;
  const BottomBar({
    Key? key,
    required this.bottmBarIndex
  }) : super(key: key);

  @override
  _BottomBarState createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {

  @override
  Widget build(BuildContext context) {
    setState(() {
      enableBottom = widget.bottmBarIndex;
    });
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      unselectedItemColor: Colors.amber,
      currentIndex: enableBottom,
      fixedColor: Colors.amber,
      onTap: (value) async {
        if (widget.bottmBarIndex != value) {
          if (value == 0) {
            Navigator.popAndPushNamed(context, Products.id);
          }else if (value == 1) {
            Navigator.popAndPushNamed(context, Contacts.id);
          }else if (value == 2) {
            Navigator.popAndPushNamed(context, Project.id);
          }else if (value == 3) {
            Navigator.popAndPushNamed(context, HomePage.id);
          }
        }
      },
      items: [
        BottomNavigationBarItem(
            icon: Icon(Icons.production_quantity_limits_outlined), label: "Products"),
        BottomNavigationBarItem(
            icon: Icon(Icons.contact_emergency_outlined), label: "Contacts"),
        BottomNavigationBarItem(
            icon: Icon(Icons.create_new_folder_outlined), label: "Projects"),
        BottomNavigationBarItem(
            icon: Icon(Icons.logout), label: "Logout"),
      ],
    );
  }
}
