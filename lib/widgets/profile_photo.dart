import 'package:eatwithme/utils/constants.dart';
import 'package:flutter/material.dart';

class ProfilePhoto {
  final String profileURL;
  final double width;
  final double height;

  ProfilePhoto({this.profileURL, this.width, this.height});

  Widget getWidget() {
    String photoURL = profileURL;

    if (photoURL == null || photoURL == '') {
      photoURL = PROFILE_PHOTO_PLACEHOLDER_PATH;
    }

    //If there is a photo, we have to pull and cache it, otherwise use the asset template
    return FadeInImage.assetNetwork(
      placeholder: PROFILE_PHOTO_PLACEHOLDER_PATH,
      fadeInCurve: SawTooth(1),
      image: photoURL,
      width: width,
      height: height,
      fit: BoxFit.fitHeight,
    );
  }

  ImageProvider getImageProvider() {
    String photoURL = profileURL;

    if (photoURL == null || photoURL == '') {
      photoURL = PROFILE_PHOTO_PLACEHOLDER_PATH;
    }

    //If there is a photo, we have to pull and cache it, otherwise use the asset template
    return FadeInImage.assetNetwork(
      placeholder: PROFILE_PHOTO_PLACEHOLDER_PATH,
      fadeInCurve: SawTooth(1),
      image: photoURL,
      width: width,
      height: height,
      fit: BoxFit.fitHeight,
    ).image;
  }
}