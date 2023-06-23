import 'dart:io';

import 'package:background_proccess/background_proccess.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp2());
}

class MyApp2 extends StatefulWidget {
  const MyApp2({Key? key}) : super(key: key);

  @override
  State<MyApp2> createState() => _MyApp2State();
}

class _MyApp2State extends State<MyApp2> {

  @override
  void initState() {
    super.initState();
    checkDeviceInfo();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(builder: (context) {
        return Scaffold(
          appBar: AppBar(
            title: Text("widget.title"),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'You have pushed the button this many times:',
                ),
                Text(
                  "",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const BackgroundProcess()));
            },
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          ), // This trailing comma makes auto-formatting nicer for build methods.
        );
      }),
    );
  }

  Future<void> checkDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

    if (Platform.isAndroid) {
      if (androidInfo.version.sdkInt < 26) {
        await Geolocator.getCurrentPosition();
        checkPermission();
      } else {
        checkPermissionLocation();
      }
    }

  }
}

void checkPermission() async {
  var location = await Permission.location.status;
  var notification = await Permission.notification.status;
  if (location.isDenied || notification.isDenied) {
    print("permCehck1 = ${location.isGranted} , ${notification.isGranted} ");

    await [
      Permission.notification,
    ].request();
  }

// You can can also directly ask the permission about its status.
  if (await Permission.location.isRestricted) {
    // The OS restricts access, for example because of parental controls.
  }
}

void checkPermissionLocation() async {
  var status = await Permission.locationWhenInUse.status;
  if (!status.isGranted) {
    var status = await Permission.locationWhenInUse.request();
    if (status.isGranted) {
      var status = await Permission.locationAlways.request();
      if (status.isGranted) {
        checkPermission();
      } else {
        //Do another stuff
      }
    } else {
      //The user deny the permission
    }
    if (status.isPermanentlyDenied) {
      //When the user previously rejected the permission and select never ask again
      //Open the screen of settings
      bool res = await openAppSettings();
    }
  } else {
    //In use is available, check the always in use
    var status = await Permission.locationAlways.status;
    if (!status.isGranted) {
      var status = await Permission.locationAlways.request();
      if (status.isGranted) {
        checkPermission();
      } else {
        //Do another stuff
      }
    } else {
      //previously available, do some stuff or nothing
    }
  }
}
