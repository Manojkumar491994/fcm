import 'dart:convert';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:http/http.dart' as https;


import 'LocalNotificationService.dart';
import 'changevalue.dart';
import 'firebase_options.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  registerNotification();
  runApp(const MyApp());
}

void getInAppMessaging() {
  print("in app messageing --> ");

  FirebaseInAppMessaging firebaseInAppMessaging = FirebaseInAppMessaging.instance;
  firebaseInAppMessaging.setAutomaticDataCollectionEnabled(true);
  firebaseInAppMessaging.triggerEvent("on_foreground");

  print("in app messageing --> {${firebaseInAppMessaging.app.name}");

}

void registerNotification() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  FirebaseInAppMessaging _firebaseInAppMessaging = FirebaseInAppMessaging.instance;
  print("token ${await messaging.getToken()}");

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    provisional: false,
    sound: true,
  );
  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    if (kDebugMode) {
      print('User granted permission');
    }
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('NOTIFICATION TITLE: ${jsonEncode(message.data)}');
        print(
            ' Local Notification  NOTIFICATION BODY: ${message.notification?.body}');

        LocalNotificationService localNotificationService =
            LocalNotificationService();
        localNotificationService
            .showNotification(message.hashCode, message.notification?.title,
                message.notification?.body, message.data)
            .then((value) {
          print("return value $value");
          ChangeDate().setCount(value);
          _firebaseInAppMessaging.triggerEvent("fcm_message_received_tr");
        });
      }
      FirebaseMessaging.onMessageOpenedApp.listen((event) {});
    });
  } else {
    if (kDebugMode) {
      print('User declined or has not accepted permission');
    }
  }
  _firebaseInAppMessaging.setAutomaticDataCollectionEnabled(true);}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  LocalNotificationService localNotificationService =
      LocalNotificationService();
  int _counter = 0;

  void _incrementCounter() async {
    setState(() {
      _counter++;
    });
    Map<String, dynamic> body = {
      "to":
          "cNCBGKF2RRqvvN9plLkuxC:APA91bGQDYHiSv6eDx8qSu6puVRxaccrEP82f_ztoLH_MtDbSKfORT-tQtiNRXT9JW4YYG48XSqw6Q0WUAvGnfM3l8lhTuymJcnZm_04a7a1b0eFdSSeWnV2ZZaqrKpAT3P9ytEuvfyx",
      "priority": "high",
      "notification": {
        "body": "New Update is Released",
        "title": "Please tap to update $_counter"
      },
      "data": {
        "openURL":
            "https://play.google.com/store/apps/details?id=com.abqaiq.smartsort&pli=1",
        "count": "$_counter"
      }
    };

    https.Response response = await https.post(
        Uri.parse("https://fcm.googleapis.com/fcm/send"),
        body: jsonEncode(body),
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'key=AAAAvW5ldBE:APA91bGL9T86uCSOAANHujaKnnwp7BECZ1H4z5jEJ4TYUADmymDFrBFV_SE1Xzo63MFqKKy8fRP4alcVpuGrPaY4mo0OpYnQRf4fuNymZEouYPwL6VsfDX5yFHHYCJnhFOA_K3XlTwCZ'
        });
    print("response ${response.body.toString()}");
  }
  void _incrementCounter2() async {
    setState(() {
      _counter++;
    });
    LocalNotificationService localNotificationService=LocalNotificationService();

    localNotificationService.scheduleNotification(0, "hi", "welcome", {});
  }
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                 Text(
                  'You have pushed the button this many times: ${ChangeDate().count}',
                ),
                Text(

                      '${_counter}',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'You have pushed the button this many times: ${ChangeDate().count}',
                ),
                Text(

                  '${ChangeDate().count}',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _triggerPurchaseEvent,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}


void _triggerPurchaseEvent() {
  final FirebaseAnalytics analytics =FirebaseAnalytics.instance;
  analytics.logEvent(
    name: 'purchase_completed',
    parameters: <String, dynamic>{
      'item_id': '123',
      'item_name': 'Sample Item',
      'currency': 'USD',
      'value': 10.0,
    },
  );
}