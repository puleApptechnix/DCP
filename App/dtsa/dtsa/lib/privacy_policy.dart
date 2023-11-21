import 'dart:convert';

import 'package:dtsa/utils/settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Policy extends StatefulWidget {
  const Policy({Key? key}) : super(key: key);

  @override
  State<Policy> createState() => _PolicyState();
}

class _PolicyState extends State<Policy> {

  String Policy= '';

  Future<String> getPolicy() async {

    const String apiUrl = "${SettingsAPI.apiUrl}/api/policy";
    try {
      var response = await http.get(Uri.parse(apiUrl));
      final jsonResponse = jsonDecode(response.body);

      if (kDebugMode) {
        print('json response: $jsonResponse.toString()');
      }

      String _policy ='';

      for (var contactData in jsonResponse) {
        int idprivacy_policy = contactData['idprivacy_policy'];
        String policy = contactData['policy'];

        _policy = policy;

        if (kDebugMode) {
          print('Policy: ${policy}');
        }
      }

      return _policy;
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
      return "Null"; // Return an empty list if an error occurs
    }
  }


  @override
  void initState() {
    super.initState();

    getPolicy().then((policy) {
      setState(() {
        Policy = policy;
      });
    });


  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: Colors.red,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black), // Back button icon color
          onPressed: () {
            // Handle back button press
            Navigator.pop(context); // Navigate to the previous page
          },
        ),

      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          Card(
            elevation: 4.0,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Privacy Policy',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 16.0),
                  Text(
                    Policy,
                    style: TextStyle(fontSize: 16.0),
                  ),
                  /**
                      SizedBox(height: 16.0),
                      Text(
                      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla in diam dui. Morbi eu sagittis nibh, a aliquam orci. Donec eleifend, nisl vitae pretium pharetra, tellus tellus tempus urna, auctor tempus tellus tortor sit amet mi. Ut laoreet urna ac efficitur gravida. Integer nec nunc nec purus consectetur sollicitudin vitae ac dui.',
                      style: TextStyle(fontSize: 16.0),
                      ),**/
                  // Add more sections as needed
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
