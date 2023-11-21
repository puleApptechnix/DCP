import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CardWidget extends StatelessWidget {
  final String topText;
  final String bottomText;
  final String emailText;
  final String leadingImagePath1; // Path to the image asset
  final String leadingImagePath; // Path to the image asset
  final VoidCallback? onNumberPressed; // Callback for phone number press
  final VoidCallback? onEmailPressed;  // Callback for email press

  const CardWidget({
    required this.topText,
    required this.bottomText,
    required this.leadingImagePath,
    required this.leadingImagePath1,
    required this.emailText,
    this.onNumberPressed, // Make sure these parameters are nullable
    this.onEmailPressed,
  });

  @override
  Widget build(BuildContext context) {


    void _launchPhoneApp(String phoneNumber) async {
      String url = 'tel:$phoneNumber';
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    }

    void _launchEmailApp(String emailAddress) async {
      String url = 'mailto:$emailAddress';
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              topText,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Image.asset(
                  leadingImagePath,
                  width: 24, // Adjust the width as needed
                  height: 24, // Adjust the height as needed
                ),
                SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    if (onNumberPressed != null) {
                      onNumberPressed!(); // Trigger the callback if provided
                    } else {
                      _launchPhoneApp(bottomText); // Fallback to the default implementation (dial the number)
                    }
                  },
                  child: Text(
                    bottomText,
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                )
              ],
            ),

            SizedBox(height: 4),
            Row(
              children: [
                Image.asset(
                  leadingImagePath1,
                  width: 24, // Adjust the width as needed
                  height: 24, // Adjust the height as needed
                ),
                SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    if (onEmailPressed != null) {
                      onEmailPressed!(); // Trigger the callback if provided
                    } else {
                      _launchEmailApp(emailText); // Fallback to the default implementation (open the email)
                    }
                  },
                  child: Text(
                    emailText,
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),

          ],
        ),
      ),
    );
  }
}
