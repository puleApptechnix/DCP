import 'dart:convert';

import 'package:dtsa/home.dart';
import 'package:dtsa/posts_categores.dart';
import 'package:dtsa/terms_conditions.dart';
import 'package:dtsa/utils/settings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'chat-page.dart';
import 'forgot_password.dart';
import 'full_article.dart';
import 'hexcolor.dart';
import 'models/logo.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final Color _red = HexColor("#FC0101");
  bool _isObscure3 = true;
  bool visible = false;
  final _formkey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isChecked = false; // Track the state of the checkbox

  String passwordError = ''; // Initialize the password error message
  Logo? logo; // Make user nullable
  late Future<Logo?> _logoFuture; // Declare a Future for logo fetching
  @override
  void initState() {
    super.initState();
    _logoFuture = getLogo(); // Initialize the logo fetching Future
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black, Colors.white],
            stops: [0.6, 0.4],
          ),
        ),
        child: SafeArea(
          child: Form(
            key: _formkey,
            child: Theme(
            data: Theme.of(context).copyWith(
    unselectedWidgetColor: Colors.white, // Set checkbox color
    ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.height * 0.03,
                  ),
                  child: Text(
                    'Login',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: MediaQuery.of(context).size.height * 0.035,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.05,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Email',
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.height * 0.018,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.005),
                      TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Enter your email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Email cannot be empty";
                          }
                          if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
                              .hasMatch(value)) {
                            return ("Please enter a valid email");
                          } else {
                            return null;
                          }
                        },
                        onSaved: (value) {
                          emailController.text = value!;
                        },
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.02),
                      Text(
                        'Password',
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.height * 0.018,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.005),
                      TextFormField(
                        controller: passwordController,
                        obscureText: _isObscure3,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Enter your password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        validator: (value) {
                          RegExp regex = RegExp(r'^.{6,}$');
                          if (value!.isEmpty) {
                            return "Password cannot be empty";
                          }
                          if (!regex.hasMatch(value)) {
                            return ("please enter valid password min. 6 character");
                          } else {
                            return null;
                          }
                        },
                        onSaved: (value) {
                          passwordController.text = value!;
                        },
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.02),
                      Center(
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                // Handle Forgot Password tap
                              },
                              child:GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => ForgotPasswordPage()),
                                  );
                                },
                                child: const Center(
                                  child: Text(
                                    'Forgot Password',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.02),
                      Row(
                        children: [
                          Checkbox(
                            visualDensity: VisualDensity.compact,
                            activeColor: Colors.white,
                            checkColor: Colors.black,
                            value: isChecked,
                            onChanged: (value) {
                              setState(() {
                                isChecked = value ?? false;
                              });
                            },
                          ),
                    RichText(
                      text: TextSpan(
                        text: 'I have received and accept the ',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                        children: [
                          TextSpan(
                            text: 'Terms and conditions',
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                // Redirect to another page or perform an action here
                              Navigator.push(context, MaterialPageRoute(builder: (context) => Terms()));
                              },
                          ),
                        ],
                      ),
                    ),
                          Spacer(),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.15),
                Container(
                  //  padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.02),
                  height: MediaQuery.of(context).size.height * 0.05,
                  margin: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.05,
                      vertical: MediaQuery.of(context).size.height * 0.04),
                  decoration: BoxDecoration(
                    color: _red,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        //  visible = true;
                      });
                    //  _saveDeviceToken('token', 'email');
                      signIn(emailController.text, passwordController.text);
                    //   Navigator.push(
                    //     context,
                    //     MaterialPageRoute(builder: (context) => const Article()),
                    //   );
                    },
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                FutureBuilder<Logo?>(
                  future: _logoFuture, // Use the Future here
                  builder: (BuildContext context, AsyncSnapshot<Logo?> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      // Display a loading widget while waiting for the image
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      // Handle error
                      return Text('Error: ${snapshot.error}');
                    } else {
                      // Image fetched successfully, display it
                      Logo? logo = snapshot.data;
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).size.height * 0.02,
                          ),
                          child: Image.network(
                            '${SettingsAPI.apiUrl}/uploads/profiles/${logo?.picture ?? 'https://picsum.photos/id/1/200/300'}',
                            // ...
                          ),
                        ),
                      );
                    }
                  },
                )
              ],
            ),
          ),
        ),
      ),
    ),);
  }

  Future<Logo> getLogo() async {
    const String apiUrl = "${SettingsAPI.apiUrl}/api/logo";

    try {
      var response = await http.get(Uri.parse(apiUrl));
      final jsonResponse = jsonDecode(response.body);

      if (kDebugMode) {
        print('json response: $jsonResponse.toString()');
      }

      if (jsonResponse.isNotEmpty) {
        var contactData = jsonResponse[0]; // Assuming you expect a single logo

        int idpictures = contactData['idpictures'];
        String picture = contactData['picture'];
        Logo _logo = Logo(picture, idpictures);
        setState(() {
          logo = _logo;
        });

        if (kDebugMode) {
          print('Picture: $picture');
        }

        return _logo;
      } else {
        // Handle the case where the API response is empty
        throw Exception('API response is empty');
      }
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
      throw error; // Re-throw the error so that it can be handled at a higher level
    }
  }





  void saveUserLogin(String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', true);
    prefs.setString('userEmail', email);
  }




  void signIn(String email, String password) async {
    if (_formkey.currentState!.validate() && isChecked == true) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);
        print("login email: $email");

        final fcmToken = await FirebaseMessaging.instance.getToken();
        String token = fcmToken.toString();
        print('--------------------------------------');
        print(token);
        saveUserLogin(email);
        _saveDeviceToken(token, email);
        // Navigate to the next screen or perform other actions here.
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          // Handle user not found error
          showLoginErrorDialog('No user found for that email.');
        } else if (e.code == 'wrong-password') {
          // Handle wrong password error
          showLoginErrorDialog('Wrong password provided for that user.');
        } else {
          // Handle other FirebaseAuthException errors
          showLoginErrorDialog('An error occurred while signing in.');
        }
      }
    }else{
      showLoginErrorDialog('Please read and accept the terms and conditions first');
    }
  }

  void showError(String errorMessage) {
    // Use showDialog to display the error message in a pop-up dialog
    showLoginErrorDialog(errorMessage);
  }



  void _saveDeviceToken(String token, String email) async{
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context1) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    Map<String, dynamic> data = {
      "token": token,
      "email": email,
    };

    String jsonData = json.encode(data);
    Uri url = Uri.parse('${SettingsAPI.apiUrl}/api/user/token');



    http.post(url,
        body: jsonData,
        headers: {'Content-Type': 'application/json'}).then((response) async {
      int statusCode = response.statusCode;
      print('status code: $statusCode');
    //  var responseBody = json.decode(response.body);

    //  String message = responseBody['message'];
if(statusCode==200){

  print("user logged in , token added");
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => HomePage(
        email: email,
      ),
    ),
  );
}else{
  print('Error saving device token');
}






    }).catchError((error) {
      print('Error: $error');

      // Close the dialog on error
      Navigator.of(context).pop();
    });


  }


  void showLoginErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Login Error'),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

}
