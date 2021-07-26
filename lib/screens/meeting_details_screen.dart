import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:attendy/providers/participants.dart';
import 'package:attendy/widgets/participant_item.dart';

class MeetingDetailsScreen extends StatefulWidget {
  static const routeName = '/meeting-detail';

  @override
  _MeetingDetailsScreenState createState() => _MeetingDetailsScreenState();
}

class _MeetingDetailsScreenState extends State<MeetingDetailsScreen> {
  Future<void> _refreshHistory(BuildContext context, String meetingId) async {
    await Provider.of<Participants>(context, listen: false)
        .fetchParticipant(meetingId);
  }

  var _isInit = true;
  var _isLoading = false;
  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      final meetingId = ModalRoute.of(context).settings.arguments as String;
      Provider.of<Participants>(context).fetchParticipant(meetingId).then((_) {
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
    final meetingId = ModalRoute.of(context).settings.arguments as String;
    final participantsData = Provider.of<Participants>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Meeting Details'),
      ),
      body: Container(
        child: RefreshIndicator(
          onRefresh: () => _refreshHistory(context, meetingId),
          child: Padding(
            padding: EdgeInsets.all(10),
            child: ListView.builder(
              //shrinkWrap: true,
              //physics: NeverScrollableScrollPhysics(),
              itemCount: participantsData.items.length,
              itemBuilder: (_, i) => Column(
                children: [
                  ParticipantItem(
                    participantsData.items[i].id,
                    participantsData.items[i].meetingId,
                    participantsData.items[i].empId,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
