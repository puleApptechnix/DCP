import 'dart:convert';

import 'package:dtsa/utils/DatabaseHelper.dart';
import 'package:dtsa/utils/settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'models/contacts.dart';

class Playing extends StatefulWidget {
  const Playing({Key? key}) : super(key: key);

  @override
  State<Playing> createState() => _PlayingState();
}

class _PlayingState extends State<Playing> {

  List<Contacts> contactsList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: Container(
      child: TextButton(
          onPressed: () {
            initialiseDatabase();
           // updateContactsIfNeeded();
          },
          child: const Text('Fetch contacts'),
      ),
    ),
        ));



  }


  void initialiseDatabase(){
    DatabaseHelper dbHelper = DatabaseHelper();
    if (kDebugMode) {
      print("Creating tables");
    }
    dbHelper.initDb();
    if (kDebugMode) {
      print("done");
    }
  }
  void saveContactsToSQLite(List<Map<String, dynamic>> contacts) async {
    DatabaseHelper dbHelper = DatabaseHelper();

    for (Map<String, dynamic> contact in contacts) {
      await dbHelper.insertOrUpdateContacts(contact);
    }
  }

  void updateContactsIfNeeded() async {
    // Fetch articles from MySQL
    List<Map<String, dynamic>> mysqlArticles = (await fetchContactsFromMySQL()) as List<Map<String, dynamic>>;

    // Save articles to SQLite
    saveContactsToSQLite(mysqlArticles);
  }

  Future<List<Map<String, dynamic>>> fetchContactsFromMySQL() async {
    const String apiUrl = "${SettingsAPI.apiUrl}/api/contacts";
    try {
      var response = await http.get(Uri.parse(apiUrl));
      final jsonResponse = jsonDecode(response.body);

      if (kDebugMode) {
        print('json response: $jsonResponse.toString()');
      }

      List<Map<String, dynamic>> contactsList = []; // Create a new list to store the contacts

      for (var contactData in jsonResponse) {
        int idcontacts = contactData['idcontacts'];
        String email = contactData['email'];
        String number = contactData['number'];

        Map<String, dynamic> contact = {
          'idcontacts': idcontacts,
          'email': email,
          'number': number,
        };
        contactsList.add(contact);

        if (kDebugMode) {
          print('Object name: $email');
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
