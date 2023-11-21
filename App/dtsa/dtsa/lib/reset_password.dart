import 'dart:convert';

import 'package:dtsa/utils/settings.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'hexcolor.dart';
import 'login.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ResetPasswordScreen(email: AutofillHints.email,),
    );
  }
}

class ResetPasswordScreen extends StatefulWidget {
  String email;
  ResetPasswordScreen({required this.email});


  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState(email: email);
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  String email;
  _ResetPasswordScreenState({required this.email});
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();
  final Color _red = HexColor("#FC0101");



  @override
  Widget build(BuildContext context) {

    double maxWidth = MediaQuery.of(context).size.width;
    double maxHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(title: Text('Reset Password'),
        backgroundColor: _red,

        leading:   IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black), // Back button icon color
          onPressed: () {
            // Handle back button press
            Navigator.pop(context); // Navigate to the previous page
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
            SizedBox(height: 30.0),
            ElevatedButton(
              onPressed: (){
                String password = _passwordController.text;
                String confirmPassword = _confirmPasswordController.text;
                print("password: $password");
                print('email: $email');
                // Perform validation and reset password logic
                if (password == confirmPassword) {
                  updatePassword(context,email,password);
                 // print('Password reset successful.');
                } else {
                  // Passwords don't match, show an error message
                  print('Passwords do not match.');
                }
              },
              child: Text('Reset Password'),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                primary: _red,
                minimumSize: Size(maxWidth * 0.8, 50),
              ),

            ),
          ],
        ),
      ),
    );
  }

  Future<void> updatePassword(BuildContext context, String email, String password) async {
    try {
      String apiUrl = '${SettingsAPI.apiUrl}/api/update-password';
      Map<String, dynamic> requestBody = {
        'email': email,
        'password': password,
      };

      // Send the POST request
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      // Check the response status code
      if (response.statusCode == 200) {
        print('Password updated successfully.');

        // Show a dialog or a snackbar indicating success
        showDialog(
          context: context,
          builder: (context) => AlertDialog(

            title: Text('Success',
              style: TextStyle(color: Colors.green),
            ),

            content: Text('Password reset is successful.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Login(

                    )),
                  );
                },

                child: Text('Continue'),
              ),
            ],
          ),
        );
      } else {
        print('Error changing password . Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error changing password: $error');
    }



  }


}
