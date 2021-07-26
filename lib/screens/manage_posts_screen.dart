import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:attendy/providers/posts.dart';
import 'package:attendy/widgets/manage_post_item.dart';

class ManagePostsScreen extends StatefulWidget {
  static const routeName = '/posts_screen';
  @override
  _ManagePostsScreenState createState() => _ManagePostsScreenState();
}

class _ManagePostsScreenState extends State<ManagePostsScreen> {
  Future<void> _refreshHistory(BuildContext context) async {
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
      Provider.of<Posts>(context).fetchPosts().then((_) {
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
    final postData = Provider.of<Posts>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Manage Posts',
            style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: Colors.black)),
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            }),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: RefreshIndicator(
                onRefresh: () => _refreshHistory(context),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: ListView.separated(
                      itemCount: postData.items.length,
                      itemBuilder: (context, i) {
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          height: 400,
                          child: ManagePostItem(
                            postData.items[i].id,
                            postData.items[i].creatorId,
                            postData.items[i].text,
                            postData.items[i].image,
                            postData.items[i].dateTime,
                          ),
                        );
                      },
                      separatorBuilder: (context, index) => Divider(),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
