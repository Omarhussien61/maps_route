import 'dart:async';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart' as locator;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:google_map_polyline/google_map_polyline.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StartGuideRouteScreen(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Set<Polyline> polyline = {};

  GoogleMapController _controller;
  List<LatLng> routeCoords;
  GoogleMapPolyline googleMapPolyline =
      new GoogleMapPolyline(apiKey: "AIzaSyAvM94MasEgmymOrt_56H_hPfreci89aVQ");



  getaddressPoints() async {
    routeCoords = await googleMapPolyline.getPolylineCoordinatesWithAddress(
            origin: '55 Kingston Ave, Brooklyn, NY 11213, USA',
            destination: '178 Broadway, Brooklyn, NY 11211, USA',
            mode: RouteMode.driving);
  }

  @override
  void initState() {
    getaddressPoints();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: GoogleMap(
      onMapCreated: onMapCreated,
      polylines: polyline,
      initialCameraPosition:
          CameraPosition(target: LatLng(40.6782, -73.9442), zoom: 14.0),
      mapType: MapType.normal,
    ));
  }

  void onMapCreated(GoogleMapController controller) {
    setState(() {
      _controller = controller;
      polyline.add(Polyline(
          polylineId: PolylineId('route1'),
          visible: true,
          points: routeCoords,
          width: 4,
          color: Colors.blue,
          startCap: Cap.roundCap,
          endCap: Cap.buttCap));
    });
  }
}

class StartGuideRouteScreen extends StatefulWidget {
  final TravelMode travelMode;
  final LatLng postion;

  StartGuideRouteScreen({this.travelMode = TravelMode.driving, this.postion});

  @override
  _StartGuideRouteScreenState createState() => _StartGuideRouteScreenState();
}

class _StartGuideRouteScreenState extends State<StartGuideRouteScreen> {
  Set<Marker> marker = new Set();
  Set<Polyline> polylines = new Set();
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  LatLng latLng;
  Dio dio = new Dio();
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController controller;
  double zoom = 20.5;
  bool onChange = false;
  BitmapDescriptor destinationIcon;
  CameraPosition kGooglePlex = CameraPosition(
    target: LatLng(30.047402, 31.242066),
    zoom: 20.5,
    tilt: 20,
    bearing: 100,
  );
  Location location = new Location();
  locator.Geolocator geoLocator = locator.Geolocator();
  var speedInMps = 0.0;
  void setSourceAndDestinationIcons() async {


    destinationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'assets/images/map-location.png');
  }
  @override
  void initState() {
    initController();
    mapType = MapType.normal;
    selectedItem = items[0];
    var options = locator.LocationOptions(
        accuracy: locator.LocationAccuracy.high, distanceFilter: 10);

    streamLocator = geoLocator.getPositionStream(options).listen((position) {
      speedInMps = position.speed; // this is your speed
      speedInMps = speedInMps * (18 / 5);
    });
    streamLocation = location.onLocationChanged().listen((event) {

      _updateGoogleMap(
          value1: LatLng(event.latitude, event.longitude),
          value2: LatLng(29.9624958,30.9479156),
          context: context);
    });
    setSourceAndDestinationIcons();

    super.initState();
  }

  List<String> items = ["normal", "satellite", "hybrid", "terrain", "none"];
  StreamSubscription<LocationData> streamLocation;
  StreamSubscription<locator.Position> streamLocator;

  @override
  void dispose() {
    streamLocation.cancel();
    streamLocator.cancel();
    super.dispose();
  }

  MapType mapType;

  @override
  Widget build(BuildContext context) {
    final Widget button = SizedBox(
      width: 120,
      height: 35,
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 11),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Flexible(
              child: Text(
                selectedItem,
                style: TextStyle(color: Color(0xff2D4149)),
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(
              width: 5,
            ),
            SizedBox(
                width: 12,
                height: 17,
                child: FittedBox(
                    fit: BoxFit.fill,
                    child: Icon(
                      Icons.arrow_drop_down,
                      color: Colors.grey,
                    ))),
          ],
        ),
      ),
    );
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            GoogleMap(
              markers: marker,
              polylines: Set<Polyline>.of(polylines),
              zoomGesturesEnabled: true,
              rotateGesturesEnabled: true,
              trafficEnabled: true,
              tiltGesturesEnabled: true,
              cameraTargetBounds:CameraTargetBounds.unbounded ,
              scrollGesturesEnabled: true,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              mapType: mapType,
              initialCameraPosition: kGooglePlex,
              onMapCreated: onMapCreated,
              onCameraMove: onCameraMove,
            ),
            Container(
              height: 100,
              color: Colors.white38,
              child: Stack(
                children: <Widget>[
                  Align(
                    alignment: AlignmentDirectional.center,
                    child: Column(
                      children: [
                        Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.rotationY(2 * pi),
                          child: Image.asset(
                            "assets/images/up_right.png",
                            width: 30,
                            height: 30,
                          ),
                        ),
                        Text(
                          "${shortDistanceInMeters.toStringAsFixed(1)} متر",
                          style:
                          TextStyle(fontSize: 16, fontWeight:FontWeight.bold ,color: Color(0xff707070)),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: Text(
                            address,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                                fontSize: 16, color: Color(0xff2D4149)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: AlignmentDirectional.topEnd,
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                        child: Icon(Icons.arrow_drop_down_circle_rounded),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
                bottom: 0,
                right: 0,
                left: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadiusDirectional.only(
                              topEnd: Radius.circular(12))),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(

                                       "باقي من الزمن",


                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Color(0xff707070)),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      "${(timeInSeconds1 / 60).toStringAsFixed(1)} ${ "دقائق"}",
                                      style: TextStyle(
                                          fontSize: 23,
                                          fontWeight:FontWeight.bold ,
                                          color: Color(0xff2D4149)),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.location_on,
                                          color: Color(0xff707070),
                                          size: 12,
                                        ),
                                        Text(
                                          "يبعد مسافة ${(longDistanceInMeters / 1000).toStringAsFixed(1)}",
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Color(0xff707070)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                margin: EdgeInsetsDirectional.only(end: 25),
                                height: 49,
                                width: 49,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xff191818)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ))
          ],
        ),
      ),
    );
  }

  String selectedItem;

  void onCameraMove(position) {
    zoom = position.zoom;
    setState(() {});
  }

  Future initController() async {
    controller = await _controller.future;
  }

  String address = "";

  Future _updateGoogleMap(
      {LatLng value1, LatLng value2, BuildContext context}) async {
    addMarker(
        context: context,
        latLng: LatLng(value2.latitude, value2.longitude),
        markerId: MarkerId("2"));
    addMarker(
        context: context,
        latLng: LatLng(value1.latitude, value1.longitude),
        markerId: MarkerId("1"));
    getPolyline(latLng1: value1, latLng2: value2);
    kGooglePlex = new CameraPosition(
      target: LatLng(value1.latitude, value1.longitude),
      zoom: zoom,
    );
    controller?.animateCamera(CameraUpdate.newCameraPosition(kGooglePlex));
    setState(() {});
  }

  Future addMarker(
      {LatLng latLng, BuildContext context, MarkerId markerId}) async {
    final Marker marker1 = Marker(
        position: latLng,
        markerId: markerId,
        icon: destinationIcon
    );
    marker.add(marker1);
    setState(() {});
  }

  Response time1;
  int timeInSeconds1 = 0;

  Future<int> time({LatLng latLng1, LatLng latLng2}) async {
    time1 = await getTime(latLng2: latLng2, latLng1: latLng1);
    if (time1.data.toString().contains("rows"))
      return time1.data["rows"][0]["elements"][0]["duration"]["value"] as int;
    else
      return 0;
  }

  double shortDistanceInMeters = 0;
  double longDistanceInMeters = 0;

  Future<double> distance({LatLng latLng1, LatLng latLng2}) async {
    return await new locator.Geolocator().distanceBetween(latLng1.latitude,
        latLng1.longitude, latLng2.latitude, latLng2.longitude);
  }

  var kGoogleApiKey = "AIzaSyAvM94MasEgmymOrt_56H_hPfreci89aVQ";

  void onMapCreated(GoogleMapController controller) {
    if (!_controller.isCompleted) _controller.complete(controller);
  }

  Future getPolyline({LatLng latLng1, LatLng latLng2}) async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        kGoogleApiKey,
        PointLatLng(latLng1.latitude, latLng1.longitude),
        PointLatLng(latLng2.latitude, latLng2.longitude),
        travelMode: widget.travelMode);
    if (result.points.isNotEmpty) {
      final coordinates = new Coordinates(
          result.points.first.latitude, result.points.first.longitude);
      var addresses =
      await Geocoder.local.findAddressesFromCoordinates(coordinates);

      address = addresses.first.addressLine;
      shortDistanceInMeters = await distance(
          latLng1: latLng1,
          latLng2:
          LatLng(result.points[1].latitude, result.points[1].longitude));
      polylineCoordinates.clear();
      result.points.removeLast();
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
      longDistanceInMeters = await distance(
          latLng1: polylineCoordinates.first,
          latLng2: polylineCoordinates[polylineCoordinates.length ~/ 2]);
      longDistanceInMeters += await distance(
          latLng1: polylineCoordinates[polylineCoordinates.length ~/ 2],
          latLng2: polylineCoordinates.last);
      timeInSeconds1 = await time(
          latLng2: polylineCoordinates[polylineCoordinates.length ~/ 2],
          latLng1: polylineCoordinates.first);
      timeInSeconds1 += await time(
          latLng2: polylineCoordinates.last,
          latLng1: polylineCoordinates[polylineCoordinates.length ~/ 2]);
    }
    firstLineRoute(points: polylineCoordinates);
  }

  void firstLineRoute({List<LatLng> points}) {
    Polyline polyline1 = new Polyline(
        polylineId: PolylineId("1"),
        color: Colors.grey,
        width: 12,
        startCap: Cap.buttCap,
        consumeTapEvents: true,
        geodesic: true,
        endCap: Cap.buttCap,
        jointType: JointType.round,
        points: points);
    polylines.add(polyline1);
    setState(() {});
  }

  Future<Response> getTime({LatLng latLng1, LatLng latLng2}) async {
    Response response = await dio.get(
        "https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=${latLng1.latitude},${latLng1.longitude}&=&destinations=${latLng2.latitude},${latLng2.longitude}&key=AIzaSyAvM94MasEgmymOrt_56H_hPfreci89aVQ");
    print('response${response.data}');
    return response;
  }
}
