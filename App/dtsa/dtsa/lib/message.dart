import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'hexcolor.dart';


class messages extends StatefulWidget {
  String email;
  String collection;

  messages({required this.email, required this.collection});
  @override
  _messagesState createState() =>
      _messagesState(email: email, groupId: collection);
}
class _messagesState extends State<messages> {
  String email;
  String groupId = '';
  Color sender = HexColor("#ECB768");
  Color reader = HexColor("#FFFDFA");
  bool isLoading = true;
  String currentDateString = ''; // Variable to track the current date
  List<String> uniqueDates = []; // List to store unique date strings
  Map<String, int> dateIndices = {}; // Map to store the last index of each date

  _messagesState({required this.email, required this.groupId}
      );


  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> _messageStream = FirebaseFirestore.instance
        .collection(groupId)
        .orderBy('time', descending: true)
        .snapshots();

    return StreamBuilder(
      stream: _messageStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Text("Something went wrong");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }


        Map<String, List<QueryDocumentSnapshot>> groupedMessages =
        groupMessagesByDate(snapshot.data!.docs);

        return ListView.builder(
          itemCount: groupedMessages.length,
          reverse: true, // Display the latest messages at the top
          physics: const ScrollPhysics(),
          shrinkWrap: true,
          primary: true,
          itemBuilder: (BuildContext context, int index) {
            String messageDateString = groupedMessages.keys.elementAt(index);
            List<QueryDocumentSnapshot> messages =
            groupedMessages[messageDateString]!;

            // Reverse the order of messages within each group
            messages = messages.reversed.toList();

            return Column(
              children: [
                Container(
                  width: 100,
                  height: 35,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                  ),
                  child: Text(
                    messageDateString,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Column(
                  children: messages.map((qs) {
                    Timestamp t = qs['time'];
                    DateTime d = t.toDate();
                    bool isCurrentUser = email == qs['email'];
                    return buildMessage(isCurrentUser, qs, d);
                  }).toList(),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Helper function to group messages by date
  Map<String, List<QueryDocumentSnapshot>> groupMessagesByDate(
      List<QueryDocumentSnapshot> messages) {
    Map<String, List<QueryDocumentSnapshot>> groupedMessages = {};

    for (QueryDocumentSnapshot qs in messages) {
      Timestamp t = qs['time'];
      DateTime d = t.toDate();
      String messageDateString = DateFormat('yyyy-MM-dd').format(d.toLocal());

      if (!groupedMessages.containsKey(messageDateString)) {
        groupedMessages[messageDateString] = [];
      }

      groupedMessages[messageDateString]!.add(qs);
    }

    return groupedMessages;
  }


  int lastDateSeparatorIndex = -1; // Keep track of the last date separator index

  Widget buildMessage(bool isCurrentUser, QueryDocumentSnapshot qs, DateTime d) {
    MainAxisAlignment mainAxisAlignment = isCurrentUser
        ? MainAxisAlignment.end
        : MainAxisAlignment.start;

    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 8),
      child: Row(
        mainAxisAlignment: mainAxisAlignment,
        children: [
          Container(
            decoration: BoxDecoration(
              color: isCurrentUser ? sender : reader,
              borderRadius: BorderRadius.circular(15.0),
            ),
            width: 200,
            child: ListTile(
              shape: RoundedRectangleBorder(
                side: const BorderSide(
                  color: Colors.black,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                "${qs['name']}  ${qs['surname']}",
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.blue,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (qs['imageUrl'] != null && qs['imageUrl'] != '')
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Image"),
                              content: Image.network(qs['imageUrl']),
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
                      child: Container(
                        width: 200,
                        height: 200,
                        child: CachedNetworkImage(
                          imageUrl: qs['imageUrl'],
                          fit: BoxFit.contain,
                          errorWidget:
                              (BuildContext context, String url, dynamic error) {
                            return Text('Failed to load image');
                          },
                        ),
                      ),
                    ),
                  if (qs['message'] != null)
                    Container(
                      width: qs['imageUrl'] != null ? 200 : null,
                      child: Text(
                        qs['message'],
                        softWrap: true,
                        style: const TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    ),
                  Text(
                    "${d.hour}:${d.minute}",
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }



}

