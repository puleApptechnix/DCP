import 'dart:convert';
import 'package:dtsa/posts_categores.dart';
import 'package:dtsa/utils/settings.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'group_participants.dart';
import 'hexcolor.dart';
import 'login.dart';
import 'message.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

import 'models/users.dart';




class chatpage extends StatefulWidget {
  String email;
  String collection;
  chatpage({required this.email,required this.collection});
  @override
  _chatpageState createState() => _chatpageState(email: email,collection: collection);
}

class _chatpageState extends State<chatpage> {
  String email;
  String collection;
  final picker = ImagePicker();
  bool hasImage = false;
  Users? user; // Make user nullable
  bool isLoading = true; // Add a loading state variable
  String? imageName; // Add this variable to store the image name

  _chatpageState({required this.email,required this.collection});

  final fs = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final TextEditingController message = new TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  File? imageFile;
  String? imageUrl;
  bool showElevatedButtons = false;
  Color bar = HexColor("#F3EEED");
  Color background= HexColor("#F1EFEC");
 bool isSendingMessage = false;


  Future<void> pickImageAndSendMessage() async {
    final image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      // Upload the image to Firebase Storage
      final Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('${DateTime.now().millisecondsSinceEpoch}.png');

      final UploadTask uploadTask = storageReference.putFile(
        File(image.path),
        SettableMetadata(contentType: 'image/png'),
      );

      final TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
      imageUrl = await taskSnapshot.ref.getDownloadURL();

      // Send the message with image URL to Firestore
      fs.collection(collection).doc().set({
        'message': message.text.trim(),
        'time': DateTime.now(),
        'email': email,
        'imageUrl': imageUrl,
      });

      message.clear();
    } else {
      // Send the message without an image to Firestore
      if (message.text.isNotEmpty) {
        fs.collection(collection).doc().set({
          'message': message.text.trim(),
          'time': DateTime.now(),
          'email': email,
        });

        message.clear();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getUser();
    addUserToReadMessages(collection);
  }


  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print("collection:$collection");
    }
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Disable debug banner
      home: Scaffold(
        backgroundColor: background,
        appBar: AppBar(
          backgroundColor:Colors.white, // Set the background color to white
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.black), // Back button icon color
            onPressed: () {
              // Handle back button press
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Posts(
                    email: email,

                  ),
                ),
              );
            },
          ),
          title: Center(
            child: Text(
              collection,
              style: TextStyle(color: Colors.black), // Title text color
            ), // Centered title
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0), // Adjust the value as per your requirement
              child: IconButton(
                icon: const Icon(Icons.search, color: Colors.black), // Search icon color
                onPressed: () {
                  // Handle search icon press
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16.0), // Adjust the value as per your requirement
              child: PopupMenuButton(
                icon: const Icon(Icons.more_horiz, color: Colors.black), // Horizontal dots icon color
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem(
                    value: 1,
                    child: Text('Show group participants'),
                  ),
                  // const PopupMenuItem(
                  //   child: Text('Option 2'),
                  //   value: 2,
                  // ),
                  // Add more menu items as needed
                ],
                onSelected: (value) {
                  // Handle menu item selection
                  if(value==1){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => GroupParticipantsPage(name:collection)));
                  }
                },
              ),
            ),
          ],
          toolbarTextStyle: const TextTheme(
            headline6: TextStyle(
              color: Colors.black, // Title text color
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ).bodyText2,
          titleTextStyle: const TextTheme(
            headline6: TextStyle(
              color: Colors.black, // Title text color
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ).headline6,
        ),
        body: Column(
          children: [

            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: messages(
                  email: email,
                  collection: collection,
                ),
              ),
            ),
            Container(
              color: bar,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: message,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[100],
                        hintText: 'Write comment',
                        enabled: true,
                        contentPadding: const EdgeInsets.only(
                            left: 14.0, bottom: 8.0, top: 8.0),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.black12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: const BorderSide(color: Colors.purple),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) {},
                      onSaved: (value) {
                        message.text = value!;
                      },
                    ),
                  ),

                  IconButton(
                    onPressed: () {
                      setState(() {
                        // Toggle the visibility of the elevated buttons
                        showElevatedButtons = !showElevatedButtons;
                      });
                    },
                    icon: Image.asset("icons/image.png"), // Assuming the first icon is for displaying the elevated buttons
                  ),
                  IconButton(
                    onPressed: () {
                      if (message.text.isNotEmpty || hasImage) {
                        if (hasImage) {
                          uploadImageAndSendMessage();
                        } else {
                          sendMessage();
                        }
                      }
                    },
                    icon: isSendingMessage
                        ? CircularProgressIndicator() // Show loading indicator while sending
                        : Image.asset("icons/Send.png"), // Display the original send icon when no image is selected
                  )
                ],
              ),
            ),
            Visibility(
              visible: hasImage , // Show the Text widget only when an image is picked
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  imageName ?? '', // Display the image name or an empty string
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
          ],
        ),




        floatingActionButton: Visibility(
          visible: showElevatedButtons, // Show/hide the elevated buttons based on this flag
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton(
                onPressed: () {
                  setState(() {
                    showElevatedButtons = false;
                  });

                  openCamera(); // Call the function to open the camera and take a picture
                },
                backgroundColor: Colors.blueGrey,

                child: Icon(Icons.camera_alt),
              ),
              SizedBox(height: 16.0),
              FloatingActionButton(
                onPressed: () {
                  setState(() {
                    showElevatedButtons = false;
                  });
                  pickImage(); // Call the function to open the gallery and pick an image
                },
                backgroundColor: Colors.blueGrey,
                child: Icon(Icons.image),
              ),

            ],
          ),
        ),

      ),
    );
  }








  Future<void> uploadImageAndSendMessage() async {
    setState(() {
      isSendingMessage = true;
    });
    // Upload the image to Firebase Storage
    final Reference storageReference = FirebaseStorage.instance
        .ref()
        .child('${DateTime.now().millisecondsSinceEpoch}.png');

    final UploadTask uploadTask = storageReference.putFile(
      imageFile!,
      SettableMetadata(contentType: 'image/png'),
    );
    List<String> myArray = [email]; // Add the user's email to the list

    final TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
    String imageUrl = await taskSnapshot.ref.getDownloadURL();

    // Send the message with image URL to Firestore
    fs.collection(collection).doc().set({
      'message': message.text.trim(),
      'time': DateTime.now(),
      'email': email,
      'imageUrl': imageUrl,
      'name': user?.name,
      'surname': user?.surname,
      'readBy':myArray
    });
    message.clear();
    setState(() {
      imageFile = null;
      isSendingMessage = false;
      hasImage = false;

    });
  }

  void sendMessage() {
    setState(() {
      isSendingMessage = true;
    });
    List<String> myArray = [email]; // Add the user's email to the list

    fs.collection(collection).doc().set({
      'message': message.text.trim(),
      'time': DateTime.now(),
      'email': email,
      'imageUrl': '',
      'name': user?.name,
      'surname': user?.surname,
      'readBy':myArray
    });
    setState(() {
      hasImage = false;
      isSendingMessage = false;
    });

    message.clear();
  }


  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final compressedImage = await compressImage(File(pickedFile.path));

      setState(() {
        imageFile = compressedImage;
        imageName = pickedFile.name;
        hasImage = true;
      });
    }
  }


  Future<File> compressImage(File image) async {
    final originalImage = img.decodeImage(image.readAsBytesSync())!;
    final compressedImage = img.encodeJpg(originalImage, quality: 85);

    final compressedFile = File('${image.parent.path}/compressed_${image.uri.pathSegments.last}');
    await compressedFile.writeAsBytes(compressedImage);

    return compressedFile;
  }


  Future<void> openCamera() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() async {
        // File? compressedImage = await compressImage(File(pickedFile.path));
        // imageFile = compressedImage;
        imageFile= await compressImage(File(pickedFile.path));
        imageName = pickedFile.name; // Update the image name
        hasImage = true;

      });

    }
  }
  Future uploadImage(File imageFile) async {
    showElevatedButtons = false;
    // Generate a unique file name for the image
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();

    // Create a reference to the Firebase Storage location where the image will be stored
    Reference storageReference = FirebaseStorage.instance.ref().child(fileName);

    // Upload the image file to Firebase Storage
    UploadTask uploadTask = storageReference.putFile(imageFile);

    // Get the download URL of the uploaded image
    String imageUrl = await (await uploadTask).ref.getDownloadURL();

    // Call a method to save the image message in Firestore with the imageUrl
    saveImageMessage(imageUrl);
  }

  void saveImageMessage(String imageUrl) {
    showElevatedButtons = false;
    fs.collection(collection).add({
      'imageUrl': imageUrl,
      'time': DateTime.now(),
      'email': email,
    });
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
  void addUserToReadMessages(String collection) async {

    String email = FirebaseAuth.instance.currentUser!.email!;


    try {
      final QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection(collection).get();

      print("query: ${querySnapshot.size}");
      print("docs: ${querySnapshot.docs}");

      for (final doc in querySnapshot.docs) {


        print('inside for loop');
        final List<dynamic> messages = doc.get('readBy');
        print(messages.length);
        if (!messages.contains(email)) {
          print(email);


          messages.add(email); // Add the email to the 'readBy' list


          // Update the 'readBy' field in Firestore
          await doc.reference.update({'readBy': messages});

          print("user added succesfully");
        }
      }

    } catch (e) {
      print('Error in adding user to read messages: $e');
    }

  }
}
