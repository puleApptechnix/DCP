import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dtsa/full_article.dart';
import 'package:dtsa/posts_categores.dart';
import 'package:dtsa/widgets/bottomNavigationBar.dart';
import 'package:dtsa/widgets/sideebar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'favourites.dart';
import 'hexcolor.dart';
import 'login.dart';
import 'message.dart';
import 'package:intl/intl.dart';
import 'package:dtsa/utils/settings.dart';
import 'package:http/http.dart' as http;

import 'models/articles.dart';
import 'models/users.dart';

class HomePage extends StatefulWidget {
  String email;
  HomePage({required this.email});

  @override
  State<HomePage> createState() => _HomePageState(email: email);
}

class _HomePageState extends State<HomePage> {
  final Color _red = HexColor("#FC0101");
  String email;
  List<Articles> articlesList = [];
  List<int> favouritesList = [];
  List<Articles> latestArticle = [];
  List<String> userGroups = []; // List to store user groups
  _HomePageState({required this.email});
  String group = 'General'; // moved the group variable to the class level
  String activeGroup = "General";
  String apiUrl = SettingsAPI.apiUrl;
  late bool favourite= false;
  late bool  topFavoutire = false;


 late String name  = '';
  @override
  void initState() {
    super.initState();


    initApp();

  }


// Usage example



  Future<List<Articles>> getArticles() async {
    String email = FirebaseAuth.instance.currentUser!.email!;
    String apiUrl = "${SettingsAPI.apiUrl}/api/division-articles/$email";
    try {
      var response = await http.get(Uri.parse(apiUrl));
      final jsonResponse = jsonDecode(response.body);

      if (kDebugMode) {
        print('json response: $jsonResponse');
      }

      List<Articles> articlesList = [];

      for (var articlesData in jsonResponse) {
        int? idarticles = articlesData["idarticles"];
        String? heading = articlesData["heading"];
        int? division_id = articlesData["division_id"];
        int? department_id = articlesData["Department_ID"];
        String? details = articlesData["details"];
        String? author = articlesData["author"];
        int? categoryId = articlesData["category_id"];
        String? date = articlesData["date"];
        int? aurthorId = articlesData["aurthor_id"];
        String? image = articlesData["image"];
        String? profile_pic = articlesData["profile_pic"];

        Articles article = Articles(
          idarticles ?? 0,
          heading ?? "null",
          division_id ?? 0,
          department_id ?? 0,
          details ?? "null",
          author ?? "",
          categoryId ?? 0,
          date ?? "null",
          aurthorId ?? 0,
          image ?? "",
          profile_pic ?? ""


        );



        print('current department: $group');
        Future<String>? retrievedName = await getDepartmentNameById(article.department_id);
        print('Department from db:${retrievedName.toString()}');



          articlesList.add(article);
          if (kDebugMode) {
            print('Added article id: ${article.idarticles}');

        }
      }

      return articlesList;
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
      return [];
    }
  }


  Users? user; // Make user nullable




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
        String name = userData['Name'] ?? '';
        String surname = userData['Surname'] ?? '';
        String designation = userData['Designation'] ?? '';
        String location = userData['Location'] ?? '';
        String email = userData['Email'] ?? '';
        String contactNumber = userData['Contact_Number'] ?? '';
        int userType = userData['User_Type'] ?? '';
        int departmentId = userData['Department_Department_ID'] ?? 0;
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

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      drawer: const SideBar(),

      body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.2,
                width: MediaQuery.of(context).size.width,
                child: Image.asset(
                  "images/Group52.png",
                  width: double.infinity,
                ),
              ),

              TextButton(
                onPressed: () {

                },
                style: TextButton.styleFrom(
                  backgroundColor: _red,
                  foregroundColor: Colors.white,
                ),
                child: Text('General Articles'),
              ),

              SizedBox(height: MediaQuery.of(context).size.height * 0.001),
              ListView.builder(

                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: articlesList.length,
                reverse:true ,


                itemBuilder: (context, index) {
               //   var articleData = article[index];
                //  var articleId = articleData['articleId'];
                //  Timestamp t = articleData['date'];
                 // DateTime d = t.toDate();
                  //String formattedDate = DateFormat('dd MMMM yyyy').format(d);
                  Articles article = articlesList[index];
                  bool fav = isEqual(favouritesList,article.idarticles);
                 // bool fav = true;
                  return GestureDetector(
                    onTap: () {
                      // Navigate to the desired page and pass the variables as arguments
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Article(
                            articleData: article,
                            group:activeGroup
                          ),
                        ),
                      );
                    },
                    child: Container(
                      // List item content

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
                                offset: Offset(0, 3), // changes position of shadow
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                article.heading ?? '',
                                style: TextStyle(fontSize: 18),
                              ),
                              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: MediaQuery.of(context).size.height * 0.2,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        image: DecorationImage(
                                          image: NetworkImage('${SettingsAPI.apiUrl}/uploads/profiles/${article.image}'),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      child: Align(
                                        alignment: Alignment.topRight,
                                        child: IconButton(
                                          onPressed: () async {
                                           // int userId = await getUserId();
                                            bool truth = await isFavourite(article.idarticles);

                                            if (!truth) {
                                              addFavourites(article.idarticles);
                                            } else {
                                              if (kDebugMode) {
                                                deleteFavourites(article.idarticles);

                                                print("This is already in favourites");
                                              }
                                            }
                                          },
                                          icon: Icon(
                                            Icons.favorite,

                                            color: fav ? Colors.red : Colors.grey,
                                          ),
                                        ),


                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    article.author,
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  Text(
                                    article.date.substring(0,10),
                                    //  d.toString(),
                                    //  "${d.day}:${d.month}:${d.year}",
                                    style: TextStyle(color: Colors.grey),
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
        bottomNavigationBar: const BottomNavWidget(),
    );



  }



//Future<bool>
void checkLikes(int user_id,int articleId ) async {

  String apiUrl = "${SettingsAPI.apiUrl}/api/check-likes/$user_id/article/$articleId";

  try {
    var response = await http.get(Uri.parse(apiUrl));
    final jsonResponse = jsonDecode(response.body);

    print(jsonResponse);



  } catch (error) {
    if (kDebugMode) {
      print(error);
    }
   // return null; // Return null if an error occurs
  }

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

      List<Articles> articlesList = []; // Create a new list to store the contacts
      for (var articlesData in jsonResponse) {


        int idarticles =articlesData["idarticles"] ;
        String heading=articlesData["heading"] ?? "empty";
        int division_id=articlesData["division_id"];
        int department_id=articlesData["department_id"];
        String details=articlesData["details"] ?? "empty";
        String author=articlesData["author"]  ?? "empty";
        int category_id=articlesData["category_id"];
        String date=articlesData["date"]  ?? "empty";
        int likes=articlesData["aurthor_id"];
        String image=articlesData["image"]  ?? "empty";
        String profile_pic = articlesData["profile_pic"]  ?? "empty";

        Articles article = Articles(idarticles,heading,division_id,department_id,
            details,author,category_id,date, likes,image,profile_pic);


        if((article.idarticles == articleid)) {
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
    return false ;
  }

  Future<void> deleteFavourites( int articleId) async {
   print("favourites function");
   print("email: $email");
   print("article id :$articleId");
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


  Future<List<int>> checkFavourite() async {

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


  Future<void> checkFavouriteTop(int userid,int articleid) async {


    String apiUrl = "${SettingsAPI.apiUrl}/api/favorites/$userid";
    try {
      var response = await http.get(Uri.parse(apiUrl));
      final jsonResponse = jsonDecode(response.body);

      if (kDebugMode) {
        print('json response: $jsonResponse.toString()');
      }

      List<Articles> articlesList = []; // Create a new list to store the contacts
      for (var articlesData in jsonResponse) {


        int idarticles =articlesData["idarticles"] ;
        String heading=articlesData["heading"] ;
        int division_id=articlesData["division_id"];
        int department_id=articlesData["department_id"];
        String details=articlesData["details"];
        String author=articlesData["author"];
        int category_id=articlesData["category_id"];
        String date=articlesData["date"];
        int likes=articlesData["aurthor_id"];
        String image=articlesData["image"];
        String profile_pic = articlesData["profile_pic"];

        Articles article = Articles(idarticles,heading,division_id,department_id,
            details,author,category_id,date, likes,image,profile_pic);


        if((article.idarticles == articleid)) {
          print("Is favourite: True");
          setState(() {
            topFavoutire= true;
          });

        }

      }


    } catch (error) {
      if (kDebugMode) {
        print(error);
      }

    }
    print("Is favourite: false");

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




  Future<int?> getArticleLikesById(int id) async {
    String apiUrl = "${SettingsAPI.apiUrl}/api/count-likes/$id";

    try {
      var response = await http.get(Uri.parse(apiUrl));
      final jsonResponse = jsonDecode(response.body);

      if (kDebugMode) {
        print('json response: $jsonResponse.toString()');
      }

      for (var articlesData in jsonResponse) {
        int articleLikes = articlesData['count'];

        if (kDebugMode) {
          print('article likes: $articleLikes');
        }

        return articleLikes;
      }

      return null;
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
      return null;
    }
  }

bool isEqual(List<int> favorites,int article){

if(favorites.contains(article)){
  return true;
}else{
  return false;
}


}



  Future<List<Articles>> getLatestArticle(String name) async {

    String apiUrl = "${SettingsAPI.apiUrl}/api/department-latest/$name";
    try {
      var response = await http.get(Uri.parse(apiUrl));
      final jsonResponse = jsonDecode(response.body);

      if (kDebugMode) {
        print('json response for latest article: $jsonResponse.toString()');
      }

      List<Articles> articlesList = []; // Create a new list to store the contacts

      for (var articlesData in jsonResponse) {

        int idarticles =articlesData["idarticles"] ;
        String heading=articlesData["heading"] ;
        int division_id=articlesData["division_id"];
        int department_id=articlesData["department_id"];
        String details=articlesData["details"];
        String author=articlesData["author"];
        int category_id=articlesData["category_id"];
        String date=articlesData["date"];
        int likes=articlesData["aurthor_id"];
        String image=articlesData["image"];
        String profile_pic =articlesData["profile_pic"];


        Articles article = Articles(idarticles,heading,division_id,department_id,
            details,author,category_id,date, likes,image,profile_pic);



        articlesList.add(article);

        if (kDebugMode) {
          print('Latest article id : ${article.idarticles}');
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

void initApp(){
  checkFavourite().then((item) {
    setState(() {
      favouritesList = item;
    });
  });
  //   addFavourites(1,45);


  getArticles().then((articles) {
    setState(() {
      articlesList = articles;
    });
  });

}





}
