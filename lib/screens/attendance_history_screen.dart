import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:attendy/providers/attendanceHistories.dart';

import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../mobile.dart' if (dart.library.html) 'web.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;

class HistoryScreen extends StatefulWidget {
  static const routeName = '/history_screen';
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  Future<void> _refreshHistory(BuildContext context) async {
    await Provider.of<AttendanceHistories>(context, listen: false)
        .fetchAttendanceHistory();
  }

  var _isInit = true;
  var _isLoading = false;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<AttendanceHistories>(context)
          .fetchAttendanceHistory()
          .then((_) {
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
    final historyData = Provider.of<AttendanceHistories>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Attendance History',
            style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: Colors.black)),
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            }),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: IconButton(
                icon: Icon(
                  Icons.print_rounded,
                  color: Colors.black,
                ),
                onPressed: () {
                  _createPDF(historyData);
                }),
          )
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: RefreshIndicator(
                onRefresh: () => _refreshHistory(context),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: ListView.separated(
                      itemCount: historyData.items.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Container(
                            width: MediaQuery.of(context).size.width,
                            height: 40,
                            color: Colors.grey[200],
                            child: Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Text("date",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  flex: 4,
                                ),
                                VerticalDivider(
                                  width: 2,
                                  color: Colors.grey,
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Text("started",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  flex: 3,
                                ),
                                VerticalDivider(
                                  width: 2,
                                  color: Colors.grey,
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Text("leved",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  flex: 4,
                                ),
                              ],
                            ),
                          );
                        } else {
                          return Container(
                            width: MediaQuery.of(context).size.width,
                            height: 40,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Row(
                                      children: <Widget>[
                                        Icon(
                                          Icons.date_range_rounded,
                                          color: Colors.blueAccent,
                                        ),
                                        Text(
                                            historyData.items[index - 1].date
                                                .toString(),
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                  flex: 4,
                                ),
                                VerticalDivider(
                                  width: 2,
                                  color: Colors.grey,
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Row(
                                      children: <Widget>[
                                        Icon(
                                          Icons.check_circle_outlined,
                                          color: Colors.green,
                                        ),
                                        Text(
                                          historyData
                                              .items[index - 1].startTime,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                  flex: 3,
                                ),
                                VerticalDivider(
                                  width: 2,
                                  color: Colors.grey,
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Row(
                                      children: <Widget>[
                                        Icon(
                                          Icons.logout_rounded,
                                          color: Colors.red,
                                        ),
                                        Text(
                                            historyData
                                                .items[index - 1].endTime,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                  flex: 4,
                                ),
                              ],
                            ),
                          );
                        }
                      },
                      separatorBuilder: (context, index) => Divider(),
                    ),
                  ),
                ),
              ),
            ),
    );
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
