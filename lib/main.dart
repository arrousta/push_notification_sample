import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:workmanager/workmanager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

//this is the name given to the background fetch
const simplePeriodicTask = "simplePeriodicTask";
// flutter local notification setup
void showNotification(v, flp) async {
  var android = const AndroidNotificationDetails('channel id', 'channel NAME',
      priority: Priority.high, importance: Importance.max);

  //var iOS = IOSNotificationDetails();
  var platform = NotificationDetails(android: android);
  await flp.show(0, 'SOHA Push Notification', '$v', platform,
      payload: 'VIS \n $v');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Workmanager().initialize(callbackDispatcher,
      isInDebugMode:
          true); //to true if still in testing lev turn it to false whenever you are launching the app

  await Workmanager().registerPeriodicTask("5", simplePeriodicTask,
      existingWorkPolicy: ExistingWorkPolicy.replace,
      frequency: Duration(minutes: 15), //when should it check the link
      initialDelay:
          Duration(seconds: 5), //duration before showing the notification
      constraints: Constraints(
        networkType: NetworkType.connected,
      ));
  runApp(MyApp());
}

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    FlutterLocalNotificationsPlugin flp = FlutterLocalNotificationsPlugin();

    var android = AndroidInitializationSettings('@mipmap/ic_launcher');
    //var iOS = IOSInitializationSettings();
    var initSetttings = InitializationSettings(android: android);
    flp.initialize(initSetttings);

    Uri uri = Uri.parse("https://app.srahmadi.ir/usersignin.php");
    var response = await http.post(
      uri,
      body: {'username': '1016', 'password': '0057'},
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      encoding: Encoding.getByName('utf-8'),
    );
    // print("here================");
    var convert = json.decode(response.body);
    print(convert);
    if (convert['id'] == '2') {
      showNotification(convert['name'], flp);
    } else {
      print("no messgae");
    }
    // showNotification('A new Push Notification from Alireza', flp);
    return Future.value(true);
  });
}

class MyApp extends StatelessWidget {
  MyApp();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter notification',
        theme: ThemeData(
          primarySwatch: Colors.teal,
        ),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            appBar: AppBar(
              title: Text("Testing push notification"),
              centerTitle: true,
            ),
            body: Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                    child: Text(
                        "Flutter push notification without firebase with background fetch feature")),
              ),
            )));
  }
}
