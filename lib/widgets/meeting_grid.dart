import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:attendy/providers/meetings.dart';
import 'package:attendy/widgets/meeting_item.dart';

class MeetingsGrid extends StatelessWidget {
  MeetingsGrid();

  @override
  Widget build(BuildContext context) {
    final meetingsData = Provider.of<Meetings>(context);
    final meeting = meetingsData.items;
    return GridView.builder(
        padding: const EdgeInsets.all(10.0), //من برة
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: meeting.length,
        itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
              value: meeting[i],
              child: Column(
                children: [MeetingItem()],
              ),
            ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          childAspectRatio: 6 / 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 0,
        ));
  }
}
