import 'dart:convert';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:timezone/timezone.dart' as tz;

class LocalNotificationService {

  int? screenType;
  String? reqID;
  String? userID;
  List<String> payLoadResponse=[];
  Map<String,dynamic> dataPayLoad={};
  String? finalPayLoad;
  LocalNotificationService();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    print(
        "Local Notification {notificationAppLaunchDetails!.didNotificationLaunchApp.toString()}");
    AndroidInitializationSettings initializationSettingsAndroid =
    const AndroidInitializationSettings('notificationicon');
    final DarwinInitializationSettings initializationSettingsDarwin =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification:
          (int id, String? title, String? body, String? payload) async {
        print("Local Notification :: ondidrecivelocal  $payload");
      },
    );
    final InitializationSettings initializationSettings =
    InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onDidReceiveNotificationResponse:notificationTapBackground,
    );
  }
  void notificationTapBackground(NotificationResponse notificationResponse) {

    print('notification payload: STEP 1 ');
    //Fluttertoast.showToast(msg: 'notification payload: STEP 1');
    //await Future.delayed(const Duration(seconds: 1));

    switch (notificationResponse.notificationResponseType) {
      case NotificationResponseType.selectedNotification:
        if (notificationResponse.payload != null) {
          print('notification payload: step 0 if ${notificationResponse.payload}');

          _launchInBrowser(Uri.parse(notificationResponse.payload!));




        }
        break;
      case NotificationResponseType.selectedNotificationAction:
        if (notificationResponse.payload != null) {
          print('notification payload: if ${notificationResponse.payload!}');
          //ToastUtil.showLongToast(navigatorStateKey.currentContext!, 'notification payload: if ' + payload);

        }
        break;
    }
  }
  Future<int> showNotification(int? id,String? title, String? body ,Map<String, dynamic> payLoad) async {
    initNotification();
    print("Local Notification  :: Step 0 ${payLoad['openURL']}");
    const AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
      'SmartNotification',
      'SmartSort',
      channelDescription: 'your channel description',
      color: Color(0XFFFFFF),
      importance: Importance.max,
      priority: Priority.high,
    );

    NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails, iOS: DarwinNotificationDetails());
    await flutterLocalNotificationsPlugin
        .show(0, title, body, notificationDetails, payload: payLoad['openURL'],);
    screenType=int.parse(payLoad['count']);
    return screenType!;
  }
  Future<int> scheduleNotification(int? id,String? title, String? body ,Map<String, dynamic> payLoad) async {
    initNotification();

    tz.timeZoneDatabase;
    final location = tz.getLocation('America/Detroit');

    // Convert current time to the specified timezone
    final tzDateTime = tz.TZDateTime.from(DateTime.now().add(Duration(seconds: 10)), location);
    print("Local Notification  :: Step 0 ${payLoad['openURL']}");
    const AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
      'SmartNotification',
      'SmartSort',
      channelDescription: 'your channel description',
      color: Color(0XFFFFFF),
      importance: Importance.max,
      priority: Priority.high,
    );

    NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails, iOS: DarwinNotificationDetails());
    await flutterLocalNotificationsPlugin
        .zonedSchedule(0, title, body,   tzDateTime ,notificationDetails,  androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime);
    screenType=int.parse(payLoad['count']);
    return screenType!;
  }

  Future<void> _launchInBrowser(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
  }
}


