class Logo{
  late String _picture;
  late int _id;

  Logo(this._picture, this._id);

  int get id => _id;

  set id(int value) {
    _id = value;
  }

  String get picture => _picture;

  set picture(String value) {
    _picture = value;
  }


}