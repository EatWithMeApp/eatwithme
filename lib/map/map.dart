import 'dart:async';
import 'package:eatwithme/pages/auth/auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';
import 'package:eatwithme/map/animationButton.dart';

class MyMap extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyMap> with TickerProviderStateMixin{
  Completer<GoogleMapController> _controller = Completer();

  static const LatLng _center = const LatLng(45.521563, -122.677433);
  static const LatLng ANU = const LatLng(-35.2777, 149.1185);
  double latitude;
  double longitude;
  final Set<Marker> _markers = {};
  LatLng _lastMapPosition = _center;
  final List<userPosition> userPositions = [];
  String currentUserName = "Ben";
  Firestore firestore;
 
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

  Future<void> _signOut(BuildContext context) async {
    try {
      await authService.signOut();
    } catch (e) {
      print(e);
    }
  }

  Future<void> set_state() async{
    final FirebaseApp app = await FirebaseApp.configure(
      name: 'EatWithMeIOS',
      options: const FirebaseOptions(
        googleAppID: '1:1050553742489:ios:d582d6d5c13ccf2c',
        bundleID: 'com.eatwithme.eatwithme',
        projectID: 'eatwithme-c103e',
        apiKey: 'AIzaSyB1dv4AdtCdmPraFPWowHmSXL9933Re1DI',
      ),
    );
    final firestore = Firestore(app: app);
    await firestore.settings(timestampsInSnapshotsEnabled: true);
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
    Future.delayed(const Duration(milliseconds: 500));
    await list.forEach((DocumentSnapshot ds) => {
    name = ds.data['name'],
    lat = ds.data['location'].latitude,
    lng = ds.data['location'].longitude,
    interest = ds.data['interest'],
    getNewPosition(lat, lng),
    up = new userPosition(_lastMapPosition, name, interest),
    addUsers(up),
    print(name),
    updateCurrentLocation(name, ds.documentID),
    addMarker(name, _lastMapPosition, interest)
    }
    );
    sn = null;
  }

  Future<void> get_location() async{
    var location = new Location();
    LocationData ld = await location.getLocation();
    location.onLocationChanged().listen((LocationData currentLocation) {
      latitude = currentLocation.latitude;
      longitude = currentLocation.longitude;
    });
  }


  bool alreadyPushed = false;
  Future<void> pushLocation(double latitude, double longitude) async{
    if (!alreadyPushed){
      var db = Firestore.instance;
      await db.collection('User_Location').add({
        'name': currentUserName,
        'location': GeoPoint(latitude, longitude),
        'interest': ['Hi', 'gogo'],
      }).then((val){
        print("Pushed success");
      }).catchError((err) {
        print(err);
      });
      alreadyPushed = true;
    }
    }

  Future<void> updateCurrentLocation(String name, String id) async{
    if ((currentUserName == name) & (id != null) & (alreadyPushed = true)){
      var db = Firestore.instance;
      if ((latitude != null) & (longitude != null)) {
        db.collection("User_Location").document(id).updateData({
          'location': new GeoPoint(latitude, longitude)
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
          actions: <Widget>[
          FlatButton(
            child: Text('Logout',
                style: TextStyle(fontSize: 17.0, color: Colors.white)),
            onPressed: () => _signOut(context),
          )
        ],
          ),
        ),
        body: Stack(
          alignment: AlignmentDirectional.bottomEnd,
          children: <Widget>[
            GoogleMap(
              onMapCreated: _onMapCreated,
              rotateGesturesEnabled: true,
              compassEnabled: true,
              myLocationEnabled: true,
              initialCameraPosition: CameraPosition(
                target: ANU,
                zoom: 16.0,
              ),
              // Add markers
              markers: _markers,
              onCameraMove: _onCameraMove,
            ),
            SafeArea(
              child: AnimationButton(),
            ),
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
