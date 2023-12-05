class Articles{

  late int _idarticles;
  late String _heading;
  late int _division_id;
  late int _department_id;
  late String _details;
  late String _author;
  late int _category_id;
  late String _date;
  late int _likes;
  late String _image;
  late String profile_pic;

  Articles(
      this._idarticles,
      this._heading,
      this._division_id,
      this._department_id,
      this._details,
      this._author,
      this._category_id,
      this._date,
      this._likes,
      this._image,this.profile_pic);

  String get image => _image;

  set image(String value) {
    _image = value;
  }

  int get likes => _likes;

  set likes(int value) {
    _likes = value;
  }


  String get date => _date;

  set date(String value) {
    _date = value;
  }

  int get category_id => _category_id;

  set category_id(int value) {
    _category_id = value;
  }


  String get author => _author;

  set author(String value) {
    _author = value;
  }

  String get details => _details;

  set details(String value) {
    _details = value;
  }

  int get department_id => _department_id;

  set department_id(int value) {
    _department_id = value;
  }

  int get division_id => _division_id;

  set division_id(int value) {
    _division_id = value;
  }

  String get heading => _heading;

  set heading(String value) {
    _heading = value;
  }

  int get idarticles => _idarticles;

  set idarticles(int value) {
    _idarticles = value;
  }
}