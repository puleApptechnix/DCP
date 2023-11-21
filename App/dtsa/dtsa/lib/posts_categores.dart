import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dtsa/models/departments.dart';
import 'package:dtsa/utils/settings.dart';
import 'package:dtsa/widgets/bottomNavigationBar.dart';
import 'package:dtsa/widgets/sideebar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'chat-page.dart';
import 'full_article.dart';
import 'hexcolor.dart';
import 'models/articles.dart';
import 'models/categories.dart';
import 'models/likes.dart';
import 'models/users.dart';

class Posts extends StatefulWidget {
  //const Posts({Key? key}) : super(key: key);

  String email;

  Posts({required this.email});
  @override
  State<Posts> createState() => _PostsState(email: email);
}

class _PostsState extends State<Posts> {
  final Color _red = HexColor("#FC0101");
  String email;
  String userGroup = '';
  List<String> userGroups = []; // List to store user groups
  _PostsState({required this.email});

  String category = "Sales";
  late int ActiveCategory; //4
  late int ActiveDepartment; //2
  List<Articles> articlesList = [];
  List<Articles> topArticlesList = [];

  List<Categories> categoryList = [];
  List<Departments> departmentList = [];
  int user_ID = -1;
  List<int> favouritesList = [];
  List<int> likesList = [];
  // Track the favorite status for each article
  int testCount = 0;
  Map<String, int> unreadMessageCounts = {};

  @override
  void initState() {
    super.initState();

    countUnreadMessages("Sales ").then((value) {
      setState(() {
        testCount = value;
      });
      print("total final : $testCount");
    });

   //getDepartmentNameById(15);
 //   fetchDepartments("test@gmail.com");
   getDeparment(email);
   getDeparments(email);

    checkFavourite().then((item) {
      setState(() {
        favouritesList = item;
      });
    });

    checkLike().then((item) {
      setState(() {
        likesList = item;
      });
    });

    // Call your dependent functions here

    //isLiked(69,13);
    getUserId().then((id) {
      setState(() {
        user_ID = id;
      });
    });
    getUser();
  }

  @override
  Widget build(BuildContext context) {
    print("posts email from login: $email");
    return Scaffold(
      drawer: const SideBar(),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height *
                  0.13, // adjust the value as needed
              width: double.infinity,
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

                  for (var group in departmentList) {
                    countUnreadMessages(group.Name).then((count) {
                      setState(() {
                        unreadMessageCounts[group.Name] = count;
                      });
                    });
                  }
                  // Calculate the number of unread messages for this group
                  //int unreadCount =  countUnreadMessages(group.Name) as int;
                  // int unreadCount = 6;
                  int unreadCount = unreadMessageCounts[group.Name] ??
                      0; // Get unread count from the map
                  return Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: [
                        TextButton(
                          onPressed: () async {
                            setState(() {
                              userGroup = group.Name;
                              getFirstCategory();
                            });
                          },
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateColor.resolveWith((states) {
                              if (userGroup == group.Name) {
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
                        if (unreadCount > 0)
                          Container(
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.green, // Badge background color
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '$unreadCount', // Display unread count
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height *
                      0.05, // You can adjust the height constraint as needed
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: categoryList.length,
                        itemBuilder: (context, index) {
                          final category = categoryList[index];
                          return TextButton(
                            onPressed: () {
                              // setState(() {
                              //   // Perform actions when the category is selected
                              //   // For example, update the selected category and fetch articles
                              ActiveCategory = category.department_category_id;
                              getTopArticles(ActiveDepartment, ActiveCategory)
                                  .then((articles) {
                                print("department from bottom nav: $userGroup");
                                setState(() {
                                  topArticlesList = articles;
                                });
                              });

                              getArticles(ActiveDepartment, ActiveCategory)
                                  .then((articles) {
                                setState(() {
                                  articlesList = articles;
                                });
                              });
                              //  ActiveDepartment = category.department_id;
                              //   // fetchArticlesFromFirestore(activeGroup, category);
                              // });
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.black,
                            ),
                            child: Text(category.name),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            SizedBox(
              height: MediaQuery.of(context).size.height *
                  0.33, // Adjust the value as needed
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      itemCount: topArticlesList.length,
                      itemBuilder: (context, index) {
                        Articles article = topArticlesList[index];
                        // checkFavouriteTop(1, article.idarticles);
                        bool fav = isEqual(favouritesList, article.idarticles);
                        bool liked = isEqual(likesList, article.idarticles);

                        return GestureDetector(
                          onTap: () {
                            // Navigate to the desired page and pass the variables as arguments
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Article(
                                    articleData: article, group: userGroup),
                              ),
                            );
                          },
                          child: Container(
                            height: MediaQuery.of(context).size.height *
                                0.30, // Specify the height
                            width: MediaQuery.of(context).size.width * 0.7,
                            margin: const EdgeInsets.all(4),
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.15,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.15,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          image: DecorationImage(
                                            image: NetworkImage(
                                                '${SettingsAPI.apiUrl}/uploads/profiles/${article.image}'),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        child: Align(
                                          alignment: Alignment.topRight,
                                          child: IconButton(
                                            onPressed: () async {
                                              // int userId = await getUserId();
                                              bool truth = await isFavourite(
                                                  article.idarticles);
                                              if (!truth) {
                                                addFavourites(
                                                    article.idarticles);
                                                setState(() {
                                                  fav = true;
                                                });
                                              } else {
                                                if (kDebugMode) {
                                                  deleteFavourites(
                                                      article.idarticles);
                                                  setState(() {
                                                    fav = false;
                                                  });

                                                  print(
                                                      "This is already in favourites");
                                                }
                                              }
                                            },
                                            icon: const Icon(Icons.favorite),
                                            color:
                                                fav ? Colors.red : Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.01),
                                Text(
                                  article.heading.length <= 30
                                      ? article.heading
                                      : '${article.heading.substring(0, 30)}....',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.01),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                      onPressed: () async {
                                        print(
                                            "article id: ${article.idarticles}");
                                        // int userId = await getUserId();
                                        print("user id: $user_ID");
                                        bool truth =
                                            await isLiked(article.idarticles);
                                        if (!truth) {
                                          addLikes(article.idarticles);
                                          setState(() {
                                            liked =
                                                true; // Update the liked state to true.
                                          });
                                        } else {
                                          if (kDebugMode) {
                                            print("This is already liked");
                                          }
                                        }
                                      },
                                      icon: Icon(
                                        Icons
                                            .thumb_up, // You can use the built-in thumb_up icon from the Icons class.
                                        color:
                                            liked ? Colors.blue : Colors.grey,
                                        size: 24, // Set the size of the icon.
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height *
                  0.40, // Specify the height

              child: ListView.builder(
                shrinkWrap: true,
                itemCount: articlesList.length,
                itemBuilder: (context, index) {
                  Articles article = articlesList[index];
                  //     checkFavourite(1,article.idarticles);
                  bool fav = isEqual(favouritesList, article.idarticles);
                  bool liked = isEqual(likesList, article.idarticles);
                  return GestureDetector(
                    onTap: () {
                      // Navigate to the desired page and pass the variables as arguments
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Article(
                            articleData: article,
                            group: userGroup,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.7,
                      margin: EdgeInsets.all(16),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.2,
                            child: Stack(
                              children: [
                                Image.network(
                                  '${SettingsAPI.apiUrl}/uploads/profiles/${article.image}',
                                  width: double.infinity,
                                  height:
                                      MediaQuery.of(context).size.height * 0.1,
                                  fit: BoxFit.cover,
                                ),
                                Align(
                                  alignment: Alignment.topRight,
                                  child: IconButton(
                                    onPressed: () async {
                                      // int userId = await getUserId();
                                      print("Article id ${article.idarticles}");
                                      bool truth =
                                          await isFavourite(article.idarticles);
                                      if (!truth) {
                                        addFavourites(article.idarticles);
                                        setState(() {
                                          fav = true;
                                        });
                                      } else {
                                        if (kDebugMode) {
                                          deleteFavourites(article.idarticles);
                                          print(
                                              "This is already in favourites");
                                        }
                                      }
                                    },
                                    icon: Icon(
                                      Icons.favorite,
                                      color: fav ? Colors.red : Colors.grey,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                              height: MediaQuery.of(context).size.height * 0.1),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    article.heading,
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.01),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        article.author,
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          IconButton(
                                            onPressed: () async {
                                              print(
                                                  "article id: ${article.idarticles}");
                                              // int userId = await getUserId();
                                              print("user id: $user_ID");
                                              bool truth = await isLiked(
                                                  article.idarticles);
                                              if (!truth) {
                                                addLikes(article.idarticles);
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
                                              Icons
                                                  .thumb_up, // You can use the built-in thumb_up icon from the Icons class.
                                              color: liked
                                                  ? Colors.blue
                                                  : Colors.grey,
                                              size:
                                                  24, // Set the size of the icon.
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavWidget(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Get the email of the currently authenticated user
          String email = FirebaseAuth.instance.currentUser!.email!;
          // Navigate to the ChatPage and pass the email as an argument

          if((departmentList.length !=0)){

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => chatpage(
                  email: email,
                  collection: userGroup,
                ),
              ),
            );
          }

        },
        child: Image.asset(
            'icons/Chat.png'), // Replace 'path-to-your-icon.png' with the actual path to your custom icon
      ),
    );
  }

  Future<void> addFavourites(int articleId) async {
    String email = FirebaseAuth.instance.currentUser!.email!;
    print("Article id $articleId");
    try {
      String apiUrl = "${SettingsAPI.apiUrl}/api/add-favorites";
      Map<String, dynamic> requestBody = {
        'user_email': email,
        'article_id': articleId,
      };

      // Send the POST request
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      // Check the response status code
      if (response.statusCode == 200) {
        print('Article added successfully.');
      } else if (response.statusCode == 404) {
        print('Article not found.');
      } else if (response.statusCode == 409) {
        print('You have already added this article.');
      } else {
        print('Error adding article. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error adding article to favorites: $error');
    }

    checkFavourite().then((item) {
      setState(() {
        favouritesList = item;
      });
    });
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

  Future<bool> isFavourite(int articleid) async {
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

        Articles article = Articles(idarticles, heading, division_id,
            department_id, details, author, category_id, date, likes, image);

        if ((article.idarticles == articleid)) {
          print("Is favourite: True");
          return true;
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
    }
    print("Is favourite: false");
    return false;
  }

  Future<List<int>> checkFavourite() async {
    String email = FirebaseAuth.instance.currentUser!.email!;
    String apiUrl = "${SettingsAPI.apiUrl}/api/favorites/$email";
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

        print("Is favourite id $idArticles : true");
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

  void markMessageAsRead(DocumentReference messageRef, String currentUserId) {
    messageRef.update({
      'readBy': FieldValue.arrayUnion([currentUserId])
    });
  }

  bool isEqual(List<int> favorites, int article) {
    if (favorites.contains(article)) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> getFirstCategory() async {
    String apiUrl = "${SettingsAPI.apiUrl}/api/categories";
    try {
      var response = await http.get(Uri.parse(apiUrl));
      final jsonResponse = jsonDecode(response.body);

      if (kDebugMode) {
        print('json response: $jsonResponse');
      }

      Categories?
          firstCategory; // Variable to store the first matching category

      for (var categoryData in jsonResponse) {
        int department_category_id = categoryData["Department_Category_ID"];
        String name = categoryData["Name"];
        int division_id = categoryData["Division_ID"];
        int department_id = categoryData["Department_ID"];

        Categories category = Categories(
          department_category_id,
          name,
          division_id,
          department_id,
        );

        if (kDebugMode) {
          print('category name from Category function: ${category.name}');
        }

        // Check the department clicked
        print('current department from Category function : $userGroup');
        print(
            'current user department id tested department  : ${category.department_id}');
        Future<String>? retrievedName =
            await getDepartmentNameById(category.department_id);
        print(
            'Department from db from Category function :${retrievedName.toString()} ');

        if ((retrievedName != null && await retrievedName == userGroup)) {
          setState(() {
            firstCategory = category; // Store the first matching category
          });
          setState(() {
            ActiveCategory = firstCategory!.department_category_id;
            print("ACTIVE CATEGORY ID FROM getFirstCategory: $ActiveCategory");
            ActiveDepartment = firstCategory!.department_id;
            print(
                "ACTIVE DEPARTMENT ID FROM getFirstCategory: $ActiveDepartment");

            print("User group variable: $userGroup");

            getCategories().then((categories) {
              setState(() {
                categoryList = categories;
              });
            });

            getTopArticles(ActiveDepartment, ActiveCategory).then((articles) {
              print("department from bottom nav: $userGroup");
              setState(() {
                topArticlesList = articles;
              });
            });

            getArticles(ActiveDepartment, ActiveCategory).then((articles) {
              setState(() {
                articlesList = articles;
              });
            });

            // Initialize unread message counts for each group here
            for (var group in departmentList) {
              countUnreadMessages(group.Name).then((count) {
                setState(() {
                  unreadMessageCounts[group.Name] = count;
                });
              });
            }
          });

          if (kDebugMode) {
            print('Added article id from Category function : ${category.name}');
          }
          break; // Break the loop after finding the first matching category
        }
      }

      //   return firstCategory;
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
      // return null; // Return null if an error occurs
    }
  }

  Future<List<Categories>> getCategories() async {
    String apiUrl = "${SettingsAPI.apiUrl}/api/categories";
    try {
      var response = await http.get(Uri.parse(apiUrl));
      final jsonResponse = jsonDecode(response.body);

      if (kDebugMode) {
        print('json response: $jsonResponse');
      }

      List<Categories> categoryList =
          []; // Create a new list to store the contacts

      for (var categoryData in jsonResponse) {
        int department_category_id =
            categoryData["Department_Category_ID"]; //change
        String name = categoryData["Name"];
        int division_id = categoryData["Division_ID"];
        int department_id = categoryData["Department_ID"];

        Categories category = Categories(
          department_category_id,
          name,
          division_id,
          department_id,
        );
        if (kDebugMode) {
          print('category name from Category function: ${category.name}');
        }
        // articlesList.add(article);
        //check the department clicked
        print('current department from Category function : $userGroup');
        Future<String>? retrievedName =
            await getDepartmentNameById(category.department_id);
        print(
            'Department from db from Category function :${retrievedName.toString()} ');
        //  categoryList.add(category);
        if ((retrievedName != null && await retrievedName == userGroup)) {
          categoryList.add(category);
          if (kDebugMode) {
            print('Added article id from Category function : ${category.name}');
          }
        }
      }

      return categoryList;
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
      return []; // Return an empty list if an error occurs
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
  }

  // Future<List<Departments>>
  getDeparments(String userEmail) async {
    final apiUrl = '${SettingsAPI.apiUrl}/api/user-departments/$userEmail';
    //  String apiUrl = "${SettingsAPI.apiUrl}/api/categories";
    try {
      var response = await http.get(Uri.parse(apiUrl));
      final jsonResponse = jsonDecode(response.body);

      if (kDebugMode) {
        print('json response: $jsonResponse');
      }

      List<Departments> categoryList =
          []; // Create a new list to store the contacts

      for (var categoryData in jsonResponse) {
        int departmentId = categoryData["Department_ID"]; //change
        String name = categoryData["Name"];
        int division_id = categoryData["Division_Division_ID"];
        String location = categoryData["Location"];
        int iduser_departments = categoryData["Department_ID"];
        String email = categoryData["user_email"];

        Departments departments = Departments(departmentId, name, division_id,
            location, iduser_departments, email);
        if (kDebugMode) {
          print(
              'Department  name from get departments function: ${departments.Name}');
        }
        if (departments.Name != null && (departments.Department_ID != 66 || departments.Department_ID != 67)) {
  setState(() {
    departmentList.add(departments);
  });
}






        // Initialize unread message counts for each group here
        for (var group in departmentList) {
          countUnreadMessages(group.Name).then((count) {
            setState(() {
              unreadMessageCounts[group.Name] = count;
            });
          });
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

  Future<void> getDeparment(String userEmail) async {
    final apiUrl = '${SettingsAPI.apiUrl}/api/user-departments/$userEmail';
    //  String apiUrl = "${SettingsAPI.apiUrl}/api/categories";
    try {
      var response = await http.get(Uri.parse(apiUrl));
      final jsonResponse = jsonDecode(response.body);

      if (kDebugMode) {
        print('json response: $jsonResponse');
      }

      List<Departments> categoryList =
          []; // Create a new list to store the contacts

      for (var categoryData in jsonResponse) {
        int departmentId = categoryData["Department_ID"]; //change
        String name = categoryData["Name"];
        int division_id = categoryData["Division_Division_ID"];
        String location = categoryData["Location"];
        int iduser_departments = categoryData["Department_ID"];
        String email = categoryData["user_email"];

        Departments departments = Departments(departmentId, name, division_id,
            location, iduser_departments, email);

        //departmentList.add(departments);
        if (departments.Name != null && (departments.Department_ID != 66 || departments.Department_ID != 67)) {
          setState(() {
            userGroup = departments.Name;
          });
          getFirstCategory();
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

  Future<List<Articles>> getArticles(int depId, int catId) async {
    String apiUrl =
        "${SettingsAPI.apiUrl}/api/department-cat-article/$depId/category/$catId/articles";
    try {
      var response = await http.get(Uri.parse(apiUrl));
      final jsonResponse = jsonDecode(response.body);

      if (kDebugMode) {
        print('json response: $jsonResponse');
      }

      List<Articles> articlesList =
          []; // Create a new list to store the contacts

      for (var articlesData in jsonResponse) {
        int idarticles = articlesData["idarticles"]; //change
        String heading = articlesData["heading"];
        int division_id = articlesData["division_id"];
        int department_id = articlesData["department_id"];
        String details = articlesData["details"];
        String author = articlesData["author"];
        int category_id = articlesData["category_id"];
        String date = articlesData["date"];
        int likes = articlesData["likes"];
        String image = articlesData["image"];

        Articles article = Articles(idarticles, heading, division_id,
            department_id, details, author, category_id, date, likes, image);
        if (kDebugMode) {
          print('article id: ${article.idarticles}');
        }
        // articlesList.add(article);
        //check the department clicked
        print(
            'Posts current department from get articles function: $userGroup');
        Future<String>? retrievedName =
            await getDepartmentNameById(article.department_id);
        print(
            'Posts Department from db from get articles function:${retrievedName.toString()} ');
        if ((retrievedName != null && await retrievedName == userGroup)) {
          articlesList.add(article);
          if (kDebugMode) {
            print(
                'Added article id from get articles function: ${article.idarticles}');
          }
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

  Future<List<Articles>> getTopArticles(int depId, int catId) async {
    String apiUrl =
        "${SettingsAPI.apiUrl}/api/department-top-articles/$depId/category/$catId/articles";
    try {
      var response = await http.get(Uri.parse(apiUrl));
      final jsonResponse = jsonDecode(response.body);

      if (kDebugMode) {
        print('json response: $jsonResponse');
      }

      List<Articles> articlesList =
          []; // Create a new list to store the contacts

      for (var articlesData in jsonResponse) {
        int idarticles = articlesData["idarticles"]; //change
        String heading = articlesData["heading"];
        int division_id = articlesData["division_id"];
        int department_id = articlesData["department_id"];
        String details = articlesData["details"];
        String author = articlesData["author"];
        int category_id = articlesData["category_id"];
        String date = articlesData["date"];
        int likes = articlesData["likes"];
        String image = articlesData["image"];

        Articles article = Articles(idarticles, heading, division_id,
            department_id, details, author, category_id, date, likes, image);
        if (kDebugMode) {
          print('article id: ${article.idarticles}');
        }
        // articlesList.add(article);
        //check the department clicked
        if (kDebugMode) {
          print('Posts current department from top articles : $userGroup');
        }
        Future<String>? retrievedName =
            await getDepartmentNameById(article.department_id);
        if (kDebugMode) {
          print('Posts Department from db:${retrievedName.toString()} ');
        }
        if ((await retrievedName != null && await retrievedName == userGroup)) {
          articlesList.add(article);
          if (kDebugMode) {
            print('Added article id to top articles : ${article.idarticles}');
          }
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
          print(
              'Department name from get DepartmentNamById function: $departmentName');
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

    checkFavourite().then((item) {
      setState(() {
        favouritesList = item;
      });
    });
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

  Future<void> fetchUserGroup() async {
    final String? group = await findUserGroup();
    print("useer group: $group");
    setState(() {
      userGroup = group!;
    });

    getFirstCategory();
  }

  Future<String> findUserGroup() async {
    String email = FirebaseAuth.instance.currentUser!.email!;
    final QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('Groups').get();

    for (final doc in querySnapshot.docs) {
      final List<dynamic> participants = doc.get('Participants');
      if (participants.contains(email)) {
        return doc.id;
      }
    }

    return ''; // Return null if no matching document is found
  }

  Users? user; // Make user nullable

  Future<int> getUserId() async {
    //String email = FirebaseAuth.instance.currentUser!.email!;
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
        String name = userData['user_name'] ?? '';
        String surname = userData['Surname'] ?? '';
        String designation = userData['Designation'] ?? '';
        String location = userData['user_location'] ?? '';
        String email = userData['Email'] ?? '';
        String contactNumber = userData['Contact_Number'] ?? '';
        String userType = userData['Type'] ?? '';
        int departmentId = userData['department_id'] ?? 0;
        String profilePicture = userData['Profile_Picture'] ?? '';
        if (kDebugMode) {
          print("user id  id from json: ${userData['User_ID']}");
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

  void getUser() async {
    String email = FirebaseAuth.instance.currentUser!.email!;
    String apiUrl = "${SettingsAPI.apiUrl}/api/user-email/$email";
    try {
      var response = await http.get(Uri.parse(apiUrl));
      final jsonResponse = jsonDecode(response.body);

      if (kDebugMode) {
        print('json response: $jsonResponse.toString()');
      }
      // String profilePicture = userData['Profile_Picture'] ?? ''; // Handle null value
      for (var userData in jsonResponse) {
        String name = userData['user_name'] ?? '';
        String surname = userData['Surname'] ?? '';
        String designation = userData['Designation'] ?? '';
        String location = userData['user_location'] ?? '';
        String email = userData['Email'] ?? '';
        String contactNumber = userData['Contact_Number'] ?? '';
        int userType = userData['Type'] ?? 0;
        int departmentId = userData['department_id'] ?? 0;
        String profilePicture = userData['Profile_Picture'] ?? '';
        // String is_Active = userData['Is_Active'];
        int userId = userData['User_ID'] ?? -1;
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

  Future<void> fetchUserGroups() async {
    //  final List<String> groups = await findUserGroups(email);
    final List<String> groups = await getDeparments("pulemojatau@gmail.com");
    setState(() {
      userGroups = groups;
    });
  }

  Future<int> countUnreadMessages(String collection) async {
    print(
        '--------------------------------7777777777777777777--------------------------------------------------------------------');
    print('Started counting');
    String email = FirebaseAuth.instance.currentUser!.email!;
    int count = 0;

    try {
      print(
          'outside for loop=========================================================');

      // Your existing code here
      final QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection(collection).get();

      print("query: ${querySnapshot.size}");
      print("docs: ${querySnapshot.docs}");
      int i = 0;
      for (final doc in querySnapshot.docs) {
        setState(() {
          i++;
        });
        print("counter : $i");
        print(
            '----------------------------------------------------------------------------------------------------');
        print('inside for loop');
        final List<dynamic> messages = doc.get('readBy');
        print(messages.length);
        if (!messages.contains(email)) {
          print(
              '----------------------------------------------------------------------------------------------------');
          print(email);
          print(count);
          setState(() {
            count++;
          });
        }
      }

      return count; // Return null if no matching document is found
    } catch (e) {
      print('Error in countUnreadMessages: $e');
    }
    return count;
  }
}
