import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class BackgroundProvider extends ChangeNotifier {
  Future<String> getLocation() async {
    String address = "";
    Geolocator.getCurrentPosition().then((value) {
      placemarkFromCoordinates(value.latitude, value.longitude).then((value) {
        address = value[0].name.toString();
      });
    });
    return address;
  }
}
