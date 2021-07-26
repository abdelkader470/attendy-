import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:attendy/providers/meetings.dart';
import 'package:attendy/widgets/meeting_grid.dart';

class MeetingsScreen extends StatefulWidget {
  static const routeName = '/meetings_screen';
  @override
  _MeetingsScreenState createState() => _MeetingsScreenState();
}

class _MeetingsScreenState extends State<MeetingsScreen> {
  var _isInit = true;
  var _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<Meetings>(context, listen: false).fetchMeetings().then((_) {
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Acctive Meetings',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: RefreshIndicator(
                  onRefresh: () => _refresh(context),
                  child: Column(
                    children: <Widget>[
                      MeetingsGrid(),
                    ],
                  ))),
    );
  }

  Future<void> _refresh(BuildContext context) async {
    await Provider.of<Meetings>(context).fetchMeetings();
  }
}
