import 'dart:convert';

import 'package:dtsa/utils/settings.dart';
import 'package:dtsa/verify_account_otp.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'hexcolor.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  TextEditingController _emailController = TextEditingController();
  final Color _red = HexColor("#FC0101");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reset Password'),
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
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'Enter your email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),


            ),
            SizedBox(height: 16.0),
            Container(
              //  padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.02),
              height: MediaQuery.of(context).size.height * 0.05,
              width:  MediaQuery.of(context).size.width*0.9,
              margin: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.05,
                  vertical: MediaQuery.of(context).size.height * 0.04),
              decoration: BoxDecoration(
                color: _red,
                borderRadius: BorderRadius.circular(5),
              ),
              child: TextButton(
                onPressed: () {
                  _handleResetPassword();
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => VerifyAccount()),
                  // );

                },
                child: const Text(
                  'Send Request',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleResetPassword() {
    String email = _emailController.text;
    postOTP(context,email);
  //  requestOTP(email);
    // TODO: Call your API here to handle password reset using the 'email' variable.
    // You can use packages like 'http' or 'dio' to make API calls.
    print('Calling API for password reset with email: $email');
  }
}


Future<void> postOTP(BuildContext context, String userEmail) async {
  // Base URL of the API
  final String baseUrl = "${SettingsAPI.apiUrl}"; // Replace this with your actual API domain

  // Endpoint for the add-otp route
  final String addOtpEndpoint = '/api/add-otp';

  // Create a random OTP code
  int code = 1000 + (DateTime.now().millisecondsSinceEpoch % 9000);
  String codeToServer = code.toString();

  // Prepare the OTP data to be sent
  Map<String, dynamic> otpData = {
    'user_email': userEmail,
    //  'code': codeToServer,
  };

  // Make the POST request
  try {
    final response = await http.post(
      Uri.parse('$baseUrl$addOtpEndpoint'),
      body: otpData,
    );

    if (response.statusCode == 200) {
      print('OTP sent successfully!');
      // Do something here after the OTP is successfully sent

      // Redirect to the VerifyAccount page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => VerifyAccount(
          email: userEmail,
        )),
      );
    } else {
      print('Failed to send OTP. Status code: ${response.statusCode}');
      // Handle the error case here
    }
  } catch (e) {
    print('Error sending OTP: $e');
    // Handle any network or other errors here
  }

}
