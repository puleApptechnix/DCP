class Likes{

  late int _idlikes;
  late String _user_email;
  late int _article_id;

  Likes(this._idlikes, this._user_email, this._article_id);

  int get article_id => _article_id;

  set article_id(int value) {
    _article_id = value;
  }


  String get user_email => _user_email;

  set user_email(String value) {
    _user_email = value;
  }

  int get idlikes => _idlikes;

  set idlikes(int value) {
    _idlikes = value;
  }
}