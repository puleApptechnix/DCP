import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dtsa/utils/settings.dart';
import 'package:dtsa/widgets/bottomNavigationBar.dart';
import 'package:dtsa/widgets/sideebar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'chat-page.dart';
import 'models/articles.dart';

class Article extends StatefulWidget {
  //const Article({Key? key,required this.articleData, required this.articleId}) : super(key: key);
   dynamic articleData;

   String group;
  Article({required this.articleData,required this.group});


  @override
  State<Article> createState() => _ArticleState(articleData:articleData, group:group);
}

class _ArticleState extends State<Article> {
  final dynamic articleData;

  String group;


  _ArticleState({required this.articleData, required this.group});
  @override
  Widget build(BuildContext context) {
    String apiUrl = SettingsAPI.apiUrl;
    Articles article =articleData;
    if (kDebugMode) {
      print(article.heading);
    }
    return Scaffold(
      drawer: const SideBar(),

      appBar: AppBar(
        backgroundColor: Colors.white, // Set the background color to white
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black), // Back button icon color
          onPressed: () {
            // Handle back button press
            Navigator.pop(context); // Navigate to the previous page
          },
        ),

      ),

        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  article.heading ?? 'heading',
                  style: const TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(50.0),
                      child: Container(
                        width: 20.0,
                        height: 20.0,
                        margin: EdgeInsets.all(16.0),
                        color: Colors.white,
                        // You can replace the placeholder image with your own image
                         child: Image.asset('images/michael-dam-258165-unsplash.png',
                           fit: BoxFit.cover,),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            article.author ?? 'author',
                            style: const TextStyle(fontSize: 12.0,fontWeight: FontWeight.normal,

                            )

                            ,

                          ),
                          Text(
                            article.date ?? 'date',
                            style: const TextStyle(fontSize: 12.0,
                              color: Colors.grey
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

              Container(
                margin: EdgeInsets.fromLTRB(16.0,0.0,16.0,0.0),
                child: Image.network( '$apiUrl/uploads/profiles/${article.image}' ?? '',
                  width: double.infinity,
                  height: 200.0,
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  article.details ?? 'details',
                  style: TextStyle(fontSize: 18.0),
                ),
              ),
            ],
          ),
        ),



      bottomNavigationBar: const BottomNavWidget(),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {

          // Get the email of the currently authenticated user
          String email = FirebaseAuth.instance.currentUser!.email!;
          // Navigate to the ChatPage and pass the email as an argument
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => chatpage(
                email: email,
                collection: group,
              ),
            ),
          );
        },
        child: Image.asset(
            'icons/Chat.png'), // Replace 'path-to-your-icon.png' with the actual path to your custom icon
      ),

    );
  }
}
