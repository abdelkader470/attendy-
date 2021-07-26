import 'package:attendy/screens/posts_screen.dart';
import 'package:flutter/material.dart';
import 'package:attendy/screens/finger_print.dart';
import 'package:attendy/screens/meetings_screen.dart';
import 'package:attendy/screens/products_overview_screen.dart';
import 'package:attendy/screens/profile_screen.dart';

enum FilterOptions {
  Favorites,
  All,
}

class HomeScreen extends StatefulWidget {
  static const routeName = '/home_screen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var _isInit = true;
  var _isLoading = false;
  bool isManager;
  PageController pageController = PageController();

  List<Widget> screens = [
    PostsScreen(),
    ProductsOverviewScreen(),
    FingerprintPage(),
    MeetingsScreen(),
    ProfileScreen(),
  ];

  int selectedIndex = 0;

  void _onPageChanged(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  void _onItemTapped(int selectedIndex) {
    pageController.jumpToPage(selectedIndex);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : PageView(
              controller: pageController,
              children: screens,
              onPageChanged: _onPageChanged,
              physics: NeverScrollableScrollPhysics(),
            ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded,
                  size: 30,
                  color: selectedIndex == 0 ? Colors.black : Colors.black54),
              label: ''),
          BottomNavigationBarItem(
              icon: Icon(Icons.people_alt_outlined,
                  size: 30,
                  color: selectedIndex == 1 ? Colors.black : Colors.black54),
              label: ''),
          BottomNavigationBarItem(
              icon: Icon(Icons.fingerprint,
                  size: 30,
                  color: selectedIndex == 2 ? Colors.black : Colors.black54),
              label: ''),
          BottomNavigationBarItem(
              icon: Icon(Icons.groups,
                  size: 30,
                  color: selectedIndex == 3 ? Colors.black : Colors.black54),
              label: ''),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_circle,
                  size: 30,
                  color: selectedIndex == 4 ? Colors.black : Colors.black54),
              label: ''),
        ],
        onTap: _onItemTapped,
        iconSize: 35,
      ),
    );
  }
}
