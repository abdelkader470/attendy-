import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:attendy/providers/auth.dart';
import 'package:attendy/models/meeting.dart';
import 'package:attendy/providers/participants.dart';
import 'package:attendy/screens/meeting_details_screen.dart';
import 'package:attendy/widgets/profile_button.dart';

class MeetingItem extends StatefulWidget {
  @override
  _MeetingItemItemState createState() => _MeetingItemItemState();
}

class _MeetingItemItemState extends State<MeetingItem> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final meeting = Provider.of<Meeting>(context);
    final auth = Provider.of<Auth>(context, listen: false);

    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .pushNamed(MeetingDetailsScreen.routeName, arguments: meeting.id);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.4),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                  border: Border.all(color: Colors.grey[300], width: 1),
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.topLeft,
                      child: Text(
                        meeting.desc,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            meeting.address,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Spacer(),
                        Container(
                          height: 50,
                          width: 100,
                          child: Consumer<Meeting>(
                              builder: (ctx, product, _) => meeting.isJoined
                                  ? ProfileButton(
                                      Icons.groups,
                                      'joind',
                                      Colors.green[400],
                                      () async => {
                                            Navigator.of(context).pushNamed(
                                                MeetingDetailsScreen.routeName,
                                                arguments: meeting.id)
                                          })
                                  : ProfileButton(
                                      Icons.group_add,
                                      'join',
                                      Colors.blueAccent,
                                      () async => {
                                            product.toggleJoinedtatus(
                                              auth.token,
                                              auth.userId,
                                            ),
                                            await Provider.of<Participants>(
                                                    context,
                                                    listen: false)
                                                .joinMeeting(meeting.id)
                                          })),
                        ),
                      ],
                    ),
                  ],
                ),
              )),
        ),
      ),
    );
  }
}
