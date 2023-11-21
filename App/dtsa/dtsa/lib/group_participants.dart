import 'dart:convert';

import 'package:dtsa/utils/settings.dart';

import 'package:dtsa/widgets/bottomNavigationBar.dart';
import 'package:dtsa/widgets/sideebar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';


import 'models/participants.dart';
import 'package:http/http.dart' as http;



class GroupParticipantsPage extends StatefulWidget {
 // const GroupParticipantsPage({super.key});
String name;

GroupParticipantsPage({required this.name});

  @override
  State<GroupParticipantsPage> createState() => _GroupParticipantsPageState(name:name);
}

class _GroupParticipantsPageState extends State<GroupParticipantsPage> {
  String appVersion ='';
  List<Participants> participantsList = [];
  String name;
  _GroupParticipantsPageState({required this.name});



  @override
  void initState() {
    super.initState();

    getParticipants('Sales').then((item) {
      setState(() {
        participantsList = item;
      });
    });




  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(

          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text("Group Participants",   style: TextStyle(color: Colors.black),),
      ),

      drawer: const SideBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Members",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Add your action here for "See All" button.
                  },
                  child: Text(
                    "See All",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Participants>>(
              future: getParticipants(name), // Replace 'yourGroupName' with the actual group name
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator(); // Show a loading indicator while waiting for data
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  final groupParticipants = snapshot.data;

                  return ListView.builder(
                    itemCount: groupParticipants?.length,
                    itemBuilder: (context, index) {
                      final participant = groupParticipants?[index];
                      return Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.grey, width: 1.0),
                          ),
                        ),
                          child: ListTile(
                            leading: Container(
                              width: 56.0, // Set a fixed width for the leading widget
                              child: ClipOval(
                                child: Image.network(
                                  '${SettingsAPI.apiUrl}/uploads/profiles/${participant?.profilePicture ?? 'https://picsum.photos/id/1/200/300'}',
                                  fit: BoxFit.cover, // You can adjust the fit based on your needs
                                ),
                              ),
                            ),
                            title: Text(
                              "${participant!.userName}  ${participant.userSurname}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(participant!.designation),
                          )

                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavWidget(),
    );
  }



  Future<List<Participants>> getParticipants(String name) async {

    const String apiUrl = "${SettingsAPI.apiUrl}/api/group-participants";
    try {
      var response = await http.get(Uri.parse('$apiUrl?name=$name'));
      final jsonResponse = jsonDecode(response.body);
      if (kDebugMode) {
        print('json response: $jsonResponse.toString()');
      }

      List<Participants> participantsList =
      []; // Create a new list to store the contacts

      for (var contactData in jsonResponse) {
        String userName = contactData['user_name'];
        String profilePicture = contactData['Profile_Picture'];
        String designation = contactData['Designation'];
        String name = contactData['Name'];
        String userSurname =  contactData['Surname'];


        Participants participant = Participants(userName, profilePicture,
            designation, name,userSurname);
        participantsList.add(participant);

        if (kDebugMode) {
          print('Object name: ${participant.userName}');
        }
      }

      return participantsList;
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
      return []; // Return an empty list if an error occurs
    }
  }

}

class GroupParticipant {
  final String name;
  final String subtitle;
  final String imagePath;

  GroupParticipant({
    required this.name,
    required this.subtitle,
    required this.imagePath,
  });
}

List<GroupParticipant> groupParticipants = [
  GroupParticipant(
    name: "John Doe",
    subtitle: "Online",
    imagePath: "assets/john_doe.jpg",
  ),
  GroupParticipant(
    name: "Jane Smith",
    subtitle: "Away",
    imagePath: "assets/jane_smith.jpg",
  ),
  // Add more participants as needed
];
