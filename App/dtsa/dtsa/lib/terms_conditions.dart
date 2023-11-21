import 'dart:convert';

import 'package:dtsa/utils/settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Terms extends StatefulWidget {
  const Terms({Key? key}) : super(key: key);

  @override
  State<Terms> createState() => _TermsState();
}

class _TermsState extends State<Terms> {
String Terms= '';

  Future<String> getTerms() async {

    const String apiUrl = "${SettingsAPI.apiUrl}/api/terms";
    try {
      var response = await http.get(Uri.parse(apiUrl));
      final jsonResponse = jsonDecode(response.body);

      if (kDebugMode) {
        print('json response: $jsonResponse.toString()');
      }

     String _terms ='';

      for (var contactData in jsonResponse) {
        int idterms_conditions = contactData['idterms_conditions'];
        String terms = contactData['terms'];

          _terms = terms;

        if (kDebugMode) {
          print('Terms: ${terms}');
        }
      }

      return _terms;
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

    getTerms().then((terms) {
      setState(() {
        Terms = terms;
      });
    });


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms and Conditions'),
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
                    'Terms and Conditions',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 16.0),
                  Text(
                        Terms,
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
