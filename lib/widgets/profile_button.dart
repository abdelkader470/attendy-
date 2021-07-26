import 'package:flutter/material.dart';

class ProfileButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback press;
  final Color color;

  ProfileButton(
    this.icon,
    this.text,
    this.color,
    this.press,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 100,
        child: TextButton(
            style: TextButton.styleFrom(
                alignment: Alignment.center,
                primary: Colors.white,
                backgroundColor: color,
                textStyle:
                    TextStyle(fontSize: 17, fontStyle: FontStyle.normal)),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                ),
                Spacer(),
                Text(text)
              ],
            ),
            onPressed: press));
  }
}
