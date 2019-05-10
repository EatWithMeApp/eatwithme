import 'dart:async';
import 'dart:ui';
import 'package:eatwithme/pages/auth/auth.dart';
import 'package:eatwithme/pages/chat/friends.dart';
import 'package:eatwithme/widgets/loadingCircle.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';
import 'package:eatwithme/pages/map/animationButton.dart';

class MyMap extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyMap> with TickerProviderStateMixin {
  Completer<GoogleMapController> _controller = Completer();

  bool alreadyPushed = false;
  static const LatLng _center = const LatLng(45.521563, -122.677433);
  static const LatLng ANU = const LatLng(-35.2777, 149.1185);
  // store the current location of the user
  double latitude;
  double longitude;
  // store markers (pins)
  final Set<Marker> _markers = {};
  LatLng _lastMapPosition = _center;
  final List<userPosition> userPositions = [];
  String currentUserName = "u6225609@anu.edu.au";

  final Firestore _firestore = Firestore.instance;
  final StreamController _controllerUserProfile = StreamController();

  @override
  void initState() {
    super.initState();
    _controllerUserProfile.addStream(_firestore
        .collection('Users')
        .document(authService.currentUid)
        .snapshots()
        .map((snap) => snap.data));
  }

  @override
  void dispose() {
    _controllerUserProfile.close();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  void _onCameraMove(CameraPosition position) {
    _lastMapPosition = position.target;
  }

  void addUsers(userPosition user) {
    if (!userPositions.contains(user)) userPositions.add(user);
  }

  // Log out button
  Future<void> _signOut(BuildContext context) async {
    try {
      await authService.signOut();
    } catch (e) {
      print(e);
    }
  }

  // Initiate the state of Firebase
  // Doesn't know whether it work
  Future<void> set_state() async {
    // final FirebaseApp app = await FirebaseApp.configure(
    //   name: 'eatwithme',
    //   options: const FirebaseOptions(
    //     googleAppID: '1:1050553742489:ios:d582d6d5c13ccf2c',
    //     bundleID: 'com.eatwithme.eatwithme',
    //     projectID: 'eatwithme-c103e',
    //   ),
    // );
    // final firestore = Firestore(app: app);
    // await firestore.settings(timestampsInSnapshotsEnabled: true);
  }

  // load data from Firebase
  Future<void> loadData() async {
    pushLocation(latitude, longitude);
    double lat;
    double lng;
    String name;
    List interest;
    userPosition up;
    QuerySnapshot sn =
        await Firestore.instance.collection('Users').getDocuments();

    // .collection('Users')
    // .where("location", isEqualTo: GeoPoint(-35.2777, 149.118))
    // .getDocuments();
    var list = sn.documents;
    // print(list.toString());
    Future.delayed(const Duration(milliseconds: 500));
    list.forEach((DocumentSnapshot ds) => {
          (ds.data['location'] == null)
              ? {
                  // Should be extremely rare that a user has
                  // no location at all, but we can ignore those users
                  // for the map
                }
              : {
                  name = ds.data['displayName'],
                  lat = ds.data['location'].latitude,
                  lng = ds.data['location'].longitude,
                  interest = ds.data['interests'],
                  getNewPosition(lat, lng),
                  up = new userPosition(_lastMapPosition, name, interest),
                  addUsers(up),
                  updateCurrentLocation(name, ds.documentID),
                  addMarker(name, _lastMapPosition, interest, ds.data['uid'])
                }
        });
  }

  // Use location package to get the location of the user
  Future<void> get_location() async {
    do {
      var location = new Location();
      LocationData ld = await location.getLocation();
      location.onLocationChanged().listen((LocationData currentLocation) {
        latitude = currentLocation.latitude;
        longitude = currentLocation.longitude;
      });
    } while ((latitude == null) || (longitude != null));
  }

  // Create a document to put user's name, user's interests
  // and user's location in
  Future<void> pushLocation(double latitude, double longitude) async {
    if (!alreadyPushed) {
      var db = Firestore.instance;
      await db.collection('Users').add({
        'displayName': currentUserName,
        'location': GeoPoint(latitude, longitude),
        'interests': ['Hi', 'gogo'],
      }).then((val) {
        print("Pushed success");
      }).catchError((err) {
        print(err);
      });
      alreadyPushed = true;
    }
  }

  // update user's location in the firebase when the user moves
  Future<void> updateCurrentLocation(String name, String id) async {
    if ((currentUserName == name) & (id != null) & (alreadyPushed = true)) {
      var db = Firestore.instance;
      if ((latitude != null) & (longitude != null)) {
        db
            .collection("Users")
            .document(id)
            .updateData({'location': new GeoPoint(latitude, longitude)});
        print("updateSuccesss");
      }
    }
  }

  // add and update markers(pins), when name, interest, and location change
  void addMarker(String name, LatLng pos, List interest, String uid) {
    if (name == currentUserName) return;

    setState(() {
      Marker markerChangeName = getMarkerByPos(pos);
      Marker markerChangePosition = getMarkerByName(name);
      Marker markerChangeInterest = getMarkerByInterest(interest);
      _markers.remove(markerChangeName);
      _markers.remove(markerChangePosition);
      _markers.remove(markerChangeInterest);

      // ImageInfo img;
      // ByteData imgBytes;

      // var sunImage = new NetworkImage(
      //   "https://s.yimg.com/ny/api/res/1.2/9u2kkdYGgTrXtvcOyLk0Uw--~A/YXBwaWQ9aGlnaGxhbmRlcjtzbT0xO3c9ODAw/http://media.zenfs.com/en-US/homerun/fatherly_721/990ffb618eda44035580f02b792bc89f");
      // sunImage.obtainKey(new ImageConfiguration()).then((val) {
      //   var load = sunImage.load(val);
      //   load.addListener((listener, err) async {
      //     setState(() => {
      //       print(img),
      //       img = listener
      //     });
      //   });
      // });

      // print(img);

      // img.image.toByteData(format: ImageByteFormat.png).then((value) => {imgBytes = value});

      // BitmapDescriptor bitmap = BitmapDescriptor.fromBytes(imgBytes.buffer.asUint8List());

      BitmapDescriptor icon;
      BitmapDescriptor.fromAssetImage(
              ImageConfiguration(size: Size(5.0, 5.0)), 'images/orange.png')
          .then((value) => {icon = value});

      _markers.add(Marker(
          markerId: MarkerId(name),
          position: pos,
          infoWindow: InfoWindow(title: name),
          icon: icon));

      // Image.network('https://s.yimg.com/ny/api/res/1.2/9u2kkdYGgTrXtvcOyLk0Uw--~A/YXBwaWQ9aGlnaGxhbmRlcjtzbT0xO3c9ODAw/http://media.zenfs.com/en-US/homerun/fatherly_721/990ffb618eda44035580f02b792bc89f')
      // .image.load(key).addListener((ImageInfo image, bool sync) async {});
    });

    // setState(() {
    //   Marker markerChangeName = getMarkerByPos(pos);
    //   Marker markerChangePosition = getMarkerByName(name);
    //   Marker markerChangeInterest = getMarkerByInterest(interest);
    //   _markers.remove(markerChangeName);
    //   _markers.remove(markerChangePosition);
    //   _markers.remove(markerChangeInterest);

    //   ImageInfo img;

    //   // Image.network(
    //   //               'https://s.yimg.com/ny/api/res/1.2/9u2kkdYGgTrXtvcOyLk0Uw--~A/YXBwaWQ9aGlnaGxhbmRlcjtzbT0xO3c9ODAw/http://media.zenfs.com/en-US/homerun/fatherly_721/990ffb618eda44035580f02b792bc89f')
    //   //               )

    //   ByteData imgBytes;

    //   img.image.toByteData(format: ImageByteFormat.png).then((value) => {imgBytes = value});

    //   BitmapDescriptor bitmap = BitmapDescriptor.fromBytes(imgBytes.buffer.asUint8List());

    //   _markers.add(
    //     Marker(
    //       markerId: MarkerId(name),
    //       position: pos,
    //       infoWindow: InfoWindow(title: name),
    //       icon: bitmap)
    //   );
    // };
  }

  // These three functions are used to get a specific marker by a position
  // name, or interest respectively
  Marker getMarkerByPos(LatLng pos) {
    for (Marker m in _markers) {
      if (m.position == pos) return m;
    }
  }

  Marker getMarkerByName(String name) {
    for (Marker m in _markers) {
      if (m.markerId == MarkerId(name)) return m;
    }
  }

  Marker getMarkerByInterest(List interest) {
    for (Marker m in _markers) {
      if (m.infoWindow.snippet == "interests: " + interest.toString()) return m;
    }
  }

  void getNewPosition(double lat, double lng) {
    _lastMapPosition = new LatLng(lat, lng);
  }

  @override
  Widget build(BuildContext context) {
    String currentUid;
    set_state();
    get_location();
    pushLocation(latitude, longitude);
    loadData();
    return MaterialApp(
      home: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(40),
          child: AppBar(
            backgroundColor: Colors.orange[700],
            actions: <Widget>[
              Hero(
                  tag: 'FriendPage',
                  child: Material(
                      child: IconButton(
                          icon: Icon(Icons.chat),
                          iconSize: 60.0,
                          onPressed: () {
                            var route = MaterialPageRoute(
                                builder: (context) => FriendsPage(
                                      currentUid: currentUid,
                                    ));
                            Navigator.of(context).push(route);
                          }))),
              FlatButton(
                child: Text('Logout',
                    style: TextStyle(fontSize: 17.0, color: Colors.white)),
                onPressed: () => _signOut(context),
              )
            ],
          ),
        ),
        body: StreamBuilder(
          stream: _controllerUserProfile.stream,
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return Text("Error reading profile");
                break;
              case ConnectionState.done:
                return Text("Error reading profile");
              case ConnectionState.waiting:
                return LoadingCircle();
                break;
              case ConnectionState.active:
                if (snapshot.hasData) {
                  currentUid = snapshot.data['uid'];
                  return SafeArea(
                    child: Stack(
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
                  );
                } else {
                  return Container(
                    child: Text("Didn't load user"),
                  );
                }
                break;
            }
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }
}

class userPosition {
  String user;
  LatLng position;
  List interest;
  userPosition(LatLng position, String user, List interest) {
    this.position = position;
    this.user = user;
    this.interest = interest;
  }
  @override
  String toString() {
    return user + position.toString();
  }
}
