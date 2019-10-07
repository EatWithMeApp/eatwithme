// Adapted from https://github.com/fireship-io/167-flutter-geolocation-firestore/blob/master/lib/main.dart

import 'dart:async';

import 'package:eatwithme/models/models.dart';
import 'package:eatwithme/pages/settings/settings.dart';
import 'package:eatwithme/services/auth.dart';
import 'package:eatwithme/pages/chat/chat_room_list.dart';
import 'package:eatwithme/pages/profile/editProfile.dart';
import 'package:eatwithme/pages/profile/profile.dart';
import 'package:eatwithme/services/db.dart';
import 'package:eatwithme/theme/eatwithme_theme.dart';
import 'package:eatwithme/utils/constants.dart';
import 'package:eatwithme/utils/routeFromBottom.dart';
import 'package:eatwithme/widgets/gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:eatwithme/EatWithMeUI/RadialMenu.dart';
import 'package:eatwithme/EatWithMeUI/MapPin.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final StreamController _controllerUserLocation = StreamController();

  User loggedInUser;
  final db = DatabaseService();
  final auth = AuthService();

  Completer<GoogleMapController> _mapController = Completer();

  Location userLocation = new Location();
  GeoFirePoint previousUserLocation;

  Map<MarkerId, Marker> _mapMarkers = <MarkerId, Marker>{};
  Map<String, User> _mapUsers = <String, User>{};

  Stream<dynamic> query;
  StreamSubscription subscription;

  double _zoomValue = INITIAL_ZOOM_VALUE;

  bool isFilteringUsers = false;
  Color overlay;

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

    showCautionDialog();
  }

  _startQuery() async {
    print('Start Query $loggedInUser');

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
          _mapUsers[uid] = currentUser;
        });
      });
    }
  }

  void filterUserMarkers() {
    _mapMarkers.forEach((id, mapMarker) {
      bool isVisible = true;
      User markerUser = _mapUsers[id.value];

      if (isFilteringUsers &&
          !loggedInUser.doesUserShareInterests(markerUser)) {
        isVisible = false;
      }

      _mapMarkers[id] = mapMarker.copyWith(visibleParam: isVisible);
    });
  }

  Future<void> showCautionDialog() {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(SAFETY_MESSAGE_TITLE),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(SAFETY_MESSAGE),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              color: themeLight().primaryColor,
              textColor: Colors.black,
              child: Text(CONFIRM_SAFETY_MESSAGE),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await auth.signOut();
      loggedInUser = null;
      dispose();
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    loggedInUser = Provider.of<User>(context);

    return Scaffold(
      appBar: PreferredSize(
        child: AppBar(),
        preferredSize: Size.fromHeight(0),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Stack(children: [
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
        SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: FractionallySizedBox(
              heightFactor: 0.08,
              widthFactor: 0.6,
              child: Container(
                height: 50.0,
                width: 50.0,
                alignment: Alignment(0.0, 0.0),
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  color: themeLight().primaryColor,
                ),
                child: SwitchListTile.adaptive(
                  onChanged: (bool value) {
                    setState(() {
                      isFilteringUsers = value;
                      filterUserMarkers();
                    });
                  },
                  isThreeLine: false,
                  value: isFilteringUsers,
                  title: Text(FILTER_USERS_TEXT),
                ),
              ),
            ),
          ),
        ),
        IgnorePointer(
          child: Container(
            decoration: BoxDecoration(
              color: overlay,
            ),
          ),
        ),
        Container(
          alignment: Alignment.bottomRight,
          padding: EdgeInsets.all(25),
          child: RadialMenu(
            onProfileTapped: () {
              Navigator.push(
                  context,
                  RouteFromBottom(
                      widget: EditProfilePage(
                    uid: loggedInUser.uid,
                  )));
              setState(() {
                overlay = Colors.transparent;
              });
            },
            onChatTapped: () {
              Navigator.push(
                  context, RouteFromBottom(widget: ChatRoomListPage()));
              setState(() {
                overlay = Colors.transparent;
              });
            },
            onSettingsTapped: () {
              Navigator.push(context, RouteFromBottom(widget: SettingsPage()));
              setState(() {
                overlay = Colors.transparent;
              });
            },
            onMenuTapped: () {
              setState(() {
                overlay = Color.fromARGB(50, 0, 0, 0);
              });
            },
            onCrossTapped: () {
              setState(() {
                overlay = Colors.transparent;
              });
            },
          ),
        ),
        Container(
          alignment: Alignment.bottomLeft,
          padding: EdgeInsets.all(25),
          child: FloatingActionButton(
              heroTag: 'GoToPos',
              child: Icon(Icons.pin_drop, size: 30.0),
              foregroundColor: Colors.white,
              backgroundColor: Color(0xff333333),
              onPressed: () => _animateToUser()),
        ),
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
