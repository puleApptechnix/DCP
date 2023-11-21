import 'dart:convert';

import 'package:dtsa/models/articles.dart';
import 'package:dtsa/utils/settings.dart';
import 'package:dtsa/widgets/bottomNavigationBar.dart';
import 'package:dtsa/widgets/sideebar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';

import 'models/notifications.dart';

class Notifications extends StatefulWidget {
  const Notifications({Key? key}) : super(key: key);

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  List<Map<String, dynamic>> notifications = [];
  List<NotificationsModel> notificationsList = [];

  @override
  void initState() {
    super.initState();

    getNotifications().then((item) {
      setState(() {
        notificationsList = item;
      });
    });

    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   print('Received message: ${message.data}');
    //   _handleNotification(message.data);
    // });
  }

  // void _handleNotification(Map<String, dynamic> message) {
  //   setState(() {
  //     if (kDebugMode) {
  //       print("Message $message");
  //      // print("notifications $notifications");
  //     }
  //     notifications.add(message);
  //   });
  // }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SideBar(),
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.15,
            width: double.infinity,
            child: Image.asset(
              "images/Company Logos.png",
              width: double.infinity,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: notificationsList.length,
              itemBuilder: (context, index) {
                final notification = notificationsList[notificationsList.length - 1 - index];
                return Container(
                  margin: EdgeInsets.all(1),
                  padding: EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        color: Colors.white,
                        width: MediaQuery.of(context).size.width * 0.2,
                        height: MediaQuery.of(context).size.height * 0.1,
                        child: Stack(
                          children: [
                            Image.asset(
                              'images/icon-notification.png',
                              width: double.infinity,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Text(
                                notification.title ?? 'No Title',
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Text(
                                    (notification.message ?? 'default').length <= 30
                                        ? notification.message ?? 'default'
                                        : '${notification.message.substring(0, 27)}...',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Text(
                                    notification.time.substring(0, 10) ?? 'No Title',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavWidget(),
    );
  }


  Future<List<NotificationsModel>> getNotifications() async {
    String email = FirebaseAuth.instance.currentUser!.email!;
    const String apiUrl = "${SettingsAPI.apiUrl}/api/notifications";
    try {
      var response = await http.get(Uri.parse('$apiUrl?user_email=$email'));
      final jsonResponse = jsonDecode(response.body);
      if (kDebugMode) {
        print('json response: $jsonResponse.toString()');
      }

      List<NotificationsModel> contactsList =
          []; // Create a new list to store the contacts

      for (var contactData in jsonResponse) {
        String title = contactData['title'];
        String message = contactData['message'];
        int idnotifications = contactData['idnotifications'];
        String time = contactData['time'];
        int is_read = contactData['is_read'];
        int division_id = contactData['division_id'];
        int department_id = contactData['department_id'];

        NotificationsModel contact = NotificationsModel(idnotifications, title,
            message, time, is_read, division_id, department_id);
        contactsList.add(contact);

        if (kDebugMode) {
          print('Object name: ${contact.title}');
        }
      }

      return contactsList;
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
      return []; // Return an empty list if an error occurs
    }
  }
}
