import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dtsa/notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../full_article.dart';
import '../home.dart';
import '../posts_categores.dart';
import '../profile.dart';

class BottomNavWidget extends StatefulWidget {
  const BottomNavWidget({Key? key}) : super(key: key);

  @override
  State<BottomNavWidget> createState() => _BottomNavWidgetState();
}

class _BottomNavWidgetState extends State<BottomNavWidget> {



  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Builder(builder: (context) {
            return IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: const Icon(Icons.more_vert),
              color: Colors.black,
            );
          }),
          IconButton(
            onPressed: () async {
              // Get the email of the currently authenticated user
              String email = FirebaseAuth.instance.currentUser!.email!;
              // Navigate to the ChatPage and pass the email as an argument
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HomePage(
                    email: email,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.home),
            color: Colors.black,
          ),
          IconButton(
            onPressed: () async {
              // Get the email of the currently authenticated user
              String email = FirebaseAuth.instance.currentUser!.email!;
              // Navigate to the ChatPage and pass the email as an argument
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Posts(
                    email: email,

                  ),
                ),
              );
            },
            icon: const Icon(Icons.explore),
            color: Colors.black,
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Notifications(

                  ),
                ),
              );
            },
            icon: const Icon(Icons.notifications),
            color: Colors.black,
          ),
          IconButton(
            onPressed: () {
              // fetchLatestArticleFromFirestore();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Profile(

                  ),
                ),
              );
            },
            icon: const Icon(Icons.person),
            color: Colors.black,
          ),
        ],
      ),
    );
  }
}
