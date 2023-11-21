class Contacts {

  late String _name ;
  late String _number;
  late String _email;

  Contacts(this._name, this._number, this._email);

  String get email => _email;

  set email(String value) {
    _email = value;
  }

  String get number => _number;

  set number(String value) {
    _number = value;
  }

  String get name => _name;

  set name(String value) {
    _name = value;
  }
}