import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:attendy/providers/employees.dart';
import 'package:attendy/widgets/profile_menu.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../mobile.dart' if (dart.library.html) 'web.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

class EmployeeDetailScreen extends StatefulWidget {
  static const routeName = '/employee-detail';

  @override
  _EmployeeDetailScreenState createState() => _EmployeeDetailScreenState();
}

class _EmployeeDetailScreenState extends State<EmployeeDetailScreen> {
  static final CameraPosition _kGooglePlex =
      CameraPosition(target: LatLng(30.5757774, 31.0087507), zoom: 14.4746);
  double lat1;
  double lng1;

  Map<MarkerId, Marker> markers = {};
  String googleAPiKey = "AIzaSyAkpu3YtR8CUhiRJb2xbUFHPfpfE36t1OI";

  Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController newGoogleMapController;

  Position currentPosition;
  var geolocator = Geolocator();

  void _locatePosition(String lat, String long) async {
    LatLng latLngPosition = LatLng(double.parse(lat), double.parse(long));

    CameraPosition cameraPosition =
        new CameraPosition(target: latLngPosition, zoom: 17);

    final GoogleMapController mapController = await _controllerGoogleMap.future;
    mapController.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  _addMarker(LatLng position, String id, BitmapDescriptor descriptor) async {
    MarkerId markerId = MarkerId(id);
    Marker marker =
        Marker(markerId: markerId, icon: descriptor, position: position);
    markers[markerId] = marker;
  }

  @override
  void didChangeDependencies() {
    final employeeId = ModalRoute.of(context).settings.arguments as String;
    final loadedEmployee =
        Provider.of<Employees>(context, listen: false).findById(employeeId);

    setState(() {
      _addMarker(
          LatLng(double.parse(loadedEmployee.latitude),
              double.parse(loadedEmployee.longtude)),
          "origin",
          BitmapDescriptor.defaultMarkerWithHue(90));
    });
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final employeeId =
        ModalRoute.of(context).settings.arguments as String; // is the id!
    final loadedEmployee =
        Provider.of<Employees>(context, listen: false).findById(employeeId);

    return Scaffold(
      appBar: AppBar(
        title: Text(loadedEmployee.username),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              height: 200,
              child: CircleAvatar(
                  radius: 70,
                  backgroundImage: NetworkImage(loadedEmployee.image)),
            ),
            SizedBox(height: 10),
            ProfileMenu(
              icon: Icons.account_circle,
              text: loadedEmployee.username,
              press: () => {},
            ),
            ProfileMenu(
              icon: Icons.email,
              text: loadedEmployee.email,
              press: () => {},
            ),
            ProfileMenu(
              icon: Icons.location_pin,
              text: "is " +
                  Geolocator.distanceBetween(
                          30.575640,
                          31.008410,
                          double.parse(loadedEmployee.latitude),
                          double.parse(loadedEmployee.longtude))
                      .round()
                      .toString() +
                  " m from the company",
              press: () => {},
            ),
            ProfileMenu(
              icon: Icons.home,
              text: loadedEmployee.address,
              press: () => {},
            ),
            ProfileMenu(
              icon: Icons.phone,
              text: loadedEmployee.phone,
              press: () async => {
                await FlutterPhoneDirectCaller.callNumber(
                    loadedEmployee.phone.toString())
              },
            ),
            ProfileMenu(
              icon: Icons.picture_as_pdf_rounded,
              text: 'Craete Pdf',
              press: () => {
                _createPDF(loadedEmployee.id, loadedEmployee.username,
                    loadedEmployee.email, loadedEmployee.job)
              },
            ),
            Container(
              width: 300,
              height: 300,
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
                  border: Border.all(color: Colors.grey[300], width: 3),
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              child: GoogleMap(
                  mapType: MapType.normal,
                  myLocationButtonEnabled: true,
                  initialCameraPosition: _kGooglePlex,
                  myLocationEnabled: true,
                  zoomControlsEnabled: true,
                  zoomGesturesEnabled: true,
                  onMapCreated: (GoogleMapController controller) {
                    _controllerGoogleMap.complete(controller);
                    _locatePosition(
                        loadedEmployee.latitude, loadedEmployee.longtude);
                  },
                  markers: Set<Marker>.of(markers.values)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createPDF(
      String id, String name, String email, String job) async {
    PdfDocument document = PdfDocument();

    PdfGrid grid = PdfGrid();

    grid.style = PdfGridStyle(
        font: PdfStandardFont(PdfFontFamily.helvetica, 12),
        cellPadding: PdfPaddings(left: 5, right: 2, top: 2, bottom: 2));

    grid.columns.add(count: 4);
    grid.headers.add(2);

    //PdfGrid header1 = grid.rows.add();
    //header1.cells[0].value = 'emolpyee information';

    PdfGridRow header = grid.headers[0];
    header.cells[0].value = 'id';
    header.cells[1].value = 'Name';
    header.cells[2].value = 'Email';
    header.cells[3].value = 'Job';

    PdfGridRow row = grid.rows.add();
    row.cells[0].value = id;
    row.cells[1].value = name;
    row.cells[2].value = email;
    row.cells[3].value = job;

    grid.draw(
        page: document.pages.add(), bounds: const Rect.fromLTWH(0, 0, 0, 0));

    List<int> bytes = document.save();
    document.dispose();

    saveAndLaunchFile(bytes, 'Output.pdf');
  }
}

Future<Uint8List> _readImageData(String name) async {
  final data = await rootBundle.load(name);
  return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
}
