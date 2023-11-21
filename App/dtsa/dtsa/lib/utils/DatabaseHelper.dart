import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';


class DatabaseHelper {

  static final DatabaseHelper _instance = DatabaseHelper.internal();

  factory DatabaseHelper() => _instance;

  static Database? _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db!;
    }
    _db = await initDb();
    return _db!;
  }

  DatabaseHelper.internal();

  Future<Database> initDb() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'dtsa.db');

    return await openDatabase(path, version: 1, onCreate: (Database db, int version) async {
      // Create your tables here

      //articles table
      await db.execute('CREATE TABLE articles (idarticles INTEGER PRIMARY KEY, heading TEXT, division_id INTEGER,department_id INTEGER'
          'details TEXT, author TEXT,category_id INTEGER,date TEXT,likes INTEGER,image BLOB)');

      //contacts table
      await db.execute('CREATE TABLE contacts(idcontacts INTEGER PRIMARY KEY,name TEXT,number TEXT,email TEXT)');

      //department table
      await db.execute('Create TABLE department(Department_ID INTEGER PRIMARY KEY,Name TEXT,Division_Division_ID INTEGER,Location TEXT)');

      //department category table
      await db.execute('CREATE TABLE department_category(Department_Category_ID INT PRIMARY KEY,Name TEXT, Division_ID INT,Department_ID INT)');

      //divisions table
      await db.execute('CREATE TABLE division(Division_ID INT PRIMARY KEY,Name TEXT)');

      //favourites table
      await db.execute('CREATE TABLE favourites(idfavourites INT PRIMARY KEY,user_email TEXT,article_id INT)');

      //groups_table table
      await db.execute('CREATE TABLE groups_table(idgroup INT PRIMARY KEY,Name TEXT,Description TEXT,Department_ID INT,Group_Icon BLOB)');

      //likes table
      await db.execute('CREATE TABLE likes(idlikes INT PRIMARY KEY,user_email TEXT,article_id INT)');

      //locations table
      await db.execute('CREATE TABLE locations(idlocations INT PRIMARY KEY,address TEXT,Division_ID INT)');

      //policy table
      await db.execute('CREATE TABLE privacy_policy(idprivacy_policy INT PRIMARY KEY,policy TEXT)');

      //terms_conditions tabe
      await db.execute('CREATE TABLE terms_conditions(idterms_conditions INT PRIMARY KEY,terms TEXT)');

      //user_departments table
      await db.execute('CREATE TABLE user_departments(iduser_departments INT PRIMARY KEY,Department_ID INT,user_email TEXT)');

      //user_divisions table
      await db.execute('CREATE TABLE user_divisions(iduser_divisions INT PRIMARY KEY,User_Email TEXT,Division_ID INT)');

      //user_types table
      await db.execute('CREATE TABLE user_types(iduser_types INT PRIMARY KEY,Type TEXT)');

      //users table
      await db.execute('CREATE TABLE users(User_ID INT PRIMARY KEY,Name TEXT,Surname TEXT,Designation TEXT,Location TEXT'
          'Email TEXT,Contact_Number TEXT,System_Password TEXT,Profile_Picture BLOB,Is_Active INT,Type INT,Division INT)');

    });
  }

  //retrieve articles from db
  Future<List<Map<String, dynamic>>> getArticles() async {
    Database dbClient = await db;
    return await dbClient.query('articles');
  }

  ///insert or update articles
  Future<int> insertOrUpdateArticle(Map<String, dynamic> article) async {
    Database dbClient = await db;
    int id = article['idarticles'];
    List<Map<String, dynamic>> existing = await dbClient.query('articles', where: 'idarticles = ?', whereArgs: [id]);

    if (existing.isEmpty) {
      return await dbClient.insert('articles', article);
    } else {
      return await dbClient.update('articles', article, where: 'idarticles = ?', whereArgs: [id]);
    }
  }

  //retrieve contacts from db
  Future<List<Map<String, dynamic>>> getContacts() async {
    Database dbClient = await db;
    return await dbClient.query('contacts');
  }

  ///insert or update contacts
  Future<int> insertOrUpdateContacts(Map<String, dynamic> contact) async {
    Database dbClient = await db;
    int id = contact['idcontacts'];
    List<Map<String, dynamic>> existing = await dbClient.query('articles', where: 'idcontacts = ?', whereArgs: [id]);

    if (existing.isEmpty) {
      return await dbClient.insert('contacts', contact);
    } else {
      return await dbClient.update('contacts', contact, where: 'idcontacts = ?', whereArgs: [id]);
    }
  }

  //retrieve departments from db
  Future<List<Map<String, dynamic>>> getDepartments() async {
    Database dbClient = await db;
    return await dbClient.query('department');
  }


  //insert or update departments
  Future<int> insertOrUpdateDepartments(Map<String, dynamic> department) async {
    Database dbClient = await db;
    int id = department['Department_ID'];
    List<Map<String, dynamic>> existing = await dbClient.query('department', where: 'Department_ID = ?', whereArgs: [id]);

    if (existing.isEmpty) {
      return await dbClient.insert('department', department);
    } else {
      return await dbClient.update('department', department, where: 'Department_ID = ?', whereArgs: [id]);
    }
  }


  //retrieve departments categories from db
  Future<List<Map<String, dynamic>>> getDepartmentCategories() async {
    Database dbClient = await db;
    return await dbClient.query('department_category');
  }


  //insert or update departments categories
  Future<int> insertOrUpdateDepartmentCategories(Map<String, dynamic> departmentCat) async {
    Database dbClient = await db;
    int id = departmentCat['Department_Category_ID'];
    List<Map<String, dynamic>> existing = await dbClient.query('department', where: 'Department_Category_ID = ?', whereArgs: [id]);

    if (existing.isEmpty) {
      return await dbClient.insert('department_category', departmentCat);
    } else {
      return await dbClient.update('department_category', departmentCat, where: 'Department_Category_ID = ?', whereArgs: [id]);
    }
  }


  //retrieve division from db
  Future<List<Map<String, dynamic>>> getDivisions() async {
    Database dbClient = await db;
    return await dbClient.query('division');
  }


  //insert or update departments categories
  Future<int> insertOrUpdateDivisions(Map<String, dynamic> division) async {
    Database dbClient = await db;
    int id = division['Division_ID'];
    List<Map<String, dynamic>> existing = await dbClient.query('division', where: 'Division_ID = ?', whereArgs: [id]);

    if (existing.isEmpty) {
      return await dbClient.insert('division', division);
    } else {
      return await dbClient.update('division', division, where: 'Division_ID = ?', whereArgs: [id]);
    }
  }



  //retrieve favourites from db
  Future<List<Map<String, dynamic>>> getFavourites() async {
    Database dbClient = await db;
    return await dbClient.query('favourites');
  }


  //insert or update departments favourites
  Future<int> insertOrUpdateFavourites(Map<String, dynamic> favourites) async {
    Database dbClient = await db;
    int id = favourites['idfavourites'];
    List<Map<String, dynamic>> existing = await dbClient.query('favourites', where: 'idfavourites = ?', whereArgs: [id]);

    if (existing.isEmpty) {
      return await dbClient.insert('favourites', favourites);
    } else {
      return await dbClient.update('favourites', favourites, where: 'idfavourites = ?', whereArgs: [id]);
    }
  }

  //retrieve groups_table from db
  Future<List<Map<String, dynamic>>> getGroups() async {
    Database dbClient = await db;
    return await dbClient.query('groups_table');
  }


  //insert or update departments favourites
  Future<int> insertOrUpdateGroups(Map<String, dynamic> groups_table) async {
    Database dbClient = await db;
    int id = groups_table['idgroup'];
    List<Map<String, dynamic>> existing = await dbClient.query('groups_table', where: 'idgroup = ?', whereArgs: [id]);

    if (existing.isEmpty) {
      return await dbClient.insert('groups_table', groups_table);
    } else {
      return await dbClient.update('groups_table', groups_table, where: 'idgroup = ?', whereArgs: [id]);
    }
  }

  //retrieve likes from db
  Future<List<Map<String, dynamic>>> getLikes() async {
    Database dbClient = await db;
    return await dbClient.query('likes');
  }


  //insert or update likes
  Future<int> insertOrUpdateLikes(Map<String, dynamic> likes) async {
    Database dbClient = await db;
    int id = likes['idlikes'];
    List<Map<String, dynamic>> existing = await dbClient.query('likes', where: 'idlikes = ?', whereArgs: [id]);

    if (existing.isEmpty) {
      return await dbClient.insert('likes', likes);
    } else {
      return await dbClient.update('likes', likes, where: 'idlikes = ?', whereArgs: [id]);
    }
  }

  //retrieve locations from db
  Future<List<Map<String, dynamic>>> getLocations() async {
    Database dbClient = await db;
    return await dbClient.query('locations');
  }


  //insert or update locations
  Future<int> insertOrUpdateLocations(Map<String, dynamic> locations) async {
    Database dbClient = await db;
    int id = locations['idlocations'];
    List<Map<String, dynamic>> existing = await dbClient.query('locations', where: 'idlocations = ?', whereArgs: [id]);

    if (existing.isEmpty) {
      return await dbClient.insert('locations', locations);
    } else {
      return await dbClient.update('locations', locations, where: 'idlocations = ?', whereArgs: [id]);
    }
  }

  //retrieve privacy_policy from db
  Future<List<Map<String, dynamic>>> getPrivacyPolicy() async {
    Database dbClient = await db;
    return await dbClient.query('privacy_policy');
  }


  //insert or privacy_policy
  Future<int> insertOrUpdatePrivacyPolicy(Map<String, dynamic> privacy_policy) async {
    Database dbClient = await db;
    int id = privacy_policy['idprivacy_policy'];
    List<Map<String, dynamic>> existing = await dbClient.query('privacy_policy', where: 'idprivacy_policy = ?', whereArgs: [id]);

    if (existing.isEmpty) {
      return await dbClient.insert('privacy_policy', privacy_policy);
    } else {
      return await dbClient.update('privacy_policy', privacy_policy, where: 'idprivacy_policy = ?', whereArgs: [id]);
    }
  }

  //retrieve terms_conditions from db
  Future<List<Map<String, dynamic>>> getTermsConditions() async {
    Database dbClient = await db;
    return await dbClient.query('terms_conditions');
  }


  //insert or terms_conditions
  Future<int> insertOrUpdateTermsConditions(Map<String, dynamic> termsConditions) async {
    Database dbClient = await db;
    int id = termsConditions['idterms_conditions'];
    List<Map<String, dynamic>> existing = await dbClient.query('terms_conditions', where: 'idterms_conditions = ?', whereArgs: [id]);

    if (existing.isEmpty) {
      return await dbClient.insert('terms_conditions', termsConditions);
    } else {
      return await dbClient.update('terms_conditions', termsConditions, where: 'idterms_conditions = ?', whereArgs: [id]);
    }
  }

  //retrieve user_departments from db
  Future<List<Map<String, dynamic>>> getUserDepartments() async {
    Database dbClient = await db;
    return await dbClient.query('user_departments');
  }


  //insert or user_departments
  Future<int> insertOrUpdateUserDepartments(Map<String, dynamic> userDepartments) async {
    Database dbClient = await db;
    int id = userDepartments['iduser_departments'];
    List<Map<String, dynamic>> existing = await dbClient.query('user_departments', where: 'iduser_departments = ?', whereArgs: [id]);

    if (existing.isEmpty) {
      return await dbClient.insert('user_departments', userDepartments);
    } else {
      return await dbClient.update('user_departments', userDepartments, where: 'iduser_departments = ?', whereArgs: [id]);
    }
  }

  //retrieve user_divisions from db
  Future<List<Map<String, dynamic>>> getUserDivisions() async {
    Database dbClient = await db;
    return await dbClient.query('user_divisions');
  }


  //insert or user_departments
  Future<int> insertOrUpdateUserDivisions(Map<String, dynamic> userDivisions) async {
    Database dbClient = await db;
    int id = userDivisions['iduser_divisions'];
    List<Map<String, dynamic>> existing = await dbClient.query('user_divisions', where: 'iduser_divisions = ?', whereArgs: [id]);

    if (existing.isEmpty) {
      return await dbClient.insert('user_divisions', userDivisions);
    } else {
      return await dbClient.update('user_divisions', userDivisions, where: 'iduser_divisions = ?', whereArgs: [id]);
    }
  }

//retrieve user_types from db
  Future<List<Map<String, dynamic>>> getUserTypes() async {
    Database dbClient = await db;
    return await dbClient.query('user_types');
  }


  //insert or user_types
  Future<int> insertOrUpdateUserTypes(Map<String, dynamic> userTypes) async {
    Database dbClient = await db;
    int id = userTypes['iduser_types'];
    List<Map<String, dynamic>> existing = await dbClient.query('user_types', where: 'iduser_types = ?', whereArgs: [id]);

    if (existing.isEmpty) {
      return await dbClient.insert('user_types', userTypes);
    } else {
      return await dbClient.update('user_types', userTypes, where: 'iduser_types = ?', whereArgs: [id]);
    }
  }

  //retrieve user from db
  Future<List<Map<String, dynamic>>> getUser() async {
    Database dbClient = await db;
    return await dbClient.query('user');
  }


  //insert or user
  Future<int> insertOrUpdateUser(Map<String, dynamic> user) async {
    Database dbClient = await db;
    int id = user['User_ID'];
    List<Map<String, dynamic>> existing = await dbClient.query('user', where: 'User_ID = ?', whereArgs: [id]);

    if (existing.isEmpty) {
      return await dbClient.insert('user', user);
    } else {
      return await dbClient.update('user', user, where: 'User_ID = ?', whereArgs: [id]);
    }
  }



}