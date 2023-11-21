import 'dart:convert';

import 'package:dtsa/reset_password.dart';
import 'package:dtsa/utils/settings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'hexcolor.dart';
import 'login.dart';
import 'models/otp.dart';



class VerifyAccount extends StatefulWidget {
  String email;

  VerifyAccount({required this.email});

  @override
  State<VerifyAccount> createState() => _VerifyAccountState(email: email);
}

class _VerifyAccountState extends State<VerifyAccount> {
  String email;

  _VerifyAccountState({required this.email});
  List<FocusNode> _focusNodes = List.generate(4, (index) => FocusNode());
  List<TextEditingController> _controllers = List.generate(
    4,
        (index) => TextEditingController(),
  );
  final Color _red = HexColor("#FC0101");
  String otp = '';

  @override
  void dispose() {
    for (int i = 0; i < _controllers.length; i++) {
      _focusNodes[i].dispose();
      _controllers[i].dispose();
    }
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    double maxWidth = MediaQuery.of(context).size.width;
    double maxHeight = MediaQuery.of(context).size.height;


    return Scaffold(

    appBar:  AppBar(
        title: Text('Forgot Password'),
        backgroundColor: _red,
        leading:   IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black), // Back button icon color
          onPressed: () {
            // Handle back button press
            Navigator.pop(context); // Navigate to the previous page
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(bottom: 0),
          // constraints: const BoxConstraints(
          //   maxWidth: double.infinity,
          //   maxHeight: double.infinity,
          // ),
          height: maxHeight,
          width: maxWidth,
          color: HexColor('#EFEFEF'),

          //All the widgets are in this Column (Parent widget)
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              SizedBox(
                height: 100,
              ),
              //Personal Details Widget
              Padding(
                padding: const EdgeInsets.only(left: 40),
                child: Text(
                  'OTP Code',
                  // text: TextCapitalization.characters,
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      color: HexColor('#042F55'),
                      fontFamily: 'SFNewRepublic_Bold'),
                ),
              ),

              Container(
                padding: EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(4, (index) => _buildOTPTextField(index)),
                ),
              ),



              //Container holding the Texts and Text fields

              SizedBox(height: maxHeight * 0.3,),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    primary: _red,
                    minimumSize: Size(maxWidth * 0.8, 50),
                  ),
                  onPressed: () {
                    // Use the otp variable here
                    verifyOTP(otp);
                  },
                  child: Text(
                    'Proceed',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'SFNewRepublic',
                    ),
                  ),
                ),
              )


            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOTPTextField(int index) {
    return Container(
      width: 60.0,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        onChanged: (value) {
          if (value.isNotEmpty) {
            _focusNodes[index].unfocus();
            if (index < _focusNodes.length - 1) {
              _focusNodes[index + 1].requestFocus();
            }
          }

          // Update the otp variable when any field changes
          otp = _controllers.map((controller) => controller.text).join('');
        },
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: HexColor('#FFFFFF'),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(20.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
      ),
    );
  }



  //Future<List<Articles>>
  verifyOTP(String otpCode) async {


    String apiUrl = "${SettingsAPI.apiUrl}/api/otp/$email";
    try {
      var response = await http.get(Uri.parse(apiUrl));
      final jsonResponse = jsonDecode(response.body);

      if (kDebugMode) {
        print('json response: $jsonResponse.toString()');
      }

    //  List<OTP> otpList = []; // Create a new list to store the contacts

      for (var otpData in jsonResponse) {

        int idotp =otpData["idotp"] ;
        String user_email=otpData["user_email"] ;

        String code=otpData["code"];


        OTP otp = OTP(idotp,user_email,code);

        if(otpCode == otp.code){

          if (kDebugMode) {
            print('OTP id : ${otp.idotp}');
          }

          deleteOTP1(otp.idotp);

        }

      }

     // return true;
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
     // false ; // Return an empty list if an error occurs
    }
  }

  Future<void> deleteOTP( int id) async {

    try {
      String apiUrl = "${SettingsAPI.apiUrl}/api/delete-otp";
      Map<String, dynamic> requestBody = {
        'id': id,

      };

      // Send the DELETE request
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      // Check the response status code
      if (response.statusCode == 200) {
        print('OTP removed successfully.');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ResetPasswordScreen(
            email: email,
          )),
        );
      } else if (response.statusCode == 404) {
        print('OTP not found.');
      }
      else {
        print('Error removing OTP. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error removing OTP : $error');
    }


  }



  Future<void> deleteOTP1(int id) async {
    final url = Uri.parse('${SettingsAPI.apiUrl}/api/delete-otp?id=$id');

    try {
      final response = await http.post(url);

      if (response.statusCode == 200) {
        // Success: OTP code deleted
        print('OTP code deleted successfully.');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ResetPasswordScreen(
            email: email,
          )),
        );
      } else {
        // Error: Failed to delete OTP code
        print('Failed to delete OTP code. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Error: Exception occurred during the request
      print('An error occurred: $e');
    }
  }


}
