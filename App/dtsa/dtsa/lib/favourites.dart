import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dtsa/posts_categores.dart';
import 'package:dtsa/utils/settings.dart';
import 'package:dtsa/widgets/bottomNavigationBar.dart';
import 'package:dtsa/widgets/sideebar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'full_article.dart';
import 'hexcolor.dart';
import 'models/articles.dart';
import 'package:http/http.dart' as http;

import 'models/departments.dart';
import 'models/fav_department.dart';
import 'models/likes.dart';
import 'models/users.dart';

class Faourites extends StatefulWidget {
  String email;
  Faourites({required this.email});

  @override
  State<Faourites> createState() => _FaouritesState(email: email);
}

class _FaouritesState extends State<Faourites> {
  String email;

  _FaouritesState({required this.email});

  List<Articles> articlesList = [];
  List<String> userGroups = []; // List to store user groups
  String group = 'Parts'; // moved the group variable to the class level
  String activeGroup = "Parts";
  final Color _red = HexColor("#FC0101");
  Users? user; // Make user nullable
  List<int> likesList = [];
  List<FavDepartment> departmentList = [];
  int testCount = 0;


  @override
  void initState() {
    super.initState();

    getDeparment(email);
    getDeparments(email);


    checkLike().then((item) {
      setState(() {
        likesList = item;
      });
    });


    getArticles().then((articles) {
      setState(() {
        articlesList = articles;
      });
    });
  }

  Future<void> getDeparment(String userEmail) async {
    final apiUrl = '${SettingsAPI.apiUrl}/api/user-departments-favourites/$userEmail';
    //  String apiUrl = "${SettingsAPI.apiUrl}/api/categories";
    try {
      var response = await http.get(Uri.parse(apiUrl));
      final jsonResponse = jsonDecode(response.body);

      if (kDebugMode) {
        print('json response: $jsonResponse');
      }

      List<FavDepartment> categoryList =
      []; // Create a new list to store the contacts

      for (var categoryData in jsonResponse) {
        int departmentId = categoryData["Department_ID"]; //change
        String name = categoryData["Name"];
        int division_id = categoryData["Division_Division_ID"];
        String location = categoryData["Location"];


        FavDepartment departments = FavDepartment(
            departmentId, name, division_id, location);

        //departmentList.add(departments);
        if (departments.Name != null) {
          setState(() {
            activeGroup = departments.Name;
            group = departments.Name;
          });

          return;
        }
      }

      //  return categoryList;
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
      //  return []; // Return an empty list if an error occurs
    }
  }

  getDeparments(String userEmail) async {
    final apiUrl = '${SettingsAPI.apiUrl}/api/user-departments-favourites/$userEmail';
    //  String apiUrl = "${SettingsAPI.apiUrl}/api/categories";
    try {
      var response = await http.get(Uri.parse(apiUrl));
      final jsonResponse = jsonDecode(response.body);

      if (kDebugMode) {
        print('json response: $jsonResponse');
      }

      List<FavDepartment> categoryList =
      []; // Create a new list to store the contacts

      for (var categoryData in jsonResponse) {
        int departmentId = categoryData["Department_ID"]; //change
        String name = categoryData["Name"];
        int division_id = categoryData["Division_Division_ID"];
        String location = categoryData["Location"];


        FavDepartment departments = FavDepartment(
            departmentId, name, division_id, location
            );
        if (kDebugMode) {
          print('Department  name from get departments function: ${departments
              .Name}');
        }

        setState(() {
          departmentList.add(departments);
        });
      }

      //  return categoryList;
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
      //  return []; // Return an empty list if an error occurs
    }
  }

  Future<int> getUserId() async {
    String email = FirebaseAuth.instance.currentUser!.email!;
    String apiUrl = "${SettingsAPI.apiUrl}/api/user-email/$email";
    try {
      var response = await http.get(Uri.parse(apiUrl));
      final jsonResponse = jsonDecode(response.body);

      if (kDebugMode) {
        print('json response: $jsonResponse');
      }

      int userId = -1; // Default value if userId is not found

      if (jsonResponse is List && jsonResponse.isNotEmpty) {
        var userData = jsonResponse[0];
        String name = userData['Name'] ?? '';
        String surname = userData['Surname'] ?? '';
        String designation = userData['Designation'] ?? '';
        String location = userData['Location'] ?? '';
        String email = userData['Email'] ?? '';
        String contactNumber = userData['Contact_Number'] ?? '';
        String userType = userData['User_Type'] ?? '';
        int departmentId = userData['Department_Department_ID'] ?? 0;
        String profilePicture = userData['Profile_Picture'] ?? '';
        if (kDebugMode) {
          print("u id from json: ${userData['User_ID']}");
        }
        userId = userData['User_ID'] ?? -1;
        if (kDebugMode) {
          print('Object name: $name');
        }
      }

      return userId;
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
      return -1; // Return -1 if an error occurs
    }
  }

  Future<List<Articles>> getArticles() async {
    String email = FirebaseAuth.instance.currentUser!.email!;
    String apiUrl = "${SettingsAPI.apiUrl}/api/favorites/$email";
    try {
      var response = await http.get(Uri.parse(apiUrl));
      final jsonResponse = jsonDecode(response.body);

      if (kDebugMode) {
        print('json response: $jsonResponse.toString()');
      }

      List<Articles> articlesList =
      []; // Create a new list to store the contacts
      for (var articlesData in jsonResponse) {
        int idarticles = articlesData["idarticles"];
        String heading = articlesData["heading"];
        int division_id = articlesData["division_id"];
        int department_id = articlesData["department_id"];
        String details = articlesData["details"];
        String author = articlesData["author"];
        int category_id = articlesData["category_id"];
        String date = articlesData["date"];
        int likes = articlesData["likes"];
        String image = articlesData["image"];

        Articles article = Articles(
            idarticles,
            heading,
            division_id,
            department_id,
            details,
            author,
            category_id,
            date,
            likes,
            image);
        Future<String>? retrievedName =
        await getDepartmentNameById(article.department_id);

        if ((retrievedName != null && await retrievedName == group)) {
          setState(() {
            articlesList.add(article);
          });
          if (kDebugMode) {
            print('Added article id: ${article.idarticles}');
          }
        }

        if (kDebugMode) {
          print('Object name: ${article.idarticles}');
        }
      }

      return articlesList;
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
      return []; // Return an empty list if an error occurs
    }
  }


  // bool isArticleFavorite(Article article) {
  //   return article.favorites.contains(currentUserEmail);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SideBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery
                  .of(context)
                  .size
                  .height * 0.2,
              width: MediaQuery
                  .of(context)
                  .size
                  .width,
              child: Image.asset(
                "images/Group52.png",
                width: double.infinity,
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: departmentList.map((group) {
                  return Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: TextButton(
                      onPressed: () async {
                        setState(() {
                          activeGroup = group.Name;
                          this.group = group.Name;
                          getArticles().then((articles) {
                            setState(() {
                              articlesList = articles;
                            });
                          });
                          //fetchFavouriteArticlesFromFirestore(group);
                        });
                        print(group);
                        print("is there");
                      },
                      style: ButtonStyle(
                        backgroundColor:
                        MaterialStateColor.resolveWith((states) {
                          if (activeGroup == group.Name) {
                            return _red; // Active button color
                          } else {
                            return Colors.black; // Default button color
                          }
                        }),
                      ),
                      child: Text(
                        group.Name,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: MediaQuery
                .of(context)
                .size
                .height * 0.001),
            ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: articlesList.length,
                itemBuilder: (context, index) {
                  Articles article = articlesList[index];
                  bool liked = isEqual(likesList, article.idarticles);
                  return GestureDetector(
                    onTap: () {
                      // Navigate to the desired page and pass the variables as arguments
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              Article(articleData: article, group: activeGroup),
                        ),
                      );
                    },
                    child: Container(
                        margin: EdgeInsets.all(8),
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset:
                              Offset(0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Container(
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width * 0.3,
                                child: Stack(
                                  children: [
                                    Image.network(
                                      '${SettingsAPI
                                          .apiUrl}/uploads/profiles/${article
                                          .image}',
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                    Positioned(
                                      top: 10, // Adjust the position as needed
                                      right:
                                      10, // Adjust the position as needed
                                      child: IconButton(
                                        onPressed: () async {
                                          int userid = await getUserId();
                                          print("user id:/${userid}");
                                          deleteFavourites(article.idarticles);
                                        },
                                        icon: Icon(Icons.favorite_border),
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                                height:
                                MediaQuery
                                    .of(context)
                                    .size
                                    .height * 0.01),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      article.heading,
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ),
                                  SizedBox(
                                      height:
                                      MediaQuery
                                          .of(context)
                                          .size
                                          .height *
                                          0.02),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          article.author,
                                          style: const TextStyle(
                                              color: Colors.grey),
                                        ),
                                        Row(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              IconButton(
                                                onPressed: () async {
                                                  print("article id: ${article
                                                      .idarticles}");


                                                  bool truth = await isLiked(
                                                      article.idarticles);
                                                  if (!truth) {
                                                    addLikes(
                                                        article.idarticles);
                                                    setState(() {
                                                      liked =
                                                      true; // Update the liked state to true.
                                                    });
                                                  } else {
                                                    if (kDebugMode) {
                                                      print(
                                                          "This is already liked");
                                                    }
                                                  }
                                                },
                                                icon: Icon(
                                                  Icons.thumb_up,
                                                  // You can use the built-in thumb_up icon from the Icons class.
                                                  color: liked
                                                      ? Colors.blue
                                                      : Colors.grey,
                                                  size: 24, // Set the size of the icon.
                                                ),
                                                color: liked
                                                    ? Colors.blue
                                                    : Colors.grey,
                                              ),
                                            ]),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )),
                  );
                }),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavWidget(),
    );
  }


  Future<Future<String>?> getDepartmentNameById(int id) async {
    Future<String>? name; // Initialize name as nullable Future<String>

    String apiUrl = "${SettingsAPI.apiUrl}/api/department-name/$id";

    try {
      var response = await http.get(Uri.parse(apiUrl));
      final jsonResponse = jsonDecode(response.body);

      if (kDebugMode) {
        print('json response: $jsonResponse.toString()');
      }

      for (var articlesData in jsonResponse) {
        String departmentName = articlesData['Name'];

        if (kDebugMode) {
          print('Department name: $departmentName');
        }

        name = Future.value(departmentName); // Wrap departmentName in a Future
      }

      return name;
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
      return null; // Return null if an error occurs
    }
  }

  Future<void> deleteFavourites(int articleId) async {
    String email = FirebaseAuth.instance.currentUser!.email!;
    try {
      String apiUrl = "${SettingsAPI.apiUrl}/api/delete-favorites";
      Map<String, dynamic> requestBody = {
        'user_email': email,
        'article_id': articleId,
      };

      // Send the DELETE request
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      // Check the response status code
      if (response.statusCode == 200) {
        print('Article removed successfully.');
      } else if (response.statusCode == 404) {
        print('Article not found.');
      } else if (response.statusCode == 409) {
        print('You have already removed this article.');
      } else {
        print('Error removing article. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error removing article from favorites: $error');
    }

    getArticles().then((articles) {
      setState(() {
        articlesList = articles;
      });
    });
  }

  Future<List<int>> checkLike() async {
    String email = FirebaseAuth.instance.currentUser!.email!;
    String apiUrl = "${SettingsAPI.apiUrl}/api/likes/$email";
    List<int> list = []; // Create a new list to store the articles
    try {
      var response = await http.get(Uri.parse(apiUrl));
      final jsonResponse = jsonDecode(response.body);

      if (kDebugMode) {
        print('json response: $jsonResponse.toString()');
      }

      for (var articlesData in jsonResponse) {
        int idArticles = articlesData["idarticles"];
        // Check if the current article ID matches the desired article ID

        print("Is liked id $idArticles : true");
        list.add(idArticles);
      }

      // Process the articlesList further or update the UI with the articles
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
    }

    // print("Is favourite: false");
    return list;
  }


  Future<bool> isLiked(int articleid) async {
    String email = FirebaseAuth.instance.currentUser!.email!;
    String apiUrl = "${SettingsAPI.apiUrl}/api/likes/$email";
    try {
      var response = await http.get(Uri.parse(apiUrl));
      final jsonResponse = jsonDecode(response.body);

      if (kDebugMode) {
        print('json response from likes: $jsonResponse.toString()');
      }

      for (var likesData in jsonResponse) {
        int idlikes = likesData["idlikes"] ?? -1;
        String user_email = likesData["user_email"] ?? -1;
        int article_id = likesData["article_id"] ?? -1;

        Likes like = Likes(idlikes, user_email, article_id);
        if (like.article_id == articleid && like.user_email == user_email) {
          print("Is Liked: True");
          return true;
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
    }

    print("Is liked: false");
    return false;
  }

  bool isEqual(List<int> favorites, int article) {
    if (favorites.contains(article)) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> likeArticle(int articleId, String userId) async {
    try {
      print("user id:$userId");
      // Set the API endpoint URL
      final apiUrl =
          '${SettingsAPI.apiUrl}/api/articles/$articleId/like/$userId';

      // Send the POST request
      final response = await http.post(Uri.parse(apiUrl));

      // Check the response status code
      if (response.statusCode == 200) {
        print('Article liked successfully.');
      } else if (response.statusCode == 404) {
        print('Article not found.');
      } else if (response.statusCode == 409) {
        print('You have already liked this article.');
      } else {
        print('Error liking article. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error liking article: $error');
    }
  }

  Future<void> addLikes(int articleId) async {
    String email = FirebaseAuth.instance.currentUser!.email!;
    try {
      String apiUrl = "${SettingsAPI.apiUrl}/api/add-likes";
      Map<String, dynamic> requestBody = {
        'user_email': email,
        'articleId': articleId,
      };

      // Send the POST request
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      // Check the response status code
      if (response.statusCode == 200) {
        print('Liked added successfully.');
      } else if (response.statusCode == 404) {
        print('Article not found.');
      } else if (response.statusCode == 409) {
        print('You have already liked this article.');
      } else {
        print('Error adding article. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error adding article to favorites: $error');
    }

    checkLike().then((item) {
      setState(() {
        likesList = item;
      });
    });


    Future<bool> isLiked(int articleid) async {
      String email = FirebaseAuth.instance.currentUser!.email!;
      String apiUrl = "${SettingsAPI.apiUrl}/api/likes/$email";
      try {
        var response = await http.get(Uri.parse(apiUrl));
        final jsonResponse = jsonDecode(response.body);

        if (kDebugMode) {
          print('json response from likes: $jsonResponse.toString()');
        }

        for (var likesData in jsonResponse) {
          int idlikes = likesData["idlikes"] ?? -1;
          String user_email = likesData["user_email"] ?? -1;
          int article_id = likesData["article_id"] ?? -1;

          Likes like = Likes(idlikes, user_email, article_id);
          if (like.article_id == articleid && like.user_email == user_email) {
            print("Is Liked: True");
            return true;
          }
        }
      } catch (error) {
        if (kDebugMode) {
          print(error);
        }
      }

      print("Is liked: false");
      return false;
    }
  }





}
