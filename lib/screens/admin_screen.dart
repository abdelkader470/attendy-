import 'package:flutter/material.dart';
import 'package:attendy/screens/edit_meetings_screen.dart';
import 'package:attendy/screens/home_screen.dart';
import 'package:attendy/screens/manage_posts_screen.dart';
import 'package:attendy/screens/today_attendance.dart';
import 'package:attendy/widgets/admin_item.dart';

class AdminScreen extends StatelessWidget {
  static const routeName = '/admin_screen';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Page",
            style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.bold,
                color: Colors.black)),
        backgroundColor: Colors.white,
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.of(context).pushNamed(HomeScreen.routeName);
            }),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView(
          padding: const EdgeInsets.all(7.0),
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: [
            AdminItem(
              title: 'manage posts',
              titleColor: Colors.white,
              backgrounColor: Colors.purple[200],
              iconColor: Colors.white,
              icon: Icons.note_alt_rounded,
              press: () => {
                Navigator.of(context).pushNamed(ManagePostsScreen.routeName)
              },
            ),
            AdminItem(
              title: 'add meetings',
              titleColor: Colors.white,
              backgrounColor: Colors.blueAccent,
              iconColor: Colors.white,
              icon: Icons.group_add_rounded,
              press: () => {
                Navigator.of(context).pushNamed(EditMeetingsScreen.routeName)
              },
            ),
            AdminItem(
              title: 'attendance',
              titleColor: Colors.white,
              backgrounColor: Colors.green[400],
              iconColor: Colors.white,
              icon: Icons.history_rounded,
              press: () => {
                Navigator.of(context)
                    .pushNamed(TodayAttendanceHistoryScreen.routeName)
              },
            ),
            AdminItem(
              title: 'events',
              titleColor: Colors.white,
              backgrounColor: Colors.redAccent[200],
              iconColor: Colors.white,
              icon: Icons.event_note_rounded,
              press: () => {},
            ),
          ],
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.5 / 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
          ),
        ),
      ),
    );
  }
}
