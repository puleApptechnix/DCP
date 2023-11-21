class Departments{

  late int _Department_ID;
  late String _Name;
  late int _Division_Division_ID;
  late String _Location;
  late int _iduser_departments;
  late String _user_email;

  Departments(this._Department_ID, this._Name, this._Division_Division_ID,
      this._Location, this._iduser_departments, this._user_email);

  String get user_email => _user_email;

  set user_email(String value) {
    _user_email = value;
  }

  int get iduser_departments => _iduser_departments;

  set iduser_departments(int value) {
    _iduser_departments = value;
  }

  String get Location => _Location;

  set Location(String value) {
    _Location = value;
  }

  int get Division_Division_ID => _Division_Division_ID;

  set Division_Division_ID(int value) {
    _Division_Division_ID = value;
  }

  String get Name => _Name;

  set Name(String value) {
    _Name = value;
  }

  int get Department_ID => _Department_ID;

  set Department_ID(int value) {
    _Department_ID = value;
  }
}