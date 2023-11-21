import 'dart:convert';


import 'package:dtsa/utils/settings.dart';
import 'package:dtsa/widgets/bottomNavigationBar.dart';
import 'package:dtsa/widgets/sideebar.dart';
import 'package:dtsa/widgets/useful-contacts-card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import 'models/contacts.dart';

class UsefulContacts extends StatefulWidget {
  const UsefulContacts({Key? key}) : super(key: key);

  @override
  State<UsefulContacts> createState() => _UsefulContactsState();
}

class _UsefulContactsState extends State<UsefulContacts> {
  List<Contacts> contactsList = [];

  Future<List<Contacts>> getContacts() async {

    const String apiUrl = "${SettingsAPI.apiUrl}/api/contacts";
    try {
      var response = await http.get(Uri.parse(apiUrl));
      final jsonResponse = jsonDecode(response.body);

      if (kDebugMode) {
        print('json response: $jsonResponse.toString()');
      }

      List<Contacts> contactsList = []; // Create a new list to store the contacts

      for (var contactData in jsonResponse) {
        String name = contactData['name'];
        String email = contactData['email'];
        String number = contactData['number'];

        Contacts contact = Contacts(name, number, email);
        contactsList.add(contact);

        if (kDebugMode) {
          print('Object name: ${contact.name}');
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


  void _launchPhoneApp(String phoneNumber) async {
    String url = 'tel:$phoneNumber';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
  @override
  void initState() {
    super.initState();

    getContacts().then((contacts) {
      setState(() {
        contactsList = contacts;
      });
    });
  }







  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Full Screen',
      theme: ThemeData(
        primaryColor: Colors.white,
      ),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Center(
            child: Text(
              'Useful Contacts',
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          ),
        ),
        drawer: const SideBar(),
        body: Padding(
          padding: EdgeInsets.all(12.0),
          child: Column(
            children: [
              // Image.asset(
              //   'images/Contact Screen 1024x1024.jpg',
              //   width: MediaQuery.of(context).size.width,
              //   height: MediaQuery.of(context).size.height * 0.4,
              //   fit: BoxFit.cover,
              // ),
              Expanded(
                child: ListView.builder(
                  itemCount: contactsList.length,
                  itemBuilder: (context, index) {
                    Contacts contact = contactsList[index];
                    return CardWidget(
                      topText: ' ${contact.name}',
                      leadingImagePath1: 'icons/email.png',
                      emailText: contact.email,
                      bottomText: contact.number,
                      leadingImagePath: 'icons/Call Icon.png',
                      onNumberPressed: () {
                        // Code to dial the number here
                        // For example, use 'url_launcher' package to launch the phone app
                        launch('tel:${contact.number}');
                      },
                      onEmailPressed: () {
                        // Code to open the email here
                        // For example, use 'url_launcher' package to launch the email app
                        launch('mailto:${contact.email}');
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),


          bottomNavigationBar: const BottomNavWidget(),
      ),
    );
  }
}
