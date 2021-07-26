import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:attendy/providers/auth.dart';
import 'package:attendy/providers/employees.dart';
import 'package:attendy/providers/participants.dart';
import 'package:attendy/screens/employee_details.dart';
import 'package:attendy/widgets/profile_button.dart';

class ParticipantItem extends StatelessWidget {
  final String id;
  final String meetingId;
  final String empId;

  ParticipantItem(this.id, this.meetingId, this.empId);
  @override
  Widget build(BuildContext context) {
    Future user;
    user = Provider.of<Employees>(context).getCreatoreInfo(empId);
    final auth = Provider.of<Auth>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.fromLTRB(2.0, 2.0, 2.0, 6),
      child: Card(
        elevation: 2.0,
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed(
                      EmployeeDetailScreen.routeName,
                      arguments: empId);
                },
                child: FutureBuilder<Map<String, dynamic>>(
                  future: user,
                  builder: (ctx, snapshot) {
                    return Row(
                      children: [
                        Padding(
                            padding:
                                const EdgeInsets.fromLTRB(6.0, 2.0, 10.0, 2.0),
                            child: snapshot.hasData
                                ? CircleAvatar(
                                    radius: 25,
                                    backgroundImage: NetworkImage(
                                        snapshot.data['profileImage']))
                                : CircleAvatar(
                                    radius: 25,
                                    child: CircularProgressIndicator())),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              snapshot.hasData
                                  ? snapshot.data['username']
                                  : 'loading....',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Spacer(),
                        auth.userId == empId
                            ? ProfileButton(
                                Icons.exit_to_app,
                                'leave',
                                Colors.red,
                                () async => {
                                      await Provider.of<Participants>(context,
                                              listen: false)
                                          .leaveMeeting(id),
                                      await Provider.of<Participants>(context,
                                              listen: false)
                                          .toggleJoinedtatus(auth.userId),
                                      Navigator.of(context).pop()
                                    })
                            : Text('')
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
