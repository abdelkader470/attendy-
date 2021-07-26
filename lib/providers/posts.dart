import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:attendy/models/http_exception.dart';
import 'package:attendy/models/post.dart';

class Posts with ChangeNotifier {
  List<Post> _items = [];
  final String authToken;
  final String userId;

  Posts(this.authToken, this.userId, this._items);

  List<Post> get items {
    return [..._items];
  }

  Post findById(String id) {
    return _items.firstWhere((post) => post.id == id);
  }

  Future<Map<String, dynamic>> getCreatoreInfo(String creatoreId) async {
    final userUrl = Uri.parse(
        'https://shop-app-6a71c-default-rtdb.firebaseio.com/users.json?auth=$authToken&orderBy="id"&equalTo="$creatoreId"');
    final userResponse = await http.get(userUrl);
    final extractedData =
        json.decode(userResponse.body) as Map<String, dynamic>;

    Map<String, dynamic> userUserrname;
    extractedData.forEach((userId, username) {
      userUserrname = username;
    });

    return userUserrname;
  }

  Future<void> fetchPosts() async {
    final url = Uri.parse(
        'https://shop-app-6a71c-default-rtdb.firebaseio.com/posts.json?auth=$authToken');
    final response = await http.get(url);

    final List<Post> loadedPosts = [];
    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    if (extractedData == null) {
      return;
    }
    extractedData.forEach((postId, postData) {
      loadedPosts.add(
        Post(
            id: postId,
            creatorId: postData['creatorId'],
            text: postData['text'],
            image: postData['image'],
            dateTime: postData['dateTime']),
      );
    });
    _items = loadedPosts.reversed.toList();
    notifyListeners();
  }

  Future<void> addPost(Post post, String imageUrl) async {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('EEE d MMM').format(now);
    final url = Uri.parse(
        'https://shop-app-6a71c-default-rtdb.firebaseio.com/posts.json?auth=$authToken');
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'creatorId': userId,
          'image': imageUrl,
          'text': post.text,
          'dateTime': formattedDate
        }),
      );
      final newPost = Post(
        creatorId: post.creatorId,
        image: post.image,
        text: post.text,
        dateTime: post.dateTime,
        id: json.decode(response.body)['name'],
      );
      _items.add(newPost);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> deletePost(String id) async {
    final url = Uri.parse(
        'https://shop-app-6a71c-default-rtdb.firebaseio.com/posts/$id.json?auth=$authToken');
    final existingPostIndex = _items.indexWhere((prod) => prod.id == id);
    var existingPost = _items[existingPostIndex];
    _items.removeAt(existingPostIndex);
    notifyListeners();
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(existingPostIndex, existingPost);
      notifyListeners();
      throw HttpException('Could not delete Post.');
    }
    existingPost = null;
  }
}
