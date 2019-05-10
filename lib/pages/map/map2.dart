import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatwithme/pages/auth/auth.dart';
import 'package:eatwithme/pages/map/animationButton.dart';
import 'package:eatwithme/theme/eatwithme_theme.dart';
import 'package:eatwithme/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class Map2 extends StatefulWidget {
  @override
  _Map2State createState() => _Map2State();
}

class _Map2State extends State<Map2> {
  final Firestore _firestore = Firestore.instance;
  final StreamController _controllerUserProfile = StreamController();

  GoogleMapController _mapController;
  Location location = new Location();

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
    setState(() {
      _mapController = controller;
    });
  }

  void _addMarker() {
    // var marker = MarkerOptions(
    //     position: _mapController.cameraPosition.target,
    //     icon: BitmapDescriptor.defaultMarker,
    //     infoWindowText: InfoWindowText('Magic Marker', '🍄🍄🍄'));

    // _mapController.addMarker(marker);
  }

  _animateToUser() async {
    LocationData pos = await location.getLocation();
    _mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      //target: LatLng(pos['latitude'], pos['longitude']),
      target: LatLng(pos.latitude, pos.longitude),
      zoom: 17.0,
    )));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        body: Stack(alignment: AlignmentDirectional.bottomEnd, children: [
          GoogleMap(
            initialCameraPosition:
                CameraPosition(target: GeoPointANU, zoom: 16.0),
            onMapCreated: _onMapCreated,
            rotateGesturesEnabled: true,
            compassEnabled: true,
            myLocationEnabled: true,
            mapType: MapType.normal,
            myLocationButtonEnabled: false,
          ),
          Positioned(bottom: 5, right: 5, child: AnimationButton()),
          Positioned(
              bottom: 5,
              left: 5,
              child: FloatingActionButton(
                  child: Icon(Icons.pin_drop, size: 30.0),
                  backgroundColor: themeLight().primaryColor,
                  onPressed: () => _animateToUser()))
        ]),
      ),
    );
  }
}
