// Adapted from https://github.com/fireship-io/167-flutter-geolocation-firestore/blob/master/lib/main.dart

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatwithme/pages/auth/auth.dart';
import 'package:eatwithme/pages/map/animationButton.dart';
import 'package:eatwithme/theme/eatwithme_theme.dart';
import 'package:eatwithme/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:rxdart/rxdart.dart';
import 'package:geoflutterfire/geoflutterfire.dart';

class Map2 extends StatefulWidget {
  @override
  _Map2State createState() => _Map2State();
}

class _Map2State extends State<Map2> {
  final Firestore _firestore = Firestore.instance;
  final Geoflutterfire geo = Geoflutterfire();
  // final StreamController _controllerUserProfile = StreamController();

  final StreamController _controllerUserLocation = StreamController();

  GoogleMapController _mapController;
  Location userLocation = new Location();
  GeoFirePoint previousUserLocation;

  BehaviorSubject<double> radius = BehaviorSubject.seeded(500.0);
  Stream<dynamic> query;

  final Set<Marker> _markers = {};

  StreamSubscription subscription;
  // Stream<List<DocumentSnapshot>> subscription;

  double _zoomValue = 16.0;

  @override
  void initState() {
    super.initState();
    // _controllerUserProfile.addStream(_firestore
    //     .collection('Users')
    //     .document(authService.currentUid)
    //     .snapshots()
    //     .map((snap) => snap.data));
    // _startQuery();

    _controllerUserLocation
        .add(userLocation.onLocationChanged().listen(_updateUserLocation));

    // userLocation.onLocationChanged().listen(_updateUserLocation);
  }

  @override
  void dispose() {
    // _controllerUserProfile.close();
    subscription.cancel();
    // userLocation.onLocationChanged().listen(_updateUserLocation).cancel();
    _controllerUserLocation.close();
    radius.close();
    super.dispose();
  }

  _onMapCreated(GoogleMapController controller) {
    setState(() {
      _mapController = controller;
      _startQuery();
      // subscription.listen((docList) {
      //   _updateMarkers(docList);
      // });
    });
  }

  _startQuery() async {
    // Get users location
    var pos = await userLocation.getLocation();
    double lat = pos.latitude;
    double lng = pos.longitude;

    previousUserLocation = geo.point(latitude: lat, longitude: lng);

    print(lat.toString() + ' - ' + lng.toString());

    // Make a reference to firestore
    var ref = _firestore.collection('Users');
    GeoFirePoint center = geo.point(latitude: lat, longitude: lng);

    // subscribe to query
    // subscription = radius.switchMap((rad) {
    //   return geo.collection(collectionRef: ref).within(
    //       center: center, radius: rad, field: 'position', strictMode: true);
    // }).listen(_updateMarkers);

    // subscription = radius.switchMap((rad) {
    //   return geo.collection(collectionRef: ref).within(
    //       center: center, radius: rad, field: 'position', strictMode: true);
    // });

    subscription = radius.switchMap((rad) {
      return geo.collection(collectionRef: ref).within(
          center: center, radius: rad, field: 'position', strictMode: true);
    }).listen(_updateMarkers);
  }

  _updateQuery(value) {
    final zoomMap = {
      100.0: 12.0,
      200.0: 10.0,
      300.0: 7.0,
      400.0: 6.0,
      500.0: 5.0
    };
    final zoom = zoomMap[value];
    _mapController.moveCamera(CameraUpdate.zoomTo(zoom));

    setState(() {
      radius.add(value);
    });
  }

  _updateUserLocation(LocationData data) async {
    // var pos = await userLocation.getLocation();
    // GeoFirePoint point =
    //     geo.point(latitude: pos.latitude, longitude: pos.longitude);

    // if (data.longitude == previousUserLocation.longitude) return null;
    // if (data.latitude == previousUserLocation.latitude) return null;

    GeoFirePoint point =
        geo.point(latitude: data.latitude, longitude: data.longitude);

    var distance = point.distance(
        lat: previousUserLocation.latitude,
        lng: previousUserLocation.longitude);

    print('distance: ' + distance.toString());

    if (distance <= 0.0) return null;

    previousUserLocation = point;

    return _firestore
        .collection('Users')
        .document(authService.currentUid)
        .setData({'position': point.data}, merge: true);
  }

  void _addMarker() {
    // var marker = MarkerOptions(
    //     position: _mapController.cameraPosition.target,
    //     icon: BitmapDescriptor.defaultMarker,
    //     infoWindowText: InfoWindowText('Magic Marker', '🍄🍄🍄'));

    // _mapController.addMarker(marker);
  }

  _animateToUser() async {
    LocationData pos = await userLocation.getLocation();
    _mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(pos.latitude, pos.longitude),
      zoom: _zoomValue,
    )));
  }

  void _updateMarkers(List<DocumentSnapshot> documentList) async {
    print(documentList);
    _markers.clear();
    documentList.forEach((DocumentSnapshot document) {
      // GeoPoint pos = document.data['position']['geopoint'];
      // double distance = document.data['distance'];
      // var marker = MarkerOptions(
      //     position: LatLng(pos.latitude, pos.longitude),
      //     icon: BitmapDescriptor.defaultMarker,
      //     infoWindowText: InfoWindowText(
      //         'Magic Marker', '$distance kilometers from query center'));

      // _mapController.addMarker(marker);

      GeoPoint pos = document.data['position']['geopoint'];
      String uid = document.data['uid'];

      // var userData = _firestore
      //     .collection('Users')
      //     .document(uid)
      //     .get()
      //     .then((snap) => snap.data);

      // var userData;

      _firestore.collection('Users').document(uid).get().then((snap) {
        var userData = snap.data;

        var marker = Marker(
            markerId: MarkerId(uid),
            icon: BitmapDescriptor.defaultMarker,
            position: LatLng(pos.latitude, pos.longitude),
            draggable: false,
            onTap: () {
              print('Update me with widget card');
              print(userData['displayName']);
            });

        _markers.add(marker);
      });
    });
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await authService.signOut();
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    //SignOutFunction button3;

    var button3 = () {
      print('Fuck you');
    };

    var animationButton = AnimationButton(
      button3: button3,
    );

    return SafeArea(
      child: Scaffold(
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
            markers: _markers,
          ),
          Positioned(bottom: 5, right: 5, child: animationButton),
          // animationButton,
          Positioned(
              bottom: 5,
              left: 5,
              child: FloatingActionButton(
                  child: Icon(Icons.pin_drop, size: 30.0),
                  backgroundColor: themeLight().primaryColor,
                  // onPressed: () => _animateToUser()))
                  onPressed: () => authService.signOut()))
        ]),
      ),
    );
  }
}

class SignOutFunction extends UseFunction {
  @override
  void onClick() {
    authService.signOut();
  }
}
