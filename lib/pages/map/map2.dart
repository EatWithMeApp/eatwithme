// Adapted from https://github.com/fireship-io/167-flutter-geolocation-firestore/blob/master/lib/main.dart

import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatwithme/pages/auth/auth.dart';
import 'package:eatwithme/pages/chat/friends.dart';
import 'package:eatwithme/pages/map/animationButton.dart';
import 'package:eatwithme/pages/profile/editProfile.dart';
import 'package:eatwithme/pages/profile/profile.dart';
import 'package:eatwithme/theme/eatwithme_theme.dart';
import 'package:eatwithme/utils/constants.dart';
import 'package:eatwithme/utils/routeFromBottom.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final StreamController _controllerUserProfile = StreamController();

  final StreamController _controllerUserLocation = StreamController();

  // GoogleMapController _mapController;
  Completer<GoogleMapController> _mapController = Completer();

  Location userLocation = new Location();
  GeoFirePoint previousUserLocation;

  BehaviorSubject<double> radius = BehaviorSubject.seeded(500.0);
  Stream<dynamic> query;

  Set<Marker> _markers = {};

  Map<MarkerId, Marker> _mapMarkers = <MarkerId, Marker>{};

  StreamSubscription subscription;
  // Stream<List<DocumentSnapshot>> subscription;

  double _zoomValue = 16.0;

  @override
  void initState() {
    print('Begin init');
    super.initState();
    _controllerUserProfile.addStream(_firestore
        .collection('Users')
        .document(authService.currentUid)
        .snapshots()
        .map((snap) => snap.data));

    // Future.delayed(const Duration(seconds: 5), () => "5");

    // startTheQuery();

    print('End init');
  }

  // void startTheQuery() async {
  //   await _startQuery();
  // }

  @override
  void dispose() {
    _controllerUserProfile.close();
    subscription.cancel();
    _controllerUserLocation.close();
    radius.close();
    super.dispose();
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
      // }).listen(_updateMarkers);
    }).listen(_updateMapMarkers);

    print(subscription.toString());
  }

  // _updateQuery(value) {
  //   final zoomMap = {
  //     100.0: 12.0,
  //     200.0: 10.0,
  //     300.0: 7.0,
  //     400.0: 6.0,
  //     500.0: 5.0
  //   };
  //   final zoom = zoomMap[value];
  //   _mapController.moveCamera(CameraUpdate.zoomTo(zoom));

  //   setState(() {
  //     radius.add(value);
  //   });
  // }

  void _updateUserLocation(LocationData data) async {
    // var pos = await userLocation.getLocation();
    // GeoFirePoint point =
    //     geo.point(latitude: pos.latitude, longitude: pos.longitude);

    // if (data.longitude == previousUserLocation.longitude) return null;
    // if (data.latitude == previousUserLocation.latitude) return null;

    if (data.latitude == null) return null;
    if (data.longitude == null) return null;

    GeoFirePoint point =
        geo.point(latitude: data.latitude, longitude: data.longitude);

    var distance = point.distance(
        lat: previousUserLocation.latitude,
        lng: previousUserLocation.longitude);

    print('distance: ' + distance.toString());

    // if (distance <= 0.0) return null;

    if (authService.currentUid == null) {
      print('Map currentuid no good');
      return null;
    }

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
    final GoogleMapController controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      // _mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(pos.latitude, pos.longitude),
      zoom: _zoomValue,
    )));
  }

  _updateMapMarkers(List<DocumentSnapshot> documents) {
    print(documents);
    for (DocumentSnapshot document in documents) {
      if (document == null) continue;

      // If the pin is us, or we can't read the uid, skip
      String uid = document.data['uid'];
      if (uid == authService.currentUid) continue;
      if (uid == null) continue;

      // If the person doesn't have any interests in common, skip
      if (document.data['interests'] != null) {}

      GeoPoint pos = document.data['position']['geopoint'];

      var lat = pos.latitude;
      var lng = pos.longitude;

      if ((lat == null) || (lng == null)) continue;

      _firestore.collection('Users').document(uid).get().then((snap) {
        var userData = snap.data;

        var markerId = MarkerId(uid);

        var marker = Marker(
            markerId: markerId,
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueOrange),
            // icon: BitmapDescriptor.defaultMarker;
            position: LatLng(lat, lng),
            draggable: false,
            infoWindow: InfoWindow(
              title: userData['displayName'],
            ),
            onTap: () {
              showModalBottomSheet<void>(
                  context: context,
                  builder: (BuildContext context) {
                    return ProfileBottomSheet(userData: userData);
                  });
            });

        setState(() {
          _mapMarkers[markerId] = marker;
        });

        print('Added a marker');
      });
    }
  }

  _updateMarkers(List<DocumentSnapshot> documentList) {
    print(documentList);
    _markers.clear();
    for (DocumentSnapshot document in documentList) {
      if (document == null) continue;

      // If the pin is us, skip
      String uid = document.data['uid'];
      if (uid == authService.currentUid) continue;

      print('Not us: ' + document.data['email']);

      // If the person doesn't have any interests in common, skip
      if (document.data['interests'] != null) {}

      GeoPoint pos = document.data['position']['geopoint'];

      var lat = pos.latitude;
      var lng = pos.longitude;

      if ((lat == null) || (lng == null)) continue;

      _firestore.collection('Users').document(uid).get().then((snap) {
        var userData = snap.data;

        var marker = Marker(
            markerId: MarkerId(uid),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueOrange),
            // icon: BitmapDescriptor.defaultMarker;
            position: LatLng(lat, lng),
            draggable: false,
            infoWindow: InfoWindow(
              title: userData['displayName'],
            ),
            onTap: () {
              showModalBottomSheet<void>(
                  context: context,
                  builder: (BuildContext context) {
                    return ProfilePage(uid: userData['uid']);
                  });
            });

        _markers.add(marker);

        print('Added a marker');
      });
    }

    Future.delayed(const Duration(seconds: 5), () => "5");
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
      print('Pressed button 3');
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
            // markers: _markers,
            markers: Set<Marker>.of(_mapMarkers.values),
          ),
          // Positioned(bottom: 5, right: 5, child: animationButton),
          // animationButton,

          Row(
            children: <Widget>[
              FloatingActionButton(
                  heroTag: 'GoToPos',
                  child: Icon(Icons.pin_drop, size: 30.0),
                  foregroundColor: Colors.black,
                  backgroundColor: themeLight().primaryColor,
                  onPressed: () => _animateToUser()),
              FloatingActionButton(
                  heroTag: 'FriendPage',
                  child: Icon(Icons.chat, size: 30.0),
                  foregroundColor: Colors.black,
                  backgroundColor: themeLight().primaryColor,
                  onPressed: () {
                    Navigator.push(
                        context,
                        RouteFromBottom(
                            widget: FriendsPage(
                                currentUid: authService.currentUid)));
                  }),
              FloatingActionButton(
                  heroTag: 'MyUserProfile',
                  child: Icon(Icons.account_circle, size: 30.0),
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.red,
                  onPressed: () {
                    Navigator.push(
                        context,
                        RouteFromBottom(
                            widget: EditProfilePage(
                                uid: authService.currentUid)));
                  }),
              FloatingActionButton(
                  heroTag: 'Logout',
                  child: Icon(Icons.exit_to_app, size: 30.0),
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.black,
                  onPressed: () => _signOut(context)),
            ],
          )

          // Positioned(
          //     bottom: 5,
          //     left: 5,
          //     child: FloatingActionButton(
          //         child: Icon(Icons.pin_drop, size: 30.0),
          //         foregroundColor: Colors.black,
          //         backgroundColor: themeLight().primaryColor,
          //         onPressed: () => _animateToUser())),
          // Positioned(
          //     bottom: 5,
          //     left: 5,
          //     child: FloatingActionButton(
          //         child: Icon(Icons.chat, size: 30.0),
          //         foregroundColor: Colors.black,
          //         backgroundColor: Colors.red,
          //         onPressed: () => _animateToUser()))
        ]),
      ),
    );
  }
}

class ProfileBottomSheet extends StatefulWidget {
  const ProfileBottomSheet({
    Key key,
    @required this.userData,
  }) : super(key: key);

  final Map<String, dynamic> userData;

  @override
  _ProfileBottomSheetState createState() => _ProfileBottomSheetState();
}

class _ProfileBottomSheetState extends State<ProfileBottomSheet> {
  double height = 800.0;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: height,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.transparent, width: 0.0),
        ),
        child: ProfilePage(uid: widget.userData['uid']));
  }
}

class SignOutFunction extends UseFunction {
  @override
  void onClick() {
    authService.signOut();
  }
}

Widget showProfilePhoto(String profileURL) {
    //If there is a photo, we have to pull and cache it, otherwise use the asset template
    if (profileURL != null) {
      //TODO: Implement Firestore image pull
      return FadeInImage.assetNetwork(
        placeholder: PROFILE_PHOTO_PLACEHOLDER_PATH,
        fadeInCurve: SawTooth(1),
        image: profileURL,
        width: 30.0,
        height: 30.0,
        fit: BoxFit.fitHeight,
      );
    } else {
      return Image.asset(
        PROFILE_PHOTO_PLACEHOLDER_PATH,
        width: 30.0,
        height: 30.0,
        fit: BoxFit.scaleDown,
      );
    }
  }

// onPressed: () => _signOut(context)))
//           onPressed: () => {_firestore
// .collection('Users')
// .document('zrHlbJ3oy5hpRPShaFsGL3JVYYl2')
// .setData({'position': geo.point(latitude: -35.2777, longitude: 149.1185).data}, merge: true)})),
