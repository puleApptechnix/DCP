import 'dart:convert';

import 'package:dtsa/privacy_policy.dart';
import 'package:dtsa/profile.dart';
import 'package:dtsa/useful-contacts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../favourites.dart';
import '../login.dart';
import '../notifications.dart';
import 'package:http/http.dart' as http;
import 'package:yaml/yaml.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../utils/settings.dart';

class SideBar extends StatefulWidget {
  const SideBar({Key? key}) : super(key: key);


  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  String appVersion ='null';
  @override
  void initState() {
    super.initState();
    getAppVersion();
  }
  @override
  Widget build(BuildContext context) {
    return Drawer(
      // Sidebar content goes here
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
                // color: Colors.white,
                ),
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.end, // Align content at the bottom
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Menu',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        Navigator.pop(context); // Close the sidebar
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Profile(

                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite_border),
            title: const Text('Favourites'),
            onTap: () {
              // Get the email of the currently authenticated user
              String email = FirebaseAuth.instance.currentUser!.email!;
              // Navigate to the ChatPage and pass the email as an argument
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Faourites(
                    email: email,
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Notifications(

                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.headset_mic_outlined),
            title: const Text('Useful Contacts'),
            onTap: () {
              // Get the email of the currently authenticated user
              String email = FirebaseAuth.instance.currentUser!.email!;

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UsefulContacts(
                  ),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.policy),
            title: const Text('Privacy Policy'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Policy(

                  ),
                ),
              );
            },
          ),






          ListTile(
            leading: const Icon(Icons.logout_sharp),
            title: const Text('Logout'),
            onTap: () async {
              deleteUserToken_SignOut();

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const Login(),
                ),
              );
            },


          ),

          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('App Version'),
            trailing: Text(appVersion),
          ),
        ],
      ),
    );
  }

  Future<void> getAppVersion() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String version = packageInfo.version;
      String buildNumber = packageInfo.buildNumber;
      setState(() {
        appVersion = '$version+$buildNumber';
      });
    } catch (e) {
      print('Error getting app version: $e');
    }
  }


  Future<void> deleteUserToken_SignOut() async {
    String email = FirebaseAuth.instance.currentUser!.email!;
    deleteUserData(email);

    try {
      String apiUrl = "${SettingsAPI.apiUrl}/api/delete-token";
      Map<String, dynamic> requestBody = {
        'user_email': email,
      };

      // Send the DELETE request
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      // Check the response status code
      if (response.statusCode == 200) {
        print('Token removed successfully.');
        await FirebaseAuth.instance.signOut();
        print('user signed out');
      } else if (response.statusCode == 404) {
        print('Token not found.');
      } else if (response.statusCode == 409) {
        print('You have already removed this Token.');
      } else {
        print('Error removing token. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error removing Token from database: $error');
    }


  }



  void deleteUserData(String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', false);
    prefs.setString('userEmail', '');
  }
}
