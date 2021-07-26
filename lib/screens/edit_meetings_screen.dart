import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:attendy/providers/auth.dart';
import 'dart:async';
import 'package:attendy/models/meeting.dart';
import 'package:attendy/providers/meetings.dart';
import 'package:attendy/screens/admin_screen.dart';
import 'package:attendy/screens/posts_screen.dart';
import 'package:attendy/widgets/TextFieldContainer.dart';

class EditMeetingsScreen extends StatefulWidget {
  static const routeName = '/edit_meetings_screen';
  @override
  _EditMeetingsScreenState createState() => _EditMeetingsScreenState();
}

class _EditMeetingsScreenState extends State<EditMeetingsScreen> {
  final Auth _auth = Auth();

  final _textFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();

  var _editedMeeting = Meeting(
    id: null,
    creatorId: '',
    date: '',
    start: '',
    length: '',
    desc: '',
    address: '',
  );
  var _initValues = {
    'creatorId': '',
    'date': '',
    'start': '',
    'length': '',
    'desc': '',
    'address': '',
  };
  var _isInit = true;
  var _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final meetingId = ModalRoute.of(context).settings.arguments as String;
      if (meetingId != null) {
        _editedMeeting =
            Provider.of<Meetings>(context, listen: false).findById(meetingId);
        _initValues = {
          'creatorId': _editedMeeting.creatorId,
          'date': _editedMeeting.date,
          'start': _editedMeeting.start,
          'length': _editedMeeting.length,
          'desc': _editedMeeting.desc,
          'address': _editedMeeting.address,
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

    if (_editedMeeting.id != null) {
      // Provider.of<Posts>(context, listen: false).updateProduct(_editedPost.id, _editedPost);
      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pop();
    } else {
      try {
        await Provider.of<Meetings>(context, listen: false)
            .addMeeting(_editedMeeting);
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
        title: Text(
          'Add New Meeting',
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.of(context).pushNamed(AdminScreen.routeName);
            }),
        backgroundColor: Colors.white,
        actions: <Widget>[
          IconButton(
              icon: Icon(
                Icons.done,
                color: Colors.black,
              ),
              onPressed: _saveForm),
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
                        keyboardType: TextInputType.datetime,
                        initialValue: _initValues['start'],
                        decoration: InputDecoration(
                            icon: Icon(
                              Icons.alarm_add_outlined,
                              color: Colors.grey[400],
                            ),
                            hintText: 'starts at',
                            border: InputBorder.none),
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
                          _editedMeeting = Meeting(
                            start: value,
                            date: _editedMeeting.date,
                            desc: _editedMeeting.desc,
                            length: _editedMeeting.length,
                            address: _editedMeeting.address,
                            id: _editedMeeting.id,
                            creatorId: _auth.userId,
                          );
                        },
                      ),
                    ),
                    TextFieldContainer(
                      child: TextFormField(
                        keyboardType: TextInputType.datetime,
                        initialValue: _initValues['date'],
                        decoration: InputDecoration(
                            icon: Icon(
                              Icons.date_range_rounded,
                              color: Colors.grey[400],
                            ),
                            hintText: 'date',
                            border: InputBorder.none),
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
                          _editedMeeting = Meeting(
                            start: _editedMeeting.start,
                            date: value,
                            desc: _editedMeeting.desc,
                            length: _editedMeeting.length,
                            address: _editedMeeting.address,
                            id: _editedMeeting.id,
                            creatorId: _auth.userId,
                          );
                        },
                      ),
                    ),
                    TextFieldContainer(
                      child: TextFormField(
                        keyboardType: TextInputType.text,
                        initialValue: _initValues['desc'],
                        decoration: InputDecoration(
                            icon: Icon(
                              Icons.help_outline,
                              color: Colors.grey[400],
                            ),
                            hintText: 'describtion',
                            border: InputBorder.none),
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
                          _editedMeeting = Meeting(
                            start: _editedMeeting.start,
                            date: _editedMeeting.date,
                            desc: value,
                            length: _editedMeeting.length,
                            address: _editedMeeting.address,
                            id: _editedMeeting.id,
                            creatorId: _auth.userId,
                          );
                        },
                      ),
                    ),
                    TextFieldContainer(
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        initialValue: _initValues['length'],
                        decoration: InputDecoration(
                            icon: Icon(
                              Icons.timer,
                              color: Colors.grey[400],
                            ),
                            hintText: 'length',
                            border: InputBorder.none),
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
                          _editedMeeting = Meeting(
                            start: _editedMeeting.start,
                            date: _editedMeeting.date,
                            desc: _editedMeeting.desc,
                            length: value,
                            address: _editedMeeting.address,
                            id: _editedMeeting.id,
                            creatorId: _auth.userId,
                          );
                        },
                      ),
                    ),
                    TextFieldContainer(
                      child: TextFormField(
                        keyboardType: TextInputType.datetime,
                        initialValue: _initValues['address'],
                        decoration: InputDecoration(
                            icon: Icon(
                              Icons.room,
                              color: Colors.grey[400],
                            ),
                            hintText: 'address',
                            border: InputBorder.none),
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
                          _editedMeeting = Meeting(
                            start: _editedMeeting.start,
                            date: _editedMeeting.date,
                            desc: _editedMeeting.desc,
                            length: _editedMeeting.length,
                            address: value,
                            id: _editedMeeting.id,
                            creatorId: _auth.userId,
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 20, right: 100.0, left: 100),
                      child: FlatButton(
                        padding: EdgeInsets.all(14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        color: Colors.blueAccent,
                        onPressed: _saveForm,
                        child: Row(
                          children: [
                            Icon(
                              Icons.done,
                              color: Colors.white,
                              size: 30,
                            ),
                            SizedBox(width: 20),
                            Expanded(
                                child: Text(
                              'save',
                              style: TextStyle(
                                  fontSize: 23,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            )),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
