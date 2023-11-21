class Participants{

late String _userName;
late String _profilePicture;
late String _designation;
late String _groupName;
late String _userSurname;

Participants(
      this._userName, this._profilePicture, this._designation, this._groupName,this._userSurname);

String get groupName => _groupName;

  set groupName(String value) {
    _groupName = value;
  }


String get userSurname => _userSurname;

  set userSurname(String value) {
    _userSurname = value;
  }

  String get designation => _designation;

  set designation(String value) {
    _designation = value;
  }

  String get profilePicture => _profilePicture;

  set profilePicture(String value) {
    _profilePicture = value;
  }

  String get userName => _userName;

  set userName(String value) {
    _userName = value;
  }
}

