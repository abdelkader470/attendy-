import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:attendy/providers/attendanceHistories.dart';
import 'dart:io';
import 'package:attendy/providers/auth.dart';
import 'package:attendy/providers/employees.dart';
import 'package:attendy/screens/admin_screen.dart';
import 'package:attendy/screens/attendance_history_screen.dart';
import 'package:attendy/screens/new_posts_screen.dart';
import 'package:attendy/providers/users.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:attendy/widgets/profile_menu.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = '/Edit';
  static String id = 'ProfileScreen';

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  Future<void> _refreshScreen(BuildContext context) async {
    await Provider.of<AttendanceHistories>(context, listen: false)
        .fetchAttendanceHistory();
  }

  File _imageFile;
  final picker = ImagePicker();
  var _isLoading = false;
  static var _showButton = false;
  SharedPreferences preferences;
  String _imageDownloadUrl;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text("profile",
            style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.bold,
                color: Colors.black)),
        backgroundColor: Colors.white,
      ),
      body: FutureBuilder(
          future: Provider.of<Employees>(context).getCreatoreInfo(auth.userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return SingleChildScrollView(
                child: RefreshIndicator(
                  onRefresh: () => _refreshScreen(context),
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      CircleAvatar(
                        radius: 64,
                        backgroundColor: snapshot.data['status'] == 'online'
                            ? Colors.green[400]
                            : Colors.red,
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.black12,
                          backgroundImage: _imageFile == null
                              ? NetworkImage(snapshot.data['profileImage'])
                              : FileImage(_imageFile),
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: FlatButton(
                                onPressed: () {
                                  _openImagePicker(context);
                                },
                                child: Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                )),
                          ),
                        ),
                      ),
                      _showButton
                          ? FlatButton(
                              onPressed: () {
                                _updateProfileImage(auth.userId);
                              },
                              color: Colors.blueAccent,
                              child: Text("upload"))
                          : SizedBox(height: 10),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(snapshot.data['status'],
                              style: TextStyle(
                                fontSize: 14,
                                color: snapshot.data['status'] == 'online'
                                    ? Colors.green[400]
                                    : Colors.red,
                              )),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.account_circle_rounded,
                                color: Colors.grey,
                                size: 25,
                              ),
                              SizedBox(width: 20),
                              Text(snapshot.data['username'],
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.black)),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.email_rounded,
                                color: Colors.grey,
                                size: 25,
                              ),
                              SizedBox(width: 20),
                              Text(snapshot.data['email'],
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.black)),
                            ],
                          ),
                        ],
                      ),
                      Divider(),
                      snapshot.data['job'] == 'manager'
                          ? ProfileMenu(
                              color: Colors.lightBlueAccent,
                              text: 'admin',
                              icon: Icons.admin_panel_settings_outlined,
                              press: () => {
                                Navigator.of(context)
                                    .pushNamed(AdminScreen.routeName)
                              },
                            )
                          : ProfileMenu(
                              text: 'job',
                              icon: Icons.history_edu_rounded,
                              press: () => {
                                Navigator.of(context)
                                    .pushNamed(HistoryScreen.routeName)
                              },
                            ),
                      ProfileMenu(
                        color: Colors.red,
                        text: 'attendance history',
                        icon: Icons.history,
                        press: () => {
                          Navigator.of(context)
                              .pushNamed(HistoryScreen.routeName)
                        },
                      ),
                      ProfileMenu(
                        color: Colors.green,
                        text: 'add post',
                        icon: Icons.note_add_outlined,
                        press: () => {
                          Navigator.of(context)
                              .pushNamed(NewPostsScreen.routeName)
                        },
                      ),
                      ProfileMenu(
                        color: Colors.blueAccent,
                        text: 'leave the company',
                        icon: Icons.run_circle_outlined,
                        press: () async => {
                          await Provider.of<Employees>(context, listen: false)
                              .updateEmployeeStatus(auth.userId, 'offline'),
                          await Provider.of<AttendanceHistories>(context,
                                  listen: false)
                              .updateAttendanceEndTime(auth.userId)
                        },
                      ),
                      ProfileMenu(
                        color: Colors.red,
                        text: 'log out',
                        icon: Icons.exit_to_app_rounded,
                        press: () => {
                          Provider.of<Auth>(context, listen: false).logout()
                        },
                      )
                    ],
                  ),
                ),
              );
            } else {
              return Container(
                  height: 225,
                  child: Center(child: CircularProgressIndicator()));
            }
          }),
    );
  }

  void _getImage(BuildContext context, ImageSource source) async {
    final pickedFile = await picker.getImage(source: source, maxWidth: 400);
    setState(() {
      _imageFile = File(pickedFile.path);
      _showButton = true;
      Navigator.pop(context);
    });
  }

  void _openImagePicker(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext) {
          return Container(
            height: 160,
            padding: EdgeInsets.only(top: 5),
            child: Column(
              children: <Widget>[
                Text(
                  "choose image",
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
                    "camera",
                    style: TextStyle(color: Colors.black54, fontSize: 18),
                  ),
                ),
                Divider(),
                FlatButton(
                  onPressed: () {
                    _getImage(context, ImageSource.gallery);
                  },
                  child: Text("gallery",
                      style: TextStyle(color: Colors.black54, fontSize: 18)),
                ),
              ],
            ),
          );
        });
  }

  String url;
  Future<String> _updateProfileImage(String id) async {
    setState(() {
      _isLoading = true;
    });

    FirebaseStorage storage = FirebaseStorage.instance;

    StorageReference ref = storage.ref().child('users/$id');
    StorageUploadTask storageUploadTask = ref.putFile(_imageFile);
    StorageTaskSnapshot taskSnapshot = await storageUploadTask.onComplete;

    url = await taskSnapshot.ref.getDownloadURL();

    _imageDownloadUrl = url.toString();

    setState(() {
      _imageDownloadUrl = url.toString();
      _isLoading = false;
      _showButton = false;
    });
    await Provider.of<Users>(context).updateProfileImage(_imageDownloadUrl);
    return _imageDownloadUrl;
  }
}
