import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import 'main.dart';

final dio = Dio();

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  /// OPTIONAL, using custom notification channel id
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'my_foreground', // id
    'MY FOREGROUND SERVICE', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.low, // importance must be at low or higher level
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // if (Platform.isIOS) {
  //   await flutterLocalNotificationsPlugin.initialize(
  //     const InitializationSettings(
  //       iOS: IOSInitializationSettings(),
  //     ),
  //   );
  // }

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      // this will be executed when app is in foreground or background in separated isolate
      onStart: onStart,

      // auto start service
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: 'my_foreground',
      initialNotificationTitle: 'AWESOME SERVICE',
      initialNotificationContent: 'Initializing',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      // auto start service
      autoStart: true,

      // this will be executed when app is in foreground in separated isolate
      onForeground: onStart,

      // you have to enable background fetch capability on xcode project
      onBackground: onIosBackground,
    ),
  );

  service.startService();
}

// to ensure this is executed
// run app from xcode, then from xcode menu, select Simulate Background Fetch

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  HttpClient client = HttpClient();
  bool servicestatus = false;
  bool haspermission = false;
  late LocationPermission permission;
  late Position position;
  String long = "", lat = "";
  late StreamSubscription<Position> positionStream;
  // Only available for flutter 3.0.0 and later
  DartPluginRegistrant.ensureInitialized();

  // For flutter prior to version 3.0.0
  // We have to register the plugin manually

  /// OPTIONAL when use custom notification
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      print("state123 foreground");
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      print("state123 background");
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    print("stopServcie");
    service.stopSelf();
  });

  void postData() async {
    Map<String, String> data = {};

    //check bad certificate
    HttpOverrides.global = MyHttpOverrides();
    data.addAll(
        {'username': '001', 'password': 'secret', 'companyCode': 'EDV'});
    dio.interceptors.add(LogInterceptor(responseBody: true));
    await dio.post("https://103.145.82.230:8243/q/global/login", data: data);
  }

  getLocation() async {
    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    print("lattt = " + position.longitude.toString()); //Output: 80.24599079
    print("longggg = " + position.latitude.toString()); //Output: 29.6593457

    placemarkFromCoordinates(position.latitude, position.longitude)
        .then((value) {
      postData();
      print("valueee = $value");
      flutterLocalNotificationsPlugin.show(
        888,
        'COOL SERVICE',
        'Latitude = ${position.latitude} \nLongitude = ${position.longitude} \n${value[0].street.toString()}',
        const NotificationDetails(
          android: AndroidNotificationDetails(
              'my_foreground', 'MY FOREGROUND SERVICE',
              icon: 'ic_bg_service_small',
              ongoing: true,
              styleInformation: BigTextStyleInformation('')),
        ),
      );
    });

    long = position.longitude.toString();
    lat = position.latitude.toString();

    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high, //accuracy of the location data
      distanceFilter: 100, //minimum distance (measured in meters) a
      //device must move horizontally before an update event is generated;
    );

    //berubah setiap ganti location
    StreamSubscription<Position> positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position position) {
      print(position.longitude); //Output: 80.24599079
      print(position.latitude); //Output: 29.6593457
      print("lattt22 = " + position.longitude.toString());
    });
  }

  checkGps() async {
    servicestatus = await Geolocator.isLocationServiceEnabled();
    if (servicestatus) {
      permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permissions are denied');
        } else if (permission == LocationPermission.deniedForever) {
          print("'Location permissions are permanently denied");
        } else {
          haspermission = true;
        }
      } else {
        haspermission = true;
      }

      print("hasPermission = $haspermission");
      if (haspermission) {
        getLocation();
      }
    } else {
      print("GPS Service is not enabled, turn on GPS location");
    }
  }

  // bring to foreground
  Timer.periodic(const Duration(seconds: 10), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        checkGps();
        //geolocatorBackground();
      }
    }

    /// you can see this log in logcat
    print('FLUTTER BACKGROUND SERVICE: ${DateTime.now()}');
    print("cekkbackground");
    service.invoke(
      'update',
      {
        "current_date": DateTime.now().toIso8601String(),
        "device": "device",
      },
    );
  });
}

class BackgroundProcess extends StatefulWidget {
  const BackgroundProcess({Key? key}) : super(key: key);

  @override
  State<BackgroundProcess> createState() => _MyAppState();
}

class _MyAppState extends State<BackgroundProcess> with WidgetsBindingObserver {
  AppLifecycleState? _notification;
  String latitudeTemp = "";
  String addressTemp = "";
  String longitudeTemp = "";

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      print("statteNow = $state");
      _notification = state;
    });
  }

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    initializeService();
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  String text = "Stop Service";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: WillPopScope(
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Service App'),
            ),
            body: Column(
              children: [
                // StreamBuilder<Map<String, dynamic>?>(
                //   stream: FlutterBackgroundService().on('update'),
                //   builder: (context, snapshot) {
                //     if (!snapshot.hasData) {
                //       return const Center(
                //         child: CircularProgressIndicator(),
                //       );
                //     }
                //
                //     Geolocator.getCurrentPosition(
                //             desiredAccuracy: LocationAccuracy.high)
                //         .then((value) {
                //       placemarkFromCoordinates(value.latitude, value.longitude)
                //           .then((value) {
                //         print("valueee = $value");
                //         addressTemp = value[0].street.toString();
                //       });
                //       latitudeTemp = value.longitude.toString();
                //       longitudeTemp = value.latitude.toString();
                //     });
                //
                //     final data = snapshot.data!;
                //     String? device = data["device"];
                //     DateTime? date = DateTime.tryParse(data["current_date"]);
                //     return Column(
                //       children: [
                //         Text("Latitude = ${latitudeTemp}"),
                //         Text("Longitude = ${longitudeTemp}"),
                //         Text("Address = ${addressTemp}"),
                //       ],
                //     );
                //   },
                // ),

                FutureBuilder(
                    future: Geolocator.getCurrentPosition(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else {
                        placemarkFromCoordinates(snapshot.data!.latitude,
                                snapshot.data!.longitude)
                            .then((value) {});
                        return Column(
                          children: [
                            Text("Latitude = ${snapshot.data?.latitude}"),
                            Text("Longitude = ${snapshot.data?.longitude}"),
                            //        Text("Address = ${addressTemp}"),
                          ],
                        );
                      }
                    }),
                ElevatedButton(
                  child: const Text("Foreground Mode"),
                  onPressed: () {
                    FlutterBackgroundService().invoke("setAsForeground");
                  },
                ),
                ElevatedButton(
                  child: const Text("Background Mode"),
                  onPressed: () {
                    FlutterBackgroundService().invoke("setAsBackground");
                  },
                ),
                ElevatedButton(
                  child: Text(text),
                  onPressed: () async {
                    final service = FlutterBackgroundService();
                    var isRunning = await service.isRunning();
                    if (isRunning) {
                      service.invoke("stopService");
                    } else {
                      service.startService();
                    }

                    if (!isRunning) {
                      text = 'Stop Service';
                    } else {
                      text = 'Start Service';
                    }
                    setState(() {});
                  },
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {},
              child: const Icon(Icons.play_arrow),
            ),
          ),
          onWillPop: () async {
            print("kasinini");

            return false;
          }),
    );
  }
}
