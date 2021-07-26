import 'package:flutter/material.dart';

class UserItem extends StatelessWidget {
  final String id;
  final String username;
  final String imageUrl;

  UserItem(this.id, this.username, this.imageUrl);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(username),
      leading: CircleAvatar(
        backgroundImage: NetworkImage(imageUrl),
      ),
    );
  }
}
