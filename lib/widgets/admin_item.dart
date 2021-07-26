import 'package:flutter/material.dart';

class AdminItem extends StatelessWidget {
  const AdminItem({
    @required this.title,
    @required this.titleColor,
    @required this.backgrounColor,
    @required this.icon,
    @required this.iconColor,
    this.press,
  });
  final String title;
  final Color titleColor;
  final Color backgrounColor;
  final IconData icon;
  final Color iconColor;
  final VoidCallback press;

  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: GridTile(
        child: GestureDetector(
            onTap: this.press,
            child: Container(
              color: backgrounColor,
              child: Icon(icon, size: 150, color: iconColor),
            )),
        footer: GridTileBar(
          title: Center(
            child: Text(
              title,
              style: TextStyle(fontSize: 20, color: titleColor),
            ),
          ),
        ),
      ),
    );
  }
}
