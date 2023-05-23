import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';

const fetchBackground = "fetchBackground";
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class WorkManager extends StatefulWidget {
  const WorkManager({Key? key}) : super(key: key);

  @override
  State<WorkManager> createState() => _WorkManagerState();
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case fetchBackground:
        print("inbackground");
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
        break;
    }
    return Future.value(true);
  });
}

class _WorkManagerState extends State<WorkManager> {
  @override
  void initState() {
    super.initState();
    initalized();
  }

  initalized() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: true,
    );
    await Workmanager().registerPeriodicTask("1", fetchBackground,
        frequency: const Duration(minutes: 15),
        constraints: Constraints(
          networkType: NetworkType.connected,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(),
    );
  }
}
