class OTP{

  late int _idotp;
  late String _user_email;
  late String _code;

  OTP(this._idotp, this._user_email, this._code);

  String get code => _code;

  set code(String value) {
    _code = value;
  }

  String get user_email => _user_email;

  set user_email(String value) {
    _user_email = value;
  }

  int get idotp => _idotp;

  set idotp(int value) {
    _idotp = value;
  }
}