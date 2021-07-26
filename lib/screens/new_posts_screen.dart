import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:attendy/providers/auth.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:attendy/models/post.dart';
import 'package:attendy/providers/posts.dart';
import 'package:attendy/screens/posts_screen.dart';
import 'package:attendy/widgets/TextFieldContainer.dart';

class NewPostsScreen extends StatefulWidget {
  static const routeName = '/new_post_screen';
  @override
  _NewPostsScreenState createState() => _NewPostsScreenState();
}

class _NewPostsScreenState extends State<NewPostsScreen> {
  final Auth _auth = Auth();
  File _imageFile;
  final picker = ImagePicker();
  String _imageDownloadUrl = '';

  final _textFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();

  var _editedPost = Post(
    id: null,
    creatorId: '',
    image: '',
    text: '',
    dateTime: '',
  );
  var _initValues = {'creatorId': '', 'image': '', 'text': '', 'dateTime': ''};
  var _isInit = true;
  var _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final postId = ModalRoute.of(context).settings.arguments as String;
      if (postId != null) {
        _editedPost =
            Provider.of<Posts>(context, listen: false).findById(postId);
        _initValues = {
          'creatorId': _editedPost.creatorId,
          'image': '',
          'text': _editedPost.text,
          'dateTime': '',
        };
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _textFocusNode.dispose();
    super.dispose();
  }

  Future<void> _saveForm() async {
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    }
    _form.currentState.save();

    setState(() {
      _isLoading = true;
    });

    if (_editedPost.id != null) {
      // Provider.of<Posts>(context, listen: false).updateProduct(_editedPost.id, _editedPost);
      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pop();
    } else {
      try {
        String imageLink = await _uploadImage();
        await Provider.of<Posts>(context, listen: false)
            .addPost(_editedPost, imageLink);
        Navigator.of(context).pushNamed(PostsScreen.routeName);
      } catch (error) {
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('An error occurred!'),
            content: Text('Something went wrong.'),
            actions: <Widget>[
              FlatButton(
                  child: Text('Okay'),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  })
            ],
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.save), onPressed: _saveForm),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _form,
                child: ListView(
                  children: <Widget>[
                    TextFieldContainer(
                      child: TextFormField(
                        initialValue: _initValues['text'],
                        decoration: InputDecoration(labelText: 'text...'),
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_textFocusNode);
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please provide a value.';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _editedPost = Post(
                              text: value,
                              image: _editedPost.image,
                              dateTime: _editedPost.dateTime,
                              id: _editedPost.id,
                              creatorId: _auth.userId);
                        },
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        _imageFile == null
                            ? SizedBox(
                                height: 20,
                              )
                            : Image.file(
                                _imageFile,
                                fit: BoxFit.cover,
                                height: 200,
                                width: MediaQuery.of(context).size.width,
                                alignment: Alignment.topCenter,
                              ),
                        OutlineButton(
                            borderSide: BorderSide(
                                color: Theme.of(context).accentColor,
                                width: 2.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(Icons.camera_alt,
                                    color: Theme.of(context).accentColor),
                                SizedBox(
                                  width: 5.0,
                                ),
                                Text(
                                  "add image",
                                  style: TextStyle(
                                      color: Theme.of(context).accentColor),
                                )
                              ],
                            ),
                            onPressed: () {
                              _openImagePicker(context);
                            }),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  void _getImage(BuildContext context, ImageSource source) async {
    final pickedFile = await picker.getImage(source: source);

    setState(() {
      _imageFile = File(pickedFile.path);
      Navigator.pop(context);
    });
  }

  void _openImagePicker(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext) {
          return Container(
            height: 200,
            padding: EdgeInsets.all(10),
            child: Column(
              children: <Widget>[
                Text(
                  "pick an image",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 23),
                ),
                SizedBox(
                  height: 5,
                ),
                FlatButton(
                  onPressed: () {
                    _getImage(context, ImageSource.camera);
                  },
                  child: Text(
                    "use camera",
                    style: TextStyle(
                        color: Theme.of(context).accentColor, fontSize: 18),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                FlatButton(
                  onPressed: () {
                    _getImage(context, ImageSource.gallery);
                  },
                  child: Text("use gallery",
                      style: TextStyle(
                          color: Theme.of(context).accentColor, fontSize: 18)),
                ),
              ],
            ),
          );
        });
  }

  String url;
  Future<String> _uploadImage() async {
    setState(() {
      _isLoading = true;
    });
    FirebaseStorage storage = FirebaseStorage.instance;

    String file = _imageFile.path;
    StorageReference ref = storage.ref().child('products/$file');
    StorageUploadTask storageUploadTask = ref.putFile(_imageFile);
    StorageTaskSnapshot taskSnapshot = await storageUploadTask.onComplete;

    url = await taskSnapshot.ref.getDownloadURL();

    _imageDownloadUrl = url.toString();
    setState(() {
      _imageDownloadUrl = url.toString();
      _isLoading = false;
    });
    return _imageDownloadUrl.toString();
  }
}
