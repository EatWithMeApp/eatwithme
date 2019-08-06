import 'package:eatwithme/utils/constants.dart';
import 'package:flutter/material.dart';

class ProfilePhoto {
  final String profileURL;
  final double width;
  final double height;

  ProfilePhoto({this.profileURL, this.width, this.height});

  Widget getWidget() {
    //TODO: Confirm if this is the best way to do this

    //If there is a photo, we have to pull and cache it, otherwise use the asset template
    if (profileURL != null) {
      return FadeInImage.assetNetwork(
        placeholder: PROFILE_PHOTO_PLACEHOLDER_PATH,
        fadeInCurve: SawTooth(1),
        image: profileURL,
        width: width,
        height: height,
        fit: BoxFit.fitHeight,
      );
    } else {
      return Image.asset(
        PROFILE_PHOTO_PLACEHOLDER_PATH,
        width: width,
        height: height,
        fit: BoxFit.scaleDown,
      );
    }
  }

  ImageProvider getImageProvider() {
    //TODO: Confirm if this is the best way to do this

    //If there is a photo, we have to pull and cache it, otherwise use the asset template
    if (profileURL != null) {
      return FadeInImage.assetNetwork(
        placeholder: PROFILE_PHOTO_PLACEHOLDER_PATH,
        fadeInCurve: SawTooth(1),
        image: profileURL,
        width: width,
        height: height,
        fit: BoxFit.fitHeight,
      ).image;
    } else {
      return Image.asset(
        PROFILE_PHOTO_PLACEHOLDER_PATH,
        width: width,
        height: height,
        fit: BoxFit.scaleDown,
      ).image;
    }
  }
}