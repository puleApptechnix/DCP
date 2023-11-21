import 'dart:convert';

import 'package:dtsa/utils/settings.dart';
import 'package:dtsa/widgets/bottomNavigationBar.dart';
import 'package:dtsa/widgets/sideebar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'login.dart';
import 'message.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

import 'models/users.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Users? user; // Make user nullable
  bool isLoading = true; // Add a loading state variable

  final ImagePicker _imagePicker = ImagePicker();
  File? imageFile;
  String? imageUrl;


  File? _selectedImage;
  bool showElevatedButtons = false;

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    uploadImage();
    }
  }

  // Function to open the camera and capture an image
  Future<void> openCamera() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(()  {
        // File? compressedImage = await compressImage(File(pickedFile.path));
        // imageFile = compressedImage;
        _selectedImage= File(pickedFile.path);

      });

      uploadImage();
    }
  }

  Future<void> uploadImage() async {
    if (_selectedImage == null) return;

    const url = '${SettingsAPI.apiUrl}/update-profile-picture';
    final headers = {'Content-Type': 'multipart/form-data'};
    final request = http.MultipartRequest('POST', Uri.parse(url));

    request.headers.addAll(headers);
    request.fields['userId'] = user!.user_ID.toString(); // Replace with the user's ID
    request.files.add(await http.MultipartFile.fromPath('image', _selectedImage!.path));

    final response = await http.Response.fromStream(await request.send());

    if (response.statusCode == 200) {
      // Profile picture updated successfully
      print('Profile picture updated successfully');
      getUser();
    } else {
      // Handle errors
      print('Error updating profile picture: ${response.body}');
    }
  }

  Future<File> compressImage(File image) async {
    final originalImage = img.decodeImage(image.readAsBytesSync())!;
    final compressedImage = img.encodeJpg(originalImage, quality: 85);

    final compressedFile = File('${image.parent.path}/compressed_${image.uri.pathSegments.last}');
    await compressedFile.writeAsBytes(compressedImage);

    return compressedFile;
  }


  void getUser() async {
    // Display loading indicator while fetching data
    setState(() {
      isLoading = true;
    });

    String email = FirebaseAuth.instance.currentUser!.email!;
    String apiUrl = "${SettingsAPI.apiUrl}/api/user-email/$email";
    try {
      var response = await http.get(Uri.parse(apiUrl));
      final jsonResponse = jsonDecode(response.body);

      if (kDebugMode) {
        print('json response: $jsonResponse');
      }

      for (var userData in jsonResponse) {
        String name = userData['user_name'] ?? 'null';
        String surname = userData['Surname'] ?? '';
        String designation = userData['Designation'] ?? 'null';
        String location = userData['user_location'] ?? 'null';
        String email = userData['Email'] ?? '';
        String contactNumber = userData['Contact_Number'] ?? 'null';
        int userType = userData['Type'] ?? '';
        int departmentId = userData['department_id'] ?? 0;
        String profilePicture = userData['Profile_Picture'] ?? 'null';
        int userId = userData['User_ID'] ?? 0;

        setState(() {
          user = Users(
            name,
            surname,
            designation,
            location,
            email,
            contactNumber,
            userType,
            departmentId,
            profilePicture,
            userId,
          );
          isLoading = false; // Data has been fetched, loading complete
        });

        if (kDebugMode) {
          print('Object name: ${user?.name}');
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
      //return []; // Return an empty list if an error occurs
    }
  }

  @override
  void initState() {
    super.initState();
    getUser();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      // Show loading indicator while data is being fetched
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading:  IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.black), // Back button icon color
            onPressed: () {
              // Handle back button press
              Navigator.pop(context); // Navigate to the previous page
            },
          ),
        ),
        drawer: const SideBar(),
        body: Center(
          child: CircularProgressIndicator(),
        ),
        bottomNavigationBar: const BottomNavWidget(),
      );
    }

    // Data has been fetched, display profile content
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading:   IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black), // Back button icon color
          onPressed: () {
            // Handle back button press
            Navigator.pop(context); // Navigate to the previous page
          },
        ),
      ),
      drawer: const SideBar(),
      body: Padding(
        padding: EdgeInsets.only(top: kToolbarHeight),
        child: Align(
          alignment: Alignment.topCenter,
          child: Column(
            children: [
              Visibility(
                visible: showElevatedButtons,
                child: Column(
                  children: [
                    FloatingActionButton(
                      onPressed: () {
                        setState(() {
                          showElevatedButtons = false;
                        });
                        pickImage();
                        // Add functionality for the first floating action button here
                      },
                      backgroundColor: Colors.blueGrey,
                      child: Icon(Icons.image),
                    ),
                    SizedBox(height: 16.0),
                    FloatingActionButton(
                      onPressed: () {
                        setState(() {
                          showElevatedButtons = false;
                        });
                        openCamera();
                        // Add functionality for the second floating action button here

                      },
                      backgroundColor: Colors.blueGrey,
                      child: Icon(Icons.camera_alt),
                    ),
                  ],
                ),
              ),


              Padding(
                padding: const EdgeInsets.only(left: 120.0),
                child: IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    setState(() {
                      showElevatedButtons = !showElevatedButtons;
                    });
                  },
                ),
              ),
          GestureDetector(
            onTap: () {
              // Implement code to open the image here
              // You can use Navigator, showDialog, or any other method to display the image
              // For simplicity, we'll use a dialog to display the image URL
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Image"),
                    content: Image.network( '${SettingsAPI.apiUrl}/uploads/profiles/${user?.profile_Picture ?? 'https://picsum.photos/id/1/200/300'}'),
                    actions: <Widget>[
                      TextButton(
                        child: Text("Close"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
            child:
            ClipOval(
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    height: MediaQuery.of(context).size.width * 0.5,
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                    child: Center(
                      child: Image.network(
                        '${SettingsAPI.apiUrl}/uploads/profiles/${user?.profile_Picture ?? 'https://picsum.photos/id/1/200/300'}',
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),),


              Text(
                '${user?.name} ${user?.surname}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on),
                  SizedBox(width: 5),
                  Text(user!.location),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavWidget(),

    );
  }
}
