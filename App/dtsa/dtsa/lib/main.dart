
import 'package:dtsa/posts_categores.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';
import 'notifications.dart';
import 'onboard_screen_one.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // Import the local notifications package


final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();


Future<void> showNotification(RemoteMessage message) async {
  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
    '123456', // Replace with your own channel ID
    'DTSA',
    importance: Importance.max,
    priority: Priority.high,
  );

  var platformChannelSpecifics =
  NotificationDetails(android: androidPlatformChannelSpecifics);

  // Extract the payload from the notification data
  String payload = message.data['payload'] ?? '';
  print('Received payload: $payload'); // Add this debugging statement

  await _flutterLocalNotificationsPlugin.show(
    0,
    message.notification!.title,
    message.notification!.body,
    platformChannelSpecifics,
    payload: payload,
  );
}




Future<void> backgroundMessageHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("onBackgroundMessage: $message");
  showNotification(message);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(backgroundMessageHandler);


  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  String? userEmail = prefs.getString('userEmail');

  //  await Firebase.initializeApp(
  //      options: const FirebaseOptions(
  //        apiKey: "AIzaSyBefCBpOaQhaATXVyuxxL166z3kL2gUTA0",
  //        storageBucket: "dtsa-app.appspot.com",
  //        appId: "1:552457506027:web:ab4dfc80c802341deb82ae",
  //        messagingSenderId: "552457506027",
  //        projectId: "dtsa-app",
  //      ));

runApp( MyApp());

}

class MyApp extends StatefulWidget {


  @override
  State<MyApp> createState() => _MyAppState();
}





class _MyAppState extends State<MyApp> {
  bool isLoggedIn = false;
  String email='';

  void checkUserLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      print('is logged in: $isLoggedIn');
      email = prefs.getString('userEmail')!;
    });
  }

  @override
  void initState() {
    super.initState();
    initializeLocalNotifications();
    configureFirebaseMessaging();
    checkUserLoggedIn();


  }


  void configureFirebaseMessaging() {
    // Request permission to receive push notifications
    _firebaseMessaging.requestPermission();

    // Handle incoming messages when the app is in the foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("onMessage foreground: $message");
      showNotification(message);
    });

    // Handle the initial message when the app is launched from a terminated state
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print("getInitialMessage: $message");
        // Handle the initial message as needed

        // Extract the payload from the initial message
        String payload = message.data['payload'] ?? '';
      print('payload: $payload');
        if (payload.isNotEmpty) {
          print('payload: $payload');
          // Navigate to the appropriate page based on the payload
          if (payload == 'notification') {
           // Navigator.of(context).pushNamed('/notification');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Notifications(

              ),
            )
            );

          } else if (payload == 'explore') {
            Navigator.of(context).pushNamed('/explore');
          }
        }
      }
    });
  }



  void initializeLocalNotifications() {
    var initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
   // var initializationSettingsIOS = IOSInitializationSettings(); // No specific settings for iOS

    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
   //   iOS: initializationSettingsIOS, // Include iOS settings
    );

    _flutterLocalNotificationsPlugin.initialize(initializationSettings);




  }


  @override
  Widget build(BuildContext context) {



    return  MaterialApp(
        debugShowCheckedModeBanner: false, // Disable debug banner
        title: 'chat',


        theme: ThemeData(
         // useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),


      home: isLoggedIn ? HomePage(email: email,) : ScreenOne(),
      routes: {
        // other routes
        '/notification': (context) => Notifications(),
        '/explore':(context) => Posts(email: email),
        '/home': (context) => HomePage(email: email)
      },
    );

  }

}
