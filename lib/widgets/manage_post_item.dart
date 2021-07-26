import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:attendy/providers/employees.dart';
import 'package:attendy/providers/posts.dart';
import 'package:attendy/screens/employee_details.dart';

class ManagePostItem extends StatelessWidget {
  final String id;
  final String creatorId;
  final String text;
  final String image;
  final String dateTime;

  ManagePostItem(this.id, this.creatorId, this.text, this.image, this.dateTime);

  @override
  Widget build(BuildContext context) {
    Future user;
    user = Provider.of<Employees>(context).getCreatoreInfo(creatorId);
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
                      arguments: creatorId);
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
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Text(
                                dateTime,
                                style: TextStyle(
                                    fontSize: 13, color: Colors.black87),
                              ),
                            ),
                          ],
                        ),
                        Spacer(),
                        IconButton(
                          onPressed: () {
                            Provider.of<Posts>(context, listen: false)
                                .deletePost(id);
                          },
                          icon: Icon(Icons.delete_outline),
                          color: Colors.red,
                        )
                      ],
                    );
                  },
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 10, 4, 10),
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                    maxLines: 3,
                  ),
                ),
              ),
              Expanded(
                  child: Image.network(
                image,
                fit: BoxFit.cover,
              )),
            ],
          ),
        ),
      ),
    );
  }
}
