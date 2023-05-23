import 'dart:isolate';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class AlarmManager extends StatefulWidget {
  const AlarmManager({Key? key}) : super(key: key);

  @override
  State<AlarmManager> createState() => _AlarmManagerState();
}

class _AlarmManagerState extends State<AlarmManager> {
  @override
  void initState() {
    super.initState();

    WidgetsFlutterBinding.ensureInitialized();

    initAlarm();
  }

  initAlarm() async {
    await AndroidAlarmManager.initialize();
    final int helloAlarmID = 0;
    await AndroidAlarmManager.periodic(
        const Duration(seconds: 10), helloAlarmID, printHello);
  }

  @pragma('vm:entry-point')
  static void printHello() {
    final DateTime now = DateTime.now();
    final int isolateId = Isolate.current.hashCode;
    print("[$now] Hello, world! isolate=${isolateId} function='$printHello'");

    flutterLocalNotificationsPlugin.show(
      888,
      'COOL SERVICE',
      'Latitude = ',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'my_foreground',
          'MY FOREGROUND SERVICE',
          icon: 'ic_bg_service_small',
          ongoing: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(),
    );
  }
}
