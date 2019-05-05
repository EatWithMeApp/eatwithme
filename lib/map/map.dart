import 'dart:async';
import 'dart:math';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vector_math/vector_math.dart' show radians;
import 'package:location/location.dart';

Future<void> main() async {
  final FirebaseApp app = await FirebaseApp.configure(
    name: 'vscodefirebase',
    options: const FirebaseOptions(
      googleAppID: "1:1050553742489:ios:b7aaeb772a3ecf08",
      bundleID: "com.example.eatWithMe",
      projectID: 'eatwithme-c103e',
    ),
  );
  final Firestore firestore = Firestore(app: app);
  await firestore.settings(timestampsInSnapshotsEnabled: true);

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with TickerProviderStateMixin{
  Completer<GoogleMapController> _controller = Completer();
  bool isOpened = false;
  double _fabHeight = 56.0;
  Animation<double> _translateButton;
  AnimationController _animationController;
  Animation<Color> _buttonColor;
  Animation<double> _animateIcon;
  Curve _curve = Curves.easeOut;

  static const LatLng _center = const LatLng(45.521563, -122.677433);
  static const LatLng ANU = const LatLng(-35.2777, 149.1185);
  double latitude;
  double longitude;
  final Set<Marker> _markers = {};
  LatLng _lastMapPosition = _center;
  final List<userPosition> userPositions = [];
  String currentUserName = "Uwe";
 
  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  void _onCameraMove(CameraPosition position) {
    _lastMapPosition = position.target;
  }

  void addUsers(userPosition user){
    if (!userPositions.contains(user))
      userPositions.add(user);
  }

  @override
  initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500))
          ..addListener(() {
            setState(() {});
          });
    _animateIcon =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _buttonColor = ColorTween(
      begin: Colors.blue,
      end: Colors.red,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.00,
        1.00,
        curve: Curves.linear,
      ),
    ));
    _translateButton = Tween<double>(
      begin: 80,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.5,
        0.75,
        curve: _curve,
      ),
    ));
    super.initState();
  }

  @override
  dispose() {
    _animationController.dispose();
    super.dispose();
  }

  animate() {
    if (!isOpened) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    isOpened = !isOpened;
  }

  Widget toggle() {
    return Container(
      child: FloatingActionButton(
        backgroundColor: Colors.orange,
        onPressed: animate,
        tooltip: 'Toggle',
        child: AnimatedIcon(
          icon: AnimatedIcons.home_menu,
          progress: _animateIcon,
        ),
      ),
    );
  }

  _buildButton(double angle, {Color color, IconData icon}) {
      final double rad = radians(angle);
      return Transform(
        transform: Matrix4.identity()..translate(
          (_translateButton.value) * cos(rad), 
          (_translateButton.value) * sin(rad)
        ),
        child: FloatingActionButton(
          child: Icon(icon), 
          backgroundColor: color, 
          onPressed: (){}, 
          elevation: 0
          )
      );
    }
  
  // load data from Firebase
  Future<void> loadData() async{
    double lat;
    double lng;
    String name;
    List interest;
    userPosition up;
    QuerySnapshot sn = await Firestore.instance.collection('User_Location').getDocuments();
    var list = sn.documents;
    list.forEach((DocumentSnapshot ds) => {
      name = ds.data['name'],
      lat = ds.data['location'].latitude,
      lng = ds.data['location'].longitude,
      interest = ds.data['interest'],
      getNewPosition(lat, lng),
      up = new userPosition(_lastMapPosition, name, interest),
      addUsers(up),
      updateCurrentLocation(name, ds.documentID),
      addMarker(name, _lastMapPosition, interest)
      }
      );
  }

  Future<void> get_location() async{
    var location = new Location();
    LocationData ld = await location.getLocation();
    location.onLocationChanged().listen((LocationData currentLocation) {
      latitude = currentLocation.latitude;
      longitude = currentLocation.longitude;
    });
  }


  int count = 0;
  Future<void> pushLocation(double latitude, double longitude) async{
    if (count == 0){
      var db = Firestore.instance;
      await db.collection('User_Location').add({
        'name': currentUserName,
        'location': GeoPoint(latitude, longitude),
        'interest': ['Hi', 'gogo'],
      }).then((val){
        print("success");
      }).catchError((err) {
        print(err);
      });
      count++;
      print(count);
    }
    }

  Future<void> updateCurrentLocation(String name, String id) async{
    if ((currentUserName == name) & (id != null)){
      var db = Firestore.instance;
      if ((latitude != null) & (longitude != null)) {
        await db.collection("User_Location").document(id).updateData({
          'location': GeoPoint(latitude, longitude)
        });
        print("updateSuccesss");
      }
    }
  }

  void addMarker(String name, LatLng pos, List interest){
    if (name != currentUserName){
    setState(() {
      Marker markerChangeName = getMarkerByPos(pos);
      Marker markerChangePosition = getMarkerByName(name);
      Marker markerChangeInterest = getMarkerByInterest(interest);
      _markers.remove(markerChangeName);
      _markers.remove(markerChangePosition);
      _markers.remove(markerChangeInterest);
      _markers.add(Marker(
        markerId: MarkerId(name),
        position: pos,
        infoWindow: InfoWindow(
          title: name,
          snippet: "interests: " + interest.toString()
        ),
        icon: BitmapDescriptor.fromAsset("assets/orange.png")
      ));
    });
    }
  }

  Marker getMarkerByPos(LatLng pos){
    for (Marker m in _markers) {
      if (m.position == pos)
        return m;
    }
  }

  Marker getMarkerByName(String name){
    for (Marker m in _markers) {
      if (m.markerId == MarkerId(name))
        return m;
    }
  }

  Marker getMarkerByInterest(List interest){
    for (Marker m in _markers) {
      if (m.infoWindow.snippet == "interests: " + interest.toString())
        return m;
    }
  }

  void getNewPosition(double lat, double lng){
    _lastMapPosition = new LatLng(lat, lng);
  }

  @override
  Widget build(BuildContext context) {
    get_location();
    if ((longitude != null) & (latitude != null))
      pushLocation(latitude, longitude);
    loadData();
    return MaterialApp(
      home: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(20),
          child: AppBar(
          backgroundColor: Colors.orange[700],
          ),
        ),
        body: Stack(
          alignment: Alignment.bottomRight,
          children: <Widget>[
            GoogleMap(
              onMapCreated: _onMapCreated,
              rotateGesturesEnabled: true,
              compassEnabled: true,
              scrollGesturesEnabled: true,
              myLocationEnabled: true,
              initialCameraPosition: CameraPosition(
                target: ANU,
                zoom: 16.0,
              ),
              // Add markers
              markers: _markers,
              onCameraMove: _onCameraMove,
            ),
            _buildButton(180, color: Colors.red),
            _buildButton(225, color: Colors.orange),
            _buildButton(-90, color: Colors.black),
            toggle(),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }
}

class userPosition{
  String user;
  LatLng position;
  List interest;
  userPosition(LatLng position, String user, List interest){
    this.position = position;
    this.user = user;
    this.interest = interest;
  }
  @override
  String toString() {
    return user + position.toString();
  }
}