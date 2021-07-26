import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:attendy/providers/attendanceHistories.dart';
import 'dart:io';
import 'package:attendy/providers/auth.dart';
import 'package:attendy/screens/edit_meetings_screen.dart';
import 'package:attendy/screens/new_posts_screen.dart';
import 'package:attendy/widgets/employee_history_item.dart';
import 'package:attendy/providers/employees.dart';
import 'package:attendy/providers/users.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:attendy/widgets/profile_button.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../mobile.dart' if (dart.library.html) 'web.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;

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

  File _imageFile;
  final picker = ImagePicker();
  var _isLoading = false;
  static var _showButton = false;
  SharedPreferences preferences;
  String _imageDownloadUrl;

  Future<void> _refreshHistory(BuildContext context) async {
    await Provider.of<AttendanceHistories>(context, listen: false)
        .fetchAttendanceHistory();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context, listen: false);
    final historiesData = Provider.of<AttendanceHistories>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("profile",
            style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.bold,
                color: Colors.black)),
        backgroundColor: Colors.white,
        actions: <Widget>[
          IconButton(
              icon: Icon(
                Icons.exit_to_app,
                color: Colors.black,
              ),
              onPressed: () {
                Provider.of<Auth>(context, listen: false).logout();
              })
        ],
      ),
      body: Column(
        children: <Widget>[
          FutureBuilder(
              future:
                  Provider.of<Employees>(context).getCreatoreInfo(auth.userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Column(
                    children: [
                      SizedBox(height: 20),
                      CircleAvatar(
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
                      SizedBox(height: 10),
                      _showButton
                          ? FlatButton(
                              onPressed: () {
                                _updateProfileImage(auth.userId);
                              },
                              color: Colors.blueAccent,
                              child: Text("upload"))
                          : SizedBox(height: 10),
                      Center(
                          child: Text(snapshot.data['username'],
                              style: TextStyle(
                                  fontSize: 20, color: Colors.black))),
                      SizedBox(height: 10),
                      Center(
                          child: Text(snapshot.data['email'],
                              style: TextStyle(
                                  fontSize: 20, color: Colors.black))),
                      SizedBox(height: 10),
                      Container(
                        width: 320,
                        child: Row(
                          children: [
                            ProfileButton(
                                Icons.print_rounded,
                                'pdf',
                                Colors.blueAccent,
                                () => {_createPDF(historiesData)}),
                            Spacer(),
                            ProfileButton(
                                Icons.add,
                                'post',
                                Colors.blueAccent,
                                () => {
                                      Navigator.of(context)
                                          .pushNamed(NewPostsScreen.routeName)
                                    }),
                            Spacer(),
                            snapshot.data['job'] == 'manager'
                                ? ProfileButton(
                                    Icons.settings,
                                    'admin',
                                    Colors.blueAccent,
                                    () => {
                                          Navigator.of(context).pushNamed(
                                              EditMeetingsScreen.routeName)
                                        })
                                : ProfileButton(
                                    Icons.account_box_rounded,
                                    'job',
                                    Colors.blueAccent,
                                    () => {
                                          Navigator.of(context).pushNamed(
                                              NewPostsScreen.routeName)
                                        })
                          ],
                        ),
                      ),
                    ],
                  );
                } else {
                  return Container(
                      height: 225,
                      child: Center(child: CircularProgressIndicator()));
                }
              }),
          Divider(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _refreshHistory(context),
              child: Padding(
                padding: EdgeInsets.all(10),
                child: ListView.builder(
                  //shrinkWrap: true,
                  //physics: NeverScrollableScrollPhysics(),
                  itemCount: historiesData.items.length,
                  itemBuilder: (_, i) => Column(
                    children: [
                      EmployeeHistoryItem(
                        historiesData.items[i].id,
                        historiesData.items[i].employeeId,
                        historiesData.items[i].startTime,
                        historiesData.items[i].endTime,
                        historiesData.items[i].date,
                      ),
                      Divider(),
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
      floatingActionButton: Container(
        height: 100,
        width: 100,
        child: Center(
          child: TextButton(
              style: TextButton.styleFrom(
                  alignment: Alignment.center,
                  primary: Colors.white,
                  backgroundColor: Colors.red,
                  textStyle:
                      TextStyle(fontSize: 24, fontStyle: FontStyle.normal)),
              child: Row(
                children: [
                  const Icon(
                    Icons.multiple_stop_sharp,
                    color: Colors.white,
                  ),
                  Text('leave')
                ],
              ),
              onPressed: () async {
                // Navigator.of(context).pushNamed(ProfileScreen.routeName);
                await Provider.of<Employees>(context, listen: false)
                    .updateEmployeeStatus(auth.userId, 'offline');
                await Provider.of<AttendanceHistories>(context, listen: false)
                    .updateAttendanceEndTime(auth.userId);
              }),
        ),
      ),
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

  Future<void> _createPDF(historiesData) async {
    PdfDocument document = PdfDocument();

    PdfGrid grid = PdfGrid();

    grid.style = PdfGridStyle(
        font: PdfStandardFont(PdfFontFamily.helvetica, 12),
        cellPadding: PdfPaddings(left: 5, right: 2, top: 2, bottom: 2));

    grid.columns.add(count: 3);
    grid.headers.add(1);

    PdfGridRow header = grid.headers[0];
    header.cells[0].value = 'date';
    header.cells[1].value = 'start';
    header.cells[2].value = 'end';

    for (int i = 0; i <= historiesData.items.length - 1; i++) {
      PdfGridRow row = grid.rows.add();
      row.cells[0].value = historiesData.items[i].date;
      row.cells[1].value = historiesData.items[i].startTime;
      row.cells[2].value = historiesData.items[i].endTime;
    }

    //page.graphics.drawString('Imployee Information', PdfStandardFont(PdfFontFamily.helvetica, 30));

    grid.draw(
      page: document.pages.add(),
      bounds: const Rect.fromLTWH(0, 0, 0, 0),
    );

    List<int> bytes = document.save();
    document.dispose();

    saveAndLaunchFile(bytes, 'Output.pdf');
  }
}
