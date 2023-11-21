import 'dart:core';

class Users {
  late String _name;
  late String _surname;
  late String _designation;
  late String _location;
  late String _email;
  late String _contact_Number;
  late int _user_Type;
  late int _department_ID;
  late String _profile_Picture;
 // late String _is_Active;
  late int  _user_ID;

  Users(
      this._name,
      this._surname,
      this._designation,
      this._location,
      this._email,
      this._contact_Number,
      this._user_Type,
      this._department_ID,
      this._profile_Picture,
     // this._is_Active,
      this._user_ID
      );


  int get user_ID => _user_ID;

  set user_ID(int value) {
    _user_ID = value;
  }


  String get profile_Picture => _profile_Picture;

  set profile_Picture(String value) {
    _profile_Picture = value;
  }

  int get department_ID => _department_ID;

  set department_ID(int value) {
    _department_ID = value;
  }


  int get user_Type => _user_Type;

  set user_Type(int value) {
    _user_Type = value;
  }

  String get contact_Number => _contact_Number;

  set contact_Number(String value) {
    _contact_Number = value;
  }

  String get email => _email;

  set email(String value) {
    _email = value;
  }

  String get location => _location;

  set location(String value) {
    _location = value;
  }

  String get designation => _designation;

  set designation(String value) {
    _designation = value;
  }

  String get surname => _surname;

  set surname(String value) {
    _surname = value;
  }

  String get name => _name;

  set name(String value) {
    _name = value;
  }
}
