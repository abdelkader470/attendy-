import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:attendy/providers/attendanceHistories.dart';
import 'package:attendy/providers/meetings.dart';
import 'package:attendy/providers/participants.dart';
import 'package:attendy/providers/posts.dart';
import 'package:attendy/providers/users.dart';
import 'package:attendy/screens/admin_screen.dart';
import 'package:attendy/screens/attendance_history_screen.dart';
import 'package:attendy/screens/edit_meetings_screen.dart';
import 'package:attendy/screens/manage_posts_screen.dart';
import 'package:attendy/screens/meetings_screen.dart';
import 'package:attendy/screens/new_posts_screen.dart';
import 'package:attendy/screens/employee_details.dart';
import 'package:attendy/screens/home_screen.dart';
import 'package:attendy/screens/meeting_details_screen.dart';
import 'package:attendy/screens/posts_screen.dart';
import 'package:attendy/screens/profile_screen.dart';
import 'package:attendy/screens/splash_screen.dart';
import 'package:attendy/screens/today_attendance.dart';
import 'providers/employees.dart';
import './providers/auth.dart';
import './screens/auth_screen.dart';
import 'package:flutter/services.dart';
import 'package:android_alarm_manager/android_alarm_manager.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await AndroidAlarmManager.initialize();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, Employees>(
          create: (_) => Employees('', '', []),
          update: (_, auth, prevProducts) {
            return Employees(auth.token, auth.userId,
                prevProducts == null ? [] : prevProducts.items);
          },
        ),
        ChangeNotifierProxyProvider<Auth, Posts>(
          create: (_) => Posts('', '', []),
          update: (_, auth, prevPosts) {
            return Posts(auth.token, auth.userId,
                prevPosts == null ? [] : prevPosts.items);
          },
        ),
        ChangeNotifierProxyProvider<Auth, AttendanceHistories>(
          create: (_) => AttendanceHistories('', '', []),
          update: (_, auth, prevHistories) {
            return AttendanceHistories(auth.token, auth.userId,
                prevHistories == null ? [] : prevHistories.items);
          },
        ),
        ChangeNotifierProxyProvider<Auth, Users>(
          create: (_) => Users('', '', []),
          update: (_, auth, prevUsers) {
            return Users(auth.token, auth.userId,
                prevUsers == null ? [] : prevUsers.users);
          },
        ),
        ChangeNotifierProxyProvider<Auth, Meetings>(
          create: (_) => Meetings('', '', []),
          update: (_, auth, prev) {
            return Meetings(
                auth.token, auth.userId, prev == null ? [] : prev.items);
          },
        ),
        ChangeNotifierProxyProvider<Auth, Participants>(
          create: (_) => Participants('', '', []),
          update: (_, auth, prev) {
            return Participants(
                auth.token, auth.userId, prev == null ? [] : prev.items);
          },
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'MyShop',
          theme: ThemeData(
            fontFamily: 'Lato',
          ),
          home: auth.isAuth
              ? HomeScreen()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (ctx, authResultSnapshot) =>
                      authResultSnapshot.connectionState ==
                              ConnectionState.waiting
                          ? SplashScreen()
                          : AuthScreen(),
                ),
          routes: {
            EmployeeDetailScreen.routeName: (ctx) => EmployeeDetailScreen(),
            HomeScreen.routeName: (ctx) => HomeScreen(),
            MeetingDetailsScreen.routeName: (ctx) => MeetingDetailsScreen(),
            NewPostsScreen.routeName: (ctx) => NewPostsScreen(),
            EditMeetingsScreen.routeName: (ctx) => EditMeetingsScreen(),
            ProfileScreen.routeName: (ctx) => ProfileScreen(),
            PostsScreen.routeName: (ctx) => PostsScreen(),
            HistoryScreen.routeName: (ctx) => HistoryScreen(),
            TodayAttendanceHistoryScreen.routeName: (ctx) =>
                TodayAttendanceHistoryScreen(),
            AdminScreen.routeName: (ctx) => AdminScreen(),
            ManagePostsScreen.routeName: (ctx) => ManagePostsScreen(),
            MeetingsScreen.routeName: (ctx) => MeetingsScreen(),
          },
        ),
      ),
    );
  }
}
