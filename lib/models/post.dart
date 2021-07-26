import 'package:flutter/foundation.dart';

class Post with ChangeNotifier {
  String id;
  String creatorId;
  String image;
  String text;
  String dateTime;

  Post({
    @required this.id,
    @required this.creatorId,
    @required this.image,
    @required this.text,
    @required this.dateTime,
  });
}
