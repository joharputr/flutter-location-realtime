import 'package:cron/cron.dart' as cc;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class Cron extends StatefulWidget {
  const Cron({Key? key}) : super(key: key);

  @override
  State<Cron> createState() => _CronState();
}

class _CronState extends State<Cron> {
  @override
  void initState() {
    super.initState();
    initCron();
  }

  initCron() {
    final cron2 = cc.Cron();

    cron2.schedule(cc.Schedule.parse('*/1 * * * *'), () async {
      print('every three minutes');

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
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
