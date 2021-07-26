import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:attendy/providers/posts.dart';
import 'package:attendy/widgets/post_item.dart';

class PostsScreen extends StatefulWidget {
  static const routeName = '/posts-screen';
  @override
  _PostsScreenState createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  Future<void> _refreshposts(BuildContext context) async {
    await Provider.of<Posts>(context, listen: false).fetchPosts();
  }

  var _isInit = true;
  var _isLoading = false;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<Posts>(context, listen: false).fetchPosts().then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final postsData = Provider.of<Posts>(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              'Next Company',
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            Text(
              'timeline posts',
              style: TextStyle(
                  fontSize: 13,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        actions: <Widget>[],
      ),
      body: Container(
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () => _refreshposts(context),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(6),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: postsData.items.length,
                      itemBuilder: (_, i) => Column(
                        children: [
                          PostItem(
                            postsData.items[i].id,
                            postsData.items[i].creatorId,
                            postsData.items[i].text,
                            postsData.items[i].image,
                            postsData.items[i].dateTime,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
