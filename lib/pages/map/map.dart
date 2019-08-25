// Adapted from https://github.com/fireship-io/167-flutter-geolocation-firestore/blob/master/lib/main.dart

import 'dart:async';

import 'package:eatwithme/models/models.dart';
import 'package:eatwithme/services/auth.dart';
import 'package:eatwithme/pages/chat/chat_room_list.dart';
import 'package:eatwithme/pages/profile/editProfile.dart';
import 'package:eatwithme/pages/profile/profile.dart';
import 'package:eatwithme/services/db.dart';
import 'package:eatwithme/theme/eatwithme_theme.dart';
import 'package:eatwithme/utils/constants.dart';
import 'package:eatwithme/utils/routeFromBottom.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:geoflutterfire/geoflutterfire.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final StreamController _controllerUserLocation = StreamController();

  FirebaseUser loggedInUser;
  final db = DatabaseService();
  final auth = AuthService();

  Completer<GoogleMapController> _mapController = Completer();

  Location userLocation = new Location();
  GeoFirePoint previousUserLocation;

  Map<MarkerId, Marker> _mapMarkers = <MarkerId, Marker>{};

  Stream<dynamic> query;
  StreamSubscription subscription;

  double _zoomValue = INITIAL_ZOOM_VALUE;

  @override
  void dispose() {
    super.dispose();
    subscription.cancel();
    _controllerUserLocation.close();
  }

  _onMapCreated(GoogleMapController controller) {
    _startQuery();

    _controllerUserLocation
        .add(userLocation.onLocationChanged().listen(_updateUserLocation));

    setState(() {
      _mapController.complete(controller);
    });
  }

  _startQuery() async {
    print('Start Query');

    // Get users location
    var pos = await userLocation.getLocation();
    double lat = pos.latitude;
    double lng = pos.longitude;

    previousUserLocation = GeoFirePoint(lat, lng);

    subscription = db
        .streamNearbyUsers(loggedInUser.uid, GeoFirePoint(lat, lng))
        .listen(_updateMapMarkers);
  }

  void _updateUserLocation(LocationData data) async {
    if (data.latitude == null) return null;
    if (data.longitude == null) return null;

    GeoFirePoint point = GeoFirePoint(data.latitude, data.longitude);

    var distance = point.distance(
        lat: previousUserLocation.latitude,
        lng: previousUserLocation.longitude);

    print('User distance delta: ' + distance.toString());

    // Only update Firestore when we've moved enough to reduce spam
    if (distance <= 0.5 && _mapMarkers.length > 0) return null;

    if (loggedInUser == null) {
      print('Map currentuid no good');
      return null;
    }

    previousUserLocation = point;

    db.updateUserLocation(loggedInUser.uid, point);

    print("Updated user location");
  }

  _animateToUser() async {
    LocationData pos = await userLocation.getLocation();
    final GoogleMapController controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(pos.latitude, pos.longitude),
      zoom: _zoomValue,
    )));
  }

  _updateMapMarkers(Iterable<User> users) {
    _mapMarkers.clear();

    print('Update markers (${users.length} users on map)');

    for (User user in users) {
      // If the pin is us, or we can't read the uid, skip
      String uid = user.uid;
      if (uid == loggedInUser.uid) continue;
      if (uid == null || uid == "") continue;

      // TODO: Match filtering goes here

      // Check valid position
      GeoFirePoint pos = user.position;

      var lat = pos.latitude;
      var lng = pos.longitude;

      if ((lat == null) || (lng == null)) continue;

      db.getUser(uid).then((currentUser) {
        var markerId = MarkerId(uid);

        var marker = Marker(
            markerId: markerId,
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueOrange),
            position: LatLng(lat, lng),
            draggable: false,
            infoWindow: InfoWindow(
              title: currentUser.displayName,
            ),
            onTap: () {
              showModalBottomSheet<void>(
                  context: context,
                  builder: (BuildContext context) {
                    return ProfileBottomSheet(user: currentUser);
                  });
            });

        setState(() {
          _mapMarkers[markerId] = marker;
        });
      });
    }
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await auth.signOut();
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    loggedInUser = Provider.of<FirebaseUser>(context);

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Stack(alignment: AlignmentDirectional.bottomEnd, children: [
        GoogleMap(
          initialCameraPosition:
              CameraPosition(target: GeoPointANU, zoom: _zoomValue),
          onMapCreated: _onMapCreated,
          rotateGesturesEnabled: true,
          compassEnabled: true,
          myLocationEnabled: true,
          mapType: MapType.normal,
          myLocationButtonEnabled: false,
          markers: Set<Marker>.of(_mapMarkers.values),
          mapToolbarEnabled: false,
        ),

        // TODO: Replace with radial menu (except for user position button)
        Row(
          children: <Widget>[
            FloatingActionButton(
                heroTag: 'GoToPos',
                child: Icon(Icons.pin_drop, size: 30.0),
                foregroundColor: Colors.black,
                backgroundColor: themeLight().primaryColor,
                onPressed: () => _animateToUser()),
            FloatingActionButton(
                heroTag: 'ChatRoomListPage',
                child: Icon(Icons.chat, size: 30.0),
                foregroundColor: Colors.black,
                backgroundColor: themeLight().primaryColor,
                onPressed: () {
                  Navigator.push(
                      context, RouteFromBottom(widget: ChatRoomListPage()));
                }),
            FloatingActionButton(
                heroTag: 'MyUserProfile',
                child: Icon(Icons.account_circle, size: 30.0),
                foregroundColor: Colors.black,
                backgroundColor: Colors.red,
                onPressed: () {
                  Navigator.push(
                      context, RouteFromBottom(widget: EditProfilePage(uid: loggedInUser.uid,)));
                }),
            FloatingActionButton(
                heroTag: 'Logout',
                child: Icon(Icons.exit_to_app, size: 30.0),
                foregroundColor: Colors.white,
                backgroundColor: Colors.black,
                onPressed: () => _signOut(context)),
          ],
        )
      ]),
    );
  }
}

class ProfileBottomSheet extends StatefulWidget {
  const ProfileBottomSheet({
    Key key,
    @required this.user,
  }) : super(key: key);

  final User user;

  @override
  _ProfileBottomSheetState createState() => _ProfileBottomSheetState();
}

class _ProfileBottomSheetState extends State<ProfileBottomSheet> {
  double height = 800.0;

  @override
  Widget build(BuildContext context) {
    return Container(
        // height: height,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.transparent, width: 0.0),
        ),
        child: ProfilePage(uid: widget.user.uid));
  }
}
